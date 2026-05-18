# 多渠道输入 · PDF / DOCX / Excel / URL → Markdown(v5.6 新增 · 借鉴 hugohe3/ppt-master)

> **场景**:客户给的不是干净的 markdown 大纲,而是一份 PDF 招标书 / 一篇微信公众号文章 / 一个 DOCX 客户简介。**Mode B 之前只接受 markdown**,现在补上其他渠道。

---

## 设计原则:不造轮子,调成熟工具

**我们不写 source_to_md/*.py 工具集**(PPT Master 那一套有 6 个 Python 脚本,30KB 代码),原因:
- 我们是单 HTML 技能,不背 Python 项目的复杂度
- 业界已有成熟工具(marker / docling / pandoc / curl_cffi),直接调用即可
- 真正的工作量在"转完之后怎么挑出能做 PPT 的骨架",而不是转换本身

---

## 工具选型表(按输入类型查)

| 输入类型 | 推荐工具 | 安装 | 命令模板 |
|---|---|---|---|
| **PDF**(扫描件 / 论文 / 招标书) | `marker-pdf` | `pip install marker-pdf` | `marker_single <file.pdf> --output_dir /tmp/md` |
| **PDF**(纯文字 + 表格,简单场景) | `pdftotext` | macOS 自带(`brew install poppler` 备用) | `pdftotext -layout <file.pdf> -` |
| **DOCX / DOC / RTF / ODT** | `pandoc` | `brew install pandoc` | `pandoc <file.docx> -t markdown -o out.md` |
| **Excel xlsx / xlsm** | `python-pptx` 同源的 `openpyxl` + 一个 shell oneliner | `pip install openpyxl` | 见下方 §3 |
| **HTML 网页**(普通) | `pandoc` 或 `html2text` | `brew install pandoc html2text` | `pandoc <url-or-file> -t markdown -o out.md` |
| **微信公众号文章** | `curl_cffi` + `pandoc`(微信反爬要绕) | `pip install curl_cffi` + `brew install pandoc` | 见下方 §4 |
| **网页(JS 渲染重)** | Claude 本身的 WebFetch 工具 | 已内置 | 直接 `WebFetch(url, prompt)` |
| **PPTX**(从老 PPT 拆素材) | `python-pptx` | `pip install python-pptx` | 见下方 §5 |
| **Markdown** | 直接读 | — | — |
| **图片(扫描课件 / 截图)** | Claude 多模态(Read 工具直接读图) | 已内置 | 直接 `Read(image_path)` |

---

## §1. PDF 转换的两种路径

### 简单 PDF(可复制文字,无图表):pdftotext

```bash
# macOS 已自带 / 如果没有:brew install poppler
pdftotext -layout 客户招标书.pdf - | head -200
# 然后人工挑骨架贴到对话
```

### 复杂 PDF(扫描件 / 论文 / 含表格图表):marker-pdf

```bash
pip install marker-pdf
marker_single 客户招标书.pdf --output_dir /tmp/md
# 输出:/tmp/md/客户招标书/客户招标书.md(含 LaTeX 公式 + 表格)
```

**何时用哪个**:
- 输入 ≤ 20 页 + 可复制文字 → `pdftotext`(快,3 秒搞定)
- 扫描件 / 复杂排版 / 论文 → `marker-pdf`(慢,首次跑要下模型 ≈1GB)
- **饶秋常用**:客户给的 PDF 招标书 / 行业白皮书 → `marker-pdf`,有耐心等

---

## §2. DOCX / Word 转换

```bash
# pandoc 是瑞士军刀,一行搞定
brew install pandoc  # 没装的话
pandoc 客户简介.docx -t markdown -o /tmp/md/客户简介.md
```

**注意**:
- pandoc 默认会保留 Word 的格式标记(`{.smallcaps}` 之类),做 PPT 用不上,可以 `--strip-comments` + 后处理 `sed` 清理
- 图片会被剥离到 `--extract-media=/tmp/md/media` 目录(默认丢弃)
- 表格保留为 markdown 表格,符合 PPT 用法

---

## §3. Excel 转换

Excel 没有"现成转 markdown 工具",但用 Python 一行解决:

```python
# 把这段存成 /tmp/xlsx2md.py
import sys, openpyxl
wb = openpyxl.load_workbook(sys.argv[1], data_only=True)
for sheet in wb.sheetnames:
    ws = wb[sheet]
    print(f"\n## {sheet}\n")
    rows = list(ws.iter_rows(values_only=True))
    if not rows: continue
    header = [str(c or '') for c in rows[0]]
    print('| ' + ' | '.join(header) + ' |')
    print('|' + '|'.join(['---'] * len(header)) + '|')
    for row in rows[1:]:
        print('| ' + ' | '.join(str(c or '') for c in row) + ' |')
```

```bash
python3 /tmp/xlsx2md.py 2026Q1业绩.xlsx > /tmp/md/业绩.md
```

**饶秋常用场景**:莱美月度业绩 Excel → markdown 表格 → 直接做 dashboard 版式页(metric card + sparkline + donut)。

---

## §4. 微信公众号文章

微信反爬严,直接 `curl` 拿到的是空壳。两个办法:

### 办法 A · curl_cffi(假装真实浏览器)

```bash
pip install curl_cffi
python3 - <<'EOF'
from curl_cffi import requests
r = requests.get("https://mp.weixin.qq.com/s/XXXXXXX", impersonate="chrome")
print(r.text)
EOF
```

抓到 HTML 后:
```bash
pandoc -f html -t markdown /tmp/wechat.html -o /tmp/md/article.md
```

### 办法 B · 直接用 Claude 的 WebFetch

最简单,**让 Claude 直接读**:

```
WebFetch(
  url="https://mp.weixin.qq.com/s/XXXXXXX",
  prompt="把文章正文转成 markdown,保留小标题结构,去掉广告和阅读引导。"
)
```

99% 的微信文章这样就够了。只有遇到 WebFetch 拿不到的(极少),才走办法 A。

---

## §5. PPTX 转(从老 PPT 拆素材)

```python
# /tmp/pptx2md.py
import sys
from pptx import Presentation
prs = Presentation(sys.argv[1])
for i, slide in enumerate(prs.slides, 1):
    print(f"\n## Slide {i}\n")
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                text = para.text.strip()
                if text:
                    print(f"- {text}")
```

```bash
pip install python-pptx
python3 /tmp/pptx2md.py 旧课件.pptx > /tmp/md/旧课件.md
```

**用途**:饶秋手上的老 PPT 太多,有些课件想重做但忘了讲什么。**先拆出文字大纲,再用 Mode B 重新做**。

---

## Mode B 工作流(v5.6 整合后)

### Step 1 · 识别输入

用户给了什么?

| 用户给的 | 第一步 |
|---|---|
| 一段对话里的文字 / 已经是 markdown | 直接进 Step 2 |
| 一个 .md 文件 | `cat` 一下确认内容 → Step 2 |
| 一个 .pdf | `pdftotext` 简单试一下;不行就 `marker_single` |
| 一个 .docx | `pandoc` |
| 一个 .xlsx | `xlsx2md.py` |
| 一个网页 url | WebFetch(微信公众号也用这个) |
| 一个 .pptx | `pptx2md.py` |
| 一张图 / 截图 | Claude `Read` 工具直读 |

### Step 2 · 转完之后

把转出来的 markdown **粘到对话**(或让 Claude `Read` 那个文件),然后:

1. **人工挑骨架**:转换出来的内容多半啰嗦,要挑出 3-5 个核心模块 + 每个模块下的 key points
2. **走 Mode B 正常流程**:大纲 → 节奏规划 → spec_lock(如果 ≥ 20 页)→ 生成

**核心**:**转换工具只是把"看不到的内容"变成"看得到的",真正的"挑骨架"还是人 + AI 做**。不要指望转完直接生成 PPT,中间一步"挑骨架"省不掉。

---

## 安装一次装齐(可选)

如果你经常做多渠道输入,一次装齐:

```bash
# 必装(brew + pip)
brew install pandoc poppler html2text
pip install marker-pdf python-pptx openpyxl curl_cffi

# 验证
echo "pandoc: $(pandoc --version | head -1)"
echo "pdftotext: $(pdftotext -v 2>&1 | head -1)"
echo "marker: $(marker_single --help | head -1)"
```

**第一次跑 marker 会下模型 ≈1GB,30-90 秒,之后秒回。**

---

## 跟 ppt-master 的区别(诚实声明)

PPT Master 自己写了 6 个 source_to_md 脚本(pdf / doc / excel / ppt / web / image),全部封装好,**用户一个命令调起来**。

我们这边的策略不同:
- **不内置脚本** — 写了也是封装别人的工具,徒增维护成本
- **给你一张工具选型表 + 命令模板**,你自己装 / 自己跑 / 转完粘进对话
- 优点:轻、灵活、出错好定位
- 缺点:用户要懂一点命令行(但饶秋懂)

**如果你想要"傻瓜式一键转换"** → 这是 PPT Master 的强项,可以直接用他们的工具拿到 markdown,然后再来我们这边做 HTML PPT。这两个工具组合用,挺顺。
