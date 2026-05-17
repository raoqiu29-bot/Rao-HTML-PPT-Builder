# 饶秋老师 PPT 设计系统 · 麦肯锡风

## 风格卡片(v5 升级 · 5 维度结构化)

借鉴 frontend-slides STYLE_PRESETS 的统一格式,让 AI 读规则时不漏项。**这是整个 skill 的视觉系总开关,锁死,不允许偏移。**

### 饶秋老师 McKinsey 风(主风格 · 唯一锁定)

**Vibe**(气质):
- Rational(理性)> 感性
- Structured(结构)> 装饰
- Restrained(克制)> 鲜艳
- Data-driven(数据)> 口号
- 形容词关键词:"咨询""极简""安静""程前式干净简单"

**Layout**(版式):
- 80% 白底 + 5% 主色(深蓝)+ 5% 客户色(--c-warm)+ 10% 灰阶
- 章节扉页深蓝整页是**唯一"视觉重音"**(每份 deck ≤ 5 张)
- F-pattern(头部左上)优先,禁止全屏居中布局
- 12 种版式分类:开场/收束(2)+ 重音(4)+ 信息处理(4)+ 操作(2)详见 [layouts.md](layouts.md)

**Typography**(字体分工):
- **默认无衬线**:中 `PingFang SC` / 英 `Manrope` / 等宽 `JetBrains Mono`
- **衬线 5 处重音**:中 `Noto Serif SC` / 英 `Fraunces`(只用在 cover h1 / chapter h1 / Key Insight / Big Quote / Big Number 数字)
- **字号基准 17px**,所有尺寸 rem(支持 Cmd+/- 缩放)+ v5 后兼容 clamp() 多屏适配
- **禁用**:Inter / Roboto / Arial / 微软雅黑(标题)/ Songti / Playfair(任何位置)详见末尾"DO NOT USE"

**Colors**(色彩,见下方"配色变量"完整定义):
```css
--c-brand:  #051C2C   /* 麦肯锡极深蓝 · 主色 · 锁定不变 */
--c-warm:   #E53935   /* 警示红 / 客户色覆盖位置 */
--c-ink-2:  #2A3744   /* 二级文字 */
--c-ink-3:  #5C6772   /* 三级文字 */
--c-line:   #E5E7EB   /* 主线条 */
```

**Signature Elements**(标志性元素):
- 章节扉页深蓝整页 + 巨大白色铅字编号(`01` / `02`)
- 卡片顶部 3px 主色边(`.bordered-top`)/ 左 3px 警示红边(`.warm-mark`)
- Key Insight 红色矩形标签 `KEY INSIGHT · 关键洞察` + 左 3px 主色竖边
- 数据 Big Number 整页大字 + 衬线 Fraunces(`60%`)
- mono 字体的元数据标签(`PROMPT · TPL 04` / `SOURCE / xxx`)
- **零渐变 / 零大阴影 / 零玻璃拟态** — 留白即审美

---

### Paper & Ink 纸墨白 风格卡片(v5.1 默认推荐 · `data-theme="paper"`)

**Vibe**(气质):
- Literary(文学)+ Restrained(克制)+ Confident(自信)
- 形容词:"古典""高级""可读""可信""有温度"
- 适用:培训现场 / 思想分享 / 演讲(白底高可读)

**Layout**(版式):同 McKinsey 主版式,只换配色 / 字体 / 装饰

**Typography**(字体分工):
- 标题(cover h1 / chapter h1 / page-title):**Cormorant Garamond italic + 600 weight**(意大利体衬线)
- 正文 / 卡片 / metric:**Noto Serif SC**(中文衬线,跟字怀匹配)
- 衬线 fallback:Source Serif 4 / Georgia
- 元数据 / 标签:JetBrains Mono(等宽)

**Colors**:
```css
--c-bg: #faf9f7;       /* 米白底 */
--c-ink: #1a1a1a;      /* 炭黑字 */
--c-brand-2: #c41e3a;  /* 红色强调 · 模块标签 / 引用前缀 */
--c-warm: #c41e3a;     /* 红色客户色 */
```

