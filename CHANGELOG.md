# CHANGELOG · Rao-HTML-to-PPT

记录这个 skill 的版本变更。每次升级都按"做了什么 / 为什么 / 影响"三段记。

**读法**:最新版在顶部,历史往下排。先看版本号和日期,再挑分类标签:✨ 新增 / 🔁 改进 / 🛠️ 真实踩坑修复 / ⛔ 弃用。

**写法**(以后增量更新照这个格式):见文末"贡献新条目"。

---

## v5.10.0 · 2026-05-19(Lightbox 方向键导航 · 饶秋实战反馈第 2 弹)

**主线**:饶秋 2026-05-19 锦江学院课件再次反馈 —— 双击卡片放大后,想看下一张要先按空白/Esc 关掉,再回原页面双击下一张,**操作流程很碎**。要的是 **Lightbox 状态下按方向键直接切到同页下一张卡片**。

### ✨ 新增

#### Lightbox 内方向键导航

**触发**:在 Lightbox 打开状态下按方向键

| 键位 | 动作 |
|---|---|
| **→ / ↓ / Space** | 下一张 |
| **← / ↑** | 上一张 |
| **Esc** | 关闭 |
| 点空白 / × | 关闭 |

**范围**:**当前 `.slide.active` 里的所有可放大元素**(`.card / .metric / .step / .quadrant / .insight-page .insight-body / .big-number / .big-quote / .prompt-block / .task-card / .process-flow / .matrix-2x2`)。

**边界行为**:**循环** — 第 1 张按 ← 跳到最后一张,最后一张按 → 跳到第 1 张。不跨片(跨片要 Esc → 翻页 → 重新双击)。

**视觉反馈**:右下角 hint 实时显示 `← → 切换 · 2 / 6 · Esc 关闭`(只在 ≥ 2 张时显示位置;单卡片时显示 `点击空白 / Esc / × 关闭`)。

**过渡动画**:切换时短暂 fade-out (opacity 0 + scale 0.94) → 重新挂载 → fade-in,160ms 一次,**不硬切**。

### 🛠️ 技术细节

#### 1. 状态管理

```js
var lightboxSiblings = [];    // 当前 lightbox 可切换的同类元素列表
var lightboxIndex = -1;       // 当前 index
```

#### 2. 拆解 openLightbox

旧版的 `openLightbox(element)` 既负责"找元素 + 克隆 + 显示 overlay",一次性做完。
新版拆成两个:

- `openLightbox(element)` — 入口:**找当前 active slide 里的同类元素列表 + 定位 index**,然后调用 render
- `renderLightboxContent(element)` — 渲染:克隆 + 替换 wrap 内容 + **更新 hint 文本**

这样 `lightboxNavigate(dir)` 切换时只调 render,不重置 overlay,**保持放大状态平滑过渡**。

#### 3. 防 Slideshow 翻页拦截

Lightbox 的 keydown listener 用 **capture phase + stopPropagation**:

```js
document.addEventListener('keydown', function(e) {
  if (!overlay.classList.contains('active')) return;
  if (e.key === 'ArrowRight' || e.key === 'ArrowDown' || e.key === ' ') {
    e.preventDefault();
    e.stopPropagation();  // ← 关键:阻止 Slideshow 看到这个键
    lightboxNavigate(+1);
  }
  // ...
}, true);  // ← capture phase
```

不然按 → 会**同时切 lightbox 内卡片 + 翻到下一页**,体验崩。

#### 4. 边界 fallback

如果用户双击的元素不在当前 active slide 里(罕见,比如脚本误触发),`lightboxSiblings` 退化为单元素列表,方向键无效,体验等同 v5.9。

### 📂 文件变更

```
assets/template.html  · Lightbox JS IIFE 重写(+50 行)· 提取 renderLightboxContent / lightboxNavigate 函数
SKILL.md              · version 5.9.0 → 5.10.0
CHANGELOG.md          · 本条
```

**注**:本次同样把改动直接 patch 到桌面锦江归档 v0.3 课件。

### 🔬 验证

- [x] 锦江课件 audit 8/8 PASS · Quality Gate 12/12 P0 PASS
- [x] template.html 自查 8/8 PASS
- [x] lightboxNavigate × 3 / lightboxSiblings × 12 / 方向键 handler × 4(每个文件验证一致)
- [ ] 实操:用户在 Safari 里双击卡片后按 ← → 验证切换

### 🧠 设计 trade-off

| 选项 | 选了 | 理由 |
|---|---|---|
| 同页循环 vs 跨片走 | **同页循环** | 跨片会越过翻页层级,跟现有 Slideshow 模型冲突;循环最简单,用户直觉 |
| 切换硬切 vs fade | **160ms fade** | 卡片切换有过渡感,不像 PPT 翻页那么硬,符合"放大看细节"语义 |
| Space 当下一张 vs 当关闭 | **下一张** | 跟 PPT 翻页系统一致(Space = next),用户不用记新键 |
| hint 显示位置 vs 不显示 | **显示 N / M** | 让用户知道还有多少张可看,不会"切到尾了不知道" |
| 单卡片时仍显示导航 hint vs 不显示 | **不显示** | 只 1 张时方向键无效,显示反而误导 |

---

## v5.9.0 · 2026-05-19(Lightbox 真整体放大 · hotfix · 饶秋实战反馈)

**主线**:饶秋 2026-05-19 锦江学院课件实战反馈 — 双击卡片"放大"后,**外框确实变大了,但里面的字号还是原大小**,视觉上很空。这是 v5.7 Lightbox 设计 bug。

### 🛠️ 真实踩坑修复

#### 现象

用户截图对比:
- 普通状态:卡片是合理的小尺寸,文字字号正常
- 双击放大后:卡片框宽度铺满屏(到 90vw),但**里面 h3 / p / li 的字号没动**,卡片中间一大块视觉空白

#### 根因

v5.7 lightbox CSS 用了 `font-size: 1.15em`:
```css
.lightbox-clone-wrap > * {
  font-size: 1.15em;  /* ❌ 只放大 15% · 几乎看不出来 */
}
```

两个问题:
1. **1.15em 太弱** — 放大 15% 视觉上几乎察觉不到
2. **`> *` 只对直接子元素生效** — 卡片内部的 h3 / p / li / span 都有自己的固定 font-size,根本不继承外层放大

所以"放大"只放大了外框,**字号和内部 layout 都没动**。

#### 修法

放弃 font-size 思路,**用 CSS `zoom` 属性做整体等比缩放**:

```css
.lightbox-clone-wrap > * {
  zoom: 2.0;  /* ✅ 真整体放大 2 倍 · 字号 / padding / border / nested 全部跟着 */
  margin: 0 !important;
  padding: 1.4rem 2rem !important;
  min-width: 28vw;
  max-width: 44vw;  /* 防止 matrix-2x2 / process-flow 等宽 layout 撑爆 viewport */
}

/* Firefox 不支持 zoom · transform: scale fallback */
@supports not (zoom: 2) {
  .lightbox-clone-wrap > * {
    transform: scale(2.0);
    transform-origin: top center;
    margin: 6rem 0 !important;
  }
}

/* 双保险:即使 zoom 在某些 layout 失效,嵌套元素也强制大字号 */
.lightbox-clone-wrap > * h2, .lightbox-clone-wrap > * .page-title { font-size: 1.35em !important; }
.lightbox-clone-wrap > * h3, .lightbox-clone-wrap > * h4 { font-size: 1.25em !important; }
.lightbox-clone-wrap > * p, .lightbox-clone-wrap > * li { font-size: 1.18em !important; }
.lightbox-clone-wrap > * .card-num, .lightbox-clone-wrap > * .q-tag { font-size: 1.1em !important; }
.lightbox-clone-wrap > * .metric .v, .lightbox-clone-wrap > * .big-number .v { font-size: 1.4em !important; }
```

#### 为什么用 zoom 而不是 transform: scale?

| 方案 | 优点 | 缺点 |
|---|---|---|
| `font-size: Xem` | 标准 CSS | **只影响直接子,nested 不继承** |
| `transform: scale()` | 真整体放大 | **不影响 layout 占用空间**,会跟 wrap 边界混乱,需要单独算 margin |
| **`zoom: 2.0`** | **真整体放大 + 影响 layout 空间** | 非标准 CSS,但 Webkit/Blink/Chromium 全支持(Safari/Chrome/Edge),Firefox 不支持 → 用 @supports fallback |

对饶秋的场景(Safari 现场演讲)`zoom` 完美。Firefox 用 `transform: scale` 兜底。

### 📂 文件变更

```
assets/template.html  · .lightbox-clone-wrap > * CSS 块重写(+25 行)
SKILL.md              · version 5.8.0 → 5.9.0
CHANGELOG.md          · 本条
```

**注**:本次也直接把改动 patch 到桌面归档的锦江学院 v0.3 课件了(用户立刻能用)。所有未来 deck 用 template.html 生成的自动带新版 lightbox。

### 🔬 验证

- [x] 锦江课件 audit 8/8 PASS · Quality Gate 12/12 P0 PASS
- [x] template.html 自查 8/8 PASS
- [ ] 实操:用户在 Safari 里双击卡片,看 zoom 是否真生效(等饶秋下次现场反馈)

### 🧠 lesson · 写进 upgrade-existing-deck.md

> font-size: Xem 不会影响 nested 子元素的固定字号。需要"整体放大"用 `zoom` 或 `transform: scale`,**不是 font-size**。

---

## v5.8.0 · 2026-05-18(Mode C-enhance 升级老课件标准化 + audit-deck 工具 + Lightbox 价值正式确认)

**主线**:2026-05-18 锦江学院 v0.1 课件升级实战中,反复踩坑两次("按 E 没反应""按 T 没反应")— 根因是 AI 没系统性 audit 老文件缺哪些模块,凭直觉补丁。这次把 Mode C-enhance(升级老课件)做成标准工作流,绝不再来回踩。

### ✨ 新增

#### 1. scripts/audit-deck.sh · 老课件审计脚本(本次最重磅)

**输入**:任何老 HTML PPT
**输出**:8 个 v5.x 标准模块的 PASS/PARTIAL/MISSING 表格报告 + 3 个 Quality Gate 兼容性反向检测

```bash
bash scripts/audit-deck.sh <老课件.html>
# 或 JSON 格式给程序消费:
bash scripts/audit-deck.sh <老课件.html> --json
```

**8 个标准模块**(每个独立 grep CSS / DOM / JS 三段):

| # | 模块 | since |
|---|---|---|
| 1 | 双主题切换(Paper / Dark) | v5.1 |
| 2 | Inline Editing(E 键编辑) | v5.2 |
| 3 | **Lightbox 双击放大** ⭐ | v5.7 |
| 4 | 单击 prompt-block 复制 | v5.7 |
| 5 | BFCache 防御 | v5.6 |
| 6 | Slideshow 翻页核心 | v5.x |
| 7 | 大纲面板 M 键 | v5.x |
| 8 | 概览模式 O 键 | v5.x |

**3 个反向检测**(应为 0):
- `.page-footer` 残留(v4 弃用,会被翻页按钮遮挡)
- emoji 装饰(✅🎯💡🚀⭐🔥📊🎨🏆⚡)
- `<div class="page-title">` 错位用 div(应该用 h2)

**审计工具甚至反向揪出 skill 自己的 bug** — 这次 audit 锦江文件时发现 inline-edit CSS 缺(我之前 patch 时只补 DOM+JS 漏了 CSS),audit 工具是第一个发现的。也就是说**这个工具不仅给老课件用,template.html 自己也要定期跑一遍自查**。

#### 2. references/upgrade-existing-deck.md · Mode C-enhance 完整工作流文档

**150+ 行的端到端文档**,包括:
- 5 步标准流程(audit → spec_lock → 备份 → 注入 → 验证)
- **每个模块的精确补丁清单**:从 template.html 第几行抓什么(行号都给死)
- 注入位置精确说明(`</style>` 前 / ctrl-bar 内 / `</body>` 前)
- emoji 标准替换表(✅→绿色 h4 / ❌→红色 h4 / 等)
- 历史踩坑记录(锦江案例完整教训)
- 反向应用:也用来给 template.html 自己做健康检查

#### 3. references/spec-lock-template.md 新增 source_audit 字段

Mode C-enhance 任务**必须填**:
```yaml
source_audit:
  audit_command: "bash scripts/audit-deck.sh <源文件>"
  modules:
    theme_switch:    PASS/PARTIAL/MISSING
    inline_editing:  PASS/PARTIAL/MISSING
    lightbox_zoom:   PASS/PARTIAL/MISSING
    click_to_copy:   PASS/PARTIAL/MISSING
    bfcache_defense: PASS/PARTIAL/MISSING
    slideshow_core:  PASS/PARTIAL/MISSING
    toc_panel:       PASS/PARTIAL/MISSING
    overview_grid:   PASS/PARTIAL/MISSING
  quality_gate_compat:
    page_footer_legacy:    0
    emoji_decoration:      0
    page_title_div_misuse: 0
  patch_plan:
    - module: <name>
      action: "从 template.html LL-MM 抓 XX,注入到 YY 前"
      done: false
```

强制走这一步,**就没"凭直觉补丁来回踩"的空间**。

#### 4. SKILL.md 新增 Step 0.6 · Mode C-enhance 入口

**触发**:用户给老 HTML 文件说"按你的格式调整 / 升级 / 重做"

**强制走**:audit → 对照 patch 清单 → 验证

**模式数从 3 个升到 4 个**:Mode A 新建 / Mode B 大纲转 / **Mode C-edit 改局部** / **Mode C-enhance 升级老课件**(后两个细化区分)

#### 5. Lightbox 双击放大 · 正式升为必备标准模块

**饶秋老师 2026-05-18 锦江学院实战后反馈**:

> "在卡片上双击可以放大这个点真的很好。建议升级到我们的 skill 里去做一个更新。"

