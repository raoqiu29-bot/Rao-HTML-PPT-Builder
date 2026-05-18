#!/usr/bin/env bash
#
# Rao-HTML-to-PPT · PDF 导出脚本(v5.6 升级 · 加 Quality Gate 前置门控)
# 借鉴 zarazhangrui/frontend-slides 的 export-pdf.sh + hugohe3/ppt-master 的 Gate 思想
#
# 用法:
#   bash scripts/export-pdf.sh <input.html> [output.pdf] [--compact]
#   bash scripts/export-pdf.sh <input.html> --skip-gate          # 紧急情况绕过门控
#
# 参数:
#   input.html   - 要导出的 HTML PPT(必填)
#   output.pdf   - 输出 PDF 路径(可选,默认放在 input.html 同目录)
#   --compact    - 用 1280x720 替代 1920x1080(文件小 50-70%,适合邮件发送)
#   --skip-gate  - 跳过 raoqiu-check --strict 门控(默认会先跑一遍,FAIL 不导出)
#
# 依赖:
#   Node.js + npx + playwright(首次跑会自动装 Chromium,约 150MB,30-60s)

set -euo pipefail

# ======================================================================
# 参数解析
# ======================================================================
INPUT=""
OUTPUT=""
COMPACT="false"
SKIP_GATE="false"

for arg in "$@"; do
  case "$arg" in
    --compact)    COMPACT="true" ;;
    --skip-gate)  SKIP_GATE="true" ;;
    *.html)       INPUT="$arg" ;;
    *.pdf)        OUTPUT="$arg" ;;
    *)            echo "[警告] 未识别参数: $arg" ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "用法: bash scripts/export-pdf.sh <input.html> [output.pdf] [--compact] [--skip-gate]"
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "[错误] 找不到文件: $INPUT"
  exit 1
fi

