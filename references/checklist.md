# 饶秋老师 PPT 质量检查清单

这份清单是基于真实迭代过程(培训交付 + 客户提案踩过的坑)整理出来的硬规则。每条都是"现象 + 根因 + 做法"三段式,生成前通读,生成后逐项对照。

**用法**:
- 第一次做 PPT:从头读完一遍
- 之后每次做完:跳到文末"最终自检清单"勾选

按重要性分四级:🔴 P0 一定不能犯 / 🟡 P1 排版节奏 / 🟢 P2 视觉打磨 / 🔵 P3 操作细节

---

## 🔴 P0 · 一定不能犯的错

### 0a. 信息处理页必须用 `.page` 包装(2026-05 真实踩坑)

**现象**:标题贴浏览器顶端、左右内容贴边、卡片堆在屏幕下半部、中间大片空白 — 整页"丑得不知道讲什么"。

**根因**:`<section class="slide">` 里**漏了 `<div class="page">` 这层包装**。`.page` 类提供 padding(3.5rem 5rem 2rem)+ flex column + 让 page-body 自动居中。少了它,信息处理页就直接贴 viewport 边。

**做法**:
- **信息处理页**(metric+split / card-grid / pipeline / matrix-2x2 / prompt-block / task-card)**必须**用 `.page` 包装:
  ```html
  <section class="slide">
    <div class="page">                  ← 不能漏
      <div class="page-meta">...</div>  ← 顶部模块+页码 chrome
      <h2 class="page-title">...</h2>   ← h2,不是 div
      <p class="page-subtitle">...</p>  ← p,不是 div
      <div class="page-body">...</div>
      <!-- ⚠️ 不要写 page-footer · 会被翻页按钮和页码遮挡(v4 已 display:none) -->
    </div>
  </section>
  ```
- **Hero 版式**(cover / chapter / insight-page / big-number / big-quote / ending)**不要**用 `.page` 包装,直接在 section 里放对应 div 即可(它们各自定义了 padding)
- 详见 `layouts.md` 头部"版式分类"表的 HTML 结构列

**自检**:`grep -c '<div class="page">' file.html` 应等于信息处理页数量。如果你做了 5 个信息处理页,这里必须 = 5,少 1 个就少 1 页。

### 0b. 不要写 `<div class="page-footer">`(v4 弃用 · 2026-05 真实踩坑)

**现象**:底部"饶秋 · XX"被左下角翻页按钮 `<` `>` 遮挡,"MODULE X · XX"被右下角页码 `XX / 10` 遮挡。全屏后还是挡 — 因为模板控件是 `position: fixed`,跟 page-footer 物理冲突。

**根因**:`.nav-arrows` 在 `bottom:1rem; left:1.5rem`,`.page-num` 在 `bottom:1rem; right:1.5rem`,跟 page-footer 共享同一片底部区域。

**做法**:
- **信息页只用顶部 `.page-meta`,不要写任何 page-footer** — 模板 CSS 已加 `.page-footer { display:none !important; }`,即使误写也不会显示
- 品牌 / 模块标识 / 页码全部在顶部 page-meta 表达(模块标签在左,页码在右)
- 翻页和当前页码由模板自动给出:左下 `.nav-arrows` + 右下 `.page-num`

**自检**:`grep -c '<div class="page-footer">' file.html` 必须 = 0。

### 0d. Citation 强制 · 借用数据必有来源(v5-beta 新增 P0)

**这是什么**:所有**外部 / 非常识性数据**必须在 slide 里标 source。

**为什么这条是 P0**:学员看到"60% 学员上完课不再用 AI"会问"哪来的数据?"。没 source = 不专业 = 客户提案会被质疑 = 培训内容会被认为是编的。借鉴 academic-pptx 的"academic integrity"原则,**这条直接决定专业感**。

**强制规则**:
- ✅ **必须有 source 的位置**:
  - `.insight-page`(已有 `.insight-source`,v4 已强制)
  - `.metric-row` 整页的数据(任何一个 metric)
  - `.big-number` 大数字下面(已有 `.source` 元素)
  - `.split` 引用外部数据的那一栏
  - 任何 `.callout` / `.card` 写了具体数字 / 调研结果 / 研究结论
- ❌ **不需要 source 的位置**(豁免):
  - 常识性陈述("AI 在变得普及")
  - 自有产品 / 案例的数据("我们公司 80 场培训")— 但建议标 "*RAOQIU 内部 2024-2026*"
  - 反问句 / 引导语("你的团队还在用 PPT 吗?")
  - Big Quote 的金句(本身就是主张,不是数据)

