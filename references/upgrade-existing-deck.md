# Mode C-enhance 升级老课件 · 标准工作流(v5.8 新增)

> **场景**:用户给一份老 HTML PPT 文件,说"按我的格式调整 / 重做 / 升级"。
>
> **不重做内容,只升级模板能力**——把缺的 v5.x 标准模块自动补齐。

---

## 为什么有这个工作流

### 真实踩坑(2026-05-18 锦江学院升级案例)

饶秋给了一份 v0.1 老课件(`AI 高校行政办公提效实战 · 锦江学院`),说"按饶秋格式重做"。

AI 凭直觉做了基础升级(切主题 + 加 lightbox + 跑 Quality Gate ✅),交付。

然后用户开始报错:
- "**按 E 没反应**" → 发现源文件 inline editing 模块完全没装(CSS 有皮、DOM/JS 都缺)
- "**两种风格切换也没有**" → 发现源文件双主题模块完全没装(0 paper CSS、0 dark CSS、0 T 键 handler)

来回补丁三轮才搞定。**根因**:AI 没有系统性 audit 源文件,只看 Quality Gate(那只验证 P0 红线,不验证"标准模块齐不齐")。

### 这个工作流的价值

**先 audit,再补丁**:用 `scripts/audit-deck.sh` 一键扫源文件,8 个标准模块的 CSS/DOM/JS 三段各自 grep,任一缺失立即报告。然后对照本文档的"补丁清单"逐个补。

**audit 工具甚至能反向发现 skill 自己的 bug** — 比如锦江案例第二轮里,audit 报 inline-edit CSS 缺失,这其实是 v5.7 之前的 patch 流程一直在漏注入 CSS(只补了 DOM+JS),audit 工具是第一个把这个 bug 揪出来的。

---

## 标准工作流(5 步)

### Step 1 · 跑 audit(必须做的第一步)

```bash
bash scripts/audit-deck.sh <用户的老课件.html>
```

输出会显示 8 个模块的 PASS / PARTIAL / MISSING 状态 + 3 个 Quality Gate 兼容性检查。

**判读**:
- ✅ 全 PASS + 全 CLEAN → 这份课件已经符合标准,**不需要升级**(只用换内容,不用动模板)
- ⚠ 任何 PARTIAL → 该模块**部分残缺**(CSS / DOM / JS 三段里某段缺),补缺失那段
- ✗ 任何 MISSING → 该模块**整套都缺**,按本文档"补丁清单"完整移植

### Step 2 · 跑 spec_lock(强制走完)

按 `references/spec-lock-template.md` 输出 spec_lock,**重点登记 `source_audit` 字段**(列出 audit 报告里的每一项 verdict)。

### Step 3 · 备份原文件 + 复制到桌面

```bash
SRC="<原文件路径>"
DST="/Users/raoyuli/Desktop/<标准命名>.html"
cp "$SRC" "$DST"
# 如有依赖资源(图片、二维码),一起 copy 到桌面同目录,保持相对路径生效
```

**标准命名**:`{主题}-{客户}-{日期}.html`
例:`AI+高校行政办公提效实战-锦江学院-2026-05-18.html`

### Step 4 · 按补丁清单逐项注入缺失模块

见下方 §补丁清单。**按依赖链顺序**注入(BFCache → 主题 → Inline Editing → Lightbox → Quality Gate fix),不要乱序。

### Step 5 · 再跑 audit 验证 + Quality Gate

```bash
bash scripts/audit-deck.sh <桌面文件.html>          # 应 8/8 PASS
bash scripts/raoqiu-check.sh --strict <桌面文件.html> # 应 12/12 P0 PASS
```

两个都通过才算交付。

---

## 补丁清单:每个标准模块的注入手册

下面 8 个模块,按"audit 报 MISSING / PARTIAL 时怎么补"组织。每条包括:

- **从模板抓哪些行**(`assets/template.html` 的精确行号范围)
- **注入到目标文件的哪个位置**
- **典型注入命令**

---

### 模块 1 · BFCache 防御 + Cache-Control no-cache(v5.6)

**audit 报 MISSING / PARTIAL 时表现**:Chrome 回退 / 前进时课件可能"卡死在某一帧"。

**从模板抓**:`assets/template.html` 第 6-12 行(`<meta http-equiv="Cache-Control">` 三行 + `<script>pageshow listener</script>`)

**注入位置**:目标文件 `<title>` 之前

**典型 Edit**:

```
old_string:
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{原标题}</title>

new_string:
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- v5.2.4: 防 Chrome 缓存 + BFCache 问题 -->
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<script>
window.addEventListener('pageshow', function(e){ if(e.persisted) window.location.reload(); });
</script>
<title>{原标题}</title>
```

---

### 模块 2 · v5.1 双主题切换(Paper & Ink / Dark Botanical / McKinsey 蓝)

**audit 报 MISSING 时表现**:按 T 键无反应 / 右下角没"纸·墨"切换按钮 / 主题永远是默认。

**3 段都要补**:

#### 2a. CSS(243 行)

**从模板抓**:`assets/template.html` 第 **1122-1364** 行(v5.1 双主题切换 CSS 段,paper + dark + #theme-toggle 按钮样式)

**注入位置**:目标文件 `</style>` 标签前

**注入命令**(用 sed 拼接):

```bash
T="<模板路径>"
F="<目标文件>"
# 找 </style> 行号
STYLE_END=$(grep -n '^</style>$' "$F" | head -1 | cut -d: -f1)
HEAD_END=$((STYLE_END - 1))
sed -n "1,${HEAD_END}p" "$F" > /tmp/head.html
sed -n "${STYLE_END},\$p" "$F" > /tmp/tail.html
sed -n '1122,1364p' "$T" > /tmp/theme-css.txt
cat /tmp/head.html /tmp/theme-css.txt /tmp/tail.html > /tmp/new.html
mv /tmp/new.html "$F"
```

#### 2b. JS(43 行)

**从模板抓**:第 **2360-2402** 行(`<!-- v5.1 双主题切换 · 纸 / 墨 -->` 注释 → `</script>`)

**注入位置**:在 inline editing JS 之前(主题模块要先 init,因为 inline editing 可能依赖主题)

**典型 Edit**:

```
old_string:
<!-- v5.2 Inline Editing · 编辑模式浮动指示条 + 已保存 toast -->

new_string:
<!-- ============================================================
     v5.1 双主题切换 · 纸 / 墨
     ============================================================ -->
<script>
{把模板 2360-2402 行的 JS 完整粘进来}
</script>

<!-- v5.2 Inline Editing · 编辑模式浮动指示条 + 已保存 toast -->
```

#### 2c. DOM 按钮(1 行)

**注入位置**:`<div class="ctrl-bar">` 内,加进现有按钮列表

**典型 Edit**:

```
old_string:
<div class="ctrl-bar">
  <button class="ctrl-btn" id="overview-btn">概览 · O</button>
  <button class="ctrl-btn" id="toc-btn">大纲 · M</button>
</div>

new_string:
<div class="ctrl-bar">
  <button class="ctrl-btn" id="overview-btn">概览 · O</button>
  <button class="ctrl-btn" id="toc-btn">大纲 · M</button>
  <button class="ctrl-btn" id="edit-toggle" title="编辑模式 · 点文字直接改(快捷键 E)">编辑 · E</button>
  <button class="ctrl-btn" id="theme-toggle" title="切换 纸 / 墨 主题(快捷键 T)"><span class="opt-paper">纸</span><span class="sep">·</span><span class="opt-dark">墨</span></button>
</div>
```

---

### 模块 3 · v5.2 Inline Editing(E 键 + Ctrl+S + localStorage)

**audit 报 MISSING / PARTIAL 时表现**:按 E 无反应 / 没有编辑模式横条 / 改文字不能保存。

**⚠️ 容易漏 CSS**:历史上有过补丁只补 DOM+JS 没补 CSS 的事故(2026-05-18 锦江案例)。**三段必须全补**。

#### 3a. CSS(123 行)

**从模板抓**:第 **1365-1487** 行(v5.2 Inline Editing CSS 段)

**注入位置**:`</style>` 标签前,**必须在主题 CSS 之后、Lightbox CSS 之前**(因为 edit-mode 下要 override Lightbox 的 cursor)

#### 3b. JS(约 210 行)

**从模板抓**:第 **2127-2356** 行(`<!-- v5.2 Inline Editing · JS 运行时 -->` 注释 → `</script>` 闭合的整块)

**注入位置**:在主题 JS 之后、Lightbox JS 之前

#### 3c. DOM(3 个块)

```html
<!-- 1. ctrl-bar 里的 edit-toggle 按钮(见 2c) -->

<!-- 2. 编辑模式浮动横条 -->
<div class="edit-banner" aria-hidden="true">
  <span class="dot"></span>
  <span>编辑模式 · 点文字直接改 · Ctrl+S 保存 · E 退出</span>
</div>

<!-- 3. 保存 toast -->
<div class="save-toast" id="save-toast">✓ 已保存到本地</div>
```

注入位置:`</div>` 关 stage 之后,JS `<script>` 之前

---

### 模块 4 · v5.7 Lightbox 双击放大(饶秋 2026-05 实战明确价值)

**audit 报 MISSING 时表现**:双击元素无任何反应。

**饶秋老师 2026-05 反馈原话**:"在卡片上双击可以放大这个点真的很好" — 这条**已升级为 v5.x 标准模块**,所有 deck 必备。

#### 4a. CSS(约 150 行)

**从模板抓**:第 **1489-1640** 行(v5.7 Lightbox + Click-to-Copy CSS 段)

**注入位置**:`</style>` 标签前,**主题 + Inline Editing CSS 之后**(Lightbox 最晚,层级最高)

#### 4b. JS(约 130 行)

**从模板抓**:第 **2617-2782** 行(v5.7 Lightbox + Click-to-Copy JS 段,IIFE 完整块)

**注入位置**:Inline Editing JS 之后、`</body>` 之前

**注意**:Lightbox 的 overlay / clone-wrap / close-btn / toast 全是 JS `createElement` 动态创建,**不需要静态 DOM**(audit 的 DOM 检测对 click-to-copy 已经特殊处理)。

---

### 模块 5 · 单击 .prompt-block 复制(v5.7,跟 Lightbox 同一段)

跟模块 4 一起注入。复制 toast 也是 JS 动态创建。

---

### 模块 6/7/8 · Slideshow / 大纲 / 概览(v5.x 老模块)

99% 的老 deck 都有这些(连 v4 时代都有)。**audit 报 MISSING 几乎不可能**,如果真报了,说明这份文件**根本不是 Rao-HTML-to-PPT 系列做的**,不要尝试 enhance,建议 Mode A 重做。

---

## Quality Gate 兼容性修正

### .page-footer 残留(v4 已弃用)

**audit 报 DIRTY 时**:用 sed 批量删:

```bash
sed -i '' '/<div class="page-footer">/d' <file>
```

### emoji 装饰

**audit 报 DIRTY 时**:按 emoji 类型替换:

| 老用法 | 标准替换 |
|---|---|
| `<h4>✅ 成功示范</h4>` | `<h4 style="color:#16A34A;">成功示范</h4>`(绿色无 emoji) |
| `<h4>❌ 失败示范</h4>` | `<h4 style="color:var(--c-warm);">失败示范</h4>`(警示红) |
| `🎯 目标` 标题 | `<span class="kicker">TARGET</span>` mono 标签 |
| `💡 洞察` 标题 | 用 `.insight-page` 版式或 mono "INSIGHT" 标签 |
| `🚀 行动` 等其它 emoji | 删除 emoji,用纯文字或 SVG icon(见 `references/icons.md`) |

批量 sed(对应锦江案例):

```bash
sed -i '' -E 's|<h4>❌ ([^<]*)</h4>|<h4 style="color:var(--c-warm);">\1</h4>|g' <file>
sed -i '' -E 's|<h4>✅ ([^<]*)</h4>|<h4 style="color:#16A34A;">\1</h4>|g' <file>
```

### page-title 用 div 而非 h2

**audit 报 DIRTY 时**:

```bash
sed -i '' -E 's|<div class="page-title"([^>]*)>|<h2 class="page-title"\1>|g; s|</div>(\s*<p class="page-subtitle")|</h2>\1|g' <file>
```

⚠️ 第二段 regex 替换"div 的 close 标签"略危险,人工 review 一下。

---

## 完整执行模版(端到端)

下面这段可以让 AI 直接执行的脚本,处理大部分老课件升级:

```bash
SRC="<用户的老课件.html>"
DST="/Users/raoyuli/Desktop/{主题}-{客户}-{日期}.html"
SKILL_DIR="/Users/raoyuli/Desktop/Skills/01-技能-Skills/我的技能-MySkills/Rao-HTML-to-PPT"

# Step 1: audit 源文件
bash "$SKILL_DIR/scripts/audit-deck.sh" "$SRC"

# Step 2: 备份 + 复制 + 同步依赖
cp "$SRC" "$DST"
# (人工: 把同目录的图片 / 二维码也 cp 到桌面)

# Step 3-4: 按 audit 报告逐项注入(由 AI 在对话里手动 Edit)
#   - 模块 1 (BFCache)
#   - 模块 2 (双主题: CSS + JS + button)
#   - 模块 3 (Inline Editing: CSS + JS + DOM × 3)
#   - 模块 4+5 (Lightbox + Copy: CSS + JS)
#   - 修 page-footer / emoji / page-title 用 div

# Step 5: 验证
bash "$SKILL_DIR/scripts/audit-deck.sh" "$DST"          # 应 8/8 PASS
bash "$SKILL_DIR/scripts/raoqiu-check.sh" --strict "$DST" # 应 12/12 P0 PASS
```

---

## 反向应用:升级 skill 自己

audit 工具不仅给老课件用,**给我们自己的 skill 也用**:

- 任何时候 template.html 有改动 / 新加 v5.x 模块,**跑 audit 看 template.html 自己是不是 8/8 PASS**
- 这就避免了 template 自己漏装某个模块,但用户不知道的尴尬

```bash
bash scripts/audit-deck.sh assets/template.html
```

应该任何时候都是 8/8 PASS + 0 dirty。**这是 template 自己的健康检查**。

---

## 历史踩坑记录

| 日期 | 事件 | 教训 |
|---|---|---|
| 2026-05-18 | 锦江学院升级,先后报错"按 E 没反应""按 T 没反应",来回三轮 | **没先 audit,凭直觉补丁** → 沉淀 audit-deck.sh 和本工作流 |
| 2026-05-18 | audit 反向发现 inline-edit CSS 一直在漏注入 | **审计工具揪出 skill 自己的 bug** → 任何"加新模块"都要 audit 自查 |

未来再撞到这种坑,加在这张表里。