**Signature Elements**(标志性元素):
- Cormorant Garamond italic 标题(像高级杂志)
- Big Quote 前面带巨大装饰引号(`\201C` Unicode)
- 卡片 2px 顶部炭黑细线
- 模块标签红色斜体
- 强化的 FBM 纸感纹理(opacity 0.8)

---

### Dark Botanical 暗色植物 风格卡片(v5.1 切换 · `data-theme="dark"`)

**Vibe**(气质):
- Elegant(优雅)+ Sophisticated(精致)+ Premium(高端)
- 形容词:"夜读""艺术""高端""神秘""有空间感"
- 适用:VIP 课 / 晚上分享 / 灯光暗时震撼

**Layout**:同 Paper & Ink,但暗底反白

**Typography**:
- 标题:**Cormorant Garamond italic + 500 weight**(暗底配 italic 显得轻盈)
- 正文:Noto Serif SC + IBM Plex Sans fallback
- 元数据:JetBrains Mono

**Colors**:
```css
--c-bg: #0f0f0f;       /* 暗黑底 */
--c-ink: #e8e4df;      /* 米色字 */
--c-brand: #d4a574;    /* 陶土金 */
--c-brand-2: #e8b4b8;  /* 暖粉 */
```

**Signature Elements**(标志性元素):
- 暗黑底配米色衬线字
- Hero 页发光圆装饰(粉色 + 金色 radial-gradient blur)
- 章节扉页对角渐变
- 卡片金色顶部细线(1px 而非 2px,更精致)
- 关闭 FBM 背景(暗底不需要纸感)

---

## 品牌身份(谁在用这个系统)

饶秋老师 = 上市公司运营总监 + AIGC 实战讲师 + 四川大学 MBA

**参考真实视觉系统**:McKinsey Quarterly、McKinsey Insights 报告。

**不要参考**:Apple 风、独立设计师风、Notion 风、Linear 风、紫色 SaaS 风、消费互联网 UI 风。

## 配色变量(在 template.html 里已定义,不要改)

```css
--c-bg:        #FFFFFF;     /* 主背景 - 纯白 */
--c-bg-2:      #F5F5F5;     /* 次背景 - 浅灰 */
--c-bg-card:   #FFFFFF;     /* 卡片背景 */
--c-bg-dark:   #051C2C;     /* 深蓝 - 章节扉页 / 深色卡片 */
--c-ink:       #051C2C;     /* 主文字 */
--c-ink-2:     #2A3744;     /* 二级 */
--c-ink-3:     #5C6772;     /* 三级 */
--c-ink-4:     #9CA5AE;     /* 弱化(脚注、页码) */
--c-line:      #E5E7EB;     /* 主线条 */
--c-line-2:    #CDD3DA;     /* 次线条 */
--c-brand:     #051C2C;     /* 品牌主色 */
--c-brand-2:   #2251FF;     /* 锐蓝 - 极少用 */
--c-accent:    #2251FF;
--c-warm:      #E53935;     /* 警示红 / 客户色位置 */
--c-deco:      rgba(5,28,44,0.05);
--c-deco-warm: rgba(229,57,53,0.05);
```

## 字体分工(本次新规则,容易跑偏)

字体在 `assets/template.html` 里已通过 Google Fonts CDN 配置好,你不用动 CSS,**只要按版式选对类**即可。

### 默认字体(无衬线 + 等宽)

| 用途 | 字体 |
|---|---|
| 中文(默认) | PingFang SC(系统级,渲染最稳) |
| 英文/数字(默认) | Manrope(几何感无衬线) |
| 元数据 / 代码 / 标签 / 页码 | JetBrains Mono(等宽) |

### 衬线字体(v5 新增,v5.1 扩展白名单)

| 用途 | 字体 |
|---|---|
| 中文重音 / 默认衬线 | **Noto Serif SC**(= Source Han Serif SC) |
| 英文重音(McKinsey 蓝默认时) | **Fraunces**(模板已加载,Variable Font) |
| **英文重音(Paper 主题)** | **Cormorant Garamond**(v5.1 新增,意大利体优美) |
| **英文重音(Dark 主题)** | **Cormorant Garamond**(同上,但 weight 500 + italic) |