**source 的标准格式**:

```html
<!-- Key Insight 内置(必填) -->
<div class="insight-source">SOURCE / 8 家企业内部追踪 · 2025-2026</div>

<!-- Big Number 内置(必填) -->
<span class="source">SOURCE / 客户内部调研 · 2026.03</span>

<!-- metric-row / split 用通用 source 标签 · v5-beta 新增 -->
<span class="data-source">SOURCE / xxx</span>

<!-- 自有数据 -->
<span class="source">SOURCE / RAOQIU 内部 · 2024-2026 累计追踪</span>

<!-- 已脱敏 -->
<span class="source">SOURCE / 客户化名 A-H · 数据已脱敏</span>
```

**source 内容写什么**:
- 来源**机构 / 研究 / 文档名**(McKinsey Global Institute / 哈佛商业评论 / 我自己的训练营)
- 时间(2026.03 / 2024-2026)
- 化名标注(如果是真实客户但要保护隐私)
- **不要写 URL**(slide 上 URL 没人会去敲)

**自检**:
- 看 deck 里所有数字,逐个问"这个数从哪来" — 都能答上来 = 通过
- grep 命令:`grep -E "[0-9]+\s*[%倍×]" file.html`(找所有百分比 / 倍数,人工核对每个都有附近的 source)

### 0c. Ghost Deck Test · 标题串读自检(v5 新增 P0 红线)

**这是什么**:把所有 slide 的 **action title**(`.page-title` / `.cover h1` / `.chapter h1` / `.insight-body` 首句 / `.big-quote .quote` / `.big-number .lead`)按顺序提取出来,**只看标题串读一遍**。

**通过标准**:不打开 PPT、不看任何内容、**只读这串标题**,应该能讲完整个故事。

**反例 — 不合格标题(P0 红线)**:

❌ Topic 标签型:
- `"目录"` / `"背景"` / `"现状分析"` / `"我们的方案"` / `"小结"` / `"问题与挑战"`
- 这些是"分类标签",不是"结论本身"

❌ 弱论点型:
- `"AI 改变工作方式"` — 太空
- `"培训效果分析"` — 是分析的"领域",不是分析的"结论"
- `"关键发现"` — 标签词,没说发现了什么

❌ 礼貌结尾型:
- `"Thank You"` / `"谢谢"` / `"Q&A"` — 浪费一页 + 结论页消失
- 结尾页必须留**行动建议或核心观点**,Q&A 时让听众一直看到这页

**正例 — 合格标题(Action Title)**:

✅ 完整句子 · 陈述结论:
- `"60% 学员上完课不再用 AI,但管理层以为是 80%"`
- `"问题不在 AI,在我们提问的方式"`
- `"不是教学员用 AI,是把学员的工作变成 AI"`
- `"三十天后,XX% → XX% — 任务嵌入是关键"`(实际写的时候用真实数据)

✅ 行动 / 决策导向:
- `"下一期试点企业:从 2 家头部客户开始"`(具体)
- `"按 TRAIN 五步做,30 天活跃度做到 60%+"`(可量化目标)

**自检命令**:
```bash
# 提取所有标题,人工通读
grep -oE '<(h1|h2)[^>]*>[^<]+|class="(kicker|lead|quote)"[^>]*>[^<]+' file.html | \
  sed 's/<[^>]*>//g' | head -30
```

**反向自检**:把上面 grep 结果发给一个**没看过这份 PPT 的人**,问他"光看这些标题,这份 PPT 在讲什么?"。
- 答得出大意 → Ghost Deck Test 通过
- 答"看不懂在讲啥" → 有标题是分类标签,回去改标题

**为什么这条最重要**(来源:academic-pptx-skill,Reynolds《演说之禅》,巴巴拉·明托《金字塔原理》):

> "Reading titles alone should tell the whole argument."

听众真正记住的不是 PPT 的具体数据,是**标题的连续叙事**。标题如果是 Topic 标签,听众听完只记得"哦讲了一些 AI 的事",留不下任何结论。

### 0. 动手前必须做的类名预检(最重要)

**现象**:写完 section 打开浏览器一看,卡片样式全丢、大标题字号不对、Key Insight 没有红色标签、矩阵的高亮象限没边框——明明照着 layouts.md 复制的,为什么会变形?