**做法**:
- SKILL.md §7.4.5 头部加入实战反馈引用
- 它已经是 v5.7 模板自带,**v5.8 通过 audit-deck.sh 把它列为 8 个必备标准模块之一**
- 所有未来 deck + 所有老 deck 升级时,Lightbox 都必须存在

### 🔁 改进

- **scripts/audit-deck.sh 改正了 1 个 false positive**:click-to-copy 的 toast 是 JS 动态 createElement 创建的,DOM 检测改用 `className.*copy-toast` 而不是静态 `class="copy-toast"`
- **SKILL.md description** 加入 4 个新关键词:`Mode C-enhance` / `audit-deck` / `升级老课件` / `Lightbox 实战明确价值`
- **tags 加 2 个**:`upgrade-existing-deck` / `audit-tool`

### 📂 文件变更

```
scripts/audit-deck.sh                       新建 230 行(8 模块 grep + 3 兼容性检测 + JSON / 人类双输出模式)
references/upgrade-existing-deck.md         新建 300 行(完整工作流 + 补丁清单 + 历史踩坑)
references/spec-lock-template.md            +28 行(source_audit 字段)
SKILL.md                                    version 5.7.0 → 5.8.0
                                            加 Step 0.6 Mode C-enhance 入口(40 行)
                                            §7.4.5 头部加 Lightbox 实战反馈引用
                                            description 更新 + tags +2
CHANGELOG.md                                本条
```

### 🎯 用法变化(对老用户)

**新场景**:用户给一份老 HTML PPT,说"按饶秋格式调整 / 升级 / 重做"

```bash
# 1. 一键 audit
bash scripts/audit-deck.sh <老课件.html>

# 2. 看报告,对照 references/upgrade-existing-deck.md 的补丁清单逐项补

# 3. 验证(两个必须都过)
bash scripts/audit-deck.sh <桌面文件>          # 8/8 PASS
bash scripts/raoqiu-check.sh --strict <桌面文件> # 12/12 P0 PASS
```

**老场景**:Mode A / Mode B / Mode C-edit 工作流不动,但**未来生成的 deck 默认都有 v5.7 Lightbox**(因为它从 v5.7 起就是 template.html 自带)。

### 🔬 实测验证

- [x] `bash scripts/audit-deck.sh <锦江学院 HTML>` → 8/8 PASS · 0 dirty
- [x] `bash scripts/audit-deck.sh assets/template.html` → 8/8 PASS · 0 dirty(template 自己自查)
- [x] 故意拿源文件 v0.1 跑 audit → 报 5 个 MISSING / 1 个 PARTIAL,跟历史踩坑一致
- [x] CHANGELOG / SKILL.md 描述 / spec-lock-template / upgrade-existing-deck 四份文档相互引用一致
- [ ] **下次有用户给老课件时,实测端到端流程,看 audit + patch + 验证三步顺不顺**

### 🧠 lessons learned 沉淀

| Lesson | 写进哪里 |
|---|---|
| 凭直觉补丁老课件会反复踩坑,**先 audit 再补丁** | upgrade-existing-deck.md §为什么有这个工作流 |
| 补 patch 时容易漏 CSS(只看 DOM + JS),**audit 三段独立检测 catch 这个** | upgrade-existing-deck.md §3a inline editing 警告 |
| **audit 工具也能反向 catch skill 自己的 bug** | upgrade-existing-deck.md §反向应用 |
| 客户实战反馈是 skill 升级最强信号(Lightbox 案例) | SKILL.md §7.4.5 头部引用 |

### 📊 累计踩坑表(留档)

| 日期 | 事件 | 解决 |
|---|---|---|
| 2026-05-18 | 锦江学院升级,先后报 inline editing + 主题切换 缺失,来回三轮 | 沉淀 audit-deck.sh + Mode C-enhance 工作流(v5.8) |
| 2026-05-18 | audit 反向发现 inline-edit CSS 一直漏注入 | 修复 patch 流程 + 加入 upgrade-existing-deck.md 警示 |

---

## v5.7.0 · 2026-05-18(鼠标交互升级 · 双击放大 + 单击复制 + 选文字不打架)

**主线**:饶秋实测 v5.6 课件时反馈"鼠标点击没什么用 — 能不能加放大、动画、复制?"。这次直接给鼠标补上实质功能,而不只是"屏幕装饰"。

### ✨ 新增

#### 1. Lightbox 双击放大(任何"内容块")

**触发**:双击 `.card / .metric / .step / .quadrant / .insight-page .insight-body / .big-number / .big-quote / .prompt-block / .task-card / .process-flow / .matrix-2x2` 中的任意一个。

**效果**:
- 该元素**深克隆**到全屏 lightbox 覆盖层
- 居中放大到 **90vh × 90vw**,字号放大 1.15×
- 黑色半透明遮罩 + `backdrop-filter: blur(8px)` 模糊背景
- 平滑 `transform: scale(0.92 → 1)` 弹入动画(`cubic-bezier(0.16, 1, 0.3, 1)` ease-out-expo)
- 关闭:点空白 / 按 Esc / 点右上 ✕ — 三种方式都行
- 关闭也是平滑过渡 + clone DOM 自动清理(不堆积)

**为什么**:讲师现场常需要把卡片放大让后排学员看清,以前只能 Cmd+ 放大整页,现在双击单卡就行。

#### 2. 单击 `.prompt-block` 一键复制

**触发**:单击任何代码块 / 提示词模板块。

**效果**:
- 自动剥掉 `.prompt-tag` 标签那一行(只复制纯 prompt 文本)
- 优先用 `navigator.clipboard.writeText`(现代浏览器),老浏览器 fallback 到 `document.execCommand('copy')`
- 右上角弹绿色 toast "✓ 已复制提示词到剪贴板",1.9 秒后自动消失
- 失败时弹红色 toast "✗ 复制失败,请手动拖选"

**视觉提示**:hover 时 `.prompt-block` 右上角浮 `⌘ 单击复制 · 双击放大` 小标签(深蓝 + mono 字体)。

**为什么**:培训现场讲完一个提示词模板,学员要复制粘贴试 — 以前要拖选很长一段,经常选错。现在点一下整块。

#### 3. 选文字 / 复制粘贴默认行为(防御)

**问题**:有些 deck 框架会用全屏点击监听翻页,但那样**会拦截浏览器原生的文字拖选**,学员根本没法复制内容。

**v5.7 明确不绑全屏 click → next**。代码里:
- 单击 `.prompt-block` 触发复制
- 单击 lightbox 空白触发关闭放大
- **其他位置的单击什么都不做**(不翻页,不冒泡)
- 拖选文字时 click 监听里有 `getSelection().length > 0` 的早返(选文字不被中断)

**视觉**:鼠标 hover 在可放大块上时显示 `cursor: zoom-in`,在 prompt-block 上显示 `cursor: pointer`,其他文字区域是默认 `text` cursor — **告诉用户哪里能干什么**。

#### 4. 编辑模式协作(不打架)

按 `E` 进编辑模式时(`body.edit-mode`):
- Lightbox dblclick 自动禁用(让双击文字 = 选词)
- 单击复制自动禁用(让点击 = 编辑光标)
- 所有 `cursor: zoom-in` / `cursor: pointer` 切换回 `cursor: text`

退出编辑模式后自动恢复。**这是 v5.2.4 踩过 contenteditable 冲突的坑,这次提前防御**。

### 📂 文件变更

```
assets/template.html         +290 行 CSS(放在 .save-toast.show 之后,</style> 之前)
                             +130 行 JS(新 <script> 块,放在 </body> 之前)
SKILL.md                     version 5.6.1 → 5.7.0
                             加 §7.4.5 "鼠标交互升级"段落
                             tags 加 lightbox-zoom / click-to-copy
CHANGELOG.md                 本条
```

**注**:本次还把 `Desktop/AIGC视频生成实战-饶秋McKinsey风-2026-05-18.html` 也手动 patch 上了同一份 CSS+JS(因为成品已交付,用户立刻需要)。以后用 v5.7 模板生成的 deck 自动带这两个功能。

### 🎯 用法变化(对老用户)

**翻页方式完全没动**:键盘 ← → / 空格 / PageDown / Home / End / 右下角箭头 / 大纲 M / 概览 O / 全屏 F / 触屏滑动 — 全保留。

**新增的鼠标动作**:
- 想放大看某张卡? **双击它**
- 想复制提示词? **单击代码块**(它会高亮提示"⌘ 单击复制")
- 想选段文字? **直接拖选**,Cmd+C — 跟之前一样

**视觉提示**:可放大的元素鼠标移上去会变成"放大镜+"光标。代码块光标变成"手"。

### 🔬 验证

- [x] AIGC 32 页课件 Quality Gate(--strict)依然通过,无 P0 回退
- [x] template.html 重新生成的 demo deck 双击 / 单击都正常
- [x] 编辑模式(E 键)进入后 lightbox/复制自动禁用
- [x] Esc 关闭 lightbox 时不会同时触发翻页(capture phase + stopPropagation)
- [x] 选文字时 click 监听不打断(`getSelection().length > 0` 早返)
- [x] 同一个 prompt-block 连续单击 → toast 计时重置,不堆积
- [ ] **下次现场培训实际用一次,验证是否真的更顺手**

### 🧠 设计 trade-off

| 选项 | 选了 | 为什么 |
|---|---|---|
| 单击放大 vs 双击放大 | **双击** | 单击保留给"复制 prompt-block",不互斥 |
| 点击空白翻页 vs 不翻页 | **不翻页** | 翻页用键盘/按钮显式触发更稳;鼠标点空白会拦截选文字 |
| Lightbox 全屏 vs 局部放大 | **全屏 + 模糊背景** | 局部放大要算偏移,且会被父级 overflow 裁;全屏 lightbox 简单可靠 |
| 复制时 toast vs 弹窗 | **toast** | 弹窗打断节奏,toast 1.9 秒自动消,不阻塞 |
| 默认 cursor 提示 vs 不提示 | **提示**(zoom-in / pointer)| "告诉用户能干什么"比"用户自己摸索"好 |

---

## v5.6.1 · 2026-05-18(hotfix · `export-pdf.sh` 真 32 页 PDF)

**主线**:饶秋实测把 32 页 HTML 课件导成 PDF 时,旧 `export-pdf.sh` 只出 1 页(后来调整后变 8 页)— 远不是 32 页。这次彻底修。

### 🛠️ 真实踩坑修复

#### 现象

`bash scripts/export-pdf.sh 32页课件.html out.pdf` → 输出 PDF 实际只有 1 页(或 8 页)。

#### 根因

模板里:
- `html, body { overflow: hidden; height: 100% }`
- `.stage { position: fixed; inset: 0; overflow: hidden }`
- `.slide { position: absolute; inset: 0; display: none }` · `.slide.active { display: flex }`

旧脚本只把 `.slide` 改成 `position: relative + display: flex`,**但 `.stage` 还是 `position: fixed + overflow: hidden`**。所以 32 张 .slide 全堆叠在那个 fixed 容器里,被 viewport 框死,Chromium print pagination 只看到"一个 viewport 的内容"→ 1 页。

我尝试过两轮"加 `!important` 解锁 html/body/.stage + 加 `page-break-after: always`"还是不 work — Chromium 的 print pipeline 在这种 fixed/absolute 切换显示的 deck 模板上**就是不可靠**。

#### 修法 · 换实现思路

**放弃 print pagination,改成"逐张 slide 单独渲染 PDF + pdf-lib 合并"**:

```javascript
for (let i = 0; i < slideCount; i++) {
  // 1. 切换 .active 到第 i 张
  await page.evaluate((idx) => {
    document.querySelectorAll('.slide').forEach((s, k) => {
      s.classList.toggle('active', k === idx);
    });
  }, i);

  // 2. 给这一张出一份 1-page PDF (buffer)
  const singlePagePdf = await page.pdf({ width: '1920px', height: '1080px', ... });

  // 3. 把这页拷进 merged PDF
  const tmpDoc = await PDFDocument.load(singlePagePdf);
  const [copiedPage] = await mergedPdf.copyPages(tmpDoc, [0]);
  mergedPdf.addPage(copiedPage);
}
```

**优点**:
- ✅ **32 张 .slide → 32 页 PDF**(严格 1:1)
- ✅ **每页仍是真矢量 PDF**(文字可选 / 链接可点),不是图片堆
- ✅ 绕开 print pagination 的所有 quirks(fixed / overflow / @page / break-after 这些都不用纠结)
- ✅ 跟 `export-pptx.sh` 同款思路(逐张切换 + 截图合成),已经在 v5.4.1 验证稳定

**代价**:
- 多一个 npm 依赖 `pdf-lib`(~500KB,无 native deps,首次安装一次)
- 渲染时间稍长(32 次 page.pdf() 调用,实测 ≈ 25 秒 vs 旧版 ≈ 8 秒)

#### 实测验证

```
原 30 页 AIGC 视频生成课件 → Rao v5.6 重做的 32 页 HTML → PDF
  bash scripts/export-pdf.sh AIGC-课件.html AIGC-课件.pdf
  [info] 找到 32 张 slide,开始逐张渲染 PDF
  [info] 进度 32 / 32
  [ok] PDF 已保存(32 页)

  mdls -name kMDItemNumberOfPages AIGC-课件.pdf
  → kMDItemNumberOfPages = 32 ✅
  
  文件大小:10.4 MB(矢量 PDF,32 页 1920×1080)
```

### 📂 文件变更

```
scripts/export-pdf.sh     重写 page.pdf() 调用为逐页循环 + pdf-lib 合并
                          package.json 加 pdf-lib 依赖
                          (~120 行 diff,核心逻辑全换)
SKILL.md                  version 5.6.0 → 5.6.1
CHANGELOG.md              本条
```

### 🎯 用法变化(对老用户)

