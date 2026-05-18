#!/usr/bin/env bash
#
# Rao-HTML-to-PPT · 老课件审计脚本(v5.8 新增 · Mode C-enhance 标准化)
#
# 输入:任何老的 HTML PPT 文件(无论 v4 / v5.0 / v5.1 / v5.2 / 客户自己改过的版本)
# 输出:8 个 v5.x 标准模块的存在状态报告(PASS / MISSING / PARTIAL)
#
# 设计哲学:
#   - 不修改文件,只检测
#   - 每个模块独立 grep,不依赖文件结构假设
#   - 输出可直接读的 markdown 表格 + 缺失清单
#   - 检测出 MISSING → 按 references/upgrade-existing-deck.md 工作流补齐
#
# 用法:
#   bash scripts/audit-deck.sh <file.html>
#   bash scripts/audit-deck.sh <file.html> --json    # 给程序用的 JSON 输出
#
# 触发场景:
#   1. 用户上传一份老课件,说"按我的格式重做"
#   2. 自己以前做的 deck 想升到 v5.7+ 新功能
#   3. 客户给的非饶秋模板课件,想做标准化
#

set -uo pipefail

# ANSI 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

# 参数解析
JSON_MODE=0
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--json" ]]; then
    JSON_MODE=1
  else
    ARGS+=("$arg")
  fi
done
if [[ ${#ARGS[@]} -gt 0 ]]; then
  set -- "${ARGS[@]}"
else
  set --
fi

F="${1:-}"
if [[ -z "$F" ]]; then
  echo "用法:"
  echo "  bash scripts/audit-deck.sh <file.html>           # 人类可读模式"
  echo "  bash scripts/audit-deck.sh <file.html> --json    # 机器可读模式"
  exit 1
fi
if [[ ! -f "$F" ]]; then
  echo "[错误] 找不到文件: $F"
  exit 1
fi

# ======================================================================
# 8 个标准模块的检测规则
# 每个模块定义:CSS 标志 / DOM 标志 / JS 标志(任意一项缺即 PARTIAL)
# ======================================================================

# 通用 grep 计数(可计文本片段或正则)
gc() {
  local pattern="$1"
  local fixed="${2:-}"
  if [[ "$fixed" == "fixed" ]]; then
    grep -cF "$pattern" "$F" 2>/dev/null | tr -d '\n '
  else
    grep -cE "$pattern" "$F" 2>/dev/null | tr -d '\n '
  fi
}

# 各模块检测
# 返回三段:CSS_count|DOM_count|JS_count|verdict(PASS/PARTIAL/MISSING)
detect_module() {
  local name="$1"; local css_pat="$2"; local dom_pat="$3"; local js_pat="$4"
  local css_n=$(gc "$css_pat")
  local dom_n=$(gc "$dom_pat")
  local js_n=$(gc "$js_pat")
  local verdict
  if [[ $css_n -eq 0 && $dom_n -eq 0 && $js_n -eq 0 ]]; then
    verdict="MISSING"
  elif [[ $css_n -eq 0 || $dom_n -eq 0 || $js_n -eq 0 ]]; then
    verdict="PARTIAL"
  else
    verdict="PASS"
  fi
  echo "$css_n|$dom_n|$js_n|$verdict"
}

# 1. v5.1 双主题切换(Paper & Ink / Dark Botanical)
RES_THEME=$(detect_module "theme-switch" \
  'body\[data-theme="paper"\]' \
  'id="theme-toggle"' \
  "raoqiu-deck-theme")

# 2. v5.2 Inline Editing(E 键 + Ctrl+S + localStorage)
RES_EDIT=$(detect_module "inline-edit" \
  '\.edit-banner' \
  'id="edit-toggle"' \
  "raoqiu-deck-html-edit")

# 3. v5.7 Lightbox 双击放大
RES_LIGHTBOX=$(detect_module "lightbox-zoom" \
  '\.lightbox-overlay' \
  'class="lightbox-clone-wrap"|class="lightbox-overlay"' \
  "openLightbox|zoomableSelectors")

# 4. v5.7 单击复制 prompt-block
# 注意:toast 是 JS 动态 createElement 创建的,所以 DOM 检测查"创建逻辑"而非静态 class 标记
RES_COPY=$(detect_module "click-to-copy" \
  '\.copy-toast' \
  "className.*copy-toast|createElement.*['\"]div['\"]" \
  "navigator.clipboard|copyText")

# 5. v5.6.1 BFCache 防御 + Cache-Control no-cache
RES_CACHE=$(detect_module "bfcache-defense" \
  'no-cache, no-store' \
  'pageshow.*persisted' \
  "pageshow.*persisted")

# 6. v5.x 翻页核心(Slideshow class + 触屏 + 键盘)
RES_SLIDESHOW=$(detect_module "slideshow-core" \
  '\.slide{|\.slide \{' \
  'id="prev-btn"' \
  "class Slideshow|new Slideshow")

# 7. v5.x 大纲面板(M 键 + 拖拽重排)
RES_TOC=$(detect_module "toc-panel" \
  '#toc-overlay|toc-panel' \
  'id="toc-btn"' \
  "toggleTOC")

# 8. v5.x 概览模式(O 键缩略图网格)
RES_OVERVIEW=$(detect_module "overview-grid" \
  '#overview' \
  'id="overview-btn"' \
  "toggleOverview")

# ======================================================================
# Quality Gate 兼容性子项(P0 红线)
# 这些是"该有 0 但实际不为 0"的反向检测
# ======================================================================

# A. .page-footer 残留(v4 已弃用,会被翻页按钮遮挡)
PF=$(gc 'class="page-footer"')

# B. emoji 装饰(✅🎯💡🚀⭐🔥📊🎨🏆⚡)
EMOJI=0
for e in '🎯' '💡' '✅' '🚀' '⭐' '🔥' '📊' '🎨' '🏆' '⚡'; do
  c=$(grep -cF "$e" "$F" 2>/dev/null | tr -d '\n ')
  EMOJI=$((EMOJI + c))
done

# C. .page-title 用 <div> 而非 <h2>(P0 错位)
PT_DIV=$(gc '<div class="page-title')

# ======================================================================
# 统计 + 渲染
# ======================================================================

# 总 slide 数(给上下文)
SLIDE_COUNT=$(gc '<section class="slide')

# 解析 detect_module 返回值
parse_module() {
  local res="$1"
  IFS='|' read -r CSS DOM JS VERDICT <<< "$res"
  echo "$CSS $DOM $JS $VERDICT"
}

print_module_row() {
  local name="$1"; local res="$2"; local since="$3"; local desc="$4"
  read -r CSS DOM JS VERDICT <<< "$(parse_module "$res")"
  local color icon
  case "$VERDICT" in
    PASS)    color="$GREEN"; icon="✓" ;;
    PARTIAL) color="$YELLOW"; icon="!" ;;
    MISSING) color="$RED"; icon="✗" ;;
  esac
  printf "  ${color}${icon} %-22s${NC}  ${BOLD}%-8s${NC}  CSS:%-3s DOM:%-3s JS:%-3s  ${GRAY}%s${NC}\n" \
    "$name" "$VERDICT" "$CSS" "$DOM" "$JS" "$desc"
}