**根因**:99% 是因为 AI 临时发明了类名(比如把 `.card.warm-mark` 写成 `.warm-card`),或者 `assets/template.html` 的 `<style>` 块里**根本没定义**这个类。浏览器就 fallback 到默认样式,看起来"没生效"。

**做法**:
1. 写任何 `<section>` 之前,**必须先 Read 一遍 `assets/template.html` 的 `<style>` 块**(从顶部到第一个 `</style>` 闭合)
2. 把要用的版式类名跟 style 块对一遍,确认每一个都有定义
3. 如果发现缺类:**在 `<style>` 块里补上**,**不要在每个 section 里 inline 重写**
4. **template.html 是唯一的类名来源** — 不发明新类名,需要小定制就用 `style="..."` 内联

**最容易遗漏的类(必须确认存在)**:
`.card.warm-mark` / `.card.bordered-top` / `.card.bordered-left` / `.card.dark` / `.card.mini` /
`.insight-tag` / `.insight-body` / `.insight-meta` / `.insight-source` /
`.metric .v` / `.metric .l` / `.split .col.brand` /
`.prompt-block` / `.prompt-tag` / `.ph` / `.prompt-meta` /
`.task-card` / `.process-flow .step.active` / `.matrix-2x2 .quadrant.highlight` / `.q-tag` /
`.serif-hero` / `.serif-quote`(本次新增,衬线大字用)

### 1. 不要用衬线字体作正文/卡片字体

**现象**:卡片小标题、内页正文、metric 数字标签都用了衬线 — 立刻显得杂志/学术,不是咨询。

**根因**:AI 看到"加了衬线"就到处用。但 McKinsey 风的衬线是**克制的重音**,不是默认。

**做法**:
- **可以用衬线的版式**(本次新增):封面 h1 / 章节扉页 h1 / Key Insight 大字 / Big Quote 大引用 / Big Number 整页大数字
- **必须无衬线的版式**:卡片网格(所有 h3 + p) / metric-row / pipeline / task-card / 内页 page-title / page-subtitle / chrome
- **衬线字体只用一种组合**:`Noto Serif SC`(中文,= Source Han Serif SC)+ `Fraunces`(英文,模板已加载的 Variable Font)
- **不要混入** Songti SC / SimSun / Playfair Display 等其他衬线 — 同页混用会字怀打架

详见 [design-system.md](./design-system.md) "字体分工" 一节。

### 2. 不要用 AI 风颜色

**现象**:出现紫色 / 亮蓝渐变 / 彩虹色 / 大阴影 / 大圆角 / 玻璃拟态 — 一秒变 SaaS 落地页。

**根因**:AI 默认审美兜底,你不锁它就漂。

**做法**:
- 主色永远是 `#051C2C` 极深蓝(不是亮蓝、不是紫蓝)
- 用色比例:80% 黑/灰/白 + 5% 品牌色 + 5% 客户色(警示红 / 客户覆盖)+ 10% 留白
- **零渐变** / **最多 1px 极淡阴影** / **圆角 2-4px 或直角** / **零玻璃拟态**

### 3. 卡片密度超限必须拆页

**现象**:cols-3 mini 卡塞了 8 张,字小到看不清。然后开始想"调一下 CSS 字号" — 错的。

**根因**:字号偏小 99% 不是 CSS 问题,是密度超限。

**做法**:严格遵守 [layouts.md](./layouts.md) 卡片网格的密度规则:
| 类型 | 容量 | 超量怎么办 |
|---|---|---|
| `cols-2` 标准卡 | 4 张(2×2) | 拆成两页 |
| `cols-3` mini 卡 | 6 张(3×2) | 拆成两页,绝不挤 8 张 |
| `cols-4` mini 卡 | 4 张(1 行) | 不允许做 2 行 |

### 4. 客户色只放 `--c-warm`,不换主色

**现象**:客户给了红/蓝/绿主色,直接把整个 deck 主色 `--c-brand` 改了 — 整份 PPT 失去"咨询"气质,变成那家客户的品牌宣传册。

**做法**:
- 主色永远 `#051C2C` 不变
- 客户色覆盖到 `--c-warm`,**只**出现在三个位置:
  - `.card.warm-mark` 的左边 3px 边
  - Key Insight 的红色标签 `.insight-tag`
  - 战略矩阵的 highlight 象限边框
- 这个机制让客户色"作为点缀存在",视觉主线是麦肯锡灰阶 + 深蓝

