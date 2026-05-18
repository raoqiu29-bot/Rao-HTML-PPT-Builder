# Rao-HTML-to-PPT

> 一个为 **Claude Code / Claude Cowork** 设计的 HTML PPT 生成 skill。基于麦肯锡咨询视觉语言 + 全套工程纪律,**12 种版式 + 双主题切换 + SVG 数据 Dashboard + spec_lock 防漂移 + Quality Gate 硬门控**。专为企业培训、客户提案、思想分享等场景设计。

[![Skill Version](https://img.shields.io/badge/version-v5.6-blue)]() [![License](https://img.shields.io/badge/license-MIT-green)]() [![Claude Skill](https://img.shields.io/badge/Claude-Skill-orange)]()

## ⚠️ 何时用本技能 vs 何时用 PPT Master(v5.6 新增 · 诚实优先)

| 场景 | 推荐工具 |
|---|---|
| 🍎 现场演讲投影 / 培训交付 | ✅ **本技能**(HTML 最适合) |
| ✏️ 客户拿到后**想点开改某一行字** | ✅ **[hugohe3/ppt-master](https://github.com/hugohe3/ppt-master)**(native DrawingML,真可编辑) |
| 学员想拿回去改成自己的版本 | ✅ **PPT Master** |
| 莱美客户经理要换 logo / 加客户名 | ✅ **PPT Master** |
| PDF/DOCX/URL 直接转 PPT 不想自己挑骨架 | ✅ **PPT Master**(他们有 source_to_md 工具集 6 个脚本) |
| 需要 PPTX 内嵌真 OOXML 入场动画 + 转场 | ✅ **PPT Master** |
| 需要带旁白视频导出 / 用克隆声音念 PPT | ✅ **PPT Master** |

**两个工具互补,不是替代。** 最佳工作流:**现场用本技能 HTML 演讲 + 同一份内容用 PPT Master 出可编辑 PPTX 给客户带走**。本技能 PPTX 导出是**图片版**(每页一张大图,不可二次编辑),诚实说明。详见 `SKILL.md` "⚠️ 边界声明"段。

---

## 设计哲学(v5.3 借鉴 html-anything · 沉淀为正式原则)

> **"Markdown is the draft. HTML is what humans read."**
> — [nexu-io/html-anything](https://github.com/nexu-io/html-anything)

每次 skill 生成的产物**必须是 ship-ready 的成品**,不是"我等会再美化"的草稿。具体落地:

- **单文件 HTML 自包含** · 字体 / CSS / JS / 主题切换 / 编辑能力全 inline,不依赖外部资源
- **零依赖运行** · 双击就开,不需要 npm / build / server
- **跨平台兼容** · macOS Safari / Chrome 隐身 / Firefox 都能开,PDF 永远稳
- **现场就能改** · E 键编辑 + Ctrl+S 保存 + localStorage 延续,临场调整不用回源码
- **多 surface 适配** · keynote 演示 / PDF 归档 / 链接分享 / 公众号文章,4 种 surface 各自优化(详见 SKILL.md `Step -1`)

## 这个 skill 解决什么问题

做 PPT 时常见痛点:
- AI 默认审美兜底(紫色渐变 / 玻璃拟态 / 7 条 bullets 一页)
- 模板风格漂移(同一份 deck 混杂多种视觉系)
- 没有自检纪律(做完才发现问题)
- 老课件改起来很难(AI 直接重做,破坏原结构)
- 不同场景需要不同视觉(培训现场 vs 暗光分享)

这个 skill 用一套**工程纪律** + **设计语言锁定** + **双主题切换**解决这些问题。

---

## 核心特性

### 🎨 视觉系统
- **12 种版式**:封面 / 章节扉页 / 卡片网格 / metric+split / pipeline / matrix-2x2 / Key Insight / Big Number / Big Quote / prompt-block / task-card / 结尾
- **双主题切换 · 纸 / 墨**(v5.1 新增):
  - 🟫 Paper & Ink 纸墨白底衬线(培训现场)
  - ⚫ Dark Botanical 暗色艺术(VIP 课 / 暗光分享)
  - 🟦 McKinsey 蓝(严肃客户提案 · 向后兼容)
- 右上角"纸 · 墨"按钮 / **T 键快捷键** / localStorage 记忆
- 单文件 HTML 自包含(零依赖,inline CSS+JS)

### ⚙️ 工程纪律
- **8 步工作流**:6 问澄清 → SCQA 大纲 → 节奏表(带选版式理由)→ 动手前预检 → 填内容 → 自检 → 输出 → 迭代
- **三种模式**:
  - **Mode A** 从零做新 PPT
  - **Mode B** 已有 Markdown 大纲 → 跳过澄清直接生成
  - **Mode C** 改 / 优化 / 扩展已有 HTML PPT(主动 reorganize)
- **节奏铁律**:重音页 ≤ 1/3,弱拍 ≥ 2/3;章节扉页 ≤5;Key Insight ≤3;Big Number ≤3;Big Quote ≤2
- **Ghost Deck Test**:只看标题串读能讲完整个故事 = 通过(借鉴 Academic PPTX)
- **Citation 强制**:借用数据必有 source
- **Brand Style 卡片**:客户色 / 字体 / Tone / 合规约束一张表自动加载

### 🛠️ 工具链
- `scripts/raoqiu-check.sh` — 一键自检 P0 合规(13 项)
- `scripts/export-pdf.sh` — Playwright headless 导出 PDF(1920×1080 标准 / `--compact` 紧凑模式)

### 📚 文档体系
- `SKILL.md` — 工作流 + 决策规则(24 KB)
- `references/design-system.md` — 配色 / 字体 / 5 维度风格卡片 + 20 条带学术引用的设计原则(24 KB)
- `references/layouts.md` — 12 版式骨架 + HTML 结构 + 节奏铁律(14 KB)
- `references/checklist.md` — P0-P3 自检清单 + Ghost Deck Test + Citation(22 KB)
- `references/brand-styles/_template.md` — 客户 Brand Style 卡片模板(4 KB)
- `CHANGELOG.md` — 完整版本演进 v4 → v5 → v5.1(26 KB)

---

## 安装

### 推荐方式:克隆到 `~/.claude/skills/`

```bash
git clone https://github.com/raoqiu29-bot/Rao-HTML-to-PPT.git ~/.claude/skills/Rao-HTML-to-PPT
```

或者克隆到任意位置,然后 symlink:
```bash
git clone https://github.com/raoqiu29-bot/Rao-HTML-to-PPT.git /your/preferred/path
ln -s /your/preferred/path ~/.claude/skills/Rao-HTML-to-PPT
```

### 验证安装

打开 Claude Code 或 Cowork,在任意目录说:
> "按 Rao-HTML-to-PPT 风格做一份 PPT 测试"

如果 AI 自动调用 skill(开始问 6 个澄清问题),说明装好了。

---

## 怎么用

### 用法 1 · 做新 PPT(Mode A)

跟 Claude 说:
> "做一份《AI 应用基础课》的培训 PPT,给企业中层,30 分钟"

AI 会自动:
1. **澄清** 6 个问题(受众 / 时长 / 素材 / Brand Style / 重点 / 硬约束)
2. **搭骨架** 用 SCQA 模板(Situation → Complication → Question → Answer → Takeaway)
3. **节奏表** 每页带版式 + 选这个版式的原因(用户确认)
4. **预检** Read template.html 确认所有类名已定义
5. **填内容** 按版式骨架装填
6. **自检** 跑 raoqiu-check.sh
7. **交付** 单文件 HTML

### 用法 2 · 大纲转 PPT(Mode B)

```
[贴 Markdown 大纲 或 上传 .md 文件] + "按这个大纲做一份 PPT"
```

AI 跳过 6 问澄清,直接进节奏规划。

### 用法 3 · 改老 PPT(Mode C)

```
[上传 .html 老课件] + "把第 5 页换成 XX" / "加一页讲 YY" / "更新这份课件的数据"
```

AI 自动:盘点 → 检查密度 → 主动 reorganize → 改 → 自检

### 用法 4 · 现场切换主题

PPT 打开后:
- **按 T 键** → 一键切换 纸 / 墨
- **点右上角"纸 · 墨"按钮** → 同上
- 选过的主题自动延续(localStorage 记忆)

---

## 设计灵感与致谢

这个 skill 在 v5 升级时通读了 5 个同行 skill 源码,提炼出可借鉴的工程实践:

- **[frontend-slides](https://github.com/zarazhangrui/frontend-slides)** by Zara Zhang · 17.1k stars
  - 启发:viewport fitting + clamp() 多屏适配 + 12 主题系统 + PDF 导出
- **[power-design](https://github.com/ItsssssJack/power-design)** by ItsssssJack
  - 启发:20 条带学术引用的设计原则 + Brand DNA 卡片机制
- **[academic-pptx-skill](https://github.com/Gabberflast/academic-pptx-skill)** by Gabberflast
  - 启发:Ghost Deck Test + Action Title 强制化 + Citation 规范
- **[clean-slides](https://github.com/tmustier/clean-slides)** by tmustier
  - 启发:`validate` 命令思路 → `raoqiu-check.sh` 自检脚本
- **[mckinsey-pptx](https://github.com/seulee26/mckinsey-pptx)** by AX Labs
  - 启发:Subagent "Defend Choice"(选版式必须解释为什么)
- **[guizang-ppt-skill](https://github.com/op7418/guizang-ppt-skill)** by 归藏
  - 启发:6 问澄清表 / SCQA 叙事弧 / 衬线边界化 / FBM 纸感背景 / Big Number+Big Quote 版式

学术理论来源(详见 `references/design-system.md`):
- Edward Tufte《The Visual Display of Quantitative Information》
- Barbara Minto《The Pyramid Principle》(金字塔原理)
- Garr Reynolds《Presentation Zen》(演说之禅)
- Robert Bringhurst《The Elements of Typographic Style》
- Nancy Duarte《Slide:ology》《resonate》
- WCAG 2.2 / 8pt Grid / Material Design / McKinsey Quarterly

---

## 文件结构

```
Rao-HTML-to-PPT/
├── README.md                   ← 你正在看
├── LICENSE                     ← MIT
├── SKILL.md                    ← 主入口 · 工作流 + 决策规则
├── CHANGELOG.md                ← 完整版本演进
├── ROADMAP.md                  ← 暂未做的功能 + 决策记录
├── assets/
│   └── template.html           ← 主模板 · 73 KB · 双主题切换内置
├── references/
│   ├── design-system.md        ← 配色 / 字体 / 5 维度风格卡片
│   ├── layouts.md              ← 12 版式骨架
│   ├── checklist.md            ← P0-P3 自检清单
│   └── brand-styles/
│       └── _template.md        ← 客户 Brand Style 卡片模板
└── scripts/
    ├── raoqiu-check.sh         ← 一键自检
    └── export-pdf.sh           ← PDF 导出(Playwright)
```

---

## 适合谁用

- 企业培训师 / 内训讲师
- 咨询顾问 / 客户提案
- 个人 IP 分享 / 思想类内容创作者
- 任何需要"做 PPT 又不想让它看起来像 AI 做的"的人

---

## 不适合做什么

- 大段表格密集数据(用 Excel)
- 协作编辑(这是静态 HTML)
- 5 分钟快速做完一份(这个 skill 强调工程纪律,慢工出细活)
- 非 Mac 系统的自动化部分(scripts/ 依赖 macOS bash + Playwright)

## Browser Compatibility / 浏览器兼容

| Browser | Status | Notes |
|---|---|---|
| **Safari** | ✅ Recommended | macOS native WebKit, no extension interference. **Use this for live presentation.** |
| **Chrome (Incognito)** | ✅ Works | Default-disabled extensions = clean environment |
| **Chrome (Normal)** | ⚠️ Use with caution | Translation extensions (immersive translate / 沙拉查词), Vim keybindings (Vimium / Surfingkeys), userscript managers (Tampermonkey) may intercept keydown events and break pagination. If you see "progress bar moves but page doesn't change", disable extensions one by one to find the culprit. |
| **Firefox / Edge** | 🟡 Untested | Should work (standard HTML5/CSS3/JS), but not verified |

**Real-world lesson**: One author's Chrome had "progress bar animates but slides don't switch" because of a translation extension intercepting arrow keys. Same file in Safari worked perfectly. **Recommendation: use Safari for live training, Chrome for everyday browsing.**

---

## 版本

**当前**:v5.1.0(2026-05-12)

**主要里程碑**:
- v4.0 加 Big Number / Big Quote 版式 + 衬线 + 字号修复 + FBM 纸感背景
- v5.0 全链路工程化(viewport fitting / clamp / Mode C / Brand Style / Ghost Deck Test / PDF 导出)
- v5.1 双主题切换 · 纸 / 墨

完整历史见 [CHANGELOG.md](CHANGELOG.md)。

---

## 贡献

欢迎 Issue / PR。特别期待:
- 新的主题(扩展 Paper & Ink / Dark Botanical 之外的选项)
- 新的版式(为特殊场景)
- 跨平台脚本(Windows / Linux 适配)
- 多语言适配(英文版 SKILL.md 等)

---

## License

MIT — 详见 [LICENSE](LICENSE)。

你可以自由使用、修改、分发(包括商用),只要保留 LICENSE 文件。