if [[ "$JSON_MODE" -eq 0 ]]; then
  # 人类模式
  echo ""
  echo -e "${BOLD}${BLUE}=== 老课件审计 · raoqiu audit-deck v5.8 ===${NC}"
  echo -e "${BLUE}文件: $F${NC}"
  echo -e "${BLUE}总片数: $SLIDE_COUNT${NC}"
  echo ""
  echo -e "${BOLD}--- 8 个 v5.x 标准模块检测 ---${NC}"
  echo -e "${GRAY}  (CSS / DOM / JS 三段独立 grep,任一为 0 即 PARTIAL,全为 0 即 MISSING)${NC}"
  echo ""
  print_module_row "1. 双主题切换"      "$RES_THEME"     "v5.1" "Paper & Ink / Dark Botanical · T 键切换"
  print_module_row "2. Inline Editing"  "$RES_EDIT"      "v5.2" "E 键进编辑 + Ctrl+S 保存 + localStorage"
  print_module_row "3. Lightbox 放大"   "$RES_LIGHTBOX"  "v5.7" "双击元素居中放大(饶秋 2026-05 实战验证)"
  print_module_row "4. 单击复制"        "$RES_COPY"      "v5.7" "单击 .prompt-block → 一键复制剪贴板"
  print_module_row "5. BFCache 防御"    "$RES_CACHE"     "v5.6" "no-cache meta + pageshow.persisted 强刷"
  print_module_row "6. Slideshow 引擎"  "$RES_SLIDESHOW" "v5.x" "翻页 / 键盘 / 触屏(应该都有)"
  print_module_row "7. 大纲面板"        "$RES_TOC"       "v5.x" "M 键 / 拖拽重排"
  print_module_row "8. 概览模式"        "$RES_OVERVIEW"  "v5.x" "O 键 / 缩略图网格"

  echo ""
  echo -e "${BOLD}--- Quality Gate 兼容性检测(应为 0)---${NC}"

  if [[ $PF -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} .page-footer 残留          ${BOLD}CLEAN${NC}  (0)"
  else
    echo -e "  ${RED}✗${NC} .page-footer 残留          ${BOLD}DIRTY${NC}  ($PF) ${YELLOW}→ v4 弃用,要 sed 删整行${NC}"
  fi

  if [[ $EMOJI -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} emoji 装饰                CLEAN  (0)"
  else
    echo -e "  ${RED}✗${NC} emoji 装饰                DIRTY  ($EMOJI) ${YELLOW}→ 禁用 ✅🎯💡🚀⭐🔥📊🎨🏆⚡,换文字标签${NC}"
  fi

  if [[ $PT_DIV -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} page-title 用 h2 不是 div CLEAN  (0)"
  else
    echo -e "  ${RED}✗${NC} page-title 用 div 错位     DIRTY  ($PT_DIV) ${YELLOW}→ 改 <h2 class=\"page-title\">${NC}"
  fi

  # ======================================================================
  # 总结 + 行动建议
  # ======================================================================
  MISSING_COUNT=0
  PARTIAL_COUNT=0
  PASS_COUNT=0
  for r in "$RES_THEME" "$RES_EDIT" "$RES_LIGHTBOX" "$RES_COPY" "$RES_CACHE" "$RES_SLIDESHOW" "$RES_TOC" "$RES_OVERVIEW"; do
    v=$(echo "$r" | cut -d'|' -f4)
    case "$v" in
      MISSING) MISSING_COUNT=$((MISSING_COUNT + 1)) ;;
      PARTIAL) PARTIAL_COUNT=$((PARTIAL_COUNT + 1)) ;;
      PASS)    PASS_COUNT=$((PASS_COUNT + 1)) ;;
    esac
  done

  echo ""
  echo -e "${BOLD}=== 总结 ===${NC}"
  printf "  ${GREEN}✓ PASS: %d${NC}  ${YELLOW}! PARTIAL: %d${NC}  ${RED}✗ MISSING: %d${NC}  (共 8 个标准模块)\n" \
    "$PASS_COUNT" "$PARTIAL_COUNT" "$MISSING_COUNT"

  if [[ $MISSING_COUNT -eq 0 && $PARTIAL_COUNT -eq 0 && $PF -eq 0 && $EMOJI -eq 0 && $PT_DIV -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}${BOLD}✅ 这份课件已经符合最新 v5.8 标准,无需升级。${NC}"
    echo -e "${YELLOW}建议直接跑 raoqiu-check.sh --strict 跑一遍 P0 自检${NC}"
    exit 0
  else
    echo ""
    echo -e "${YELLOW}${BOLD}⚠ 这份课件需要升级。${NC}"
    echo -e "${YELLOW}下一步:按 references/upgrade-existing-deck.md 的"补丁清单"逐项注入缺失模块${NC}"
    echo ""
    echo -e "${BOLD}建议补丁顺序(按依赖链)${NC}:"
    [[ "$(echo $RES_CACHE | cut -d'|' -f4)" != "PASS" ]] && echo "  1. BFCache 防御 + Cache-Control(head meta,改一次永久受益)"
    [[ "$(echo $RES_THEME | cut -d'|' -f4)" != "PASS" ]] && echo "  2. 双主题切换(CSS 243 行 + JS 43 行 + button 1 行)"
    [[ "$(echo $RES_EDIT | cut -d'|' -f4)" != "PASS" ]] && echo "  3. Inline Editing(CSS 已知 + JS ~210 行 + DOM 3 个块)"
    [[ "$(echo $RES_LIGHTBOX | cut -d'|' -f4)" != "PASS" ]] && echo "  4. Lightbox 放大 + 单击复制(CSS 150 行 + JS 130 行,一起做)"
    [[ $PF -gt 0 ]] && echo "  5. 删 .page-footer 残留:sed -i '' '/<div class=\"page-footer\">/d' <file>"
    [[ $EMOJI -gt 0 ]] && echo "  6. 替换 emoji:见 references/upgrade-existing-deck.md §emoji 标准替换表"
    echo ""
    echo -e "${GRAY}补完后跑:${NC}"
    echo "  bash scripts/audit-deck.sh $F"
    echo "  bash scripts/raoqiu-check.sh --strict $F"
    exit 1
  fi
else
  # JSON 模式(给程序消费)
  pj() { echo "$1" | cut -d'|' -f4; }
  cat <<EOF
{
  "file": "$F",
  "slide_count": $SLIDE_COUNT,
  "modules": {
    "theme_switch":   {"verdict": "$(pj $RES_THEME)",     "since": "v5.1"},
    "inline_editing": {"verdict": "$(pj $RES_EDIT)",      "since": "v5.2"},
    "lightbox_zoom":  {"verdict": "$(pj $RES_LIGHTBOX)",  "since": "v5.7"},
    "click_to_copy":  {"verdict": "$(pj $RES_COPY)",      "since": "v5.7"},
    "bfcache_defense":{"verdict": "$(pj $RES_CACHE)",     "since": "v5.6"},
    "slideshow_core": {"verdict": "$(pj $RES_SLIDESHOW)", "since": "v5.x"},
    "toc_panel":      {"verdict": "$(pj $RES_TOC)",       "since": "v5.x"},
    "overview_grid":  {"verdict": "$(pj $RES_OVERVIEW)",  "since": "v5.x"}
  },
  "quality_gate": {
    "page_footer_legacy": $PF,
    "emoji_decoration":   $EMOJI,
    "page_title_div_misuse": $PT_DIV
  }
}
EOF
fi
