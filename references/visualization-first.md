# 可视化优先工作流(v5.11 新增 · 饶秋实战反馈)

> **饶秋 2026-05-19 锦江课件实战诊断**:
> > "整个看起来文字太多了,讲解的时候很难让别人抓住重点。"
>
> **数据**:锦江课件 44 张片,**42 张是全文字页**(0 视觉元素),全 deck 总共只有 4 个视觉元素。
>
> **根因**:skill v5.5 起已有 SVG Dashboard 版式库(12 个组件)+ 24 个 SVG icon,**但 AI 生成时默认走"文字 + 卡片"路线,根本没用上**。

---

## 核心原则

**先想视觉,再想文字** — 跟之前"先想内容,再选版式"是反的。

| 老流程(v5.10 及之前)| 新流程(v5.11 起) |
|---|---|
| 1. 写大纲 → 2. 选版式 → 3. 填文字 → 4. 偶尔配图 | **1. 写大纲 → 2. 标识"哪些数据/对比/趋势"→ 3. 强制可视化 → 4. 文字降到辅助** |

---

## 强制可视化触发条件(满足任一即必须用图)

### 🚨 P0 红线 · 出现以下情况必须用图,不许用文字 list

| 触发信号 | 必须用的版式 | 不许用 |
|---|---|---|
| 内容有 **≥ 2 个数据对比**(前 vs 后 / 老 vs 新 / 传统 vs 现在)| **`.metric-row` 大数字 + SVG 横条对比** | ❌ split 两栏文字 |
| 内容有 **百分比 / 比率 / 转化率**(60% / 92% / 3.2×)| **`.big-number` 整页大字** 或 **donut/gauge** | ❌ 段落里嵌数字 |
| 内容有 **时间序列**(月度变化 / 季度趋势 / 周环比)| **SVG line/area chart 趋势线** | ❌ 表格 / 文字描述 |
| 内容有 **流程步骤 ≥ 3 步** | **`.process-flow` 横向时间线**(N 步 = N 节点)| ❌ 编号 list |
| 内容有 **2 维度分类**(高频/低频 × 强/弱 之类) | **`.matrix-2x2` 战略矩阵** | ❌ 4 段文字 |
| 内容有 **≥ 3 个并列要点 + 每个都带数据** | **`.card-grid` 卡片 + 每卡 metric 大数字** | ❌ 纯 card.h3+p |
| 内容是 **"5 个翻车 / 5 个原因 / 5 个步骤"** | **process-flow 5 节点** 或 **5 张连续 insight-page** | ❌ 一张片塞 5 项 list |

### 🟡 P1 · 出现以下情况强烈推荐用图

| 信号 | 推荐版式 |
|---|---|
| 单纯讲一个核心概念 / 定义 | `.big-quote` 整页大字(衬线)|
| 单个超震撼数据(60% / 80+) | `.big-number` 整页大字 + source |
| 工具 / 角色 4-6 个并列(每个有图标 + 短描述)| `.card-grid cols-3` + 每卡 SVG icon |
| 关键洞察 + 数据支撑 | `.insight-page` + 红色 tag + insight-meta |

### ✅ P2 · 可以用文字的极少数场景

| 场景 | 用什么 |
|---|---|
| 代码 / 提示词 / 命令 | `.prompt-block` 等宽字体 |
| 任务卡(动手时间 + 验收标准)| `.task-card` |
| 章节扉页(只有 1 个标题 + 1 句副标)| `.chapter` |
| 收尾页(讲师签名)| `.ending` |

**其他场景都应该先考虑可视化**,文字是兜底,不是首选。

---

## 文字 → 视觉化的 10 个常见转换模式

### 模式 1 · 文字 list 4 项 → process-flow 4 节点

**反例(锦江原 v0.3 场景 1)**:
```html
<ol class="list-clean">
  <li>翻去年的方案,复制一份</li>
  <li>改改改 — 主题、人数、时间、节目</li>
  <li>挠头想新节目创意</li>
  <li>2 小时改完 → 还是去年的味儿</li>
</ol>
```

