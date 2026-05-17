# 12 种版式索引

每种版式记录:用途、密度规则(关键!)、template.html 中的位置、注意事项。

**核心方法:不要从零写版式 HTML,在 template.html 里找到对应的 section,复制后改文字内容即可。**

**版式分类**(动手前先想清楚每页属于哪一类):

| 类别 | 版式 | 节奏作用 | **HTML 结构** ⚠️ |
|---|---|---|---|
| **开场 / 收束** | 1 封面 / 10 结尾 | 框架 | `<section>` 直接放 `<div class="cover\|ending">` |
| **重音页**(强冲击) | 2 章节扉页 / 7 Key Insight / **11 Big Number** / **12 Big Quote** | hero — 制造节奏重音 | `<section>` 直接放 `<div class="chapter\|insight-page\|big-number\|big-quote">`(**不要用 .page 包装!**) |
| **信息处理页** | 3 卡片网格 / 4 metric+split / 8 流程时间线 / 9 2x2 矩阵 | 弱拍 — 信息组织 | `<section>` → `<div class="page">` → 内部用 page-meta / page-title / page-body(**必须 .page 包装,不要写 page-footer**) |
| **操作类页** | 5 提示词代码块 / 6 学员任务卡 | 实操指引 | 同信息处理页:`<section>` → `<div class="page">` |

### 信息处理页的标准结构(漏一个就崩)

```html
<section class="slide" data-module="模块名" data-name="页面名">
  <div class="page">                                    ← P0 漏掉就贴边贴顶
    <div class="page-meta">                             ← 顶部 chrome(模块标签 + 页码)
      <span class="module">模块 X · 子主题</span>
      <span>XX / 10</span>
    </div>
    <h2 class="page-title">标题(用 h2,不要用 div)</h2>
    <p class="page-subtitle">副标题(用 p,不要用 div)</p>
    <div class="page-body">                             ← 主内容区(自动垂直居中)
      <!-- 卡片网格 / metric-row / pipeline / matrix 等 -->
    </div>
  </div>
</section>
```

**为什么 `.page` 不能漏**:`.page` 类是 `padding: 3.5rem 5rem 2rem` + `flex column` + 让 `.page-body` 自动 flex:1 撑开。少了它,所有内容都贴 viewport 边,标题贴顶、卡片堆底、左右零留白 —— 视觉立刻崩。Hero 版式不用 `.page` 是因为它们各自定义了 `padding`(例如 `.big-number` / `.cover` / `.chapter` 都内置了大 padding)。

**子标题用 `<p class="page-subtitle">` 不是 `<div>`**:模板的 CSS 是 `p.page-subtitle` 选择器(虽然 CSS 没强制,但保持语义)。同理 `h2.page-title` 用 h2 不用 div。

### ⚠️ 不要写 `.page-footer`(v4 弃用 · 2026-05 真实踩坑)

**现象**:写了 `<div class="page-footer">` 之后,底部"饶秋 · XX"被左下角翻页按钮 `<` `>` 遮挡,"MODULE X · XX"被右下角页码 `XX / 10` 遮挡。全屏也挡。

**根因**:模板 UI 的 `.nav-arrows` 固定在 `bottom:1rem; left:1.5rem`,`.page-num` 固定在 `bottom:1rem; right:1.5rem` — page-footer 在 `.page` 的 padding-bottom 内,跟它们硬撞。

**做法**:**信息页只用顶部 page-meta,不要写 page-footer**。template.html 的 `.page-footer` CSS 已加 `display:none !important`,即使误写也不会显示。品牌/模块/页码信息全部交给:
- 顶部 `.page-meta`(信息页内嵌)
- 右下角 `.page-num`(模板自动生成,跟随当前 slide)
- 大纲面板(按 M 触发,显示所有页面名)

---

## 1. 封面 `.cover`

**用途**:课程开场,PPT 第一页

**密度规则**:每个 PPT **1 张**

**位置**:template.html 第 1 页(搜索 `data-name="课程封面"`)

**填什么**:
- `eyebrow`:小写英文标识(如 "AIGC TRAINING · CLIENT NAME · 2026")
- `h1`:课程主标题,可以两行,**禁止超过 12 字一行**
- `lead`:副标题,**30 字以内**,讲清楚课程定位
- `meta-grid` 三列:主讲 / 课程时长 / 对象,固定结构

