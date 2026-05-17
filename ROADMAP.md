# raoqiu-slide-builder · ROADMAP

> **这份文档是什么**:记录"已识别但暂时不做"的功能 — 不是被否决,是**饶秋说"以后可能想做"**(2026-05-11 PROPOSAL-v5 §4 决策 D1 全部保留)。
>
> **怎么用**:以后某天觉得"现在想做这条了",来这里翻;复制对应条目的实施思路 + 参考实现路径 → 启动 vN 升级。
>
> **跟 CHANGELOG 的区别**:CHANGELOG 记录"已经做过的",ROADMAP 记录"暂时不做但可能想做的"。

---

## R1 · Show Don't Tell · 生成 3 个预览给用户选

**思路**:大纲澄清完成后,AI 先生成 **3 个封面预览**(不同主题节奏 / 衬线 vs 无衬线 / WebGL 开关),用户挑一个再做整份 20 页。

**为什么 v5 不做**:培训交付场景过度(3 倍 token),饶秋通常已有明确风格诉求("McKinsey 风")。

**什么时候可能想做**:
- 给学员 / 合作讲师用饶秋 skill 时 — 他们没有"McKinsey 风默认认知",需要先看预览选风格
- 给非培训客户提案时(发布会 / 演讲 / 投资人路演)

**参考实现**:
- 路径:`02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/frontend-slides/SKILL.md` Phase 2
- 关键代码:Phase 2 Style Discovery → Step 2.2 Generate 3 Style Previews

**预估工程量**:4 小时

---

## R2 · Vercel 一键部署集成

**思路**:生成 HTML 后 `bash scripts/deploy.sh` 一键发布到 Vercel,得分享 URL。

**为什么 v5 不做**:培训现场用本地 HTML / U 盘 / 离线投影,饶秋不需要公网。

**什么时候可能想做**:
- 远程培训 / 异步分发场景:学员在家看培训回放
- 客户内部传播 PPT(需要短链)
- 录播课配套 PPT 链接

**参考实现**:
- 路径:`02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/frontend-slides/scripts/deploy.sh`
- 依赖:Vercel CLI + Node.js

**预估工程量**:1.5 小时

---

## R3 · PPTX → HTML 转换

**思路**:用户传 .pptx 文件,Python `python-pptx` 库提取内容 → 套饶秋模板生成 HTML。

**为什么 v5 不做**:饶秋工作流是大纲 → HTML,不是 PPTX → HTML;且 PPTX 里大量手工设计很难自动套模板。

**什么时候可能想做**:
- 接手客户老 PPT 重做时 — 客户给一个旧版 PPT 说"按你的风格重做",目前手工大纲化,有 PPTX 转换会快 10 倍
- 接手第三方讲师 PPT 来标准化

**参考实现**:
- 路径:`02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/frontend-slides/scripts/extract-pptx.py`
- 依赖:`pip install python-pptx`

**预估工程量**:3 小时(转换 + 测试老 PPT 不破)

---

## R4 · 12 主题系统(多风格选择器)

**思路**:像 frontend-slides 一样维护 12 个主题(Bold Signal / Neon Cyber / Paper & Ink 等),用户选一个。

**为什么 v5 不做**:饶秋人设是"McKinsey 风的程前式干净简单",不是"多风格设计工作室"。**多主题会模糊饶秋个人标签**。

**什么时候可能想做**:
- 饶秋以后做"非培训"内容时 — 比如做产品发布 / 个人作品集 / 婚礼请柬 / 课件 SaaS 化售卖
- **那时考虑做一个"raoqiu-slide-builder-pro"独立 skill**,不在主 skill 里加(避免模糊主品牌)

**参考实现**:
- 路径:`02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/frontend-slides/STYLE_PRESETS.md`
- 12 主题的完整定义(Vibe/Layout/Typography/Colors/Signature)

**预估工程量**:2-3 天(每个主题 2 小时调试 + 自检兼容)

---

## R5 · URL 提取 Brand DNA(Firecrawl MCP)

**思路**:给一个公司 URL,Firecrawl MCP 自动抓取 colors / fonts / logo / voice,生成 Brand Style 卡片。

**为什么 v5 不做**:v5-beta 改造 9(Brand Style 卡片)是**手动填**,够用了。Firecrawl MCP 依赖额外 API key,工程链路重。

**什么时候可能想做**:
- Brand Style 卡片用熟以后,如果觉得"每次手动填 5-10 分钟太慢"
- 客户数量大幅增长(每月 5+ 新客户)
- 想自动化"客户简称 → 卡片自动生成"流程

**参考实现**:
- 路径:`02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/power-design/lib/extract-brand.md`
- 依赖:Firecrawl MCP(需注册 API key)

**预估工程量**:1.5-2 小时

---

## 怎么决定"什么时候启动 vN 升级"

每条都有 **"什么时候可能想做"** 的具体触发场景。下次饶秋发现某个场景反复出现,就回这里翻:

- "我这个月接手了 3 份老 PPT 要重做" → 启动 R3(PPTX 转换)
- "我要做远程培训了,需要分享链接" → 启动 R2(Vercel 部署)
- "我打算把课件 SaaS 化,要做多风格选择器" → 启动 R4(12 主题)
- "我现在每周都新加客户,卡片填不动了" → 启动 R5(URL 提取)
- "我要做产品发布会 PPT 给学员看" → 启动 R1(Show Don't Tell)

---

## 升级新条目的格式

如果以后发现新的"想做但暂时不做"功能,按这个格式追加:

```markdown
## R6 · [简短功能名]

**思路**:[一句话功能描述]

**为什么 vX 不做**:[当前优先级低的原因]

**什么时候可能想做**:[具体触发场景]

**参考实现**:[路径 / 项目 / 文档]

**预估工程量**:[小时 / 天]
```

---

## 跨档案引用

- 历史决策记录:[`99-归档-Archive/raoqiu-slide-builder-proposals/PROPOSAL-v5-2026-05-11-approved-implemented.md`](../../../99-归档-Archive/raoqiu-slide-builder-proposals/) §4
- 通读笔记(为什么这 5 条被识别为机会):[`02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/通读笔记-2026-05-11.md`](../../../02-参考资料-References/演示工具-PresentationTools/他山之石-OtherSlideSkills/通读笔记-2026-05-11.md) §5
- 已做的升级:[CHANGELOG.md](CHANGELOG.md)