**正例**:
```html
<div class="process-flow" style="--steps:4;">
  <div class="step"><div class="dot">1</div><h4>翻去年方案</h4><p>拷一份</p></div>
  <div class="step"><div class="dot">2</div><h4>改主题人数</h4><p>逐项改</p></div>
  <div class="step"><div class="dot">3</div><h4>挠头创意</h4><p>无新意</p></div>
  <div class="step"><div class="dot">4</div><h4>2 小时去年味</h4><p>白干</p></div>
</div>
```

字数减 70%,视觉冲击 ×5。

### 模式 2 · "2 小时变 10 分钟" → metric-row + SVG 横条

**反例**:`<p>用 AI 之前要 2 小时,用 AI 之后 10 分钟,效率提升 12 倍。</p>`

**正例**:
```html
<div class="metric-row">
  <div class="metric"><div class="v" style="color:var(--c-warm);">2<span class="unit"> 小时</span></div><div class="l">传统</div></div>
  <div class="metric"><div class="v" style="color:#16A34A;">10<span class="unit"> 分钟</span></div><div class="l">用 AI</div></div>
  <div class="metric"><div class="v">12<span class="unit">×</span></div><div class="l">效率提升</div></div>
</div>
<!-- SVG 横条对比(传统满条 vs AI 短条)= 直观看到 12 倍长度差 -->
<svg width="100%" height="22"><rect width="600" height="22" fill="var(--c-warm)"/></svg>
<svg width="100%" height="22"><rect width="50" height="22" fill="#16A34A"/></svg>
```

### 模式 3 · "AI 能干 5 件事" 列表 → card-grid + icon + metric

**反例**:`<ol><li>写文字</li><li>拉表格</li>... 5 个 li</ol>`

**正例**:5 张 mini card 各带 SVG icon(file-text / table / audio / presentation / search,从 `references/icons.md` 选),每卡顶部 mono 标签 "AI 01-05"。

### 模式 4 · "5 个翻车" → 5 张连续片(每张一个翻车 + 大数字)

**反例**:一张片塞 5 个翻车 → 字太密。

**正例**:5 张 `process-flow` 三节点片(现象 → 原因 → 应对)+ 每张片一个核心数字(比如"翻车 4 · 一次生太长 · 后半段崩"→ ≤5 秒 / 4×5 秒 / 10+秒 三个 metric)。

### 模式 5 · "AI 工作 5 件事 / 生活 7 件事" → 双 dashboard hero

**反例**(锦江"工作 5 件事" 371 字符):两张片 + 12 张文字卡片。

**正例**:
- 第 1 张:Big Number "5 件事" + 5 个 sparkline(每个对应一件事的时间节省曲线)+ 1 行 takeaway
- 第 2 张:同模式,7 件事 = 7 个 sparkline

### 模式 6 · "工具地图四件套" → 2x2 矩阵(频次 × 重要性)

**反例**:4 张 card 文字描述 4 个工具。

**正例**:`.matrix-2x2` — 横轴"使用频次"纵轴"不可替代性",4 个工具落到 4 个象限,带颜色 + tag。

### 模式 7 · "今天讲完你能做的三件事" → 3 个 metric + 3 个 SVG icon

不要 `<li>` 三项文字,要 3 个超大数字 + icon + 一句话。

### 模式 8 · 章节扉页的"3 章节内容预告" → 不要 ch-meta 3 项文字,改成 3 个 thumbnail-style mini box

### 模式 9 · "AI 给的第一稿不满意 · 3 个层次" → process-flow 3 节点 + 每节点 prompt-block 短代码

不要文字描述"什么是方向层、什么是局部层、什么是细节层",**直接展示 3 段示范提示词代码**(prompt-block × 3 横排)。

### 模式 11 · Count-up 数字动画(v5.12 · 饶秋实战反馈)