**核心规则**:衬线**只能用在 5 个版式**,其他位置一律无衬线。

### 衬线边界规则(P0 红线)

| 版式 | 是否可衬线 | 实现类 |
|---|---|---|
| 封面 h1(`.cover .h1`) | ✅ 可选 | 加 `.serif-hero` |
| 章节扉页 h1(`.chapter .h1`) | ✅ 可选 | 加 `.serif-hero` |
| Key Insight 大字(`.insight-body`) | ✅ 可选 | 加 `.serif-quote` |
| Big Quote 大引用(`.big-quote .quote`) | ✅ 可选 | 加 `.serif-quote` |
| Big Number 大数字(`.big-number .v`) | ✅ 可选 | 加 `.serif-quote` |
| **其他全部位置** | ❌ 必须无衬线 | 不要加衬线类 |

**禁用清单**:
- ❌ 卡片网格的 h3 / p 不要衬线
- ❌ metric-row 的数字标签不要衬线
- ❌ pipeline / task-card / prompt-block 不要衬线
- ❌ 内页 page-title / page-subtitle / chrome 不要衬线
- ❌ 不要混入 Songti SC / SimSun / Playfair Display / Bodoni Moda 等其他衬线 — 衬线白名单只有 **Noto Serif SC + Fraunces + Cormorant Garamond**(后者 v5.1 加入,Paper / Dark 主题用)

### 为什么衬线要边界化

衬线放开后,AI 默认会"哪里大用哪里",一份 PPT 衬线/无衬线大标题混着用,**视觉系会从"咨询风"漂向"杂志风"**。

真正的麦肯锡 Insights 报告里:封面、章节、关键引用用衬线增加权威感;但所有信息处理页(图表标签、数据表、流程图)一律无衬线。本规则照搬这个分工。

## 字号(基准 20px · v5 升级 · 培训现场可读性优先)

| 元素 | rem 值 | 像素(基准 20px) | v4 像素(对比) |
|---|---|---|---|
| 封面 h1 | 4.25rem | **~85px** | 72px |
| 章节 h1 | 4.5rem | **~90px** | 76px |
| 内页 page-title | 2.25rem | **~45px** | 38px |
| 内页 page-subtitle | 1.0625rem | **~21px** | 18px |
| 卡片标准 h3 | 1.125rem | **~22px** | 19px |
| 卡片 mini h3 | 1rem | **~20px** | 17px |
| 正文 p | 0.875–1rem | **~17-20px** | 15-17px |
| 元数据 mono | 0.7–0.8125rem | **~14-16px** | 12-14px |
| Big Number 大数字 | clamp(8rem, 22vw, 22rem) | 自动适配 | 同 |

**基准 `:root font-size: 20px`**(template.html line 38),Cmd+/- 会同比例缩放所有 rem 元素。

### 为什么是 20px 不是 17px(v5 重要决策,以后不要回退)

**v4 用 17px 是错的判断**。17px 是"网页阅读"(Medium / 微信公众号)的舒适基准,不是"投影演讲"的可读基准。

**业界共识**:
- Garr Reynolds《Presentation Zen》:演讲 PPT 正文 ≥ **30 pt ≈ 40px**(最后排可见)
- McKinsey 内部 PPT 模板:正文 24 pt ≈ 32px,标题 28 pt ≈ 37px
- power-design Rule #8(WCAG + Material Design 综合):Body ≥ 24 px,Title ≥ 48 px
- academic-pptx:Body bullets 20 pt ≈ 27 px(注:academic 用 PPTX 真实 pt 值,跟 HTML px 有 1.333 转换)

**为什么不直接上 24 px / 28 px**:
- 24-28 px 在笔记本屏(13/15 寸)预览时**视觉过大**,信息密度跌一档
- 饶秋培训交付场景两栖:① 培训现场投影 + ② 客户/学员自己电脑回看,要兼顾
- 20 px 是兼顾两个场景的中间点 — 笔记本看舒适,投影也够大

