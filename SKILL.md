---
name: Rao-HTML-to-PPT
zh_name: "饶秋老师 HTML PPT 标准生成器"
en_name: "Rao HTML to PPT"
emoji: "🎯"
description: 基于饶秋老师 McKinsey 风 HTML PPT 标准模板(v5.6),生成结构清晰、克制专业、带麦肯锡咨询气质的培训课件、汇报演讲、提案材料。**支持三种模式**:Mode A 新建一份 PPT / Mode B 把 Markdown 大纲转成 PPT / Mode C 改/优化/扩展已有 HTML PPT。当用户要求"做 PPT""做培训课件""做汇报""做客户提案""把大纲变成 PPT""改一下这页""加一页讲 XX""更新这份课件的数据""按我的风格做"时,必须使用此技能。也支持 PDF 导出、PPTX 导出和一键自检脚本。包括但不限于:Cowork 中上传课程大纲生成 HTML PPT / 给老课件改局部 / 客户提案 / AIGC 培训交付。即使用户没明说"麦肯锡风",只要场景是企业培训 / 咨询汇报 / 商业提案 / 个人分享 / 演讲材料,都应触发。**边界声明(v5.6)**:本技能产出的 PPTX 是图片版(不可二次编辑);如需原生可编辑 PPTX 让客户/学员带回去改,推荐用 hugohe3/ppt-master 配合。配套:Brand Style 卡片自动加载、Ghost Deck Test 标题串读自检、Citation 强制(借用数据必有来源)、双主题切换(纸/墨 v5.1)、Inline Editing(浏览器内 E 键编辑 v5.2)、培训片五段循环大纲模板(v5.5)、SVG 数据 Dashboard 版式库(v5.5)、SVG icon 库 24 个基础图标(v5.5)、Anti AI-slop 反清单(v5.5)、CSS Gotchas 踩坑警示档(v5.5)、**spec_lock 长 deck 防漂移机制(v5.6 · 每页重读)**、**Quality Gate 导出前硬门控(v5.6 · raoqiu-check --strict)**、**多渠道输入工具表 PDF/DOCX/Excel/URL/PPTX→Markdown(v5.6)**、**examples/ 真实成片示范库(v5.6)**、scripts/ 提供 PDF 和 PPTX 导出 + 合规自检。
category: slides
scenario: training-presentation
surface: ["keynote-live", "pdf-archive", "pptx-editable", "html-share", "wechat-article"]
design_system: mckinsey-paper-dark
aspect_hint: "16:9"
modes: ["A-new", "B-outline-to-deck", "C-enhance-existing"]
themes: ["mckinsey-blue", "paper-ink", "dark-botanical"]
version: "5.6.0"
tags: ["training", "presentation", "mckinsey", "paper-ink", "dark-botanical", "chinese", "consulting", "html-slides", "wysiwyg-edit", "svg-charts", "dashboard", "training-cycle", "anti-ai-slop", "spec-lock", "quality-gate", "multi-input"]
repo: "https://github.com/raoqiu29-bot/Rao-HTML-to-PPT"
license: MIT
---

# 饶秋老师 HTML PPT 标准化生成技能

## 这是什么

这是饶秋老师本人的 HTML PPT 标准模板系统,基于 McKinsey 咨询报告视觉语言深度定制。

**包含**:
- **一份生产可用的 `assets/template.html` 标准模板**(单文件 HTML,自包含)
- **一套 McKinsey 风设计规范**(配色、字体、留白、品牌身份)— 见 `references/design-system.md`
- **12 种可复用版式**:封面 / 章节扉页 / 卡片网格 / 数据对比 / 提示词代码块 / 学员任务卡 / Key Insight 洞察 / 流程时间线 / 2x2 战略矩阵 / 结尾 / **Big Number 整页大数字** / **Big Quote 整页大引用** — 见 `references/layouts.md`
- **一份 P0-P3 分级的质量检查清单** — 见 `references/checklist.md`

**模板自带交互**:M 键大纲(支持拖拽重排)、F 键全屏、Cmd+/- 字号缩放、O 键概览、URL hash 同步页码、触屏左右滑动、PDF 打印友好。

## 触发场景

只要满足以下任一条件,必须使用此技能:

1. 用户提到"按饶秋老师的风格""按我的标准模板""按我的咨询风"做 PPT
2. 用户上传一份课程大纲、培训内容、提案框架,要求转成 PPT / 课件 / 演讲材料
3. 用户在 Cowork 中要求生成 HTML 格式的演讲材料
4. 用户提到"做培训课件""做汇报""做 PPT""做客户提案"且场景明显是企业培训、咨询汇报、商业提案
5. 用户明确说要"麦肯锡风""咨询报告风""极简商务风"

---

## 使用流程

### Step -1 · 确认 Surface 目标(v5.3 新增 · 借鉴 html-anything 多 surface 概念)

**做 PPT 之前先问:做完给谁看 / 在哪看?** 不同 surface 影响 skill 输出策略。