**触发场景**:任何"60% / 80% / 12× / 2000+ 学员"类大数字 hero 页。

**做法**:
- 给数字元素加 `class="js-count" data-target="80"`
- 模板自带 JS 引擎用 `requestAnimationFrame` + ease-out 把数字从 0 滚动到目标值(1.8 秒)
- 配 `<div class="progress-fill js-progress" data-target="80">` 同步进度条 fill

**视觉效果**:数字从 0 跳到 80%,进度条同步从 0 长到 80% — Apple Keynote 风,讲师讲到这页时听众的目光被数字吸住。

**适用版式**:`.big-number` / `.metric .v` / Hero 数字页

### 模式 12 · Icon Array 点阵(v5.12)

**触发场景**:讲百分比 / 比率 / "X 个里有 Y 个"时,用具象点阵代替抽象数字。

**做法**:10×10 = 100 个 dot,其中 N 个填色 = N% — **把"60%"变成"60 个看得见的点"**,听众秒理解"这意味着 60 个真实的人"。

**实现**:`<div class="dot-grid js-iconarray" data-filled="60"></div>` + JS 生成 100 dot + Fisher-Yates 打乱前 60 个 index 填色 + 错峰 scale 出现(每点 delay 12ms)。

**比 donut/gauge 更直观**:donut 是抽象环,icon array 是"60 个具体的人 / 件 / 个"。

### 模式 13 · 径向放射 layout(v5.12)

**触发场景**:1 个核心 + 多个 satellite(豆包 6 件事 / 6 个能力 / 5 个场景)。

**做法**:中心 brand 色圆 + 大数字"6",围绕 6 个白色卫星圆放射状排布(60° 间隔),SVG `<line>` spokes 用 `stroke-dasharray` 动画从中心向 satellite 画出来。

**为什么用**:**打破"上下左右堆叠"** — 矩阵排版是工业风,放射排版是"中心-辐射"叙事(讲师指中心讲核心,指卫星讲具体场景)。

### 模式 14 · 垂直 Timeline + Stagger Reveal(v5.12)

**触发场景**:5 步流程 / 5 个翻车 / TRAIN 五步 — 有"顺序"的内容。

**做法**:左 32% 固定(大编号 + 标题 + summary metric),右 68% 垂直时间线(每个 step 带 step-meta / h3 / p),节点圆点 + 连接线,**步骤从 -12px translateX 错峰滑入**(每个 delay 0.15s)。

**比横向 process-flow 更叙事**:横向是"鸟瞰",垂直是"顺着读"。

### ⚠⚠ Fragment 使用红线再升级(v5.14 · 2026-05-19 锦江实战第 2 次教训)

**v5.13 已经规定"只用于有顺序的流程",但 v5.14 实测**:
> 饶秋反馈:"11 页也是需要点几下,才能到下一页的,修复一下"

即使是真"有顺序"的流程(说→问→改 / TRAIN 五步),讲师也嫌"按几下太烦",影响演讲节奏。

**v5.14 终极规则 · 默认所有页都不用 fragment**:

只有以下两种**极端情况**才用 fragment:

1. **讲师明确要求** — "这页我要逐步揭示"(比如悬念页 / 翻车揭晓页 / 抽签揭晓 / 互动答题)
2. **内容本身要求** — 单步必须先讲完才能讲下一步(罕见,通常是"理论铺垫 → 应用示例"这种深度依赖)

**所有视觉上一目了然的顺序内容**(流程图 / TRAIN / 翻车 1-5 / 5 步法 / 时间线),**默认不用 fragment** — 听众一眼看完整图,讲师指着图讲就行。

### ⚠ Fragment 使用红线(v5.13 锦江实战教训 · 2026-05-19)

**饶秋 2026-05-19 锦江 v0.4 实战反馈**:
> "第三页的必须要按 6 下,才能翻页"(6 张承诺卡用了 fragment,导致按 6 下才翻页,体验崩)