**无变化**。命令完全一样:
```bash
bash scripts/export-pdf.sh <file.html>              # 默认 1920×1080
bash scripts/export-pdf.sh <file.html> --compact    # 1280×720 紧凑
bash scripts/export-pdf.sh <file.html> --skip-gate  # 跳过 P0 门控
```

首次跑会自动装 `pdf-lib`(几秒钟,不影响 Playwright/Chromium 那一次性 150MB 下载)。

### 🔬 lessons learned

- **Chrome print pagination 在 deck 模板上不可靠** — 任何用 `position: fixed/absolute + .active 切换显示` 的 SPA-style HTML 都不适合直接 `page.pdf()`
- **遇到这种情况,改用"per-element 渲染 + 合并"才稳** — 我们 `export-pptx.sh` 早就这么干了,`export-pdf.sh` 这次也对齐
- **不要试图用 `!important` + `@page` + `break-after` 一层一层"打补丁"** — 改架构比加补丁省时间。我前两轮折腾的 hour 印证了这一点

---

## v5.6.0 · 2026-05-18(借鉴 hugohe3/ppt-master 18k stars · 方案 C)

**主线**:饶秋发现 [hugohe3/ppt-master](https://github.com/hugohe3/ppt-master)(17,782 stars),做完调研走方案 C——借 P0 三件 + P1 一件 + 战略上明示边界推荐对方。

**关键背景**:PPT Master 是 484MB 的 Python 完整工程,核心是**自研 SVG → DrawingML 转换器**,产出真正可编辑的 PPTX。我们做不出,也没必要做——我们卖点是 HTML 现场演讲 + McKinsey 风深度锁死 + 培训片优化。两个工具是互补的,**饶秋诚实优先,推用户去用对方做"客户带回去改"的场景**。

### ✨ 新增

#### 1. spec_lock 长 deck 防漂移机制(借鉴 ppt-master 第 28 条铁律)

**加在哪**:新建 `references/spec-lock-template.md`(290 行),`SKILL.md` 工作流加 Step 1.6。

**触发条件**:培训片 ≥ 20 页 / 客户提案 ≥ 12 页 / Mode B / Mode C 加 ≥ 5 页。

**做什么**:动笔前输出完整 spec_lock(YAML 格式 · 12 个字段:colors / fonts / client_override / pii_safety / data_sources / rhythm / layouts_used / charts ...),**生成每一页前重读一次**,所有颜色/字体/客户名/数据 hex 必须从 spec_lock 取,不许凭记忆。

**为什么是 P0**:v4 时代我们撞过同一个坑——做 20+ 页培训片时,主色 `#051C2C` 从第 7 张悄悄滑到 `#0A2540`。当时只改 CSS 用 `var()` 兜底,没沉淀方法。这次把方法补回来:**不靠 CSS 兜底,靠生成时纪律**。PPT Master 把这条写成"SPEC_LOCK RE-READ PER PAGE"红线,17.8k stars 验证了价值。

#### 2. Quality Gate 导出前硬门控(借鉴 ppt-master `svg_quality_checker.py`)

**加在哪**:`scripts/raoqiu-check.sh` 加 `--strict` 标志;`scripts/export-pdf.sh` + `scripts/export-pptx.sh` 都加前置门控调用(导出前自动跑 `--strict`,FAIL 不导出)。

**用法**:
- 普通自检:`bash scripts/raoqiu-check.sh <file.html>`
- 严格门控:`bash scripts/raoqiu-check.sh --strict <file.html>`(P0 不通过 → `⛔ GATE FAILED · 禁止导出`)
- 导出脚本已内置:`bash scripts/export-pdf.sh <file.html>` 自动先跑门控
- 紧急绕过:`--skip-gate`(责任自负)

**为什么是 P0**:之前 P0 自检是"建议必跑",AI 急着交付时会跳。v5.6 改成"导出脚本强制先跑,FAIL 不导出"——绕不过去。借鉴 PPT Master 的"`error must be fixed before proceeding`"思想。

#### 3. 多渠道输入工具表(借鉴 ppt-master `source_to_md/*.py`)

**加在哪**:新建 `references/source-input.md`(220 行)。

**包含**:PDF / DOCX / Excel / 微信公众号 / 网页 / PPTX / 图片 7 种输入类型的工具选型 + 命令模板:
- PDF → `pdftotext`(简单) / `marker-pdf`(复杂扫描件)
- DOCX → `pandoc`
- Excel → `openpyxl` 一行脚本(模板提供)
- 微信公众号 → `curl_cffi` 或直接用 Claude `WebFetch`(更简单)
- PPTX → `python-pptx` 拆素材脚本(模板提供)

**与 PPT Master 的差异**:**我们不内置脚本**(写了也是封装别人的工具,徒增维护成本),给一张选型表 + 命令模板,用户自己装自己跑。优点:轻、灵活、出错好定位。傻瓜式一键转换用 PPT Master 自己的工具。

#### 4. examples/ 真实成片示范库(借鉴 ppt-master 22 个 deck 309 页)

**加在哪**:新建 `examples/` 目录 + 4 个子目录(training / client-proposal / laimei / xhs-or-self-media)+ README.md(详细的脱敏规则)。

**怎么用**:Mode A 开始前 `Step 0.5` 先看 `examples/<scenario>/` 对应子目录,有就 `Read` 示范片学版式 / 节奏 / 体感,没有就跳过——不会因为目录空导致流程卡住。

**脱敏 P0 红线**:客户真名 / 学员真名 / 团队真名 / 莱美内部数据 / 健康具体值 / 陶勇医生相关 / 手机号身份证全部禁止。配有自检 grep 命令。

**现状**:占位符已建好,等饶秋逐步填入真实成片(优先培训片,因为样本最有用)。

#### 5. 战略边界声明(借鉴 ppt-master 的存在 + 饶秋"诚实优先"人格)

**加在哪**:SKILL.md Step -1 之后加"⚠️ 边界声明"段;CHANGELOG 这条;README 同步。

**核心**:用一张表说清楚 8 个场景下用哪个工具(本技能 vs PPT Master)。两个工具是互补关系,不是替代。最佳工作流:**现场用本技能 HTML 演讲 + 同一份内容用 PPT Master 出可编辑 PPTX 给客户带走**。

**为什么这条最重要**:
- **诚实**:不假装我们 PPTX 是"完整的 PPT",其实就是图片
- **不夺人之美**:对方做了 484MB 工程,我们尊重
- **反而抬高自己**:用户跟随推荐走,信我们的判断
- 饶秋人格四特质全占了:知行合一 / 追问本质 / 诚实优先 / 安静的深度

### 🔁 改进

- **SKILL.md description**:加入"spec_lock / Quality Gate / 多渠道输入 / examples"四个关键词 + 边界声明
- **tags**:新增 `spec-lock` / `quality-gate` / `multi-input` 三个标签
- **SKILL.md 工作流**:在 Step 1 前加 Step 0.5(看 examples)、Step 1.5 后加 Step 1.6(锁 spec_lock)、Step 4 升级为"P0 人工对照 + `--strict` 脚本门控 + 导出脚本内置门控 + spec_lock 抽查"四阶段
- **export-pdf.sh** + **export-pptx.sh** 注释头部都加了"如需原生可编辑 PPTX → 推荐 hugohe3/ppt-master"
- **export-pptx.sh** 命名从"可编辑 PPTX 导出"诚实改为"图片版 PPTX 导出"

### 📂 文件变更

```
references/spec-lock-template.md  新建 290 行
references/source-input.md        新建 220 行
examples/README.md                新建 80  行
examples/{training,client-proposal,laimei,xhs-or-self-media}/_placeholder.md  4 个占位
scripts/raoqiu-check.sh           +30 行(--strict 模式 + 失败提示升级)
scripts/export-pdf.sh             +25 行(Quality Gate 前置门控)
scripts/export-pptx.sh            +35 行(Quality Gate 前置门控 + 边界声明)
SKILL.md                          version 5.5.0 → 5.6.0 + 边界声明 + Step 0.5 + Step 1.6 + Step 4 升级
CHANGELOG.md                      +110 行(本条)
```

### ⚠️ 不借的(明确决策)

- **SVG → DrawingML 转换器**:对方 484MB 核心工程,我们做不出也没必要做 → **推荐用户去用他们**
- **动画 / TTS / 视频导出 / 声音克隆**:太重,不在职责范围 → 推荐
- **模板复刻**(读 .pptx 提主题色):我们锁死 McKinsey 不需要复刻别人风格
- **8 Confirmations BLOCKING 流程**:跟我们 Mode A 现有"边写边对齐"风格冲突,且我们已经评估过 frontend-slides 类似流程不借
- **造 6 个 source_to_md/*.py 脚本**:不背 Python 项目复杂度,给工具表 + 命令模板就够

### 🎯 用法变化(对老用户)

**Mode B 用户**:
- 现在可以处理 PDF / DOCX / Excel / 微信公众号 / 网页 / PPTX 7 种输入(查 `references/source-input.md`)
- 长 deck(≥ 20 页培训片 / ≥ 12 页提案)在大纲后多走一步 Step 1.6 锁 spec_lock

**Mode A / Mode C 用户**:
- 改 PPT 前先 `ls examples/<scenario>/` 看有没有示范片,有就先 Read 一份学手感
- 导出前自动跑 `--strict` 门控,P0 不通过不许导出(紧急可 `--skip-gate`)

**全员**:
- 客户问"能不能在 PowerPoint 里改字"→ 现在有明确答案:本技能产出图片版,要可编辑用 PPT Master
- PPT Master 本地副本在 `/Users/raoyuli/Desktop/Skills/02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/ppt-master/`

### 🔬 验证方式

- [x] SKILL.md frontmatter YAML 解析正常,Skill 列表显示 v5.6
- [x] `raoqiu-check.sh --strict` 在 FAIL 时 exit 1 + 打印"GATE FAILED"
- [x] `export-pdf.sh` / `export-pptx.sh` 调用门控,FAIL 时不进入 Playwright
- [x] `examples/` 目录结构 + 4 个占位都在位
- [x] PPT Master 本地副本 80MB 已 clone 到 References 库
- [ ] **下次做长培训片时,实际用一次 spec_lock 流程验证防漂移效果**

---

## v5.5.0 · 2026-05-18(借鉴 3 个外部仓库,补齐"文字太单一了"的洞)

**主线**:饶秋读了 3 个 GitHub PPT 仓库——zarazhangrui/frontend-slides(17.8k stars)+ code-on-sunday/slide-deck-generator + robonuggets/marp-slides——决定**做 P0(4 件)+ P1(2 件)**。重点是 SVG 配图,补"文字太单一"的洞。

### ✨ 新增

#### 1. 培训片大纲模板:五段循环 + Module 时长表(借鉴 slide-deck-generator)

**加在哪**:`references/layouts.md` 末尾新增"培训片大纲模板"章节。

**核心**:成人学习的 Problem → Discussion → Concept → Example → Takeaway 五段循环 + 时长对照表(30 分钟 / 1 小时 / 2 小时 / **4 小时(100-140 张)** / 全天)+ 视觉比例建议(视觉 60-70% / 图表 10-15% / 文字 15-20%)。

**服务工作面**:培训交付。Mode B(把客户大纲转成 PPT)流程现在有了硬节奏参考——4 小时培训怎么排 100-140 张?切几个 Module?每个 Module 几个 Cycle?都有表。

#### 2. SVG 数据 Dashboard 版式库(借鉴 marp-slides)

**加在哪**:`references/layouts.md` 末尾新增"数据 Dashboard 版式"章节(代号"版式 13",含 12 个子组件)。

**包含 12 个生产可用组件**:
- **Metric card**(KPI 卡片,顶部 2px 渐变描边 + icon + 大数字 + trend arrow)
- **Donut ring**(单环占比,含 dashoffset 数学公式表)
- **Pie / multi-segment donut**(多段饼图)
- **Sparkline**(50×16 内联迷你折线)
- **Stacked bar**(横向堆叠条 + 图例)
- **Vertical bar chart**(纵向柱状图,CSS variable 控高度)
- **Line / Area chart**(SVG 折线 + 渐变面积 + 网格 + 目标线)
- **Half-circle gauge**(半圆表盘,含 dashoffset 公式)
- **Status dots**(8×8 圆点,绿/黄/红/灰四态)
- **Verdict tag**(放大 / 砍掉 / 观察 三态标签)
- **Hover row**(表格悬停高亮)
- **一页 Dashboard 范例**(展示组合方式 + 密度上限)

**为什么做**:饶秋原话——"我们之前文字太单一了"。模板原来只有"卡片网格 / metric-row / 2x2 矩阵",**没有真正能塞数字的可视化原语**。补完后,客户提案 / 莱美业绩页 / 培训数据页都能直接抄。

**保持麦肯锡风**:所有图表颜色锁定 `--c-brand` / `--c-warm` / `--c-up` / `--c-down`,没有渐变色饼图、没有荧光色,字体跟随模板。

#### 3. SVG icon 库(借鉴 marp-slides)

**加在哪**:新建 `references/icons.md`。

**包含 24 个基础图标**(Lucide 标准):
- 趋势数据(6 个):arrow-up/down/right · trending-up · bar-chart · pie-chart
- 状态反馈(5 个):check · check-circle · x-circle · alert-triangle · info
- 时间节奏(3 个):clock · calendar · zap
- 内容主体(5 个):file-text · book-open · users · target · lightbulb
- 工具操作(5 个):edit · download · search · settings · play
- 商业业绩(5 个):dollar-sign · activity · award · globe · shield

**统一规范**:viewBox `0 0 24 24` · stroke 1.5 · `fill:none` + `stroke:currentColor` · round linecap/linejoin。

**4 档尺寸**:inline(14-16px)/ card(20-24px)/ feature(32-44px)/ hero(56-72px)。

**配色规则表**:中性 → `--c-ink-3`,主色 → `--c-brand`,正向 → `--c-up`(#16A34A),负向 → `--c-down`(#DC2626),警告 → `--c-warn`(#F59E0B)。

#### 4. Content density 表 · 每种版式的内容硬上限(借鉴 frontend-slides)

**加在哪**:`references/checklist.md` 的 P0 段加 8a 条。

**核心**:把"一页一观点"从抽象规则变成机械可查的表——封面 = 1 主标题 + 1 副标题 + 0-1 装饰;卡片网格 = 标题 + 2×3 或 3×2 共 6 卡;Big Number = 1 数字 + ≤ 8 字说明 + 1 source;Big Quote = ≤ 3 行 / ≤ 40 字;**Dashboard 页(新)** = 一行 ≤ 4 metric / 一页 ≤ 3 donut / ≤ 2 line / ≤ 1 vertical bar。

**超量信号速查**:`.page-body` 出现垂直滚动条 / 字号被缩到 < 14px / 卡片 gap < 0.5rem → 内容超了,**不要改 CSS,拆页**。

#### 5. 培训片专属:按时长查张数表(借鉴 slide-deck-generator)

**加在哪**:`references/checklist.md` 的 P0 段加 8b 条。

**核心**:做培训片强制查表,4 小时 = 100-140 张是基准。算口径:每张约 1.5-2 分钟(含 Q&A 缓冲)。

#### 6. Anti AI-slop 反清单(借鉴 frontend-slides + slide-deck-generator)

**加在哪**:`references/design-system.md` 末尾新增"Anti AI-Slop 反清单"章节。

**核心**:把"AI 套版"的标志(Inter 字体 / `#6366f1` indigo / 紫粉渐变 / 全居中堆栈 / 玻璃拟态 + 拟物 + 阴影三件套 / 写实插画 / 每页都飞进来)白纸黑字列出来全禁。配套"眯眼测试"(模糊看 deck,任何一条命中就要重做)。

#### 7. CSS Gotchas 踩坑警示档(借鉴 frontend-slides + 我们自己 v5.2.x 的坑)

**加在哪**:`references/design-system.md` 末尾新增"CSS Gotchas"章节。

**包含 6 个坑**:
1. **`-clamp()` 静默失败**:浏览器丢弃整条声明无报错,必须用 `calc(-1 * clamp(...))`
2. **clamp() 三值单调**:max < min 会退化为常量
3. **`vh` 在 iOS Safari 被工具栏吞掉**:双行写法 `height: 100vh; height: 100dvh;`
4. **`~` 兄弟选择器 + pointer-events:none 死循环**:edit toggle 永远点不到,必须 JS + 400ms 延迟
5. **`outerHTML` 捕获临时 UI 状态**:edit 模式导出后永远停在 edit 模式,必须先剥状态再 capture(我们 v5.2.4 修过的坑,留档警示)
6. **nav dots 无限叠加**:`setupNavDots()` 第一行必须 `innerHTML = ''` 清空

### 🔁 改进

- **SKILL.md description**:加入"培训片五段循环"、"SVG 数据 Dashboard"、"SVG icon 库"、"Anti AI-slop 反清单"、"CSS Gotchas" 关键词,让 Cowork 和 Claude Code 触发更精准
- **tags**:新增 `svg-charts` / `dashboard` / `training-cycle` / `anti-ai-slop` 四个标签
- **scripts/ 介绍**:从"PDF 导出和合规自检"扩展到"PDF 和 PPTX 导出 + 合规自检"

### 📂 文件变更

```
references/layouts.md      +500 行(培训五段循环 + 数据 Dashboard 版式库)
references/checklist.md    +60  行(Content density 表 + 培训片张数表)
references/design-system.md +180 行(Anti AI-slop 反清单 + 6 个 CSS Gotcha)
references/icons.md        新建 320 行(24 个 SVG icon 配方 + 配色规则)
SKILL.md                   version 5.4.0 → 5.5.0 + description + tags
```

### ⚠️ 不做的(决策记录)

- **不**借 frontend-slides 的 12 个 preset 全套 — 我们锁定 McKinsey 风就是辨识度,多 preset 会稀释
- **不**借 frontend-slides 的"先生成 3 个 preview HTML 让用户挑"流程 — 多走一轮 token 收益不明
- **不**借 slide-deck-generator 的 React + Vite + Framer Motion 整套栈 — 和我们 zero-dependency 单 HTML 路线相反
- **不**借 marp-slides 的 MARP markdown 语法 — 另一条赛道
- **暂缓**:PPTX → HTML 反向转换(`extract-pptx.py`)、Vercel 一键部署(`deploy.sh`)—— P2 级,等真有需求再做

### 🎯 用法变化(对老用户)

**Mode A / B 用户**:
- 培训片现在可以让 AI 先按"五段循环"排骨架,再填内容
- 数据页可以让 AI 直接出 dashboard 版式(以前只能出 metric-row + 卡片)

**Mode C 用户**:
- 改 PPT 时先查 `checklist.md` 的 Content density 表,机械化判断是否要拆页
- 信息密集的旧 PPT,可以让 AI 用 dashboard 版式重排

**全员**:
- 出图时图标统一查 `icons.md`,不再让 AI 瞎画
- 配色 / 字体 / 元素 / 文案有疑虑,先查 `design-system.md` 的 Anti AI-slop 反清单

### 🔬 验证方式

- [x] SKILL.md frontmatter 通过 YAML 解析
- [x] 4 个 references 文件无 broken link
- [x] icons.md 里的 SVG 代码可直接 copy 进浏览器渲染
- [x] checklist.md Content density 表的版式名与 layouts.md 一致(没有错位)
- [ ] **下一次实际做 PPT 时,用一次新章节确认顺手**

---

## v5.4.1 · 2026-05-12(hotfix · PPTX 视觉问题修复)

**主线**:v5.4.0 实测后饶秋发现 3 个问题,这次集中修。

### 🛠️ 真实踩坑修复

#### 修复 1 · 第 18 页 PROMPT TPL 02 跟标题重叠(动画半截被截图)

**现象**:`scripts/export-pptx.sh` 跑完,某些页(尤其是有 prompt-block 的)出现两个元素重叠,像截图截到了动画过渡的中间状态。

**根因**:截图前只等了 `400ms`,fadeIn 动画(.slide.active 切换)还没结束,**截图记录了动画过渡的瞬间**。

**修正**:
- `waitForTimeout(400)` → `1000`(等动画完全结束)
- 加 `await page.evaluate(() => document.fonts.ready)`(等字体加载完,防止衬线字体没好就截图)

#### 修复 2 · 截图内容不完整 / 边缘被裁

**现象**:某些页内容看起来"截图没截完整"。

**根因**:用了 `page.screenshot({ fullPage: false })`,截的是整个 viewport,如果 .slide 内容跟 viewport 边界对不齐就会有问题。

**修正**:改用 **`element.screenshot('.slide.active')`** — 截 `.slide.active` 元素的精准 bounding box,**保证一定截到完整的当前页内容**。

#### 修复 3 · 默认 1280×720(--compact)太挤

**现象**:饶秋反馈"内容看起来不够占满全页"。

**根因**:v5.4.0 用户跑的时候带了 `--compact` 参数(1280×720),**但模板某些版式(尤其 cols-3 9 卡片网格)在窄屏下视觉效果差** — padding 显得大,卡片显得挤。

**修正**:**默认 1920×1080**(全高清),--compact 才是 1280×720。文件从 16M → 19M(可接受)。

### ✨ 新增

- **Debug 模式** `RAOQIU_PPTX_DEBUG=1`
  - 跑 `RAOQIU_PPTX_DEBUG=1 bash scripts/export-pptx.sh ...`
  - 每页 PNG 单独存到 `/tmp/raoqiu-pptx-debug/slide-XX.png`
  - **用途**:如果某页 PPTX 里有问题,可以单独看 raw PNG,确认是截图问题还是 HTML 本身问题

### 📌 未修复 / HTML 本身问题(不在脚本能管的范围)

**用户反馈第 3 页"9 个模块"卡片网格,第 09 卡片"内容发布"文字 "公众号 / 小红书 / 视频号 / 海报 /..." 后面被裁切**。

**根因**:**这是 HTML 模板本身的问题**(卡片固定高度 + cols-3 网格 + 文字过长)。**浏览器里看也是这样**,不是 PPTX 导出脚本的问题。

**怎么解决**:用 v5.2 Inline Editing 在浏览器里按 E 进编辑模式,把那条文字改短(比如只留前 3 项),或者拆成两行。

### Patch 范围

`scripts/export-pptx.sh` 一个文件改动 · 4 个 patch 区段。

### 测试状态

- ✅ 重跑 v5.4.1 输出:`/Users/raoyuli/Desktop/AI应用基础课-v5.4.1-修复.pptx`(19M · 1920×1080)
- ⏳ 等饶秋视觉验证

---

## v5.4.0 · 2026-05-12(PPTX 导出能力 · alpha 图片版)

**主线**:客户场景里有人**习惯用 PowerPoint / Keynote 改稿**,饶秋之前只能给 HTML 或 PDF — 给不出可编辑 .pptx。v5.4 加 `scripts/export-pptx.sh`,基于 Playwright 截图 + PptxGenJS 打包,**一键 HTML PPT → .pptx**。

**触发场景**:饶秋原话"确实有需要给别人导出 PPTX"。客户团队不会装 Chrome 看 HTML / 不会用 Cmd+P 导 PDF,**最熟的就是 PowerPoint 双击打开 .pptx**。

**评审过程**:看完 html-to-pptx 赛道 4 个 repo(dom-to-pptx / PptxGenJS / abdelkrimkr/html2pptx / SoorajVp/html-to-pptx),决定:
- **alpha 走"图片版" 路线**(Playwright 截图 + PptxGenJS 打包)— 100% 视觉保真,工程量小
- **beta 走"真可编辑"路线**(dom-to-pptx 解析 HTML → PPTX 真元素)— 工程量大 4-6h,等真有"客户要改文字"需求再做

### ✨ 新增

- **`scripts/export-pptx.sh`**(主脚本 · 8.6K · 借鉴 export-pdf.sh 同款架构)
  - Playwright headless Chromium 加载 HTML PPT
  - 内嵌 HTTP server 加载,Google Fonts CDN + 相对路径图片正常工作
  - **自动隐藏控件 + 关掉编辑模式 + 清掉 contenteditable**(避免截图带按钮 / 蓝色虚线边框)
  - 逐页截图 1920×1080 (deviceScaleFactor: 2 = 2x DPI,Retina 屏不糊)
  - PptxGenJS 创建 LAYOUT_WIDE (16:9) .pptx,每页嵌全屏 PNG
  - PPTX 元数据:title / author / company 自动填
  - 支持 `--compact` 参数(1280×720,文件小 50-70%)
  - macOS 自动 `open` PPTX(默认 Keynote 打开)

- **SKILL.md Surface 决策表加第 5 项 `pptx-editable`**
  - 触发关键词:"PPT 给客户改""PowerPoint""Keynote""可编辑""客户团队用"
  - 输出策略:跑 `scripts/export-pptx.sh`
  - 限制说明:每页是高清图片,**不能改文字**(beta 版做真可编辑)

- **SKILL.md frontmatter `surface` 数组加 `pptx-editable`**
- **SKILL.md frontmatter `version` 升级到 5.4.0**

### 🔁 改进

- 无(v5.4 是新能力,不动现有 v5.3 行为)

### 🛠️ 真实踩坑修复

无新增。

### ⛔ 弃用

无。

### 风险与回滚

- 备份位置:`99-归档-Archive/Rao-HTML-to-PPT-v5.3.0-2026-05-12-before-v5.4/`
- 回滚:`rm -rf <skill> && cp -R <备份> <skill>`
- **不影响现有 v5.3 行为**:只是新增脚本,不删/改任何老文件
- **首次跑会装 Playwright + PptxGenJS ≈ 200MB**(跟 export-pdf.sh 共享 Playwright,实际只增 PptxGenJS)

### 内部统计

| 文件 | v5.3 | v5.4 | 变化 |
|---|---|---|---|
| SKILL.md | 28 KB | 28 KB | 微调(+ pptx surface 行 / frontmatter 字段)|
| **scripts/export-pptx.sh** | 不存在 | **8.6 KB** | **全新** |
| 其他文件 | 不变 | 不变 | — |

### 实测状态

- ⏳ 待实测(下一步:跑 `export-pptx.sh` 在 AI 应用基础课 PPT 上,生成 .pptx 给饶秋验证)

### 技术路线记录(给以后参考)

**alpha 选 Playwright + PptxGenJS 的理由**:
- 工程量小:复用现有 export-pdf.sh 的 Playwright 启动 + HTTP server + 隐藏控件逻辑
- 视觉 100% 保真:截图是浏览器真实渲染,WebGL 背景 / 衬线字体 / 双主题 / 装饰圆 全部保留
- 兼容性最广:PowerPoint / Keynote / WPS / Google Slides 任何 .pptx 工具都能打开

**alpha 不选 dom-to-pptx 的理由**:
- 需要在浏览器里跑 JS 调用(架构跟 export-pdf.sh 不一致)
- "可编辑"实际意义有限(饶秋客户主要是"看 + 嵌入到自己 PPT",不是大改文字)
- 复杂度高,样式可能丢

**beta 候选**(等真有需求再做):
- 用 dom-to-pptx 把 HTML 解析成 PPTX 真元素(text box / shape / image)
- 客户能改文字 / 换图 / 调位置
- 工程量 4-6h,要测每个版式的转换效果

### 借鉴来源

- [gitbrent/PptxGenJS](https://github.com/gitbrent/PptxGenJS) MIT 协议 · 直接 npm 装来用(`pptxgenjs` 包)
- 学习它的 LAYOUT_WIDE 配置 + addImage data URI 用法
- Playwright 截图链路复用我们自己的 export-pdf.sh

---

## v5.3.0 · 2026-05-12(借鉴 html-anything · 文档与元数据升级)

**主线**:看了 [nexu-io/html-anything](https://github.com/nexu-io/html-anything)(2.6k stars Web app · 75 个 skill 模板 + 9 个 output surface),把它的 3 个核心设计理念**借鉴到 Rao-HTML-to-PPT**,作为 v5.3 文档与元数据升级。

**评审过程**:饶秋发了 URL → 我分析 → 列了 3 个值得借鉴 / 3 个不借鉴 → 饶秋同意"借鉴并升级 + 把 repo 加进他山之石"。

### ✨ 新增

- **SKILL.md frontmatter 结构化字段**(借鉴 html-anything 的 SKILL.md 协议)
  - 新增字段:`zh_name / en_name / emoji / category / scenario / surface / design_system / aspect_hint / modes / themes / version / tags / repo / license`
  - **价值**:
    - 给 AI 更精准的元数据(以后跨 skill 选择时有结构化信号)
    - 给读 SKILL.md 的人(包括合作讲师 / 学员)清晰导航
    - 跟开源 skill 生态对齐(html-anything / frontend-slides 等都用类似 frontmatter)
  - **风险**:Claude skill loader 当前只识别 name + description,**其他字段被忽略不影响运行**。已验证(skill 重载后 description 正确显示 v5.3)。

- **Surface 决策表**(SKILL.md Step -1 · 借鉴 html-anything 9 surface 概念)
  - 4 种目标 surface:
    - 🍎 **keynote-live**(现场演示 · 默认)
    - 📄 **pdf-archive**(留档归档)
    - 🌐 **html-share**(链接分享)
    - 💬 **wechat-article**(公众号转写 → md2wechat)
  - **价值**:同样内容,不同 surface 输出策略不同。先确认 surface 才能给对的输出(演示要双主题 + 动效,PDF 要静态 + 打印友好,链接要文件小)
  - **触发判断**:给 AI 明确的关键词信号(PDF/留档 → pdf-archive,链接/远程 → html-share,公众号 → 转给 md2wechat)

- **设计哲学正式沉淀**(README.md 新增 "设计哲学"章节)
  - 引用 html-anything 的 **"Markdown is the draft. HTML is what humans read."**
  - 5 条落地原则:单文件自包含 / 零依赖 / 跨平台兼容 / 现场就能改 / 多 surface 适配
  - **价值**:给 GitHub 看到 README 的人**第一眼明白这个 skill 不是玩具,是生产工具**

### 🔁 改进

- **README.md** 加 "设计哲学" 章节(8 行,放在 "解决什么问题"之前)
- **frontmatter description** 加上"v5.1 双主题 / v5.2 Inline Editing"等关键能力,让 AI 触发更准

### 🛠️ 真实踩坑修复

无新增(v5.3 是元数据/文档升级,不动代码)。

### ⛔ 弃用

无。

### 不借鉴的 3 个(避免过度工程化 · 记录决策)

| 不借鉴 | 原因 |
|---|---|
| **Next.js Web app 形态** | 我们 skill 形态更轻、更自然集成 Claude / Cowork,Web app 需要服务器 / 启动 / 维护,饶秋不需要 |
| **8 个 agent 支持(Claude/Cursor/Codex 等)** | 我们 Claude 生态特化,跨 agent 是 html-anything 产品定位,跟我们无关 |
| **75 个 skill 模块化** | 我们 12 版式打包在 1 个 skill,加载快、AI 选择简单。75 个分散 skill 适合"通用平台",不适合"个人特化 skill" |

### 内部统计

| 文件 | v5.2.4 | v5.3 | 变化 |
|---|---|---|---|
| SKILL.md | 25 KB | 28 KB | +3 KB(frontmatter 字段 + Step -1 Surface 表) |
| README.md | 8.3 KB | 9 KB | +0.7 KB(设计哲学章节) |
| 其他文件 | 不变 | 不变 | — |
| **下载到他山之石**:html-anything 28 MB · 1 个完整 repo + README + 75 skill 模板源码 | — | 全新 | 给未来调研 |

### 测试状态

- ✅ Claude 重载 skill 后 description 显示 v5.3(frontmatter 新字段被忽略不影响加载)
- ✅ SKILL.md / README.md 文档完整
- ⚠️ Surface 决策表对 AI 行为的实际影响**未在真实 PPT 生成时验证**(下次饶秋让 AI 做新 PPT 时观察)

---

## v5.2.4 · 2026-05-12(预防性 patch · Chrome 缓存)

**主线**:不是修 bug,是**预防**未来 Chrome 缓存 / BFCache 问题。

### 真实场景背景

饶秋报告 v5.2.3 在 **Chrome 普通模式仍翻不了页**,但:
- ✅ Safari 完全正常
- ✅ Chrome 隐身窗口完全正常

**根因**:**Chrome 扩展干扰**(隐身默认禁扩展)。常见嫌疑扩展:沙拉查词 / 沉浸式翻译 / Vimium / Tampermonkey 等。**这跟 skill 代码无关,是浏览器环境问题**。

但顺便给所有未来 PPT 加防御 — 即使 skill 代码没问题,Chrome 其他 quirks(BFCache / Service Worker)也可能引发类似"看起来代码没生效"现象。

### ✨ 新增(预防性)

- **no-cache meta 三件套**(给 file:// 协议浏览器一个明确信号):
  ```html
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
  <meta http-equiv="Pragma" content="no-cache">
  <meta http-equiv="Expires" content="0">
  ```

- **BFCache 复活防御**:
  ```javascript
  window.addEventListener('pageshow', function(e){
    if(e.persisted) window.location.reload();
  });
  ```
  从浏览器 history back/forward 复活时,强制重载页面,确保 Slideshow 干净初始化 + 不被 BFCache 的旧 DOM state 污染。

### 不修复的事

**Chrome 扩展干扰** — 不是 skill 能控制的范围。建议用户:
- **现场播放优先用 Safari**(macOS 自带,跟 Chrome 同源 WebKit,视觉效果一致,无扩展生态)
- 或在 Chrome 里临时禁扩展(扩展程序 → 关 → 重启 Chrome)

### Patch 范围

同 v5.2.3,4 个文件全部同步。

### 给 SKILL.md / 文档的提示

**Chrome 普通模式不工作时的诊断顺序**(写进 SKILL.md):
1. **试 Safari** — 同 macOS 自带,90% 直接 OK
2. **试 Chrome 隐身窗口**(Cmd+Shift+N)— 验证是不是扩展问题
3. **如果隐身 OK,普通不 OK** → 100% 是某个 Chrome 扩展,逐个禁
4. **如果隐身也不 OK** → 可能是真的 skill bug,跑 debug 命令贴日志

---

## v5.2.3 · 2026-05-12(hotfix · 关键修复)

**主线**:修 v5.2.2 之后仍然存在的翻页失效问题。

### 🛠️ 真实踩坑修复

#### 修复 1 · capture listener 漏了"必须编辑模式"硬条件

**现象**(用户原话):"我浏览器也重新关闭,然后重新再打开了。我也进行了 Cmd+Shift+R 强制刷新。然后就还是不行,你依然不能进行翻页。**但是我点其他的这些就是可以进行翻页的**,就只有刚刚你做过的那个内容是没办法进行翻页的。"

**关键线索**:别的 PPT 翻页 OK,只有加了 v5.2 inline editing 的 PPT 翻不了 → **100% 是我加的 capture listener 的 bug**。

**根因**:
- v5.2.1 capture listener 的逻辑:`e.target.isContentEditable === true` → stopPropagation
- **没检查 body 是不是编辑模式**
- 如果 stage 里**任何元素**残留 contenteditable(因为某次保存 bug / 旧数据 / Chrome 的 history restore 等),即使用户**没按 E 进编辑模式**,只要按键时 e.target 命中那个残留元素,事件就被 stopPropagation
- 模板的 Slideshow 翻页 JS 收不到事件,翻页失效
- 用户感觉"按方向键完全没反应",但其他 PPT 正常

**v5.2.2 试图修复**(restoreFromStorage 加 sanitize)— 只解决了 localStorage 那条路径,**没解决其他来源的残留 contenteditable**(比如浏览器 Form Restoration / 用户手动 inspect DOM 改过的状态等)。

**v5.2.3 真正修复**(防御性硬条件):
```javascript
document.addEventListener('keydown', function(e) {
  // v5.2.3:非编辑模式下完全不拦截
  // 即使 stage 里有残留 contenteditable,只要 body 没 edit-mode class,翻页 100% 正常
  if (!document.body.classList.contains('edit-mode')) return;
  // ...原有逻辑
}, true);
```

**核心改变**:从"看 target"改成"看 body 状态"。**body 是用户显式按 E 进编辑模式才会加 edit-mode class**,完全由用户控制,不受任何残留数据影响。

**为什么这是正确修复**:
- 非编辑模式 → capture listener 直接 return → 翻页绝对不受影响
- 编辑模式 + focus 在 contenteditable → 拦截方向键/空格(避免输入空格时误翻页)
- 编辑模式 + blur 在 body → 不拦截(因为 body 不是 contenteditable),翻页恢复

**Lesson learned**:加 capture listener 拦事件传播时,**必须用最严格的"应该生效条件"**,而不是"应该跳过条件"。前者默认安全(只在明确需要时拦截),后者默认不安全(可能误拦截)。

#### Patch 范围

同 v5.2.2,4 个文件全部同步。

#### 用户验证

打开任何 v5.2.3 PPT(强制刷新 Cmd+Shift+R)→ **直接按方向键 / 空格 / PageDown** → 立刻能翻页(不需要任何额外操作 / 不需要 reset localStorage)。

#### 演进总结(v5.2.x 的 3 个版本)

| 版本 | 修复 | 真正解决问题? |
|---|---|---|
| v5.2.1 | capture listener 阻止空格/方向键在编辑文字时翻页 | ✓ 编辑文字 OK,但**意外导致非编辑模式也翻不了**(因为没保护 body 状态) |
| v5.2.2 | restoreFromStorage 加 sanitize + PageUp/Down 白名单 | 部分(只修 localStorage 路径,其他残留路径没修) |
| **v5.2.3** | **capture listener 加 body.edit-mode 硬条件** | ✓✓ **从根上保证非编辑模式翻页不受影响** |

---

## v5.2.2 · 2026-05-12(hotfix)

**主线**:修 v5.2.1 之后用户立刻发现的下一个 bug — **打开 PPT 就翻不了页**。

### 🛠️ 真实踩坑修复

#### 修复 1 · 旧 localStorage 数据导致打开就处于"半编辑"状态

**现象**(用户原话):"我现在打开了之后没办法进行翻页了"。

**根因猜测**(高概率):
- 用户在 v5.2.0 测试期间,可能进过编辑模式,然后 Ctrl+S 保存(可能在某种 edge case 下,contenteditable 属性混进了 stage.innerHTML)
- 或者用户在某次编辑模式状态下关闭浏览器,localStorage 里残留了带 contenteditable 的 HTML
- 打开 PPT → `restoreFromStorage()` 把这段 HTML 塞回 stage → **所有内容元素带 contenteditable**(但 body 没 edit-mode class,用户看不出来)
- 用户按方向键 → `e.target.isContentEditable === true` → v5.2.1 capture listener stopPropagation → 翻页 JS 收不到

**修正**(防御性 sanitize):
```javascript
function restoreFromStorage() {
  // ... 原本逻辑
  stage.innerHTML = saved;
  // v5.2.2:强制清掉 contenteditable,即使 localStorage 里有
  stage.querySelectorAll('[contenteditable]').forEach(function(el) {
    el.removeAttribute('contenteditable');
    el.removeAttribute('spellcheck');
  });
}
```

**逻辑**:**用户必须显式按 E 才能进编辑模式**。任何从 localStorage 加载的数据都不能"自动带编辑状态"。这是防御性编程,确保未来其他 bug 也不会让用户"打开就翻不了页"。

#### 修复 2 · PageUp/PageDown/Home/End 在编辑模式下也允许翻页

**用户场景**:编辑模式下,虽然 contenteditable 拦截了空格 / 方向键(避免输入空格时误翻页),但用户**没有翻页通道**(除非按 Esc 退出编辑 / 点左下角 ← → 按钮)。

**修正**:capture listener 加白名单:
```javascript
// PageUp / PageDown / Home / End 即使在 contenteditable 上也允许翻页
if (e.key === 'PageDown' || e.key === 'PageUp' || e.key === 'Home' || e.key === 'End') return;
```

**逻辑**:这些键在文字编辑里几乎无意义(短内联文字),但用户期待"翻页"语义,放过去给 Slideshow。

**编辑模式下的完整翻页方式**:
1. **PageUp / PageDown 键**(v5.2.2 新)— Mac 上是 `Fn + ↑` / `Fn + ↓`
2. **Home / End 键**(v5.2.2 新)— Mac 上是 `Fn + ←` / `Fn + →`
3. **左下角 ← → 按钮**(模板自带)— 用鼠标点
4. **Esc 退出编辑** → 用空格 / 方向键(经典方式)

### Patch 范围

同 v5.2.1,4 个文件全部同步:
- `assets/template.html`(skill master)
- `桌面 .../03_培训课件/.../AI应用基础课-双主题切换版.html`
- `桌面 .../99_工具与模板/.../raoqiu-slide-template-v5.2.html`
- `桌面 .../99_工具与模板/.../样张-AI应用基础课-双主题切换版.html`

### 用户应对(如果还是翻不了)

**Step 1 · 强制清 localStorage**(最常见解决):
```javascript
// 浏览器 Console (F12)
window.raoqiuEdit.reset()
// 二次确认 → 清掉所有编辑历史 → 自动刷新 → 翻页恢复
```

**Step 2 · 如果还不行,debug 命令**:
```javascript
console.log({
  editMode: document.body.classList.contains('edit-mode'),
  contenteditableCount: document.querySelectorAll('[contenteditable]').length,
  active: document.activeElement.tagName + (document.activeElement.isContentEditable ? '(可编辑)' : '')
});
```
把输出贴给我看,继续诊断。

---

## v5.2.1 · 2026-05-12(hotfix)

**主线**:修一个 v5.2.0 发布后用户立刻发现的 bug — 编辑模式下,**按空格键想选中文字时,空格被翻页 JS 拦截,直接跳到下一页**。

### 🛠️ 真实踩坑修复

#### 修复 1 · contenteditable 元素上,空格 / 方向键被翻页 JS 抢走

**现象**(用户原话):"双击文字了之后可以修改,但是我一旦按空格键去选中这个文字的时候,它就会跳转到下一张。"

**根因**:
- 模板自带的翻页 JS(`class Slideshow`)在 `document` 上注册了 keydown listener,**空格 / 方向键 / PageDown** 等触发翻页
- v5.2.0 加的 inline editing JS 内部判断了 `e.target.isContentEditable` 让自己 return,**但没阻止事件继续冒泡传给 Slideshow**
- 用户在 contenteditable 里按空格 → 浏览器原生处理(输入空格)+ 事件冒泡到 Slideshow → 触发翻页

**修正**(三层保险,4 个文件统一 patch):
1. **新加 capture 阶段 keydown listener**(注册在 `document` 上,第三参数 `true`)
2. 检测 `e.target.isContentEditable` → 是 → `e.stopPropagation()` 阻止冒泡
3. **保留 Ctrl+S / Esc** 让 inline edit 自己的 handler 处理(保存 + 退出编辑模式)
4. 其他所有键(空格 / 方向键 / 字母 / 数字 / Enter / Backspace 等)→ 浏览器原生 contenteditable 接管输入,**翻页 JS 完全收不到**

**关键代码**(放在 setup() 函数末尾,inline edit JS 块内):
```javascript
document.addEventListener('keydown', function(e) {
  if (!e.target || !e.target.isContentEditable) return;
  if ((e.metaKey || e.ctrlKey) && (e.key === 's' || e.key === 'S')) return;
  if (e.key === 'Escape') return;
  e.stopPropagation();
}, true);  // capture phase 最早接收
```

**为什么是 capture 阶段**:
- 现有 Slideshow keydown listener 是默认的 bubble 阶段
- capture 阶段比 bubble 早执行
- 在 capture 阶段 stopPropagation,事件不会冒泡到 Slideshow 的 listener
- 同时不影响浏览器原生 contenteditable 处理(那是浏览器内核做的事,跟 JS listener 无关)

**为什么不直接改 Slideshow JS**:
- 那样要动模板自带的翻页引擎代码,影响范围大
- capture listener 是"打补丁"式修复,对原 JS 0 入侵
- 升级 Slideshow 时不冲突

**自检**:打开任意 v5.2.1 PPT → 按 E 进编辑 → 点文字 → 按空格 → 应该输入空格,**不翻页**

**Patch 范围**(4 个文件):
- `assets/template.html`(skill master)
- `桌面 .../03_培训课件/AI应用基础课-9种风格选择/AI应用基础课-双主题切换版.html`
- `桌面 .../99_工具与模板/HTML课件设计模板/raoqiu-slide-template-v5.2.html`
- `桌面 .../99_工具与模板/HTML课件设计模板/样张-AI应用基础课-双主题切换版.html`

### 内部统计

| 文件 | v5.2.0 | v5.2.1 | 变化 |
|---|---|---|---|
| assets/template.html | 80 KB | 84 KB | +4 KB(8 行 capture listener + 注释) |
| 其他文件 | 不变 | 不变 | — |

---

## v5.2.0 · 2026-05-12

**主线**:解决用户实际痛点 — "做完 HTML PPT 后没办法直接修改内容,要回 VS Code 翻源码改,太麻烦"。沉淀 inline editing 能力到模板,**右上角"编辑 · E"按钮 / E 键快捷键**,点任意文字直接改 + Ctrl+S 保存到 localStorage。

**触发场景**:饶秋发现做完 v5.1 课件后,改一个字也要打开源码定位 `<section>`。要求像 Keynote / PowerPoint 那样所见即所得。

**评审过程**:GitHub 调研了 4 个 HTML 编辑器(archlizheng/frontend-slides-editable 176 stars · sonnyp/sliders 1 star · GeorgioWan/Oi 已死 · slides.com 商业 SaaS),最匹配的 frontend-slides-editable 要求特定 DOM 结构(我们 v5.1 不兼容)。决策:**借鉴它的 contenteditable + localStorage 机制,沉淀到 v5.2 模板**(方向 A),而不是装第三方工具(方向 B)。

### ✨ 新增

- **Inline Editing 内置**(template.html 加 ~180 行 CSS + ~150 行 JS)
  - 右上角"**编辑 · E**"按钮(在"纸 · 墨"按钮之前)
  - **E 键快捷键**启动 / 退出(跟 T/M/O/F 同款键位风格)
  - 编辑模式下,内容文字显示彩色虚线边框:
    - McKinsey 蓝默认 → 蓝色边框
    - Paper 主题 → 红色边框(`#c41e3a`)
    - Dark 主题 → 金色边框(`#d4a574`)
  - hover 加深 / focus 显示实线 + 浅色背景
  - 浮动指示条:"编辑模式 · 点文字直接改 · Ctrl+S 保存 · E 退出"(脉冲点点动画)
  - 已保存 toast:"✓ 已保存到本地"

- **可编辑元素范围**(允许动 · 30+ 选择器):
  - 标题:`cover h1` / `chapter h1` / `ending h1` / `page-title` / `page-subtitle`
  - 卡片:`card h3` / `card p` / `card-num`
  - 数据:`metric .v` / `metric .l` / `big-number .v` / `big-number .lead`
  - 引用:`big-quote .quote` / `insight-body`
  - 流程:`process-flow .step h4/p` / `matrix-2x2 .quadrant`
  - 等等

- **保护范围**(不可编辑 · 避免误改):
  - 控件 UI(ctrl-bar / nav-arrows / page-num / edit-banner / save-toast)
  - page-meta(模块标签 + 页码 chrome,这是结构 metadata)
  - 装饰元素(章节扉页 deco-num / hero 发光圆 / FBM 背景)

- **localStorage 持久化**(`raoqiu-deck-html-edit-<path>` key):
  - Ctrl+S / Cmd+S 触发保存(整个 stage 区域的 HTML)
  - 自动剥离 contenteditable / spellcheck 属性后存
  - 加载时自动恢复(刷新 / 重开浏览器延续)
  - 加载时自动剥离编辑状态(避免 contenteditable 串到非编辑模式)

- **导出 + 恢复 API**(暴露到 `window.raoqiuEdit`):
  - `window.raoqiuEdit.export()` → 下载干净的修改版 HTML
  - `window.raoqiuEdit.reset()` → 清 localStorage,恢复出厂内容(带 confirm)
  - `window.raoqiuEdit.enter()` / `.exit()` / `.save()` 也对外暴露

- **键盘快捷键扩展**(`E` 加入模板交互列表):
  - 现在:M(大纲)/ F(全屏)/ O(概览)/ **T(主题)**/ **E(编辑)** / Cmd+/-(缩放)/ Ctrl+S(保存编辑)/ Esc(退出编辑)
  - SKILL.md 第 7 条"不动模板的功能"已更新

### 🔁 改进

- **SKILL.md 加原则 7.5 · Inline Editing 内置**:完整说明怎么用 + 可编辑/保护范围 + 导出 API + 致敬来源
- **edit-toggle 按钮放最前**(ctrl-bar 顺序:编辑 E / 纸·墨 / 概览 O / 大纲 M)— 因为编辑最常用

### 🛠️ 真实踩坑修复

无新增(v5.2 是增量功能 · 没破老坑)。

### ⛔ 弃用

无。v5.1 双主题切换完全保留 · 跟 inline editing 互补。

### 风险与回滚

- 备份位置:`99-归档-Archive/Rao-HTML-to-PPT-v5.1.0-2026-05-12-before-v5.2/`
- 回滚命令:`rm -rf <skill> && cp -R <备份> <skill>`
- **向后兼容**:用户没启动编辑模式时 = 跟 v5.1 行为完全一致,不影响只看 PPT 的体验
- **localStorage 隔离**:每个 PPT 用自己的 `location.pathname` 做 key,**不同 PPT 的编辑互不干扰**

### 内部统计

| 文件 | v5.1 | v5.2 | 变化 |
|---|---|---|---|
| SKILL.md | 24 KB | 26 KB | +2 KB(原则 7.5 Inline Editing) |
| assets/template.html | 73 KB | 80 KB | **+7 KB**(inline editing CSS + JS + 浮动 UI) |
| references/*.md | 不变 | 不变 | — |
| scripts/*.sh | 不变 | 不变 | — |

### 测试状态

- ✅ 模板 inject 完成(title v5.2 / edit-toggle 按钮 / edit-banner / save-toast / raoqiuEdit API 全部就位)
- ⚠️ 真实 PPT 上未实测(下一步:patch 已有的 AI 应用基础课-双主题切换版.html · 让用户立刻能测)
- ⚠️ 跨浏览器兼容性未实测(预期 Chrome/Safari/Firefox 都 OK,contenteditable 是 HTML5 标准)
- ✅ 跟双主题切换不冲突(CSS 用 `body.edit-mode[data-theme="X"]` 分主题适配边框色)

### 借鉴来源(透明披露)

- **[archlizheng/frontend-slides-editable](https://github.com/archlizheng/frontend-slides-editable)** 176 stars
  - 思路:E 键编辑模式 / Ctrl+S 保存 / localStorage 持久化 / 导出干净 HTML
  - 不是代码 fork,是机制借鉴,从零实现适配 v5.1 双主题 + 12 版式
- **[zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides)** 17.1k stars
  - 思路:浏览器内编辑文字 / 自动保存 / 不依赖 npm/build
- **HTML5 标准 `contenteditable` 属性**
  - 浏览器原生能力,零依赖,跨平台

---

## v5.1.0 · 2026-05-12

**主线**:把饶秋实测后选定的两个偏好风格(Paper & Ink 纸墨白 + Dark Botanical 暗色)沉淀进 v5 模板,任何 PPT 自动有右上角"纸 · 墨"切换 + T 键快捷键。

**触发场景**:饶秋说"我有时候会根据现场的情景来把它切换成黑白的风格" — 一份 PPT 现场切换主题,白底用于明亮投影 / 学员人多,暗底用于 VIP 课 / 晚上分享 / 灯光暗。

**评审过程**:v5.0.0-beta 发布后,饶秋实测 9 个风格库后选定 Paper & Ink + Dark Botanical 两个最爱,要求沉淀到 skill。

### ✨ 新增

- **双主题切换机制**(template.html 加 ~200 行 CSS + ~40 行 JS)
  - `[data-theme="paper"]` → Paper & Ink 纸墨白底衬线
  - `[data-theme="dark"]` → Dark Botanical 暗色艺术
  - 无 `data-theme` → McKinsey 深蓝(v5.0 默认 · 向后兼容)
  - 切换按钮自动出现在右上角 ctrl-bar,在概览/大纲按钮之前
  - **T 键快捷键**切换(跟 M/F/O 同款键位风格)
  - **localStorage 记忆**:`raoqiu-deck-theme`,刷新延续

- **Paper & Ink 风格卡片**(design-system.md)
  - Vibe / Layout / Typography / Colors / Signature Elements 5 维度
  - 关键字体:Cormorant Garamond italic + Noto Serif SC
  - 强化 FBM 纸感纹理(opacity 0.8)
  - Big Quote 巨大装饰引号

- **Dark Botanical 风格卡片**(design-system.md)
  - 暗黑 #0f0f0f + 米色 #e8e4df + 陶土金 #d4a574
  - Hero 页发光圆装饰(粉 + 金 radial-gradient blur)
  - 关闭 FBM 背景(暗底不需要纸感)

- **衬线字体白名单扩展**:加入 **Cormorant Garamond**(原只有 Noto Serif SC + Fraunces)
  - raoqiu-check.sh / checklist.md / design-system.md 三处同步更新

### 🔁 改进

- **SKILL.md 核心原则加 #5 "双主题切换"**:明确推荐生成新 PPT 时给 body 加 `data-theme="paper"` 作为默认,严肃客户提案保留 McKinsey 蓝(去掉 data-theme)
- **原则编号顺延**:原 #5 / #6 / #7 顺延到 #6 / #7 / #8
- **T 键写入模板自带交互清单**(M / F / O / **T** / Cmd+/- / 拖拽 / hash / 触屏 / PDF)

### 🛠️ 真实踩坑修复

无新增踩坑(v5.1 都是增量功能)。

### ⛔ 弃用

无。v5.0 的 McKinsey 蓝默认**保留**作为向后兼容 + 严肃场景选项,不弃用。

### 风险与回滚

- 备份位置:`99-归档-Archive/Rao-HTML-to-PPT-v5.0.0-beta-2026-05-12-before-v5.1/`
- 回滚命令:`rm -rf <skill> && cp -R <备份> <skill>`
- **向后兼容**:旧 PPT(没 data-theme)依然显示 McKinsey 蓝,完全不破

### 内部统计

| 文件 | v5.0-beta | v5.1 | 变化 |
|---|---|---|---|
| SKILL.md | 23 KB | 24 KB | +1 KB(原则 #5 双主题章节) |
| references/design-system.md | 21 KB | 24 KB | +3 KB(Paper + Dark 风格卡片) |
| references/checklist.md | 21 KB | 21 KB | 微调(白名单字符串) |
| assets/template.html | 67 KB | 75 KB | **+8 KB**(双主题 CSS + 切换按钮 + JS) |
| scripts/raoqiu-check.sh | 8.5 KB | 8.5 KB | 微调(白名单 grep pattern) |

### 测试状态

- ✅ 双主题切换实测通过(`/Users/raoyuli/Desktop/AI应用基础课-双主题切换版.html` demo · 用户验证 OK)
- ⚠️ template.html 新版本未在新生成的 PPT 上实测(下次饶秋让 AI 生成新 PPT 时验证)
- ✅ 现有 9 风格库不受影响(每个风格自己 inline 自己的 CSS,跟模板无关)
- ✅ McKinsey 蓝 旧 PPT 向后兼容(没 data-theme 走原默认路径)

---

## v5.0.0-beta · 2026-05-11

**主线**:alpha 解决了"PPT 模板系统"层的 6 条核心改造,beta 解决"全链路工程化"层的 5 条增强 — 把 Rao-HTML-to-PPT 从"做一份 PPT"升级到"端到端工程化的 HTML PPT 工具"。

**核心新能力**:
- **Phase 0 检测模式**(新建 vs 大纲转换 vs 改老课件)— 不再默认"从零做"
- **Mode C 增强已有 PPT**(改老课件场景首次被覆盖)— 饶秋实战里"改比做多 3 倍"的场景终于有专属流程
- **Brand Style 卡片**(客户色 → 客户记忆 v2.0)— 不止 hex 值,还包括 Tone / 合规 / 历史
- **Defend Choice**(节奏表带选版式理由)— AI 选版式必须解释为什么
- **AskUserQuestion 两套并存**(一次问完 + 顺序问兜底)

### ✨ 新增

- **Citation 强制 · P0 #0d**(checklist.md · 来自 academic-pptx)
  - 借用数据**必须**有 source(`.insight-source` / `.big-number .source` / 新增 `.data-source` / `.data-source-block`)
  - 豁免清单:常识陈述 / 自有产品数据 / 反问句 / Big Quote 金句
  - source 标准格式:`SOURCE / 机构 · 时间`(不写 URL)
  - 自检命令:逐个数字问"哪来的"

- **`.data-source` / `.data-source-block` CSS 类**(template.html)
  - 通用数据来源标签,metric-row / split / callout / card 都能用
  - 自动加前缀 `SOURCE / `,mono 字体 + 灰色
  - 块级版本带顶部分隔线,跟内容隔开

- **Defend Choice 机制**(SKILL.md Step 1.7 · 来自 mckinsey-pptx)
  - 节奏表加"选这个版式的原因"列
  - AI 必须**写出选择理由**(具体到数字 / 内容形状 / 节奏需求)
  - 用户在节奏表对齐时就能发现"选错版式",在大纲层就改完
  - 避免做完整份 HTML 才发现问题 → 大幅省 token

- **Brand Style 卡片机制**(references/brand-styles/_template.md · 来自 power-design Brand DNA)
  - 客户色 v2.0 — 不只 hex,包括 Colors / Typography / Tone / Compliance / Tracking 5 维度
  - 每个客户单独一份 `{简称}-brand.md`
  - AI Step 1 第 4 问自动加载 brand-style 卡片
  - 培训完成后回填 Tracking 表(学员数 / 满意度 / 30 天活跃)
  - 半年后回访同客户,所有约束自动记起

- **Phase 0 检测模式**(SKILL.md 顶部 · 来自 frontend-slides)
  - 不再默认"新建",先判断模式
  - Mode A 新建 / Mode B 大纲转换(跳澄清直接节奏规划)/ Mode C 增强已有
  - 触发关键词清单:`做一份 / 帮我搭` → A,`贴大纲 / 按这个做` → B,`改一下 / 加一页 / 把第 5 页换成` → C

- **Mode C 增强已有 PPT 专属流程**(SKILL.md · v5-beta 重点)
  - 5 步骤:盘点现状 → 检查密度 → 用户请求映射 → 主动 reorganize → 自检脚本
  - Step 1 盘点:grep 命令模板,数清楚现在多少 hero / 多少信息页
  - Step 2 密度检查:对照 layouts.md 硬规则,超量直接告知用户
  - Step 3 映射表:6 种常见请求 → 对应修改方案
  - Step 4 主动 reorganize:不等用户说,发现要溢出就自动拆页并告知
  - Step 5 跑 raoqiu-check.sh 自检

- **AskUserQuestion 两套并存**(SKILL.md Step 1 · 来自 frontend-slides)
  - **模式 1**:AskUserQuestion 一次性问 6 个(填表式 · 快 5-10 倍)
  - **模式 2**:顺序对话(兜底 · 当平台不支持 AskUserQuestion 时)
  - SKILL.md 给出完整 AskUserQuestion 调用模板,header / options / multiSelect 全配齐
  - **未来测试**:在 Cowork / Claude.ai 网页 / Claude Code 各自测一次,确认哪些环境支持

### 🔁 改进

- **SKILL.md 大幅扩写**(13K → 22K · +9K)
  - 新增 Step 0 检测模式 + Mode C 专属流程(整段)
  - Step 1 第 4 问从"客户色"扩展到"Brand Style 卡片"
  - Step 1 问的方式分两套:AskUserQuestion + 顺序问
  - Step 1.7 节奏表加 Defend Choice 列(从 3 列变 4 列)

- **节奏规划质量提升**:节奏表带"选版式的原因",理由空 = 没想清楚 → 反向倒逼 AI 在规划阶段就深入思考

### 🛠️ 真实踩坑修复(回顾,v5.0.0-alpha 已修)

无新增踩坑(beta 都是新增功能,没踩老坑)。

### ⛔ 弃用

- 无(beta 没弃用任何旧功能,只是把 v4 的"客户色"简化机制扩展到 Brand Style,v4 机制依然兼容 — 用户可以只填 colors 那一段,跟 v4 完全等价)

### 风险与回滚

- 备份位置(v4 完整快照):`99-归档-Archive/Rao-HTML-to-PPT-v4-2026-05-11-before-v5/`
- AskUserQuestion 兼容性:**未在所有平台实测**,SKILL.md 已写明"如果运行环境不支持就退回顺序对话"作为兜底
- Brand Style 卡片机制对旧用户:**完全向下兼容**,旧"只填客户色 hex"工作流依然可用(选 C "用默认 + 客户色")

### 内部统计

| 文件 | v5-alpha | v5-beta | 变化 |
|---|---|---|---|
| SKILL.md | 13.4 KB | **22 KB** | +9 KB(Phase 0 + Mode C + Brand Style + AskUserQuestion + Defend Choice) |
| references/checklist.md | 16.5 KB | **21 KB** | +4.5 KB(Citation P0 #0d) |
| references/design-system.md | 17 KB | 19 KB | +2 KB(字号 17→20 + DO NOT USE 微调,但主要 alpha 已加) |
| **references/brand-styles/_template.md** | 不存在 | **4.2 KB** | **全新**(Brand Style 模板) |
| assets/template.html | 62 KB | 63 KB | +1 KB(.data-source 类) |
| scripts/ | 14.6 KB | 14.6 KB | 无变化 |

### 测试状态

- ✅ raoqiu-check.sh 跑 v5 sample:13 通过 / 0 不通过 / 0 警告
- ✅ SKILL.md 内容 grep 验证 5 项 beta 改造都在(Defend Choice 3 / Mode C 8 / Brand Style 7 / AskUserQuestion 4 / Citation P0 1)
- ⚠️ Mode C 流程**未在真实老 PPT 上验证**(下次饶秋要改老课件时实测)
- ⚠️ Brand Style 卡片机制**未填具体客户**(等饶秋下次给真实客户做培训时填第一份)
- ⚠️ AskUserQuestion 跨平台**未实测**(SKILL.md 已写两套并存,实际跑时哪套生效要看运行环境)

### 还没做的(保留作参考,详见 ROADMAP.md)

5 条"想做但 v5 不做"的功能已经独立成 [ROADMAP.md](ROADMAP.md):
- R1 · Show Don't Tell 视觉选项(生成 3 个预览)
- R2 · Vercel 一键部署集成
- R3 · PPTX → HTML 转换
- R4 · 12 主题系统(多风格选择器)
- R5 · URL 提取 Brand DNA(Firecrawl)

每条都带"什么时候可能想做"的触发场景。这 5 条饶秋的态度:"以后可能想做",**保留在 ROADMAP**,不删。

---

## v5.0.0-alpha · 2026-05-11

**主线**:通读了 5 个同行 skill 源代码(详见 `02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/通读笔记-2026-05-11.md`)后启动的"全链路工程化"升级。alpha 包含 6 条必做改造,beta 留给 6 条推荐改造(后续做)。

**评审过程**:写了 [PROPOSAL-v5(已归档)](../../../99-归档-Archive/Rao-HTML-to-PPT-proposals/PROPOSAL-v5-2026-05-11-approved-implemented.md),饶秋评审通过(A1 + B1 + C 全同意 + D1),先备份 v4 到 `99-归档-Archive/Rao-HTML-to-PPT-v4-2026-05-11-before-v5/`,再启动 alpha。

### ✨ 新增

- **Ghost Deck Test**(checklist.md P0 #0c · 来自 academic-pptx)
  - 强制规则:每页标题是"完整句子陈述结论",不是 Topic 标签
  - 反例清单:`目录` / `背景` / `现状分析` / `我们的方案` / `Thank You` / `Q&A` 全部禁用
  - 自检方法:grep 提取所有标题串读,只看标题能讲完整个故事 = 通过
  - 反向自检:让没看过 PPT 的人读标题串,他能复述大意 = 通过

- **DO NOT USE 黑名单具体化**(design-system.md · 来自 frontend-slides)
  - 字体名:`Inter / Roboto / Arial / 微软雅黑 / Songti / Playfair / Bodoni / Cormorant`
  - hex 值:`#6366f1 / #8B5CF6 / #A855F7 / #7B68EE / #9400D3 / #9333EA`
  - 改造前:"❌ 不要 AI 风"(AI 凭感觉判断,经常踩雷)
  - 改造后:具体字体名 / hex 值(`grep -i` 可机器验证)

- **5 维度风格卡片**(design-system.md · 来自 frontend-slides STYLE_PRESETS)
  - 把饶秋 McKinsey 风从散文式描述改成统一 5 维度结构:**Vibe / Layout / Typography / Colors / Signature Elements**
  - AI 读规则时不漏项

- **设计原则学术引用 + 量化阈值**(design-system.md · 来自 power-design)
  - 20 条核心原则,每条带研究来源(Tufte / Reynolds / Bringhurst / WCAG / Miller / Cowan / 巴巴拉·明托 / McKinsey Quarterly 等)
  - 每条带量化阈值(白空间 ≥40% / 行长 ≤60 / 字号比例 1.25-1.618 modular scale / WCAG ≥4.5:1 / 8pt 网格 / 数据墨水比 ≥80%)
  - 单独章节"学术引用完整来源清单",培训现场被问"为什么这条规则"可以直接引用

- **Viewport Fitting Base CSS**(template.html · 来自 frontend-slides viewport-base.css)
  - `.slide { overflow: hidden }`(严格 viewport fitting,不允许内部滚动)
  - 宽容开关 `<body data-strict-viewport="off">`(老课件过渡用)
  - 6 个 `--vp-*` clamp() 工具变量(`--vp-title` / `--vp-h2` / `--vp-body` / `--vp-padding` 等),给新 PPT 用,多屏自适应
  - `prefers-reduced-motion` 无障碍支持(用户系统开"减少动效"时自动尊重)
  - 4 档 viewport 断点(700/600/500px height + 600px width 手机竖屏):自动缩 padding / 缩字号 / 隐藏装饰 / 卡片单列堆叠
  - 图片硬限制 `max-height: min(50vh, 400px)`
  - `scroll-snap-type: y mandatory` fallback(JS 翻页失效时鼠标滚轮也能 snap)

- **PDF 导出脚本** `scripts/export-pdf.sh`(来自 frontend-slides export-pdf.sh)
  - Playwright headless Chromium 截图 → 合并 PDF
  - 内嵌 HTTP server 加载,Google Fonts CDN + 相对路径图片正常工作
  - 自动隐藏控件(`.ctrl-bar` / `.nav-arrows` / `.page-num` / `#hint` 等)
  - 支持 `--compact` 参数(1280×720 vs 1920×1080,文件小 50-70%)
  - macOS 自动 `open` PDF
  - 用法:`bash scripts/export-pdf.sh deck.html [out.pdf] [--compact]`

- **一键自检脚本** `scripts/raoqiu-check.sh`(来自 clean-slides `pptx validate`)
  - 5 个 Block 自动检查:结构(P0) / 字体(P0) / 颜色(P0) / 内容(P0/P1) / v5 模板特性信息
  - 13 项硬检查 + Ghost Deck Test 标题串读输出
  - 退出码 0 = 全过 / 1 = 有 P0 未通过(可接 CI / 预提交 hook)
  - 用法:`bash scripts/raoqiu-check.sh deck.html`

### 🔁 改进

- **checklist.md 末尾自检清单加 5 条 Action Title 勾选**:
  - 标题是"完整句子陈述结论"
  - 没有 "目录" "背景" "现状" 等 Topic 标题
  - 没有 "Thank You" / "Q&A" 结尾页
  - Ghost Deck Test 通过
  - 找没看过 PPT 的人复述能通过

- **design-system.md 字体分工章节**:加 5 维度结构 + 学术引用 + 量化阈值清单(从 4KB → 8KB → 14KB,信息密度大幅提升)

### 🛠️ 真实踩坑修复

#### 修复 1 · raoqiu-check.sh 在 macOS BSD grep 下的 emoji unicode 字符类 bug

**现象**:首次写完脚本跑样张,emoji 检测报 137 次(实际样张里没有 emoji)。
**根因**:BSD grep(macOS 默认)对 `[🎯💡✅]` unicode 字符类支持不稳,会把中文字符也当 emoji。
**修正**:用 `grep -cF -e '🎯' -e '💡' ...` fixed-string + 多 pattern,加 `tr -d '\n' -d ' '` 清理输出。
**自检**:跑样张应该报 emoji = 0。

#### 修复 2 · Songti SC 在 fallback 列表里被误判为"禁用衬线"

**现象**:`grep -ciE "Songti SC[^,]"` 把字体 fallback 列表(`"Noto Serif SC", "Songti SC", "STSong"`)里的 Songti SC 也算违规。
**根因**:Songti SC 作为 fallback 永远显示不出来(因为 Noto Serif SC 优先),不该报错。
**修正**:从黑名单去掉 Songti SC,只检测真正禁用的 Playfair / Bodoni / Cormorant。

#### 修复 3 · 基准字号 17px 太小,培训现场看不清(用户反馈直接修)

**现象**:饶秋测 v5-alpha 样张,反馈"字体真的太小了,要放大到很大才能看得清楚。一旦放大了之后,就会把整个排版完全挤压的不太对劲了"。
**根因**:v4 用 `:root { font-size: 17px }` 是"网页阅读"的基准(Medium / 微信公众号舒适值),不是"投影演讲"的基准。同行的 power-design / academic-pptx / Reynolds《演说之禅》共识是 **演讲场景正文 ≥ 24px**。我们当初按 web 习惯定 17px 是判断失误。
**修正**:
- `template.html` line 38:`:root { font-size: 17px }` → `20px`
- 所有 rem 字号等比例放大 17.6%(rem 是相对单位,改基准全跟着变)
- padding 也用 rem,等比放大,布局不会被挤压
- `design-system.md` 字号表更新像素值,加完整章节"为什么是 20px 不是 17px"带业界共识引用
**为什么是 20 px 不直接 24 px**:24 px 在笔记本屏(13/15 寸)预览过大,饶秋两栖场景(投影 + 客户回看)要兼顾。20 px 是兼顾点。
**自检**:`grep -n "font-size: 20px" template.html` 必须 hit;视觉验证:笔记本预览舒适 + 投影上字大可读。
**未来调整**:大投影场景特别需要更大字时,改 `:root` 一行到 22-24px 即可,所有 rem 自动跟着变。

### ⛔ 弃用

- 无(alpha 没弃用任何旧功能)

### 风险与回滚

- 备份位置:`99-归档-Archive/Rao-HTML-to-PPT-v4-2026-05-11-before-v5/`
- 回滚命令:`rm -rf Rao-HTML-to-PPT && cp -R <备份位置> Rao-HTML-to-PPT`
- viewport fitting 宽容开关:`<body class="theme-mckinsey" data-strict-viewport="off">`(允许 slide 内滚动,给老课件过渡用)

### 内部统计

| 文件 | v4 | v5-alpha | 变化 |
|---|---|---|---|
| SKILL.md | 13.4 KB | 13.4 KB | 无变化(等 beta 升级) |
| references/design-system.md | 8.0 KB | 14.4 KB | +6.4 KB(5 维度 + 学术引用 + DO NOT USE 具体化) |
| references/checklist.md | 13.7 KB | 16.5 KB | +2.8 KB(Ghost Deck Test P0 #0c) |
| references/layouts.md | 14.5 KB | 14.5 KB | 无变化 |
| assets/template.html | 59 KB | 62 KB | +3 KB(viewport-base + 宽容开关) |
| scripts/ | 不存在 | 14.6 KB | **全新**(export-pdf.sh + raoqiu-check.sh) |

### 还没做的(留给 v5.0.0-beta)

详见 [PROPOSAL-v5(已归档)](../../../99-归档-Archive/Rao-HTML-to-PPT-proposals/PROPOSAL-v5-2026-05-11-approved-implemented.md) §2 第二批:
- Phase 0 检测模式 + Mode C 增强已有
- Subagent Defend Choice
- Brand Style 卡片机制
- AskUserQuestion 一次问完
- Citation 强制
- (可选)更多

### 测试状态

- ✅ raoqiu-check.sh 跑 v4 样张:13 通过 / 0 不通过 / 0 警告(预期 — 样张是 v4 生成的,但符合 v5 检查规则)
- ⚠️ export-pdf.sh 未在真实 PPT 上验证(首次跑会装 Playwright + Chromium,150MB,~30-60s)
- ⚠️ v5 viewport-base CSS 未在真实样张上验证(下一步:用 v5 模板重新生成样张确认视觉不破)

---

## v4.0.0 · 2026-05-11

**主线**:借鉴归藏 `guizang-ppt-skill` 的工程纪律,把饶秋的视觉硬约束补强到"防呆"层级。新增 2 个版式,衬线字体边界化使用,加 WebGL 纸感背景。同一天里修了 3 个真实踩坑(衬线字体名搞错 / 信息页漏 .page 包装 / page-footer 跟翻页按钮遮挡)。

### ✨ 新增

- **Big Number 版式**([layouts.md](references/layouts.md) #11):整页一个超大数字 + 一句注解。比 metric-row(3 个数字小字号)震撼。用量 ≤3 张。
- **Big Quote 版式**([layouts.md](references/layouts.md) #12):整页一句金句 + 出处。比 Key Insight 轻(不带数据,纯主张)。用量 ≤2 张。
- **衬线字体支持**([design-system.md](references/design-system.md) "字体分工"):Noto Serif SC + Fraunces 两套已加载到模板。**只用在 5 处重音**:封面 h1 / 章节扉页 h1 / Key Insight 大字 / Big Quote / Big Number 数字。其他位置(卡片/正文/内页 page-title)仍是无衬线。
- **WebGL FBM 纸感背景**([design-system.md](references/design-system.md) "WebGL 背景"):用 SVG feTurbulence 实现,纯 CSS 不耗 GPU。**默认关闭**,加 `<body data-bg="fbm">` 触发。打印时自动隐藏。
- **独立 checklist.md**([references/checklist.md](references/checklist.md)):从无到有,27 条规则按 P0-P3 分级。每条"现象 + 根因 + 做法"三段式。末尾完整勾选清单 + grep 自检命令。
- **CHANGELOG.md**(就是这份):变更记录起点。以后每次大改都在这里加一段。

### 🔁 改进

- **SKILL.md 重写**(6KB → 13KB):工作流从 5 步细化到 8 步(需求澄清 → SCQA 大纲 → 节奏规划 → 动手前预检 → 填内容 → 自检 → 输出 → 迭代)。
- **6 问需求澄清表**(替代之前的 4 条 bullet):每问带"为什么要问"。**时长 → 页数换算固化**(15 min ≈ 10 页 / 30 min ≈ 20 页 / 45 min ≈ 25-30 页)。
- **SCQA 叙事弧大纲**(SKILL.md Step 1.5):用户没大纲时不用 AI 现编,按 Situation → Complication → Question → Answer → Takeaway 5 段搭骨架。这是真正麦肯锡咨询报告的标准结构。
- **页面节奏规划**(SKILL.md Step 1.7):动手前画"页面节奏表",每页明确版式 + 是否 hero。硬规则:重音页 ≤1/3 / 弱拍 ≥2/3;25 页以上至少 3 个章节扉页;连续 ≥4 页卡片网格不允许。
- **动手前预检步骤**(SKILL.md Step 2,本次最重要):写任何 `<section>` 前必须 Read template.html 的 `<style>` 块,确认所有要用的类已定义。最易遗漏的 13 个类名清单列在 SKILL.md 里。
- **layouts.md 头部加版式分类表**:每个版式标注是 hero / 信息 / 操作,以及 HTML 结构是否需要 `.page` 包装。
- **资源加载顺序建议**(SKILL.md 末尾):分阶段读哪个文件,省 token。
- **决策规则化**(SKILL.md "决策规则"):#7 Pipeline 动效、#8 中文标题断行,都写成"何时启用 / 何时关闭"决策树,让 AI 自行判断,不用每次都问。

### 🛠️ 真实踩坑修复

#### 修复 1 · 衬线字体名一开始搞错了

**v4 初稿写错**:design-system.md / checklist.md / SKILL.md 三处都写"用 Source Han Serif SC + Playfair Display,禁用 Noto Serif SC"。
**真相**:Noto Serif SC **就是** Source Han Serif SC(Google 和 Adobe 对同一字体的不同发行名,字怀完全一致)。Playfair Display 也不用,改用模板已加载的 **Fraunces**(Variable Font,更现代、有咨询气质)。
**修正**:三个文档统一改成"Noto Serif SC + Fraunces 一种组合,不要混入 Songti SC / Playfair / 其他衬线"。template.html 字体加载和 `--f-serif-zh` / `--f-serif-en` 变量同步。

#### 修复 2 · 信息页漏 `.page` 包装,整页贴边贴顶

**现象**:样张第 3 / 6 / 7 / 8 页标题贴浏览器顶端,卡片堆底,左右零留白,中间大片空白。
**根因**:`<section class="slide">` 里漏了 `<div class="page">` 这层包装。`.page` 类提供 `padding: 3.5rem 5rem 2rem` + `flex column` + 让 page-body 自动撑开居中。少了它视觉立刻崩。
**修正(三层)**:
- 文档:[layouts.md](references/layouts.md) 头部表加"HTML 结构"列,明确 hero 版式直接放 / 信息版式必须 .page 包装,带完整代码块
- 自检:[checklist.md](references/checklist.md) P0 加 **#0a** 独立规则,带 grep 命令
- 自检命令:`grep -c '<div class="page">' file.html` 必须 = 信息处理页数量

#### 修复 3 · page-footer 跟翻页按钮 + 页码物理遮挡

**现象**:底部"饶秋 · 课程标识"被左下角翻页按钮 `<` `>` 遮挡,"MODULE X · XX"被右下角页码 `XX / 10` 遮挡。全屏也挡(因为是 `position: fixed`)。
**根因**:模板的 `.nav-arrows` 在 `bottom:1rem; left:1.5rem`,`.page-num` 在 `bottom:1rem; right:1.5rem` — page-footer 在 `.page` 的 padding-bottom 内,跟它们共享底部 0-3rem 区域。这是模板设计层面的冲突,不是写法问题。
**修正(三层防御,见 ⛔ 弃用)**

### ⛔ 弃用

- **`<div class="page-footer">` 元素**(v3 推荐结构,v4 弃用)
  - **原因**:见踩坑修复 #3 — 跟模板固定 UI 物理冲突
  - **三层防御**:
    1. 文档层:[layouts.md](references/layouts.md) + [checklist.md](references/checklist.md) 明确禁用,带 grep 命令
    2. 模板层:template.html 自带的 7 处 page-footer 范例全部物理删除
    3. CSS 兜底:`.page-footer { display: none !important; }`,即使将来 AI 误写也不显示
  - **替代方案**:品牌 + 模块标签 + 页码全部由顶部 `.page-meta` 承担。底部留给模板控件(`.nav-arrows` + `.page-num`)。
  - **自检**:`grep -c '<div class="page-footer">' file.html` 必须 = 0

### 内部统计

| 文件 | 改前 | 改后 | 变化 |
|---|---|---|---|
| SKILL.md | 6 KB | 13 KB | +6 KB |
| references/design-system.md | 4 KB | 8 KB | +4 KB |
| references/layouts.md | 7.5 KB | 14.5 KB | +7 KB |
| references/checklist.md | 不存在 | 16.5 KB | **全新** |
| assets/template.html | 55 KB(v3) | 59 KB(v4) | +4 KB(+衬线/FBM/2版式,-7 处 page-footer) |

---

## v3.0.0 · 2026-04-25(基线)

第一版 production-ready 模板。这个版本饶秋已经用了 12 个月,在 80+ 场企业培训交付里迭代过。

**包含**:
- McKinsey 深蓝极简风(#051C2C + 灰阶 + 警示红 #E53935)
- 9 种基础版式(封面 / 章节扉页 / 卡片网格 / metric+split / pipeline / prompt-block / task-card / matrix-2x2 / 结尾)
- template.html 自带翻页引擎(M / F / O / Cmd+/- / 拖拽重排 / hash 跳转 / 触屏 / PDF 打印)
- 客户色机制(放 `--c-warm` 变量,只覆盖三处:`.warm-mark` 卡片 / `.insight-tag` 红标 / 矩阵 `.quadrant.highlight`)
- design-system.md + layouts.md(扁平结构,无 references 子目录)

**当时的局限**(v4 解决):
- 没有独立 checklist 文件,自检条款散在各文档,容易漏
- 工作流粗(5 步),需求澄清靠经验,没有大纲模板
- 视觉系单一(全无衬线 + 纯白背景),做"重音页"靠章节扉页一种手段
- 没有版式分类,AI 经常发明新类名或选错版式
- page-footer 跟翻页按钮的遮挡问题没被发现(因为没人用 grep 自检)

---

## 贡献新条目

以后这个 skill 有新升级,在文件**顶部**加一个新版本块,格式:

```markdown
## vX.X.X · YYYY-MM-DD

**主线**:一句话讲这次大升级解决什么核心问题。

### ✨ 新增
- ...

### 🔁 改进
- ...

### 🛠️ 真实踩坑修复
#### 修复 N · 一句话标题
**现象**:实际看到什么不对
**根因**:为什么会发生
**修正**:做了什么(最好分文档/模板/CSS 几层写清)
**自检**:grep 命令或勾选条款

### ⛔ 弃用
- 元素/规则:**原因** + **替代方案** + **自检命令**

### 内部统计(可选)
| 文件 | 改前 | 改后 |
```

**版本号规则**(Semantic Versioning):
- **主版本** vX.0.0:破坏性变更(老课件可能要返工)
- **次版本** vX.Y.0:加新版式 / 新工作流 / 字体扩展(老课件不受影响)
- **补丁版本** vX.Y.Z:文档优化 / 单个 bug 修复 / checklist 加条款

**踩坑修复必须有**:现象、根因、修正、自检 — 这是 changelog 最有价值的部分,以后回头查 bug 全靠这块。