# ======================================================================
# Quality Gate · 导出前必跑(可用 --skip-gate 跳过,但不推荐)
# ======================================================================
if [[ "$SKIP_GATE" == "false" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  CHECK_SCRIPT="${SCRIPT_DIR}/raoqiu-check.sh"
  if [[ -f "$CHECK_SCRIPT" ]]; then
    echo "[gate] 跑 P0 自检门控(--strict 模式)..."
    echo ""
    if ! bash "$CHECK_SCRIPT" --strict "$INPUT"; then
      echo ""
      echo "[gate] ⛔ Quality Gate 不通过,禁止导出 PDF。"
      echo "[gate] 修完 P0 后重跑;紧急情况可加 --skip-gate 绕过(不推荐)"
      exit 1
    fi
    echo ""
    echo "[gate] ✅ Quality Gate 通过,继续导出..."
    echo ""
  else
    echo "[gate] 警告:找不到 raoqiu-check.sh,跳过门控"
  fi
else
  echo "[gate] ⚠️  --skip-gate 已启用,跳过 P0 自检(责任自负)"
fi

# 默认输出路径:同目录,扩展名换成 .pdf
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="${INPUT%.html}.pdf"
fi

# 分辨率
if [[ "$COMPACT" == "true" ]]; then
  WIDTH=1280
  HEIGHT=720
  echo "[info] 紧凑模式 (1280x720)"
else
  WIDTH=1920
  HEIGHT=1080
  echo "[info] 标准模式 (1920x1080) · 加 --compact 启用紧凑模式"
fi

# ======================================================================
# 检查 Node + Playwright
# ======================================================================
if ! command -v node >/dev/null 2>&1; then
  echo "[错误] 需要 Node.js · 安装方法 (macOS): brew install node"
  exit 1
fi

# ======================================================================
# 生成临时 Playwright 脚本
# ======================================================================
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

cat > "$TMPDIR/export.cjs" <<'JS_END'
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const http = require('http');

async function main() {
  const [, , inputHtml, outputPdf, w, h] = process.argv;
  const width = parseInt(w, 10);
  const height = parseInt(h, 10);

  // 用 http 服务器加载 HTML,这样 Google Fonts CDN 和相对路径图片都能工作
  const inputDir = path.dirname(path.resolve(inputHtml));
  const inputName = path.basename(inputHtml);

  const server = http.createServer((req, res) => {
    let filePath = req.url === '/' ? '/' + inputName : decodeURIComponent(req.url);
    filePath = path.join(inputDir, filePath);
    if (!fs.existsSync(filePath)) { res.writeHead(404); res.end(); return; }
    const ext = path.extname(filePath).toLowerCase();
    const mime = {
      '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript',
      '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg',
      '.svg': 'image/svg+xml', '.gif': 'image/gif', '.webp': 'image/webp'
    }[ext] || 'application/octet-stream';
    res.writeHead(200, { 'Content-Type': mime });
    res.end(fs.readFileSync(filePath));
  });

  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const port = server.address().port;
  const url = `http://127.0.0.1:${port}/`;

  const browser = await chromium.launch();
  const context = await browser.newContext({ viewport: { width, height } });
  const page = await context.newPage();

  console.log(`[info] 打开 ${url}`);
  await page.goto(url, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);  // 等动画结束

  // 找所有 .slide
  const slideCount = await page.evaluate(() => document.querySelectorAll('.slide').length);
  if (slideCount === 0) {
    console.error('[错误] 没找到 .slide 元素,确认 HTML 是 Rao-HTML-to-PPT 生成的');
    await browser.close();
    server.close();
    process.exit(1);
  }
  console.log(`[info] 找到 ${slideCount} 张 slide,开始截图`);

  // 用 PDF 导出 · 每页一张
  await page.evaluate(() => {
    document.querySelectorAll('.slide').forEach((s) => {
      s.style.position = 'relative';
      s.style.display = 'flex';
      s.style.pageBreakAfter = 'always';
    });
    // 隐藏控件
    ['.ctrl-bar', '.nav-arrows', '.page-num', '#hint', '#toc-overlay', '#overview', '.progress-bar']
      .forEach((sel) => document.querySelectorAll(sel).forEach((e) => e.style.display = 'none'));
  });

  await page.pdf({
    path: outputPdf,
    width: `${width}px`,
    height: `${height}px`,
    printBackground: true,
    margin: { top: 0, right: 0, bottom: 0, left: 0 }
  });

  await browser.close();
  server.close();
  console.log(`[ok] PDF 已保存: ${outputPdf}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
JS_END

cat > "$TMPDIR/package.json" <<'PKG_END'
{
  "name": "raoqiu-pdf-export",
  "version": "1.0.0",
  "private": true,
  "dependencies": { "playwright": "^1.40.0" }
}
PKG_END

# ======================================================================
# 装 playwright(只装一次,缓存在 ~/.cache/ms-playwright)
# ======================================================================
echo "[info] 检查 Playwright(首次会装 Chromium ≈150MB,30-60s)"
cd "$TMPDIR"
npm install --silent --no-audit --no-fund playwright 2>&1 | tail -3
npx playwright install chromium --with-deps 2>&1 | tail -3

# ======================================================================
# 执行导出
# ======================================================================
node "$TMPDIR/export.cjs" "$INPUT" "$OUTPUT" "$WIDTH" "$HEIGHT"

# ======================================================================
# 自动打开(macOS)
# ======================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "[info] 自动打开 PDF"
  open "$OUTPUT" || true
fi

# 提示文件大小
SIZE=$(du -h "$OUTPUT" | awk '{print $1}')
echo ""
echo "============================================================"
echo "[完成] 导出 PDF: $OUTPUT"
echo "       文件大小: $SIZE"
if [[ "$COMPACT" == "false" ]]; then
  echo "       太大?加 --compact 参数,大约能压缩到 30-50%"
fi
echo "============================================================"