**lesson learned · Fragment 不能滥用**:

| Fragment **适用** ✅ | Fragment **不适用** ❌ |
|---|---|
| **5 步流程** / 3 步流程 / TRAIN 五步 | 6 张承诺卡 / 工具四件套 / feature 网格 |
| 翻车 1→5 顺序揭示 | 输入 6 要素 / 输出 5 形态(平铺并列) |
| 时间线节点 | metric-row 数据行 |
| 配套示范代码(讲完原则再示范) | card-grid 平等并列卡片 |

**判断标准**:**有"顺序感"才用 fragment** — 听众心智里能默认编号 1→2→3 的内容才适合"逐个出现"。**无序的"列表型 / 并列型"内容用 fragment 反而让讲师多按 N 下,体验崩**。

**默认规则**:
- ✅ `.process-flow .step` → 必加 fragment(本来就是流程)
- ✅ `.task-card` 步骤 → 可加 fragment
- ❌ `.card-grid` 卡片 → **不要默认加 fragment**(除非有强顺序如"第 1 个最重要,逐个看")
- ❌ `.metric-row` → 不加(数据要一眼看到对比)
- ❌ feature list 平铺要点 → 不加

### 模式 15 · ⭐ Fragment 渐进显示(v5.12 · 培训现场神器)

**饶秋 2026-05-19 反馈原话**:"步骤是按 1 2 3 4 5 顺序出现的时候,先出现第一个,点击之后再出现第二个,加一点这个逐步出现的动画效果会不会更好一点?"

**触发场景**:任何"5 步 / N 件事 / 多卡片 / 多 list" 内容,需要讲师**边讲边出**节奏控制。

**做法**:给元素加 `class="fragment"`(默认 opacity:0 + translateY(12px)),按 → / 空格 / 下一页按钮**先让 fragment 逐个 reveal**,全部 reveal 完后再按 → 才真翻页。

**实现**:
```html
<div class="step fragment">步骤 1</div>
<div class="step fragment">步骤 2</div>
<div class="step fragment">步骤 3</div>
```

模板自带 Slideshow.next/prev **已经 fragment-aware**(v5.12 内置)— 不用写任何 JS,加 class 就行。

**变体**:
- `class="fragment fade-only"` — 只 fade 不位移
- `class="fragment from-left"` — 从左滑入
- `class="fragment zoom"` — scale 0.85 → 1

**Esc 反向**:按 ← 撤销最后一个 fragment(讲师讲错了能回退)。

**对培训现场为什么关键**:
- 卡片一次性全亮 → 听众目光散 / 讲师抓不回来
- 逐个出现 → **听众跟随讲师节奏**,讲到哪看到哪
- 给讲师"控场感"

### 模式 17 · ⭐⭐ Donut + 中心数字 count-up(v5.13)

**触发场景**:单个百分比数据(完成率 / 通过率 / 满意度 / 转化率)。

**比单独 count-up 强**:有"圆环 draw"的视觉冲击,数字落在中心更精致。

**用法**:
```html
<div class="viz-donut-wrap">
  <svg viewBox="0 0 200 200">
    <circle class="viz-donut-bg" cx="100" cy="100" r="80"/>
    <circle class="viz-donut-fg" cx="100" cy="100" r="80"
            transform="rotate(-90 100 100)"
            data-target="89"/>
  </svg>
  <div class="viz-donut-center">
    <div class="v"><span class="js-count" data-target="89">0</span><span class="pct">%</span></div>
    <div class="l">学员通过率</div>
  </div>
</div>
```

**动画自动触发**(切片到 active 时 MutationObserver hook)— **不用写任何 JS**。

### 模式 18 · ⭐⭐ 半圆 gauge 仪表盘(v5.13)

**触发场景**:0-100 范围的"分值 / 评分 / 健康度 / 满意度 / 完成度"。