| Surface | 场景 | 输出优化 |
|---|---|---|
| 🍎 **keynote-live**(现场演示 · **默认**) | 培训现场投影 / 内部分享 | Safari 优先 / 双主题切换开 / 全屏 F 键 / E 键现场编辑 |
| 📄 **pdf-archive**(留档归档) | 客户提案 PDF / 学员资料 | 跑 `scripts/export-pdf.sh` / 关 WebGL 背景节省渲染 / 1920×1080 标清 |
| 📊 **pptx-editable**(PowerPoint 客户用 · v5.4 新)| 客户惯用 PowerPoint/Keynote / 团队协作改稿 | 跑 `scripts/export-pptx.sh` / 每页高清图打包 .pptx(视觉 100% 保真但不能改字)|
| 🌐 **html-share**(链接分享) | 远程培训 / 学员异步学习 | 保留单文件 HTML 自包含 / 加 viewer notes 元信息(可选)|
| 💬 **wechat-article**(公众号转写) | PPT 内容转公众号文章 | **不直接做** → 引用 md2wechat skill 处理 |

**判断**:
- 用户没明说 → **默认 keynote-live**(培训现场最常见)
- 用户提"PDF""留档""归档" → **pdf-archive**
- 用户提"PPT 给客户改""PowerPoint""Keynote""可编辑""客户团队用" → **pptx-editable**(v5.4 新)
- 用户提"链接""学员看""异步""远程" → **html-share**
- 用户提"公众号""转文章""发推文" → **wechat-article**(转给 md2wechat skill)

**为什么这一步重要**:同样内容,**演示用 PPT 需要双主题 + 动效 + 编辑能力**,**PDF 归档需要静态稳重 + 打印友好**,**链接分享需要文件小 + 字体 CDN 优化**。先确认 surface 才能给对的输出。

### ⚠️ 边界声明 · 何时用本技能 vs 何时用 PPT Master(v5.6 新增 · 诚实优先)

**本技能(Rao-HTML-to-PPT)的强项**:
- 🍎 HTML 现场演讲(键盘翻页 / 全屏 / 大纲面板 / 触屏 / Inline E 键编辑)
- 🎯 McKinsey 风深度锁死(单一风格,不稀释辨识度)
- 📚 培训片五段循环大纲 + 时长表(4 小时 = 100-140 张这种基准)
- 🎨 双主题切换 / SVG 数据 Dashboard / 24 个 SVG icon 统一规范
- 📄 PDF 导出(图片版),📊 PPTX 导出(**图片版,不可二次编辑**)

**本技能的边界**(实事求是说):
- ❌ **导出的 PPTX 是图片版**——每页一张大图塞进 PowerPoint,客户拿到后**不能改文字、不能换图表数据、不能挪元素**
- ❌ 不支持 PDF/DOCX/URL 直接转 PPT(Mode B 输入靠 markdown,转换走 `references/source-input.md` 的工具表)
- ❌ 不做 TTS 旁白 / 视频导出 / 声音克隆

