# spec_lock 机制 · 长 deck 防漂移(v5.6 新增 · 借鉴 hugohe3/ppt-master)

> **真实踩坑**:v4 时代我们做 20+ 页的培训片,改完主色 `#051C2C` 之后,**前 6 张是新色,从第 7 张开始悄悄滑回旧的 `#0A2540`**。原因:long-context 下 AI"凭印象"写颜色,记忆漂移。

> **解法**:动笔前先把所有关键设计参数写成一份**机器可读的"锁定档"**(spec_lock),写每一页前**强制重读一遍**,所有值必须来自这份档,不许"凭记忆"。

---

## 什么时候用 spec_lock

**强制用**:
- 培训片 ≥ 20 页(模块切换时容易漂)
- 客户提案 ≥ 12 页(品牌色 / 客户色 / 数据来源是 P0,不能错)
- Mode B(把大纲转 deck,长度往往超 20 页)
- Mode C 改老课件 + 新加 ≥ 5 页(混入新页时最容易漂)

**可以省**:
- ≤ 5 页的单话题分享(范围太小漂不起来)
- 自媒体小红书图集(用另一个 skill,有独立锁)

---

## spec_lock 的位置

在生成 deck 之前,**先在对话里输出一份完整的 spec_lock**,然后再开始写 HTML。

不需要落盘成单独文件——**它就是"动笔前最后一次确认设计参数"的对话步骤**。每写一页之前,AI 在内心(或显式)对照这份 spec_lock,任何颜色 / 字体 / 客户名 / 数据 hex 都查它,不查记忆。

---

## spec_lock 完整模板

把下面这块直接复制到对话,改完里面的占位值,作为生成前的"锁"。

```yaml
# spec_lock · {项目名} · {日期}
# 这是本 deck 的硬约束,生成每页前重读一遍,所有值从这里取,不要凭记忆

project:
  name: "{项目名,例:迈瑞医疗 AI 培训 4 小时}"
  surface: keynote-live      # keynote-live / pdf-archive / pptx-editable / html-share / wechat-article
  mode: A                    # A 新建 / B 大纲转 / C 改已有
  total_slides: 0            # 不知道就写 0,执行中更新
  estimated_duration_min: 0  # 现场时长(分钟),培训片必填

theme:
  active: paper              # paper / dark / mckinsey-blue
  rationale: "{为什么选这个,例:培训现场用 paper 最不刺眼}"

colors:
  c_brand: "#051C2C"         # 麦肯锡极深蓝 · 主色 · 永远锁死
  c_warm: "#E53935"          # 客户色覆盖位置 · 一份 deck 出现 ≤ 3 处
  c_ink_2: "#2A3744"         # 二级文字
  c_ink_3: "#5C6772"         # 三级文字
  c_line: "#E5E7EB"          # 主线条
  # Dashboard 语义色(v5.5 新增,只在数据页用)
  c_up:    "#16A34A"
  c_down:  "#DC2626"
  c_warn:  "#F59E0B"
  c_flat:  "#6B7280"

  # ⚠️ 如果有客户色覆盖,在这里登记
  client_override:
    enabled: false
    target: "c_warm"         # 客户色只能覆盖 c_warm,绝对不能覆盖 c_brand
    value: ""                # 例:#005BAC(招行蓝)
    rationale: ""

fonts:
  zh_sans: "PingFang SC"
  en_sans: "Manrope"
  mono:    "JetBrains Mono"
  zh_serif: "Noto Serif SC"  # 衬线只用 5 处
  en_serif: "Fraunces"
  serif_allowed_in:
    - cover h1
    - chapter h1
    - insight-page (Key Insight)
    - big-quote
    - big-number 数字本身

typography:
  base_size: 20px            # v5 升级 · 培训现场可读性优先
  use_clamp: true

icons:
  source: "references/icons.md (Lucide 标准)"
  size_tiers: [inline, card, feature, hero]
  color_policy: |
    中性 → c_ink_3
    主色 → c_brand
    正向 → c_up
    负向 → c_down
    警告 → c_warn
  banned: [Material, FontAwesome, emoji 作版式装饰]

content:
  client_name: "{真实客户名,内部记账用,公开版本要脱敏}"
  client_pseudonym: "{脱敏代号,例:客户 A}"
  publish_audience: training-students  # internal / client-proposal / training-students / public
  pii_safety:
    contains_health_data: false
    contains_laimei_internal: false
    contains_real_student_names: false
    if_any_true_then: "强制脱敏,违反 CLAUDE.md 隐私红线"

rhythm:
  # 重音页用量上限
  chapter_max: 5
  insight_max: 3
  big_number_max: 3
  big_quote_max: 2
  # 总和上限
  hero_total_max: 13
  hero_ratio_target: "重音页 ≤ 1/3,弱拍 ≥ 2/3"

data_sources:
  # 凡用了外部数据,在这里登记 source,Citation 强制
  - slide: 0           # 第几张
    claim: ""          # 写了什么数据
    source: ""         # 来源,例:中国 AIGC 培训行业白皮书 2024 · 艾瑞
    verified: false

layouts_used:
  # 这份 deck 用到的版式,生成前先列清楚
  hero: []              # 例:[cover, chapter, insight-page, big-number]
  info: []              # 例:[card-grid, metric-row, pipeline, matrix-2x2]
  dashboard: []         # 例:[metric-card, donut, line-chart, sparkline]

charts:
  # 凡用到 SVG 图表,在这里登记数据 + 公式
  - slide: 0
    type: donut         # donut / gauge / line / bar / pie / sparkline / radar
    data: {}            # 例:{value: 89, total: 100}
    formula_note: ""    # 例:r=74 → circumference=465 → dashoffset = 465 × (1-89/100) = 51

quality_gate:
  must_pass_before_export:
    - "bash scripts/raoqiu-check.sh --strict <file>"
  on_fail: hard_stop_no_export

# ============================================================
# Per-page checklist · 写每一页前对照这份 spec_lock
# ============================================================
per_page_rules: |
  ✓ 颜色:只用 colors.* 里登记过的值,不许自己写新 hex
  ✓ 字体:body 用 fonts.{zh_sans,en_sans},衬线只在 serif_allowed_in 列出的 5 处
  ✓ icon:从 references/icons.md 24 个里挑,颜色按 icons.color_policy
  ✓ 客户名:出现客户色 → 检查 client_override.enabled 是否真的开了
  ✓ 数据:写了具体数字 → 检查是否登记在 data_sources(没登记不许写)
  ✓ 版式:这一页用的版式是否在 layouts_used 里(没在 → 要么加进去,要么换版式)
  ✓ 节奏:这一页是 hero 还是 info,hero 总数是否还在 rhythm.*_max 上限内
```