**注意**:封面 h1 的左上方有一个 3rem 宽的横线作为视觉锚点(`::before`),不要删

---

## 2. 章节扉页 `.chapter`

**用途**:模块切换,深蓝整页 + 白色巨大数字

**密度规则**:每个 PPT **不超过 5 张**(对应 5 个模块,多了就是模块设计有问题)

**位置**:template.html 第 3、9 页(搜索 `data-module="模块一"` 和 `data-module="模块二"` 的 chapter 页)

**填什么**:
- `deco-num`:超大铅字数字(01 / 02 / 03 ...)
- `ch-label`:Chapter One · 第一章
- `h1`:章节标题,**禁止超过 8 字**
- `desc`:副标题描述
- `ch-meta`:三个数据(几步方法 / 几分钟 / 几案例)

**注意**:章节扉页是整个 PPT 唯一用深蓝整页的版式,作为视觉节奏的"重音"。不要在其他页面用深蓝底。

---

## 3. 卡片网格内容页 `.card-grid`

**用途**:罗列要点、对比维度、列功能

**密度规则**(必须严格遵守,这是字号偏小的根源):

| 类型 | 容量上限 | 超量怎么办 |
|---|---|---|
| `.card-grid.cols-2` 标准卡 | **4 张**(2×2) | 拆成两页 |
| `.card-grid.cols-3` mini 卡 | **6 张**(3×2) | 拆成两页,绝不挤 8 张 |
| `.card-grid.cols-4` mini 卡 | **4 张**(1 行) | 不允许做 2 行 |

**位置**:
- 标准卡 cols-2:template.html 第 2 页
- mini 卡 cols-3:template.html 第 10 页(豆包六件套)

**卡片变体**:
- `.card.bordered-top`:顶部 3px 主色边(默认推荐)
- `.card.bordered-left`:左边 3px 主色边
- `.card.dark`:深蓝底白字(对比强烈,慎用,一页最多 3 张)
- `.card.warm-mark`:左边 3px 警示红边(标记"关键""客户色位置")
- `.card.mini`:紧凑版,padding 小一档,字号小一档

**卡片内必填**:
- `.card-num`:01 · 类别 / 02 · 类别 ...
- `h3`:**8 字以内**的小标题
- `p`:**30 字以内**的描述,**1-2 行**

---

## 4. 数据 + 对比 `.metric-row` + `.split`

**用途**:左右双栏对比 + 大数字 metric 展示

**密度规则**:
- `.metric-row` 每页 **不超过 3 个数字**
- `.split` 必须左右两栏,不要三栏

**位置**:template.html 第 4 页(搜索 `data-name="为什么需要 TRAIN"`)

**填什么**:
- `.metric .v`:大号数字(可以加 `<span class="unit">%</span>` 或 `×` 等单位)
- `.metric .l`:数字下方的小标签(mono 字体)
- `.split` 两栏:左边"现状/问题",右边"对策/答案"(用 `.col.brand` 让右栏标题用主色)

---

## 5. 提示词代码块 `.prompt-block`

**用途**:展示提示词模板,是饶秋老师课程的高频版式

**密度规则**:每页 **1 个 prompt-block**(超过就拆页)

**位置**:template.html 第 6 页(搜索 `data-name="提示词模板 · TRAIN"`)

**填什么**:
- `.prompt-tag`:`PROMPT · TPL XX` 红色矩形标签
- 提示词正文:用等宽字体显示,行内可以混排
- `.ph` 类标记的占位符:`[xxx]`,显示为棕赭色高亮
- `.prompt-meta`:底部元数据(适用场景 / 预计耗时)

**注意**:占位符 `<span class="ph">[内容]</span>` 是关键交互——告诉用户哪些地方需要替换

---

## 6. 学员任务卡 `.task-card`

**用途**:实操任务说明,左右双栏

**密度规则**:每页 **1 个 task-card**

**位置**:template.html 第 7 页(搜索 `data-name="实操任务 · 任务1"`)

**填什么**:
- 左栏:任务编号(大号数字) + 任务名 + 任务背景 + 你的任务(数字编号 list)
- 右栏:验收标准(数字编号 list) + 配套资料 + 倒计时(大号红色数字,如 `10:00`)

**注意**:这是双栏布局,内容必须左右匹配,不要左多右少或反之