**何时去用 [hugohe3/ppt-master](https://github.com/hugohe3/ppt-master)(17.8k stars)**:

| 场景 | 推荐工具 |
|---|---|
| 现场演讲投影 / 培训交付 | ✅ **本技能**(HTML 最适合) |
| 客户拿到后**想点开改某一行字** | ✅ **PPT Master**(native DrawingML,真可编辑) |
| 学员拿到后**想改成自己的版本** | ✅ **PPT Master** |
| 莱美客户经理**要换 logo / 加客户名** | ✅ **PPT Master** |
| 客户提案**对方要插入自家数据** | ✅ **PPT Master** |
| PDF/DOCX/URL 直接转 PPT(不想自己挑骨架) | ✅ **PPT Master**(他们 source_to_md 工具集 6 个脚本封装好了) |
| 需要 PPTX 内嵌真 OOXML 入场动画 + 转场 | ✅ **PPT Master** |
| 需要带旁白的视频导出 / 用克隆声音念 PPT | ✅ **PPT Master** |

**两个工具是互补关系,不是替代关系**。最佳工作流:
- **现场用本技能 HTML 演讲**(键盘翻页 / 双主题 / 大纲拖拽)
- **同一份内容用 PPT Master 出一份可编辑 PPTX 给客户/学员带走**(他们可以在 PowerPoint 里继续改)

PPT Master 本地副本在 `/Users/raoyuli/Desktop/Skills/02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/ppt-master/`。

**借鉴源**:[nexu-io/html-anything](https://github.com/nexu-io/html-anything) 的"9 个 output surface"概念(2.6k stars)— 让用户明确目标平台,skill 自动适配输出规则。

### Step 0 · 检测模式(v5-beta 新增 · 借鉴 frontend-slides Phase 0)

**先判断用户在干啥,再走不同分支**。不要默认"新做一份 PPT"。

| 模式 | 触发条件 | 走哪个流程 |
|---|---|---|
| **Mode A · 新建** | 用户给主题 / 大纲 / 想法,要从零做 | Step 1 → Step 6(主流程) |
| **Mode B · 大纲转换** | 用户给完整 Markdown 大纲(`大纲-v1.md` 或文档) | **跳过 Step 1 澄清**,直接进 Step 1.7 节奏规划 |
| **Mode C · 增强已有**(v5-beta 重点) | 用户上传旧 HTML PPT 要"改一下""加一页""更新数据" | 走下方 Mode C 专属流程 |

**如何判断**:
- 用户说"做一份 / 帮我搭 / 从头开始" → **Mode A**
- 用户贴大纲 / 上传 .md / 说"按这个大纲做" → **Mode B**
- 用户上传 .html / 说"改一下""加一页""把第 5 页换成" → **Mode C**

---

### Mode C 专属流程 · 增强已有 PPT(v5-beta 新增)

**为什么单独流程**:饶秋实战里"改老课件比做新课件多 3 倍"。v4 完全没考虑这个场景,导致 AI 上来就重做整份,浪费 token 还破坏老内容。

#### Mode C · Step 1:盘点现状(动手前必做)

读用户传来的 HTML,**先 grep 数清楚**:

```bash
# 盘点命令模板(AI 自己跑或用 Read 工具看)
grep -c '<section class="slide' file.html    # 总页数
grep -c '<div class="chapter">' file.html    # 章节扉页数
grep -c '<div class="insight-page">' file.html  # Key Insight 数
grep -c '<div class="big-number">' file.html    # Big Number 数
grep -c '<div class="big-quote">' file.html     # Big Quote 数
grep -c '<div class="page">' file.html          # 信息处理页数
grep -c '<div class="card mini' file.html       # mini 卡片数
```

汇报给用户:"现在 PPT 有 20 页,其中 hero 8 张(包括 3 章节扉页/2 Big Number/2 Key Insight/1 Big Quote),信息页 12 张(8 cards/3 metric/1 pipeline)。"

#### Mode C · Step 2:检查密度限制

对照 [layouts.md](references/layouts.md) 密度规则:
- 章节扉页 ≤ 5(超量 → 模块设计有问题,可能要合并)
- Key Insight ≤ 3(超量 → 强调价值递减,要砍掉几张)
- Big Number ≤ 3 / Big Quote ≤ 2
- 连续 ≥ 4 页卡片网格不允许
- 重音页 ≤ 1/3 总页数(超量 → 节奏疲劳)

发现违规直接告诉用户:"现在有 6 个章节扉页,超过 5 张上限,建议合并模块 X 和模块 Y。"

#### Mode C · Step 3:用户请求映射

用户的请求**映射到具体修改方案**:

| 用户请求 | AI 做什么 |
|---|---|
| "加一页讲 XX" | 找最合适的版式 → 确认插入位置(在第几页之后)→ 用户确认后插入,不破坏前后页 |
| "把第 5 页换成 XX" | 读第 5 页原内容 → 跟用户对齐新内容(SCQA 是否一致)→ 替换 section 内容,**保留前后 chrome** |
| "更新数据"(同一份 PPT,数字变了) | 找所有 metric / Big Number / Insight 的数据 → 列出 → 用户确认 → 批量替换 |
| "改字号 / 改颜色 / 改字体" | **优先用 v5 的 `:root` 变量改一行**,不要每个版式都改 |
| "把第 8 页拆成两页"(密度超了) | 拆页 + 加新 section + 调 chrome 页码(注意 JS 自动 + 1) |

#### Mode C · Step 4:主动 reorganize(关键)

**不等用户说,发现要溢出就自动拆页 + 告诉用户**:

> "您加这一页内容后,模块二会连续 5 页卡片网格(超过 4 页上限),听众容易疲劳。建议:① 把第 3 页拆成 metric + Key Insight 制造节奏 ② 删掉第 4 页(内容跟第 3 页重复)。您选哪个?"

主动 reorganize 的判断时机:
- 加 section 后 → 检查重音节奏 / 卡片密度 / hero 比例
- 改 section 后 → 检查类名预检(改完不要漏类)
- 删 section 后 → 检查总页数 / chrome 页码 / 章节是否还连贯

#### Mode C · Step 5:改完跑自检脚本

```bash
bash scripts/raoqiu-check.sh <改后的文件>
```

要求 P0 全过,才能交付。

---

### Step 0.5 · 看 examples/ 示范片(v5.6 新增 · 借鉴 ppt-master examples/)

**做什么**:开始 Step 1 之前,先 `ls examples/<scenario>/` 看对应场景子目录有没有真实示范片。

| 用户场景 | 看哪个子目录 |
|---|---|
| 培训片 / 课件 / 培训交付 | `examples/training/` |
| 客户提案 / 销售演示 | `examples/client-proposal/` |
| 莱美对外文档 | `examples/laimei/` |
| 自媒体单页 / 小红书图集 | `examples/xhs-or-self-media/` |

**有示范片就**:`Read` 一份(选最近期的或最像当前任务的),学它的版式选择 / 节奏 / 留白 / 标题写作风格,**这比读抽象规则有效得多**。

**没有示范片就**:跳过,按默认流程走。**不要因为目录空导致流程卡住**——examples 是辅助,不是前置。

详细规则 + 脱敏要求见 `examples/README.md`。

### Step 1 · 需求澄清(动手前必做,绝不跳过)

**这一步对应饶秋老师的核心工作哲学**:大纲未定型不动手。问清楚再做,**省的是 token,赚的是质量**。

#### 问的方式(v5-beta 升级 · 两套并存)

**优先尝试 · 模式 1:一次问完(AskUserQuestion 表单)**

如果运行环境支持 `AskUserQuestion` 工具(Claude Code 新版 / 部分平台),**用一个 AskUserQuestion 一次性问 6 个问题**,用户填表式回答 — 比顺序对话快 5-10 倍。

```
AskUserQuestion(
  questions: [
    { header: "受众",     question: "受众/场景?",      options: ["企业内训", "客户提案", "公开演讲", "内部汇报"] },
    { header: "时长",     question: "多长时间/页数?",  options: ["15分钟≈10页", "30分钟≈20页", "45分钟≈25-30页", "60分钟≈30-40页"] },
    { header: "素材",     question: "有原始素材吗?",   options: ["完整大纲", "粗略笔记", "只有主题", "旧PPT要改"] },
    { header: "Brand",    question: "客户Brand Style?", options: ["已有卡片(给简称)", "临时填一份", "用默认McKinsey风"] },
    { header: "重点",     question: "关键模块/论点?",  multiSelect: true, options: ["现状分析", "根因诊断", "解法方案", "案例数据", "行动建议"] },
    { header: "约束",     question: "有硬约束吗?",     options: ["合规禁用词", "必须包含特定数据", "客户名隐私", "无特别要求"] }
  ]
)
```

**兜底 · 模式 2:顺序问 6 问(普通对话)**

如果运行环境不支持 `AskUserQuestion`(Cowork / Claude.ai 网页 / 旧版客户端),**退回顺序对话**:

按下面这 6 问逐项对齐:

| # | 问题 | 为什么要问 |
|---|---|---|
| 1 | **受众是谁?场景是?**(企业内训 / 客户提案 / 公开演讲 / 内部汇报) | 决定用语深度和风格 |
| 2 | **多长时间 / 多少页?** | **15 分钟≈10 页 / 30 分钟≈20 页 / 45 分钟≈25-30 页 / 60 分钟≈30-40 页** |
| 3 | **有没有原始素材?**(大纲 / 旧 PPT / 文章 / 数据) | 有素材就基于素材,没有就帮搭骨架 |
| 4 | **客户 Brand Style?**(v5-beta 升级) | 客户简称 → 查 `references/brand-styles/{简称}-brand.md`;找不到就让用户回答客户色 + 行业 + 合规约束(详见下方"Brand Style 自动加载") |
| 5 | **关键模块 / 关键论点?** | 锁主线,避免后期返工 |
| 6 | **硬约束?**(必须包含 / 绝不能出现 / 合规要求) | 培训客户名、健康数据、内部团队成员等不能进 PPT |

**信息不足时必须先问,绝不直接开始生成 HTML** — 一旦开始生成,token 消耗会快速上升。

### Brand Style 自动加载(v5-beta 新增)

第 4 问"客户 Brand Style"的工作流:

1. **用户给客户简称**(例:"客户 A"、"客户 B"、"化名 A")
2. **AI 优先查 `references/brand-styles/{简称}-brand.md`**:
   - **找到** → 直接读取并应用(客户色 / 字体偏好 / Tone / 合规禁用全自动),告诉用户"已加载 [客户] Brand Style v2026.XX,确认无误吗?"
   - **找不到** → 让用户**选**:
     - 选 A:**临时填一份**(读 `references/brand-styles/_template.md`,问用户必填字段,生成 `{简称}-brand.md`)
     - 选 B:**跳过 brand style**(用默认 McKinsey 风,不覆盖 --c-warm)
     - 选 C:**只给客户色,其他用默认**(简化版,跟 v4 一致)
3. **生成 PPT 时自动应用**:
   - 客户色 → 加到 `<style>` 末尾 `body.theme-mckinsey { --c-warm: #XXXXXX; }`
   - 合规禁用词 → 在生成过程主动避开
   - Tone → 用文案影响语言风格
4. **培训完成后回填**(可选):
   - 培训交付完,把学员数 / 满意度 / 30 天活跃数据回填到 brand-style 卡片的 Tracking 表

**Brand Style 卡片包含什么**(详见 `references/brand-styles/_template.md`):
- **基础信息**:行业 / 培训对象 / 时长 / 场景
- **Colors**:客户色 hex / 禁用色
- **Typography**:客户惯用字体 / 禁用字体
- **Tone**:行业语言风格 / 称呼习惯 / 数据陈述偏好
- **Compliance**:行业合规禁用词(医药"治愈"、金融"稳赚"等)/ 强制包含 / 对外可用 vs 不可用客户名

**为什么不用 v4 的"客户色"简化机制**:
- v4 只问 hex,但实际场景客户有 Tone / 合规 / 禁用词等多维约束
- 每次培训都重新问 5-10 分钟,效率低
- 半年后回访同一客户,前面问的全忘了
- Brand Style 卡片 = 客户记忆 + 自动应用,效率高 10 倍

### Step 1.5 · 大纲搭骨架(用户没大纲时必做)

如果用户给了完整大纲,直接进 Step 1.7。
如果只给了主题 + 模糊想法,**用 SCQA 模板**搭骨架,再让用户确认:

```
SITUATION   (现状)        → 1-2 页 :用数据说现在多痛
                                     版式:metric-row + split / Key Insight
COMPLICATION (根因)        → 1 页   :为什么会这样?
                                     版式:Key Insight(必带数据)
QUESTION    (核心问题)     → 1 页   :一句话提问
                                     版式:Big Quote 或单独大字页
ANSWER      (解法主体)     → 主体 2-4 个模块 :每模块章节扉页 + 3-5 页内容
                                     版式:卡片网格 / pipeline / matrix-2x2 / prompt-block
EVIDENCE    (案例 / 实操)  → 每模块尾 1-2 页:具体演示
                                     版式:prompt-block / task-card
TAKEAWAY    (收束)         → 1-2 页:Key Insight + ending
                                     版式:Big Number 或 Big Quote 收尾
```

**为什么是 SCQA**:这是真正麦肯锡咨询报告的标准结构(Barbara Minto《金字塔原理》),跟"标题即结论"+"数据驱动"完美契合,也跟饶秋老师的"先讲清问题再讲解法"哲学一致。

大纲建议保存为 `大纲-v1.md`,便于迭代。

### Step 1.6 · 锁 spec_lock(v5.6 新增 · 借鉴 ppt-master 防漂移机制)

**触发条件**(任一命中就做):
- 培训片 ≥ 20 页
- 客户提案 ≥ 12 页
- Mode B(把外部大纲转 deck)
- Mode C 加 ≥ 5 页

**做什么**:在对话里输出一份 **spec_lock**(机器可读的"动笔前最后一次确认设计参数")。
完整模板:`references/spec-lock-template.md`。

**核心 12 个字段**(简版,完整版见模板):
- `colors`(c_brand / c_warm / c_ink_2 / c_ink_3 / c_line + 5 个 dashboard 语义色)
- `fonts`(中英无衬线 + mono + 衬线只用 5 处)
- `client_override`(客户色是否覆盖 c_warm,登记 hex 和理由)
- `pii_safety`(健康数据 / 莱美内部 / 学员真名 三个红线)
- `data_sources`(凡用了外部数据,在这里登记 source,Citation 强制)
- `rhythm`(章节扉页 ≤ 5 / Insight ≤ 3 / Big Number ≤ 3 / Big Quote ≤ 2)
- `layouts_used`(hero / info / dashboard 各用了哪些版式)

**生成时纪律**:
- 写每一页前**重读一次 spec_lock**,所有颜色 / 字体 / 客户名 / 数据 hex 必须从 spec_lock 取
- **不许凭记忆**——长 deck 下记忆会漂移,v4 时代我们撞过(深蓝 `#051C2C` 从第 7 张悄悄滑到 `#0A2540`)
- 一旦发现漂移,**立即停手再修**,不要"继续写完再统一替换"

**这条为什么很值得**:PPT Master(hugohe3)17.8k stars 的核心机制就是"SPEC_LOCK RE-READ PER PAGE",写在 SKILL.md 第 28 条规则,跟红线一样。我们撞过同样的坑,这次把方法补回来。

### Step 1.7 · 页面节奏规划(动手写 HTML 前必做)

光有大纲不够,**还要画一张"页面节奏表"** — 每一页明确写下:页码 / 版式名 / 是否重音页 / 主题色调。

**硬规则**:
- 章节扉页 **≤ 5 张**(模块设计上限,5 个模块封顶)
- Key Insight **≤ 3 张**(强调价值递减)
- **连续 4 页以上卡片网格不允许** — 听众视觉疲劳
- 25 页以上 deck **至少 3 个章节扉页**作为视觉重音
- **Hero 页(章节扉页 / Big Number / Big Quote / Key Insight)与信息页(卡片 / metric / pipeline / task-card)交替** — 类比"重音 + 弱拍"

**节奏表样例**(20 页课件 · v5-beta 升级:加"选版式的原因"列,AI 必须 defend choice):

| 页 | 版式 | 类型 | **选这个版式的原因**(v5-beta 强制) |
|---|---|---|---|
| 1 | 封面 | hero | 开场必备,定调子 |
| 2 | 章节扉页 · 模块一 | hero | 进入模块一,需要节奏重音 |
| 3-5 | 卡片网格 / metric | 信息 | 模块一三组信息平等并列(cards),其中一页有 3 个对比数字(metric) |
| 6 | Key Insight | hero | 模块一关键洞察 · 带数据 + 来源 |
| 7 | 章节扉页 · 模块二 | hero | 模块切换重音 |
| 8-10 | pipeline / prompt-block / task-card | 信息 | 模块二讲流程(5 步 Pipeline)+ 提示词模板(prompt-block)+ 学员任务(task-card) |
| 11 | Big Number | hero | 单数字震撼比 metric-row 三数字平均更狠 |
| 12 | 章节扉页 · 模块三 | hero | 模块切换重音 |
| 13-16 | 卡片网格 / matrix-2x2 | 信息 | 模块三四个方向比较(matrix)+ 多组要点(cards) |
| 17 | Big Quote | hero | 收束金句 · 纯主张不带数据,Big Quote 比 Key Insight 更轻 |
| 18 | 章节扉页 · 模块四 | hero | 转入收束 |
| 19 | Key Insight 收束 | hero | 收束最大论点 · 带数据 |
| 20 | 结尾页 | hero | 行动建议,绝不写 Thank You |

### 为什么节奏表必须带"选版式的原因"(v5-beta 强制 · 来自 mckinsey-pptx 的 Defend Choice)

**没有这条之前**:AI 默默选版式 → 用户看到生成的 PPT 才发现"这页应该用 metric 不是 cards" → 返工 → 浪费 token + 时间。

**加这条之后**:AI 在节奏规划阶段就**写出选择理由** → 用户在节奏表对齐时就能发现"AI 选错了" → 在大纲层就改完 → 不浪费 token 做整页 HTML。

**规则**:
- 节奏表每一行**必须**有"选这个版式的原因"这一列
- 理由要**具体**(数字 / 内容形状 / 节奏需求 / 跟前后页的关系),不要写"看起来合适"这种泛泛而谈
- 反例:"这页用 cards" — ❌ 没说为什么
- 正例:"这页用 cards 因为有 3 个平等并列的根因,cols-3 正好" — ✅ 数字 + 形状 + 关系都说清

**用户审核节奏表(包括理由)后,才进 Step 2 拷贝模板。不要跳过这步**。理由本身就是"节奏规划质量"的体现,理由空 = 没想清楚。

### Step 2 · 动手前预检(最重要,容易跳过)

**写任何 `<section>` 之前,必须做这件事**:

1. **Read 一遍 `assets/template.html` 的 `<style>` 块**(从顶部到第一个 `</style>` 闭合)
2. 把 Step 1.7 节奏表里要用的版式类名跟 style 块对一遍
3. 确认每个类都有定义,缺了就在 style 块里补,**不要在 section 里 inline 重写**

**最容易遗漏的类**(必须确认存在):
`.card.warm-mark` / `.insight-tag` / `.insight-body` / `.insight-source` / `.q-tag` / `.matrix-2x2 .quadrant.highlight` / `.process-flow .step.active` / `.metric .v` / `.split .col.brand` / **`.serif-hero`(本次新增,衬线大字)** / **`.serif-quote`(本次新增,衬线引用)** / **`.big-number .v`(本次新增)** / **`.big-quote`(本次新增)**

**为什么这一步最重要**:99% 的"样式没生效""字号变小""卡片样式丢失"问题都是因为 AI 临时发明类名,或者 template.html 里根本没定义这个类,浏览器 fallback 到默认样式。**所有问题都是这一步漏掉造成的。**

### Step 3 · 基于 template.html 填内容,绝不从零写

工作方法:

1. **复制 `assets/template.html` 作为起点**(不是参考,是起点)
2. **只修改 `<section class="slide">` 内的内容**,CSS 和 JS 一行不动
3. **`<body class="theme-mckinsey">` 的 class 不要动**
4. **不发明新版式 / 新类名**,有需要就在 `<style>` 块里补,不在 section 里 inline 重写

**填内容时**:
- 对照 `references/layouts.md` 找版式骨架,复制粘贴改文字
- 对照 `references/design-system.md` 看配色、字体、留白规范
- 衬线字体的边界规则在 `design-system.md` "字体分工" 一节 — **只在重音版式可用衬线**

### Step 4 · 自检 + Quality Gate 硬门控(v5.6 升级 · 借鉴 ppt-master)

生成完不要直接交付。

**4.1 走 checklist.md 人工对照**:
- 第一次做的人:从头到尾读
- 老手:跳到文末"最终自检清单"勾选

**4.2 跑脚本严格门控**(v5.6 强制):
```bash
bash scripts/raoqiu-check.sh --strict <file.html>
```
- ✅ `GATE PASSED` → 允许导出 / 交付
- ⛔ `GATE FAILED` → **禁止导出**,修完 P0 再重跑

**4.3 导出前再跑一次**(`export-pdf.sh` / `export-pptx.sh` 已经内置门控,自动跑一遍 `--strict`,FAIL 不导出):
```bash
bash scripts/export-pdf.sh <file.html>      # 内置 gate,FAIL 不导
bash scripts/export-pptx.sh <file.html>     # 内置 gate,FAIL 不导
```

**4.4 spec_lock 抽查**(如果 Step 1.6 锁了 spec_lock):
- 任挑 3 张片,搜 hex 颜色是否全在 `spec_lock.colors.*` 里
- 任挑 1 张数据页,数字是否登记在 `spec_lock.data_sources`
- 任挑 1 张衬线标题,是不是在 `serif_allowed_in` 5 处之一

**为什么要硬门控**:之前 P0 是"建议必跑",AI 急着交付时会跳。v5.6 改成"导出脚本强制先跑,FAIL 不导出"——绕不过去。紧急情况可以加 `--skip-gate` 跳过,但责任自负。借鉴 PPT Master 的 Quality Gate 思想:`error must be fixed before proceeding`。

### Step 5 · 输出

- **单文件 HTML,完全自包含**(所有 CSS/JS 内联,字体走 Google Fonts CDN)
- **文件名格式**:`{课程主题}-{客户简称}-{日期}.html`
  - 例:`AI办公提效-XX企业-202604.html`
- **保存到当前任务指定的输出目录**;在 Cowork 环境中可使用 `/mnt/user-data/outputs/`

---

## 核心原则

### 1. 严格 McKinsey 风格,不要摇摆

主色 `#051C2C` 极深蓝(不是亮蓝),用色比例 **80% 黑/灰/白 + 5% 品牌色 + 5% 客户色**,不要做"看起来很丰富"的设计。

### 2. 一页一观点,密度即气质

宁可多一页,不要挤一页。"留白"是核心审美。

### 3. 数据驱动,不空喊口号

引用洞察必须有数据支撑(看 Key Insight 版式),不要写"AI 改变世界"这种空话。

### 4. 衬线字体只用作"重音"(本次新规则,必须把握)

可用衬线的版式**只有 5 处**:封面 h1 / 章节扉页 h1 / Key Insight 大字 / Big Quote 大引用 / Big Number 大数字。其他位置(卡片、metric、pipeline、内页 page-title 等)**必须无衬线**。

衬线字体只用一种组合:**Noto Serif SC(中文)+ Fraunces(英文)**。Fraunces 是模板已加载的 Variable Font,有现代感且不偏文学;Noto Serif SC 与 Source Han Serif SC 是同一字体的不同发布名,与 Source Han Sans 字怀匹配。**不要混入 Songti SC / SimSun / Playfair / 其他衬线**。

如果衬线扩散到信息处理页 → 视觉系会从"咨询风"漂向"杂志风"。

### 5. 双主题切换 · 纸 / 墨(v5.1 新增 · 饶秋偏好默认)

**饶秋已实测后选定的两个最爱风格**:**Paper & Ink 纸墨白** 和 **Dark Botanical 暗色**。v5.1 把这两种风格沉淀进模板,**任何 PPT 都可以右上角一键切换 + T 键快捷键**。

**生成新 PPT 时**(强烈推荐):
- 在 body 标签加 `data-theme="paper"` 作为默认 → **默认显示 Paper & Ink 纸墨白底**(衬线 Cormorant + 红色强调)
- 用户现场需要切换 → 右上角点"纸 · 墨"按钮 / 按 T 键 → 切到 Dark Botanical 暗色

**body 标签写法**:
```html
<!-- 推荐:新 PPT 默认 Paper & Ink -->
<body class="theme-mckinsey" data-bg="fbm" data-theme="paper">

<!-- 可选:严肃客户提案保留 McKinsey 蓝(去掉 data-theme) -->
<body class="theme-mckinsey">
```

**三种主题对应场景**:
| 主题 | 触发 | 适用场景 |
|---|---|---|
| **Paper & Ink 纸墨**(v5.1 默认推荐) | `data-theme="paper"` | 培训现场 / 思想分享 / 演讲(白底高可读) |
| **Dark Botanical 暗色** | `data-theme="dark"` 或现场按 T 切换 | VIP 课 / 晚上分享 / 灯光暗时震撼 |
| **McKinsey 深蓝**(v5.0 兼容) | 无 `data-theme` 属性 | 严肃客户提案 / 咨询汇报 / 老 PPT 兼容 |

**切换器自动出现在右上角**,所有用 v5.1 模板生成的 PPT 都有这个能力。
**localStorage 记忆**:用户选过的主题,刷新 / 重新打开自动延续。

### 6. WebGL 背景默认关闭(本次新规则)

只在以下场景可开启:**AIGC 培训 / 行业分享 / 私享会**(允许"轻视觉感")。
不要开启:**客户提案 / 内部汇报 / PDF 输出 / 老旧投影场景**(可能掉帧)。

只允许 **FBM 噪波 shader**(纸感纹理),禁用 holographic / spiral vortex 等带强中心点的(那是发布会风,不是咨询风)。开关方式见 `design-system.md`。

### 7. 不动模板的功能

`assets/template.html` 自带的交互(M / F / O / **T(v5.1)** / **E(v5.2)** / Cmd+/- / 拖拽重排 / hash 跳转 / 触屏 / PDF 打印 / Ctrl+S 保存编辑)一个都不能破坏。

### 7.4 现场播放浏览器推荐(v5.2 实战验证)

| 场景 | 推荐浏览器 | 原因 |
|---|---|---|
| **培训现场播放** | **Safari**(macOS 自带) | WebKit 原生,无扩展生态干扰,**最稳** |
| 编辑 PPT / 用 E 键改文字 | Safari 或 Chrome 隐身 | 不被扩展拦截 keydown |
| Chrome 普通模式 | **不推荐现场用** | 翻译类 / Vimium / Tampermonkey 等扩展可能拦截方向键,出现"进度条动但页面不切"的诡异现象 |
| 分享给学员 / 客户 | **导出 PDF**(`bash scripts/export-pdf.sh`) | 学员环境不可控,PDF 永远稳 |

**饶秋实战教训**:某次现场用 Chrome 打开 v5.2 PPT,翻页失效;Safari 同文件完全正常。根因是 Chrome 装了"沙拉查词 / 沉浸式翻译 / Vimium"等扩展拦截键盘事件。**结论:Chrome 日常用,PPT 现场用 Safari**。

### 7.5 Inline Editing 内置(v5.2 新增 · 浏览器内可编辑)

**饶秋直接在浏览器里改 PPT 文字**,不用回 VS Code 翻源码。

**怎么用**:
- 打开 PPT(已经是 v5.2 模板生成的)
- 按 **E 键** 或点右上角"编辑 · E"按钮 → 启动编辑模式
- 编辑模式下,所有内容文字会显示彩色虚线边框(主题色 · 纸是红色 / 墨是金色 / 蓝色)
- 点任意文字直接改 → **Ctrl+S 保存** → 显示 "✓ 已保存到本地" toast
- 再按 E 或 Esc → 退出编辑模式
- **localStorage 记忆**:刷新 / 重开浏览器,自动延续上次的编辑

**可编辑范围**(允许动的):
- page-title / page-subtitle / 卡片 h3+p / metric / pipeline 步骤 / Key Insight / Big Number / Big Quote / 提示词块 / 学员任务卡

**不可编辑范围**(锁定 · 避免误改):
- 控件 UI(ctrl-bar / nav-arrows / page-num)
- page-meta(顶部模块标签 + 页码 chrome)
- 装饰元素(章节扉页 deco-num / hero 发光圆等)

**导出新 HTML**:浏览器 Console 跑一行
```javascript
window.raoqiuEdit.export()
```
会下载一份名为 `<原 title>-edited.html` 的新文件,**剥离所有编辑器状态,可以直接交付**。

**恢复出厂内容**:浏览器 Console
```javascript
window.raoqiuEdit.reset()
```
**会丢失所有编辑**,清空 localStorage 后重新加载原 HTML。

**生成 PPT 时无需特殊操作**:v5.2 模板自动包含这套机制,所有用 v5.2 模板生成的新 PPT 默认都能用 E 键编辑。

**借鉴来源**:Zara Zhang frontend-slides + archlizheng/frontend-slides-editable 的 contenteditable + localStorage 机制,简化适配饶秋 v5.1 双主题 + 12 版式结构。

### 8. 客户色用 `--c-warm`,不要换主色

### 8. 客户色用 `--c-warm`,不要换主色

主色永远 `#051C2C`。客户色覆盖到 `--c-warm`,**只**出现在三处:`.card.warm-mark` 左 3px 边 / Key Insight `.insight-tag` 红标 / 矩阵 `.quadrant.highlight` 边框。

---

## 决策规则(AI 自行判断)

### Pipeline 多步动效(逐步点亮)

**启用条件**:
- 用户说"我要在课上讲""现场分享""演示用"
- 用户提到"逐步揭示""一步一步讲"

**关闭条件**:
- 用户说"做成 PDF""打印用""异步阅读""客户自己看"
- 没有明确演示场景(默认关闭,保守)

**实现方式**:Pipeline `<section>` 加 `data-animate="pipeline"`,每个 step 加 `data-anim="step"`(详见 `layouts.md` Layout 8)。

### 中文大标题断行处理

| 位置 | 规则 |
|---|---|
| 封面 h1 / 章节扉页 h1 | **强制 ≤ 5 字 + `nowrap`**(超过让用户拆) |
| Key Insight 大字 / Big Quote / Big Number 注解 | 8-12 字两行,用手工 `<br>` 断行 |
| 内页 page-title(2.25rem) | 自由,正常断行即可 |

---

## 不要做的事

❌ **不要从零写 HTML** — 永远基于 `assets/template.html`
❌ **不要发明新版式 / 新类名** — 12 种现有的够用,需要小定制用 `style="..."` 内联
❌ **不要用渐变 / 大阴影 / 大圆角** — McKinsey 不用
❌ **不要在卡片/正文/内页用衬线** — 衬线只限 5 个重音版式
❌ **不要混入 Songti SC / SimSun / Playfair Display 等其他衬线** — 衬线只用 Noto Serif SC + Fraunces
❌ **不要用紫色 / 亮蓝 / 多色 / 玻璃拟态** — AI 风标志
❌ **不要在普通页背景铺深蓝** — 章节扉页是唯一深蓝整页
❌ **不要往一页里塞超过版式上限的内容** — 拆页
❌ **不要用 emoji 做装饰** — 除非内容本身就是 emoji 主题
❌ **不要导入外部框架(reveal.js / Slidev 等)** — 模板自带翻页引擎
❌ **WebGL 背景不要默认开** — 仅 AIGC 培训 / 分享场景按需开启

---

## Token 节约提示

饶秋老师非常在意 AI token 消耗。以下做法有效:

- **改动 < 文件 10% 时用 str_replace**,不要全文重写
- **新课程时只生成 section 片段**,让用户自己复制进 `assets/template.html`
- **大纲未定型不要生成完整 HTML** — 这是最费 token 的环节
- **不必要的 CSS 修改不做** — 模板已经调过很多版,大部分情况只改 HTML 内容就够

---

## 资源加载顺序建议

不要一次把所有 reference 文件全读进来 — 按阶段读,省 token:

| 阶段 | 该读什么 |
|---|---|
| Step 0 检测模式 | **不读 reference**,只用 SKILL.md |
| Step 1 需求澄清 | **不读 reference**,只用 SKILL.md;**第 4 问 Brand Style** 时读 `references/brand-styles/{客户简称}-brand.md`(找不到就读 `_template.md` 临时填) |
| Step 1.5 大纲搭骨架 | **不读 reference**,用 SKILL.md 里的 SCQA 模板 |
| Step 1.7 节奏规划 | 读 `layouts.md` 头部的"版式列表"挑版式 + 写"选版式的原因" |
| Step 2 动手前预检 | **必须 Read** `assets/template.html` 的 `<style>` 块 |
| Step 3 填内容 | 读 `layouts.md` 完整版式骨架 + `design-system.md` 配色字体 |
| Step 4 自检 | 读 `references/checklist.md`(末尾勾选清单)+ 跑 `bash scripts/raoqiu-check.sh <file>` 一键自动检查 |
| Step 5 输出 PDF(可选) | 跑 `bash scripts/export-pdf.sh <file>`(Playwright headless) |
| Mode C 改老课件 | 读老 HTML 文件 + 跑 `scripts/raoqiu-check.sh` 盘点 + 读 `layouts.md` 密度规则 |
| 用户问"为啥这条规则" / 想看历史 | 读 `CHANGELOG.md`(记录每次升级的原因和踩坑) |

---

## 关键词

HTML PPT, 培训课件, 麦肯锡风, McKinsey, 饶秋, 饶秋老师, AIGC 培训, 课程 PPT, 汇报材料, 演讲材料, Cowork PPT, 咨询报告风, 极简商务风, 深蓝极简, 客户提案, SCQA, 金字塔原理, Big Number, Big Quote