---

## 用法工作流(写入 SKILL.md 主流程)

### Step 1.6 · 锁 spec_lock(在 Step 1.5 大纲完成之后,Step 1.7 节奏规划之前)

**只在以下场景做**:培训片 ≥ 20 页 / 客户提案 ≥ 12 页 / Mode B / Mode C 加 ≥ 5 页。

**输出**:
1. 复制上方完整模板到对话
2. 填完所有空缺占位符(`{xxx}` 和 `""` `0` `false`)
3. **特别强调**:`client_override` 是否开启 / `pii_safety` 三项有没有命中 / `data_sources` 是否登记完
4. **明确告诉用户**:"接下来生成的每一页 HTML 都按这份 spec_lock 走,任何颜色 / 字体 / 客户名 / 数据 hex 出问题,我会先回查 spec_lock,不凭记忆"

### Step 3.5 · 每页生成前的"内心对照"

写每一页之前,AI 内心(或在 todo 备注里)对照一遍 `per_page_rules` 7 条。**漂移的 99% 出在颜色和字体上**,这两项必须查 spec_lock,不查记忆。

### Step 4.5 · 收尾自检时,顺带核 spec_lock

跑 `raoqiu-check.sh --strict` 后,人工对照 spec_lock 抽查:
- 任挑 3 张片,搜 hex 颜色是否全在 `colors.*` 里
- 任挑 1 张数据页,搜数字是否登记在 `data_sources`
- 任挑 1 张衬线标题,看是不是在 `serif_allowed_in` 5 处之一

---

## 如果生成中途发现漂移怎么办

**症状**:第 8 张片打开,主色变成了 `#0A2540`(不是 spec_lock 里的 `#051C2C`)。

**做法**:
1. **不要继续往下写** — 漂移会传染,后面 12 张全错
2. 用 sed 或 IDE 全局替换错色 → 正色
3. **回去看上一次"对话压缩"前后**:漂移多半发生在 context 接近上限被压缩的时候,模型把 spec_lock 的具体值忘了,改用"印象中的深蓝"
4. **强制重读 spec_lock**:在对话里粘贴一遍 spec_lock,告诉模型"这是硬约束,接下来每一页都按这个写"
5. 如果还漂,**拆 deck**:把剩下的页移到新对话,重新粘贴 spec_lock + 已生成的最后 1 页作上下文,继续写

---

## 为什么这条很值得

PPT Master(hugohe3)能从 0 stars 涨到 17.8k stars,**spec_lock + 每页重读**这个机制是核心原因之一。他们 SKILL.md 第 28 条规则原文是"SPEC_LOCK RE-READ PER PAGE"——每页重读,写得跟红线一样。

我们撞过同一个坑(v4 时代深蓝漂浅蓝),但当时没沉淀方法,只是改了 CSS 把"主色用 var"统一。这次借鉴 ppt-master,**把方法补回来**:

- 不靠 CSS 兜底,而是靠**生成时纪律**——所有值从 spec_lock 取
- 一旦 spec_lock 跟实际产出不一致,**先停手再修**,不要"继续写完再统一替换"

这是真正解决长 deck 一致性的工程方法,不是设计技巧。