### 5. 章节扉页是整个 deck 唯一的深蓝整页

**现象**:为了"丰富视觉",在普通卡片网格页也用了深蓝底白字,结果章节扉页失去节奏重音感。

**做法**:
- 整份 deck **只有 `.chapter` 章节扉页**用深蓝整页
- 普通页面要"深"的视觉冲击,用 `.card.dark` 单卡(一页最多 3 张)
- 不要在内页背景上铺深蓝

### 6. 不要用 emoji 作版式装饰

**现象**:章节标题前加 🎯 💡 ✅ — 立刻不咨询。

**做法**:
- 装饰图标用 mono 字体的纯文字标签(`PROMPT · TPL 04` / `KEY INSIGHT` / `01 · 模块`)
- 真要用图标,Lucide 线性图标(模板已加载),不用 emoji
- **例外**:内容本身在讲 emoji(比如"AI 客服话术里要不要用 emoji")才能出现

### 7. 不要导入外部演示框架

**现象**:有人想加 reveal.js / Slidev / 把模板改成 Marp,觉得"专业一点"。

**做法**:模板已经自研翻页引擎(M / F / O / Cmd+/- / 拖拽 / hash / 触屏 / PDF),零外部依赖。**不要加任何演示框架** — 加了功能反而冲突。

---

## 🟡 P1 · 排版节奏

### 8. 章节扉页 ≤ 5 张

5 个模块封顶。如果你想做 6 个模块以上,**先回去看大纲** — 模块切得太细本身就是结构问题,不是 PPT 问题。

### 9. Key Insight 关键洞察 ≤ 3 张

强调有价值递减规律:1 个 Key Insight = 重磅,3 个 Key Insight = 强调,7 个 Key Insight = 全是废话。整份 deck 最多 3 张。

### 10. 一页一个核心信息,标题即结论

**做法**:
- 标题不是"目录""背景""现状",而是这页的**论点本身**(例:"现状是 60% 员工每周用 AI 不到 1 次,但管理层以为是 80%")
- 一页超过 1 个核心信息 → 拆页
- 这是真正麦肯锡风的底层逻辑,字号偏小、信息混乱、看完不知道讲了什么 — 99% 都是因为破了这一条

### 11. 中文大标题处理

强制规则:
- **封面 h1 / 章节扉页 h1**:**≤ 5 字 + `nowrap`** — 强制
- **Key Insight 大字**:可 8-12 字两行,用手工 `<br>` 断行,不依赖自动换行
- **内页 page-title**(2.25rem):自由,正常断行即可

**示例**:
- 封面好:`从 AI 工具到 AI 操作系统`(11 字 — 超过了,要拆,改成 `AI 操作系统` + 副标题`从工具到协作伙伴`)
- 章节扉页好:`训练干预`(4 字)
- Key Insight 好:`60% 的人 / 每周用不到 1 次`(用 `<br>` 分两行)

### 12. 章节扉页节奏:不要让人疲劳

硬规则:
- 25 页以上 deck **至少插入 3 个章节扉页**,作为视觉重音
- **连续 4 页以上卡片网格不允许** — 听众眼睛会累
- 章节扉页与卡片网格之间穿插 metric / Key Insight / Big Number,制造节奏

### 13. 数据驱动,不空喊口号

**现象**:Key Insight 里写"AI 改变世界" — 没数据,没来源,等于没说。

**做法**:
- 引用洞察必须有 `.insight-meta`(三个量化指标)+ `.insight-source`(来源)
- 数字的来源(自有数据 / 引用研究 / 客户访谈)必须可溯
- 不要写"很多""大量""显著提升" — 给具体百分比

### 14. 同一概念的术语用法要统一

整份 deck 同一个词只用一种写法。
- 例:整份用 "Workflow",不要一会儿"工作流"一会儿"流水线"
- 例:整份用 "提示词",不要一会儿 "Prompt" 一会儿 "提示词" 一会儿 "指令"

### 15. 节奏铁律:Hero 页与信息页交替

类比"重音 + 弱拍":
- 章节扉页 / Big Number / Big Quote / Key Insight = 重音(视觉冲击)
- 卡片网格 / metric-row / pipeline / task-card = 弱拍(信息处理)
- **连续 2 页以上重音 → 听众疲劳** / **连续 4 页以上弱拍 → 节奏死**

### 16. 底部 chrome 页码格式统一