---

## 7. Key Insight 关键洞察 `.insight-page`

**用途**:核心论点 + 数据支撑 + 来源(替代金句页)

**密度规则**:每个 PPT **不超过 3 张**(用太多就失去强调感,价值递减)

**位置**:template.html 第 8 页(搜索 `data-name="关键洞察"`)

**填什么**:
- `.insight-tag`:KEY INSIGHT · 关键洞察(红色标签 + 横线)
- `.insight-body`:核心论点(2.25rem 大字 + 左侧 3px 主色竖边)
- `.insight-meta`:三个量化指标(每个 item 有 mono 标签 + brand 大字)
- `.insight-source`:数据来源脚注(SOURCE / xxx)

**注意**:这是麦肯锡式的"洞察标注",必须有数据 + 来源,不能只是金句

---

## 8. 流程时间线 `.process-flow`

**用途**:横向 N 步流程,5 步最佳

**密度规则**:每页 1 个流程图,**最多 5-6 步**(7+ 步必须拆成两个流程图)

**位置**:template.html 第 5 页(搜索 `data-name="TRAIN 五步流程图"`)

**填什么**:
- 容器加 `style="--steps: 5"` 控制列数
- 每个 `.step` 包含:`step-num` + `dot`(可加 `.active` 表示当前) + `h4` + `p`
- 第一步常加 `.active` 表示"起点",其他空心

**注意**:流程图横线由 CSS 自动生成(`::before`),不需要手写

---

## 9. 2x2 战略矩阵 `.matrix-2x2`

**用途**:四象限战略图,SWOT,优先级判断

**密度规则**:每页 **1 个矩阵**

**位置**:template.html 第 11 页(搜索 `data-name="AI 应用战略矩阵"`)

**填什么**:
- `.y-axis`:左边坐标轴(高/低 + 标签 + 高/低)
- `.x-axis`:底部坐标轴(低/高 + 标签 + 低/高)
- 4 个 `.quadrant`:
  - 通常右上是"重点象限",加 `.highlight` 类
  - 每个象限:`.q-tag`(象限编号 + 行动建议) + `h4`(象限名) + `p`(描述)

**注意**:矩阵的高度需要至少占 page-body 的 80%,内容少了会显得空——要确保 4 个象限都填实

---

## 11. Big Number 整页大数字 `.big-number`(本次新增)

**用途**:把一个核心数字放大到整页 — 比 metric-row 更强的视觉冲击,适合开场/章末/Key Insight 收束。

**密度规则**:每个 PPT **不超过 3 张**(过多会失去震撼感)

**位置**:template.html(搜索 `data-name="Big Number 范例"`)

**填什么**:
- `.kicker`:小标题(mono 字体,如 `THE GAP · 真实差距`)
- `.v.serif-quote`:**整页大数字**,可加衬线(20-30vw 字号),例 `60%`、`70万`、`105`
- `.lead`:数字下方一句话注解,30 字内,无衬线
- `.source`:数据来源(SOURCE / xxx)

**衬线规则**:
- `.v` 数字本身可以加 `.serif-quote` 类(用 Source Han Serif SC + Playfair Display)— 增强权威感
- `.lead` 注解必须无衬线 — 信息处理

**示例**:
```html
<section class="slide big-number light">
  <span class="kicker">THE GAP · 真实差距</span>
  <div class="v serif-quote">60%</div>
  <p class="lead">员工每周用 AI 不到 1 次,管理层以为是 80%。</p>
  <span class="source">SOURCE / 某客户内部调研 2026.03</span>
</section>
```

**注意**:
- 数字字号 20-30vw,**单数字最多 4 字符**(包括百分号),超过用 lead 句拆解
- 数字旁不要堆其他数字,这一页就讲一个数
- 与 `.metric-row`(每页 3 个数字小字号)互补:metric-row 处理"对比",Big Number 处理"震撼"

---

## 12. Big Quote 整页大引用 `.big-quote`(本次新增)

**用途**:用一句话承担整页 — 适合关键金句、章节收束、Takeaway 页。**比 Key Insight 更"轻"**(Key Insight 必带数据来源,Big Quote 是纯主张)。

**密度规则**:每个 PPT **不超过 2 张**(过多会显得"文学化",失去咨询风的克制)

**位置**:template.html(搜索 `data-name="Big Quote 范例"`)