**真要更大字怎么办**:
- 客户特定要求"显眼字" → 改 SKILL.md 决策规则 #N:在 Step 1 第 4 问加"投影距离 / 学员视距",大投影场景临时升 22-24 px(改 `:root` 一行)
- 也可以 Cmd+ 浏览器缩放(因为 rem 是相对单位)

**v5 升级历史**:见 [CHANGELOG.md](../CHANGELOG.md) v5.0.0-alpha "🛠️ 修复 3"

### Cmd+/- 缩放还能用吗

能。`:root font-size: 20px` 改的是基准,浏览器 Cmd+/- 是在基准之上再缩放,两套机制独立。
- 笔记本默认看:20 px 基准
- 客户大屏:Cmd+ 2 档 = 24 px 基准
- 学员手机预览:Cmd- 2 档 = 16 px 基准 + 多档 viewport 断点自动缩 padding

## 留白规则(v5 升级 · 基于 20px 基准)

- 页面内 padding:`3.5rem 5rem 2rem`(上 **70px** / 左右 **100px** / 下 **40px**)
- 章节扉页 padding:`4.5rem 6rem`(上下 **90px** / 左右 **120px**)
- 卡片网格 gap:`1rem`(**20px**)
- 卡片内 padding:`1.4rem`(标准 **28px**) / `1rem`(mini **20px**)

**留白是核心审美,宁少勿多。不要为了"填满"而加内容。**

**v4 对比**(基准 17px 时):上 60 / 左右 85 / 下 34 / gap 17 / 卡片 24-17。v5 等比放大 17.6%。布局比例不变。

---

## 核心设计原则 · 学术引用 + 量化阈值(v5 升级)

借鉴 power-design 的"每条规则带研究来源"做法,给 AI 应用规则时**权威感**和**机器可验证性**。

**规则总览**(每条都对应 layouts.md / checklist.md 里具体条款):

| # | 原则 | 量化阈值 | 学术来源 |
|---|------|---------|---------|
| 1 | 一页一观点 | 每页 1 个核心信息;超过拆页 | Reynolds《演说之禅》/ Duarte《Slide:ology》 |
| 2 | 3 秒可读 | 听众扫视 3 秒能 get 主标题 + 1 个数据点 | Duarte / Nielsen Norman |
| 3 | 视觉块 ≤ 7 ± 2 | 卡片网格 cols-2 ≤4 / cols-3 ≤6 / cols-4 ≤4 | Miller 1956 · 短时记忆 7±2 / Cowan 2001 |
| 4 | 白空间 ≥ 40% | 主内容区不超过 viewport 60%;hero 页 ≥ 60% 白 | Refactoring UI / Reynolds |
| 5 | F-pattern 头部左上 | 主标题在左上,关键 metric 在左上 1/3 区域 | Nielsen Norman 眼动研究 |
| 6 | 字号比例锁定 | 17px 基准,封面 h1 = 4.25rem,page-title = 2.25rem(modular scale ≈ 1.33-1.618) | Tschichold 《书籍设计》/ Bringhurst《字体编排》 |
| 7 | 一页最多 4 种字号 | 不允许 5+ 种字号在同一页 | Refactoring UI |
| 8 | 行长 ≤ 60 字符 | 正文 max-width 控制(slide 一般不写段落,但说明 / 注解里有效) | Bringhurst |
| 9 | WCAG 对比度 | 正文 ≥ 4.5:1,标题 ≥ 3:1,主色 #051C2C 对白底 ≈ 17:1(AAA 级远超标) | WCAG 2.2 标准 |
| 10 | 60-30-10 用色 | 60% 白底 + 30% 灰阶 + 10% 主色 / 客户色 | Itten 色彩学 / Refactoring UI |
| 11 | 一页一个 Accent | 一页内只允许 1 种强调色(主色 或 客户色,不要混) | Tufte《Envisioning Information》 |
| 12 | 不靠颜色单独编码意义 | 标记 "关键"用 .warm-mark **3px 红边 + 文字标签**,不要只换字色 | WCAG 1.4.1 / 色盲友好 |
| 13 | 8pt 网格对齐 | 所有 spacing 值 ∈ {8, 16, 24, 32, 48, 64, 96, 128} px,**不要 13 / 27 这种 ad-hoc 数字** | Material Design / Jackson |
| 14 | 关联近 / 无关远 | 相关元素 ≤ 16px,无关元素 ≥ 48px(卡片 gap 1rem ≈ 16px 正好) | Gestalt 接近性原理 / Williams |
| 15 | 数据墨水比 ≥ 80% | 图表 80% 像素是数据本身,不是装饰;无 3D / 无渐变 / 无 chartjunk | Tufte《The Visual Display of Quantitative Information》1983 |
| 16 | 标题即结论 | 每页标题是完整句子陈述结论,不是 Topic 标签(Ghost Deck Test 验证) | 巴巴拉·明托《金字塔原理》/ McKinsey Quarterly 风格手册 |
| 17 | 数据必有来源 | 借用数据 → 标 `SOURCE / xxx`;Key Insight 强制带 `.insight-source` | McKinsey Insights 引用规范 / 学术 integrity |
| 18 | 选定一种模式坚持 | 演讲模式(每页 ≤15 字)vs 文档模式(密度较高)二选一,不要混 | Tufte vs Reynolds 之争 / 设计哲学坚持 |
| 19 | 留白是审美不是浪费 | 看到大片白不是要填,是要保留 | Reynolds / 麦肯锡咨询风核心审美 |
| 20 | 一份 deck 视觉系锁定 | 不在同一份 PPT 里混杂 McKinsey + 杂志风 + Apple 风(选定一种) | 整体性原则 · 见 frontend-slides Phase 0 |