用 `XX / 总页数`(例 `05 / 27`)。**不要在右上角再加动态页码**,会和 chrome 重复。
加页/删页时记得手工改总页数(JS 不会自动同步 chrome 文字)。

---

## 🟢 P2 · 视觉打磨

### 17. 衬线字体的边界(本次新规则,容易跑偏)

**只在以下 5 类版式可用衬线大字**:
- 封面 h1(`.cover .h1.serif-hero`)
- 章节扉页 h1(`.chapter .h1.serif-hero`)
- Key Insight 大字(`.insight-body.serif-quote`)
- Big Quote 整页大引用(`.big-quote .quote.serif-quote`)
- Big Number 整页大数字 — 数字本身可以衬线(`.big-number .v.serif-quote`)

**其他位置一律无衬线**。
衬线字体**只用** Noto Serif SC(中文)+ Fraunces(英文)。**不要混入** Songti SC / SimSun / Playfair 等其他衬线。

### 18. WebGL 流体背景的边界

**默认关闭**。要开启需明确条件:
- 场景:AIGC 培训 / 行业分享 / 私享会(允许"轻视觉感")
- 不要开:客户提案 / 内部汇报 / PDF 输出 / 老旧投影场景(可能掉帧)

**只允许一种 shader**:静谧 FBM 噪波(纸感纹理)。
**禁用**:Holographic Dispersion / Spiral Vortex / 任何带强中心点的(那是发布会风,不是咨询风)。

**遮罩透明度**:
- hero 页:18-22%(WebGL 隐约可见)
- 普通页:95%(几乎不透,只剩纸感底噪)

开关方式:在 `<body>` 加/去 `data-bg="fbm"` 类。详见 [design-system.md](./design-system.md) "WebGL 背景"一节。

### 19. 图片只裁底部,左右和顶部绝对不能切

**做法**:
- 图片容器用**固定 `height:Nvh` + `overflow:hidden`**,不要用 `aspect-ratio`(会撑破)
- 图片走 `object-fit:cover + object-position:top`(模板已预设)
- 图片标准比例:**16:10 / 4:3 / 3:2 / 1:1 / 16:9** 选一个,不要复制原图奇葩比例

### 20. metric-row 每页 ≤ 3 个数字

每页 4 个以上数字 → 视觉上变成一排小字,失去"大数字震撼"效果。改用 Big Number(整页 1 个) 或拆页。

### 21. 客户色只在三处出现

参考 P0 #4 — 强调一遍:`.card.warm-mark` 左边 3px / Key Insight `.insight-tag` 红标 / 矩阵 `.quadrant.highlight` 边框。**只在这三处**。其他位置看到客户色 = 错。

### 22. 留白是审美,不是浪费

页面 padding 不要改:
- 普通页:`3.5rem 5rem 2rem`
- 章节扉页:`4.5rem 6rem`(更大)
- 卡片 gap:`1rem`
- "宁少勿多" — 看到大片白不是要填的,是要保留的

---

## 🔵 P3 · 操作细节

### 23. 改动 < 10% 用 str_replace,不要全文重写

token 节约的根本方法。修个标题、改个数据,别让 AI 整个文件吐一遍。

### 24. 大纲未定型,不生成完整 HTML

最费 token 的环节。先把大纲(用 SCQA 或叙事弧)在文档里对齐,再让 AI 生成 HTML。

### 25. 文件名格式

`{课程主题}-{客户简称}-{日期}.html`
例:`AI办公提效-XX企业-202604.html`

### 26. 单文件自包含

所有 CSS / JS 内联,字体走 Google Fonts CDN。**不要拆成多文件**,客户拿到 PPT 应该是 1 个 `.html`。

### 27. 不要破坏模板交互

模板自带:M(大纲) / F(全屏) / O(概览) / Cmd+/-(缩放) / 拖拽重排 / hash 跳转 / 触屏 / PDF 打印 — 一个都不能破坏。改 HTML 内容时不要动 JS。

---

## 🧪 最终自检清单

生成完 PPT 后,逐项对照(纸笔勾选 or `grep` 自检):