**填什么**:
- `.kicker`:小标题(可选,mono 字体)
- `.quote.serif-quote`:**整页大引用**,衬线字体(8-12vw 字号),用手工 `<br>` 控制断行
- `.attribution`:出处 / 署名(— 饶秋 · 2026 / SOURCE)
- 可选 `.aside`:小注解一段(无衬线,正文字号)

**衬线规则**:
- `.quote` **必须** 加 `.serif-quote` 类 — 这是 Big Quote 的标志
- `.attribution` 用 mono 字体,无衬线
- `.aside` 注解无衬线

**示例**:
```html
<section class="slide big-quote light">
  <span class="kicker">TAKEAWAY · 我的判断</span>
  <blockquote class="quote serif-quote">
    AI 不会取代你,<br>
    但用 AI 的人会。
  </blockquote>
  <span class="attribution">— 饶秋 · AIGC 培训交付现场</span>
</section>
```

**注意**:
- 中文引用 ≤ 16 字(两行),英文 ≤ 12 词
- 引用本身就是结论,不要再加"小标题翻译"
- 衬线和引文是这一版式的灵魂 — 但**整份 deck 最多 2 张**,过多就漂

---

## 10. 结尾页 `.ending`

**用途**:致谢 + 联系方式 + 课程编号

**密度规则**:每个 PPT **1 张**

**位置**:template.html 最后一页(搜索 `data-name="结尾致谢"`)

**填什么**:
- `eyebrow`:`从今天开始 · Continue From Today`(可改文字但保留两段式结构)
- `h1`:号召 / 总结金句(主标题)
- `lead`:补充行动指引(50 字内)
- `signature`:三栏(主讲 / 联系方式 / 课程编号)

---

## 版式选择决策树

```
要做什么?
├── 开场 / 结束 → 封面 / 结尾(版式 1, 10)
├── 模块切换 → 章节扉页(版式 2)
├── 罗列内容
│   ├── ≤4 项 → cols-2 标准卡(版式 3)
│   ├── ≤6 项 → cols-3 mini 卡(版式 3)
│   └── 7+ 项 → 拆页 / 改用流程图
├── 数据强调
│   ├── 多个数字对比(2-3 个) → metric + split(版式 4)
│   └── 单个数字震撼 → Big Number(版式 11) ★ 本次新增
├── 流程步骤 → 流程时间线(版式 8)
├── 四象限 → 2x2 矩阵(版式 9)
├── 关键观点
│   ├── 带数据 + 来源 → Key Insight(版式 7)
│   └── 纯主张 / 金句 / Takeaway → Big Quote(版式 12) ★ 本次新增
├── 操作类内容
│   ├── 提示词 → prompt-block(版式 5)
│   └── 学员任务 → task-card(版式 6)
└── 不在以上 → 拆解需求,99% 能匹配上面某个版式
```

## "重音页"用量上限(节奏铁律)

整份 deck 重音页(版式 2 / 7 / 11 / 12)的总用量必须节制,否则节奏会"全是高潮 = 没有高潮":

| 版式 | 上限 | 超量信号 |
|---|---|---|
| 章节扉页(版式 2) | ≤ 5 张 | 模块切太细,回去看大纲 |
| Key Insight(版式 7) | ≤ 3 张 | 强调价值递减,挑最重要的 3 个 |
| Big Number(版式 11) | ≤ 3 张 | 数字太多反而平淡,挑最震撼的 |
| Big Quote(版式 12) | ≤ 2 张 | 引用太多变文学化,失去咨询气质 |

**总和上限**:整份 deck 重音页(2+7+11+12)合计 **≤ 13 张**,且**至少有同等数量的信息处理页(3/4/5/6/8/9)**作为"弱拍"。

如果你做了 25 页 deck,重音页 13 张,弱拍 12 张 — 节奏就是"重 / 弱 / 重 / 弱"近乎对半。这是上限,不是目标。**目标是重音 ≤ 1/3,弱拍 ≥ 2/3**。

## 信息密度铁律

> **一页一观点。塞不下不是字小了,是观点多了。**

这是饶秋老师课程理念"标题即结论"的体现,也是真正麦肯锡风格的底层逻辑。

字号偏小的问题 99% 不是 CSS 问题,是版式选择和内容密度问题。先看密度规则,再考虑改 CSS。