**为什么用**:汽车仪表盘风,**指针摆动 + 弧形填充**双动画,有"实时测量"的科技感。比 donut 更适合"评分"语义。

**用法**:
```html
<div class="viz-gauge-wrap">
  <svg viewBox="0 0 200 130">
    <path class="viz-gauge-arc-bg" d="M 10 100 A 90 90 0 0 1 190 100"/>
    <path class="viz-gauge-arc-fg" d="M 10 100 A 90 90 0 0 1 190 100" data-target="92"/>
    <text class="scale-label" x="10" y="120" text-anchor="middle">0</text>
    <text class="scale-label" x="100" y="20" text-anchor="middle">50</text>
    <text class="scale-label" x="190" y="120" text-anchor="middle">100</text>
    <line class="viz-gauge-needle" x1="100" y1="100" x2="100" y2="20" data-target="92"/>
    <circle class="viz-gauge-pivot" cx="100" cy="100" r="6"/>
  </svg>
  <div style="text-align:center;margin-top:1rem;">
    <span class="js-count" data-target="92" style="font-size:4rem;font-family:var(--f-en);">0</span>
  </div>
</div>
```

### 模式 19 · ⭐⭐ 柱状 grow + count-up(v5.13)

**触发场景**:时间序列对比(月度 / 季度 / 周度变化)、排名(各部门 / 各产品)、多类目数值。

**为什么用**:柱子从底**长起来** + 顶部数字**滚动**,比 sparkline / 静态 bar chart 视觉冲击强一个量级。

**用法**:
```html
<div class="viz-bar-chart">
  <div class="viz-bar" data-target="45">
    <div class="v"><span class="js-count" data-target="350">0</span></div>
  </div>
  <div class="viz-bar" data-target="58">
    <div class="v"><span class="js-count" data-target="450">0</span></div>
  </div>
  <!-- ...更多柱子... -->
  <div class="viz-bar accent" data-target="100">  <!-- 最后一个用客户色突出 -->
    <div class="v"><span class="js-count" data-target="780">0</span></div>
  </div>
</div>
<div class="viz-bar-labels">
  <div class="label">2025-12</div>
  <div class="label">2026-01</div>
  <!-- ... -->
</div>
```

`data-target="45"` 是柱子高度百分比(45% of 容器高度);`js-count data-target="350"` 是顶部数字目标值。两个动画自动同步。

### 模式 20 · ⭐⭐⭐ 整页大数字 Hero(v5.13 · Apple Keynote 极简)

**触发场景**:单个核心数字想要**最强视觉冲击**(全场就讲一个数字时)。

**为什么用**:整页 80vh 一个超大数字 + 1 句衬线大字 lead + 1 行 source。**Apple Keynote 经典套路**,讲师指着数字讲故事,听众无法跑神。

**用法**:
```html
<div class="viz-big-hero">
  <div class="eyebrow">真实差距 · THE GAP</div>
  <div class="super-v">
    <span class="js-count" data-target="60">0</span><span class="pct">%</span>
  </div>
  <p class="lead">行政办公老师每周用 AI 不到 1 次 — <span class="kw-mark2">而管理层以为是 80%</span>。</p>
  <p class="source">SOURCE / 内部经营调研 · 2026 Q1 · 1200 样本</p>
</div>
```

字号自适应 `clamp(10rem, 22vw, 22rem)`,在大屏小屏都顶天立地。

### 模式 16 · ⭐ 关键词高亮(v5.13 精简版 · 只 3 种武器 · 整体只 2 种颜色)

> **饶秋 2026-05-19 第 5 次反馈**:
> > "关键词的视觉化不要颜色太多了,样式也太多了,你颜色样式一多就看起来非常的影响大家的这个观感。最多选三种颜色就 ok 了。"

**v5.13 砍掉 v5.12 的 7 种武器**(.kw-brand / .kw-pop / .kw-warm / .kw-up / .kw-mark / .kw-underline 6 个 deprecated · 老 class 保留作 backward compat 但**新生成内容不许用**),只保留 **3 种核心**:

