# CHANGELOG · raoqiu-slide-builder

记录这个 skill 的版本变更。每次升级都按"做了什么 / 为什么 / 影响"三段记。

**读法**:最新版在顶部,历史往下排。先看版本号和日期,再挑分类标签:✨ 新增 / 🔁 改进 / 🛠️ 真实踩坑修复 / ⛔ 弃用。

**写法**(以后增量更新照这个格式):见文末"贡献新条目"。

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

- 备份位置:`99-归档-Archive/raoqiu-slide-builder-v5.3.0-2026-05-12-before-v5.4/`
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

**主线**:看了 [nexu-io/html-anything](https://github.com/nexu-io/html-anything)(2.6k stars Web app · 75 个 skill 模板 + 9 个 output surface),把它的 3 个核心设计理念**借鉴到 raoqiu-slide-builder**,作为 v5.3 文档与元数据升级。

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

- 备份位置:`99-归档-Archive/raoqiu-slide-builder-v5.1.0-2026-05-12-before-v5.2/`
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

- 备份位置:`99-归档-Archive/raoqiu-slide-builder-v5.0.0-beta-2026-05-12-before-v5.1/`
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

**主线**:alpha 解决了"PPT 模板系统"层的 6 条核心改造,beta 解决"全链路工程化"层的 5 条增强 — 把 raoqiu-slide-builder 从"做一份 PPT"升级到"端到端工程化的 HTML PPT 工具"。

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

- 备份位置(v4 完整快照):`99-归档-Archive/raoqiu-slide-builder-v4-2026-05-11-before-v5/`
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

**评审过程**:写了 [PROPOSAL-v5(已归档)](../../../99-归档-Archive/raoqiu-slide-builder-proposals/PROPOSAL-v5-2026-05-11-approved-implemented.md),饶秋评审通过(A1 + B1 + C 全同意 + D1),先备份 v4 到 `99-归档-Archive/raoqiu-slide-builder-v4-2026-05-11-before-v5/`,再启动 alpha。

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

- 备份位置:`99-归档-Archive/raoqiu-slide-builder-v4-2026-05-11-before-v5/`
- 回滚命令:`rm -rf raoqiu-slide-builder && cp -R <备份位置> raoqiu-slide-builder`
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

详见 [PROPOSAL-v5(已归档)](../../../99-归档-Archive/raoqiu-slide-builder-proposals/PROPOSAL-v5-2026-05-11-approved-implemented.md) §2 第二批:
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