### 这 20 条怎么用

- **写 PPT 前**:这些是"价值观",不需要每条都查
- **AI 自动生成时**:checklist.md 里每条 P0-P3 都映射到这 20 条里的某一条(下次升级 v5.1 时可显式标注映射关系)
- **跟客户解释为什么这样设计**:直接引用学术来源,**比"我们觉得好看"有说服力 10 倍**

### 学术引用 · 完整来源清单(以后写作 / 培训用得着)

- **Edward Tufte** · 《The Visual Display of Quantitative Information》1983 · 数据墨水比 / chartjunk
- **Barbara Minto**(巴巴拉·明托)· 《The Pyramid Principle》(《金字塔原理》)· 标题即结论 / SCQA
- **Garr Reynolds** · 《Presentation Zen》(《演说之禅》)· 留白 / 一页一观点 / 信号-噪声比
- **Nancy Duarte** · 《Slide:ology》 / 《resonate》 · 视觉化叙事
- **Robert Bringhurst** · 《The Elements of Typographic Style》(《字体编排》)· modular scale / 字号比例
- **Jan Tschichold** · 《Die neue Typographie》(《新版式》)· 现代主义版式
- **Johannes Itten** · 《Kunst der Farbe》(《色彩艺术》)· 60-30-10 色彩理论
- **George A. Miller** · "The Magical Number Seven, Plus or Minus Two" 1956 · 短时记忆
- **Nelson Cowan** · "The magical mystery four" 2001 · 工作记忆容量
- **Don Norman / Nielsen Norman Group** · F-pattern 眼动研究
- **WCAG 2.2** · Web Content Accessibility Guidelines 国际标准
- **Material Design / 8pt Grid** · Google + Jackson 推动的工业标准
- **McKinsey Quarterly / McKinsey Insights** · 真实咨询报告视觉规范
- **Refactoring UI** · Adam Wathan / Steve Schoger · 实用 UI 设计原则
- **Gestalt 心理学派**(20 世纪初)· 接近性 / 相似性 / 闭合性

**用法**:培训现场学员问"为什么这条规则定下来",直接引用对应来源 + 一句话解释。比"凭经验"有底气。

## 颜色用法清单

### 主色 #051C2C 用在哪
- 标题文字
- 章节扉页背景
- 卡片顶部 3px 边
- 强调标记
- TOC 项 hover

### 锐蓝 #2251FF 用在哪
- 极少,只用作 CTA 或链接色

### 警示红 #E53935 用在哪
- `.card.warm-mark` 卡片左边 3px 边
- Key Insight 的 KEY INSIGHT 标签
- 矩阵图的 highlight 象限边框