| 武器 | class | 用途 | 颜色 |
|---|---|---|---|
| 主色加粗 | `.kw-key` | 默认武器 · 名词性核心词 · 95% 场景 | 深蓝(主) |
| 数字 mono | `.kw-num2` | 让数字跳出("60%""2 小时""12×") | 深蓝(主)+ 字体变化 |
| 高亮底色 | `.kw-mark2` | 强记忆点(类似荧光笔)· **每页 ≤ 2 处** | 客户色(第二种颜色) |

**整段视觉只 2 种颜色**(深蓝主 + 客户色),符合 McKinsey 克制原则。

**反例**(纯文字):
> 用豆包写一份 2000 字的迎新晚会策划方案,传统做法要 2 小时,跟豆包协作只要 10 分钟,效率提升 12 倍。关键是让 AI 先反问你 5 个问题,你一次性回完,它再开始写。

**正例 v5.13**(3 种武器配合):
```html
<p>用豆包写一份 <span class="kw-num2">2000 字</span> 的迎新晚会策划方案,
传统做法要 <span class="kw-num2">2 小时</span>,跟豆包协作只要 <span class="kw-num2">10 分钟</span>,
效率提升 <span class="kw-num2">12 倍</span>。
关键是让 AI 先 <span class="kw-mark2">反问你 5 个问题</span>,
你 <span class="kw-key">一次性回完</span>,它再开始写。</p>
```

**AI 生成时的强约束**:
- 每段 ≥ 30 字必须给 3-5 个关键词配武器
- 数字 + 单位 → 一律 `.kw-num2`
- 核心动作 / 名词 → `.kw-key`
- 强结论 / 警示句 → `.kw-mark2`(慎用,每页 ≤ 2 处)
- **不许用 v5.12 的 .kw-pop / .kw-warm / .kw-up / .kw-underline**(已 deprecated)

### v5.12 旧版 7 武器(deprecated · 保留 backward compat · 不要新用)

**饶秋 2026-05-19 反馈原话**:"一旦遇到大段文字的时候,你就需要去这个大段文字里面找出一些关键词,然后针对这个关键词进行一些加粗、加深、或者颜色的变化或者做一些关键词的一些优化的这种排版"

**思路**:**不是简单 bold,要按语义选武器**。同一段话,不同语义的关键词配不同视觉武器。

**6 种武器**(v5.12 模板自带 class):

| 武器 | class | 用途 | 视觉 |
|---|---|---|---|
| 主色加粗 | `.kw-brand` | 默认强调 / 名词性核心词 | 深蓝 + 粗 |
| 大字 + 客户色 | `.kw-pop` | 超强调 / 核心结论数字 | 1.18em + 客户色 |
| 数字 mono | `.kw-num` | 让"60%""2 小时""12×"跳出来 | Manrope + 1.15em + 数字字号优化 |
| 警示色 | `.kw-warm` | 反例 / 警告 / 痛点 | 红 + 粗 |
| 正向色 | `.kw-up` | 收益 / 成功 / 提升 | 绿 + 粗 |
| 荧光底色 | `.kw-mark` | 强记忆点(像荧光笔划过)| 半透明色块底 |
| SVG 波浪线 | `.kw-underline` | "亲笔强调"感 | 手绘风波浪下划线 |

**反例**(纯文字大段):
> 用豆包写一份 2000 字的迎新晚会策划方案,传统做法要 2 小时,跟豆包协作只要 10 分钟,效率提升 12 倍。关键是让 AI 先反问你 5 个问题,你一次性回完,它再开始写。

**正例**(关键词配武器):
```html
<p>用豆包写一份 <span class="kw-num">2000 字</span> 的迎新晚会策划方案,
传统做法要 <span class="kw-warm">2 小时</span>,
跟豆包协作只要 <span class="kw-up">10 分钟</span>,
效率提升 <span class="kw-pop">12 倍</span>。
关键是让 AI 先 <span class="kw-mark">反问你 5 个问题</span>,
你 <span class="kw-brand">一次性回完</span>,它再开始写。</p>
```