```
预检
  □ 已 Read assets/template.html 的 <style> 块,所有要用的类都已定义
  □ 已画"页面节奏表":每页明确版式 + 是否 hero
  □ 节奏表满足:章节扉页 ≤5 / Key Insight ≤3 / 25页以上至少 3 个章节扉页 / 连续卡片网格 ≤4 页

结构(2026-05 新增 · 漏一个全页崩)
  □ 信息处理页都用了 .page 包装:grep -c '<div class="page">' 应等于信息页数量
  □ Hero 版式没用 .page 包装(cover / chapter / insight-page / big-number / big-quote / ending 直接放 section)
  □ 信息页标题用 <h2 class="page-title">,不是 <div>
  □ 信息页副标题用 <p class="page-subtitle">,不是 <div>
  □ 信息页有 page-meta(顶部模块+页码),没有 page-footer(底部会被翻页按钮和页码遮挡)

Action Title · Ghost Deck Test(v5 新增 · P0)
  □ 每页标题都是"完整句子陈述结论",不是"分类标签"
  □ 没有 "目录" "背景" "现状分析" "我们的方案" 等 Topic 型标题
  □ 没有 "Thank You" / "谢谢" / "Q&A" 结尾页
  □ 串读所有标题,**不看内容**,能讲完整个故事(Ghost Deck Test 通过)
  □ 找一个没看过 PPT 的人读标题串,他能复述大意

Citation · 数据有来源(v5-beta 新增 · P0)
  □ 所有外部 / 非常识数据(百分比 / 倍数 / 调研结果)都有 SOURCE 标注
  □ Key Insight 有 .insight-source
  □ Big Number 有 .source
  □ metric-row / split 等版式如果引用外部数据,有 .data-source 标签
  □ source 内容含机构 + 时间(例 "8 家企业 · 2025-2026"),不写 URL
  □ 自有数据标注 "RAOQIU 内部 · YYYY-YYYY 累计 N 场" 等

Brand Style 应用(v5-beta 新增 · P1)
  □ 客户色已通过 --c-warm 变量覆盖(没改 --c-brand 主色)
  □ Brand Style 卡片里的 Tone 已反映在文案中
  □ Compliance 禁用词清单 grep 通过 = 0
  □ 培训完成后回填了 Tracking 表(学员数 / 满意度 / 30 天活跃)

字体(本次重点)
  □ 衬线字体只出现在封面 h1 / 章节扉页 h1 / Key Insight / Big Quote / Big Number 数字
  □ 卡片网格 / metric / pipeline / task-card 全是无衬线
  □ 衬线只用 Noto Serif SC + Fraunces + Cormorant Garamond(v5.1 Paper/Dark 主题) 这一种组合,没混入 Songti SC / Playfair 等其他衬线

颜色
  □ 没有紫色 / 亮蓝渐变 / 彩虹色 / 玻璃拟态
  □ 主色还是 #051C2C(没被客户色替换)
  □ 客户色只在 .warm-mark / 红色 insight-tag / 矩阵 highlight 三处
  □ 章节扉页是唯一深蓝整页,内页背景没用深蓝

排版
  □ 每页一个核心信息,标题即结论
  □ 卡片密度没超(cols-2≤4 / cols-3≤6 / cols-4≤4)
  □ 中文大标题:封面/章节扉页 ≤5字+nowrap;Key Insight 用 <br> 手工断行
  □ metric-row 每页 ≤3 个数字
  □ 没有 emoji 作图标(除非内容本身就是 emoji 主题)
  □ 没有渐变/大阴影/大圆角

图片
  □ 容器用 height:Nvh,不用 aspect-ratio
  □ 图片只裁底部(object-position:top)
  □ 图片用标准比例(16:10 / 4:3 / 3:2 / 1:1 / 16:9 之一)

WebGL 背景(若开启)
  □ 场景属于 AIGC 培训 / 行业分享(不是客户提案 / PDF 输出)
  □ 只用 FBM 噪波 shader,没用 holographic / spiral vortex
  □ hero 页遮罩 18-22%,普通页 95%

交互
  □ ← → / 滚轮 / 触屏 / 底部圆点 翻页正常
  □ chrome 里的页码 N 与实际总页数一致
  □ 打印 PDF 控件自动隐藏
  □ 没有引入 reveal.js / 其他演示框架

文档纪律
  □ 文件名格式 {主题}-{客户}-{日期}.html
  □ 单文件自包含,没有外部 .css / .js / .png 依赖(图片除外)
  □ 改动 < 10% 用 str_replace,没全文重写
```

全部勾完,才是合格的饶秋老师 PPT。

---

## 用法补充

**做新课件**:从头读完一遍 → 边写边对照 → 写完走勾选清单。
**改老课件**:跳到"最终自检清单",找改动相关的几条对照即可。
**学员协作**:学员按照模板填内容时,把"P0 一定不能犯"打印出来贴墙上。