### 中性灰阶
- 80% 篇幅由灰阶构成(文字层级、线条、底纹)

## 客户色处理(关键!)

如果客户有自己的品牌色(比如某酒水品牌的深红、某金融机构的稳重蓝),不要替换主色。

正确做法:把客户色放在 `--c-warm` 变量上覆盖:

```css
body.theme-mckinsey{
  --c-warm: #客户品牌色;
}
```

这样客户色只会出现在:
- `.card.warm-mark` 的左边 3px 边
- Key Insight 的红色标签
- 战略矩阵的 highlight 象限边框

主色永远 #051C2C 不变,客户色作为点缀出现。

## WebGL 流体背景(本次新增,默认关闭)

借鉴归藏 `guizang-ppt-skill` 的视觉感,但严格收敛在 McKinsey 克制美学里。

### 何时开 / 何时关

| 场景 | 是否开启 |
|---|---|
| AIGC 培训 / 行业分享 / 私享会 | ✅ 可选开启(允许"轻视觉感") |
| 客户提案 / 内部汇报 | ❌ 关闭(咨询场合零干扰) |
| PDF 输出 / 打印交付 | ❌ 关闭(WebGL 不会被打印捕获,反而留下空白) |
| 老旧投影 / 学员笔记本演示 | ❌ 关闭(可能掉帧) |

### 只允许的 shader 类型

**只用 FBM 噪波**(纸感纹理,无中心点,色彩极淡,接近底噪)。

❌ 禁用以下任何一种:
- Holographic Dispersion(钛金色散) — 发布会风,不是咨询风
- Spiral Vortex / 径向涟漪 — 像 Windows 98 屏保
- Aurora / Plasma / 任何带色彩流动的 — 视觉信息量太大,抢字
- 任何带"中心点"或"主轴"的 shader — 与"克制"原则冲突

### 遮罩透明度规则

WebGL 背景之上覆盖一层白色遮罩,控制透出强度:

| 页面类型 | 遮罩 alpha |
|---|---|
| Hero 页(封面 / 章节扉页 / Big Number / Big Quote / Key Insight) | 18-22%(WebGL 隐约可见,纸感纹理透出) |
| 普通信息页(卡片 / metric / pipeline / task-card) | 95%(几乎不透,只剩极淡底噪) |
| 文字密集页(prompt-block / 长引用) | 98%(全部用纯白背景,确保可读) |

### 开关方式

**默认状态**:`<body class="theme-mckinsey">` — WebGL canvas 不渲染。

**开启**:`<body class="theme-mckinsey" data-bg="fbm">` — WebGL canvas 启用 FBM shader。

**实现**:`assets/template.html` 已预设 canvas + shader 代码,但默认 hidden。`data-bg="fbm"` 触发渲染。

### 颜色基调

FBM 噪波的色彩基调:
- 主色:#FCFCFC(纸白)→ #F4F4F2(纸灰)的极弱波动
- 偏色:不超过 hue ±5%(几乎无彩感)
- 流速:慢(完整周期 30s+,不要"流动感"明显)

记住一句话:**WebGL 背景不是来"被看见"的,是来给纯白底加"一点呼吸"的**。如果听众/读者注意到背景在动 → 失败。

## DO NOT USE · 具体禁用清单(v5 升级 · 字体名 / hex 值 / 类名都列具体)

**为什么要写具体**:定性禁用"❌ AI 风" AI 经常凭感觉判断、踩雷。具体值禁用(字体名 / hex 值 / 类名)可以**机器 grep 验证**。

### 禁用字体(作为标题或正文)

❌ **绝对禁用作为标题字体**(AI 默认审美兜底):
- `Inter`(SaaS 落地页标志)
- `Roboto`(Google Material 默认)
- `Arial` / `Helvetica`(网页默认)
- `微软雅黑` / `Microsoft YaHei`(中文 SaaS 默认)
- `系统默认 sans-serif` 不指明字体

❌ **绝对禁用衬线字体**(除衬线 5 处重音例外):
- `Songti SC` / `STSong` / `SimSun`(显示效果差,字怀不匹配)
- `Playfair Display`(我们之前误判过,Fraunces 更现代)
- `Cormorant` / `Bodoni`(过于文学,偏离咨询气质)
- `Times New Roman`(报告风,不是演讲风)