**视觉效果**:同一段话,**眼睛会自动停在数字和"反问 5 个问题"上**,讲师讲解时听众的视线跟着关键词跳,信息密度大幅提升。

**AI 在生成内容时的强约束**(写进 SKILL.md):

> 每个段落 ≥ 30 字时,**必须**给 3-5 个关键词包 kw-* 武器:
> - 数字 + 单位(2 小时 / 80% / 12×)→ `.kw-num`
> - 反例 / 痛点 / 警告 → `.kw-warm`
> - 收益 / 数字提升 / 成功 → `.kw-up`
> - 核心动作 / 关键名词 → `.kw-brand`
> - 1-2 处"超强调结论" → `.kw-pop` 或 `.kw-mark`(慎用,每页 ≤ 2 处)
>
> **不许整段没有任何高亮 class**。

### 模式 10 · 数据 dashboard 范例(综合)

任何"业绩复盘 / 学员反馈 / 月度数据"页 → 不要 paragraph,**直接给完整 dashboard**:顶部 4 个 metric card + 中部 1 个 donut + 1 个 line chart + 底部 hover-row 表格。版式见 `references/layouts.md` "13. 数据 Dashboard 版式"。

---

## 写每页前必问的 3 个问题(v5.11 强制)

写每张 slide 之前,**先在心里(或对话里)回答**:

```
Q1. 这页有没有数字 / 对比 / 趋势 / 流程?
    ─ 有 → 强制走可视化,不许写文字 list
    ─ 没有 → 进 Q2

Q2. 这页有没有 ≥ 3 个并列要点?
    ─ 有 → 用 card-grid + icon + 每卡数字,不用纯文字
    ─ 没有 → 进 Q3

Q3. 这页是不是"单个核心观点"?
    ─ 是 → 用 big-quote 或 insight-page(衬线大字)
    ─ 否 → 才允许用 split 文字对比 / list-clean
```

**默认假设:用户给的内容**不是**纯叙述,一定有数据/对比/流程藏在里面 — AI 要主动挖出来,而不是直接抄成文字 list。**

---

## 跟"信息密度铁律"的关系

旧版铁律(v5.5):**"塞不下不是字小了,是观点多了。"**

新版补充(v5.11):**"字多不是字号问题,是没把数据挖出来。"**

`.page-body` 超 350 字符 → 一定能拆成 2-3 个视觉模块。**字数应该是 last resort**。

---

## visualize-audit 工具(v5.11 新增)

跑 `bash scripts/visualize-audit.sh <file.html>` 一键扫:
- 每张片的字符数 / 视觉元素数(SVG + img + metric)
- 文字 / 视觉比例
- 全 deck 视觉化健康指数

输出报告标识"哪些页文字最多 / 哪些页 0 视觉元素",优先改造这些。

---

## 历史实战案例

| 日期 | 课件 | 改造前 | 改造后 |
|---|---|---|---|
| 2026-05-19 | 锦江"场景 1 · 痛点+提示词" | 598 字符 + 0 SVG | 240 字符 + 3 SVG + 3 metric(参见桌面 `可视化改造示范-场景1-2026-05-19.html`)|

每做完一个可视化改造案例,加进这张表。

---

## 给 AI 的强约束(写进 SKILL.md Step 1.7)

> **节奏规划阶段,每张片必须 defend choice**:
> - 这页内容是什么?
> - **第一选项**:能不能用图/数字/流程表达?(查上面"模式 1-10")
> - **第二选项**:不能,那能不能用 card-grid + icon + 数字?
> - **第三选项**:实在不行,才考虑 split 文字 / list-clean
>
> **AI 不可以默认走 split / list-clean,必须先排除前两个选项。**