✅ **唯一允许**:`PingFang SC + Manrope`(默认无衬线)/ `Noto Serif SC + Fraunces`(衬线 5 处重音)/ `JetBrains Mono`(等宽)

**自检**:`grep -i "Inter\|Roboto\|微软雅黑\|Songti\|Playfair\|Bodoni" file.html` 必须 = 0(除非命中字体 fallback 列表里)。

### 禁用颜色(AI 风标志)

❌ **绝对禁用色**(具体 hex,grep 可验证):
- `#6366f1`(generic indigo,Tailwind 默认 SaaS 紫)
- `#8B5CF6` / `#A855F7` / `#9333EA`(各种紫罗兰)
- `#7B68EE` / `#9400D3`(深紫)
- `#3B82F6`(Tailwind blue-500,SaaS 标志蓝)
- `#10B981`(Tailwind green-500,SaaS 标志绿)
- 任何 `linear-gradient(白底紫 / 白底亮蓝 / 多色彩虹)`

❌ **绝对禁用样式**:
- 任何 `linear-gradient` 在 slide 内容上(只允许在 hero 页 WebGL 背景遮罩)
- `box-shadow` blur ≥ 8px(只允许 ≤2px 极淡阴影)
- `border-radius` ≥ 8px(只允许 2-4px 或直角)
- `backdrop-filter: blur(>8px)`(玻璃拟态)— 控件 UI 例外(0.7rem 小按钮可微 blur)

✅ **唯一允许的颜色**:模板 CSS 变量定义的(详见上方"配色变量"),客户色覆盖到 `--c-warm` 而已。

**自检**:
```bash
grep -iE "#6366f1|#8B5CF6|#A855F7|#7B68EE|linear-gradient(?!.*WebGL)" file.html | wc -l
# 必须 = 0
```

### 禁用版式 / 元素

❌ 全屏居中布局(F-pattern 优先,头部左上 — 来源 Nielsen Norman 眼动研究)
❌ 6+ bullets 一页(Miller 1956 · 短时记忆 7±2,实际可读 3-5)
❌ 玻璃拟态卡片(消费 app 美学,不是咨询风)
❌ 装饰性 emoji 作图标(`🎯 💡 ✅ 🚀 ⭐`)
❌ 渐变(任何 `linear-gradient` 在内容层)
❌ Page-footer(v4 已弃用,跟翻页按钮 / 页码物理遮挡)
❌ 衬线在卡片 / metric / pipeline / task-card / 内页 page-title(衬线只限 5 处重音版式)

### 禁用工具 / 框架

❌ 不要导入 `reveal.js` / `slidev` / `marp` / 任何外部演示框架 — 模板自带翻页引擎
❌ 不要用 Vue / React 组件化 — 单 HTML 自包含是硬约束
❌ 不要用 npm / build tool — CSS / JS 全部 inline

### 留下来的"不要做"(保留,定性级)

❌ "信息密集"的页面 — 拆页(具体阈值见 layouts.md 密度规则)
❌ 客户色替换 `--c-brand` 主色 — 永远 #051C2C,客户色只覆盖 --c-warm
❌ 在普通页背景铺深蓝 — 章节扉页是唯一深蓝整页
❌ WebGL 背景默认开启 — 仅 AIGC 培训 / 分享场景按需开启
❌ WebGL 用 holographic / spiral vortex / aurora 等 shader — 只用 FBM 噪波

## 不要破坏的功能

template.html 自带的功能:
- M 键:切换大纲面板,支持拖拽重排页面顺序
- F 键:全屏切换
- O 键:概览模式(缩略图网格)
- Cmd+/-:浏览器缩放,所有 rem 元素同比例放大
- 方向键 / Space / PageUp/Down:翻页
- URL hash:`#s-3` 跳转到第 3 页
- 触屏:左右滑动翻页
- 打印:Ctrl+P 直接生成 PDF,自动隐藏控件

修改 HTML 内容时确保以上功能不受影响。
