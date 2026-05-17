#!/usr/bin/env bash
#
# raoqiu-slide-builder · 一键自检脚本(v5 升级)
# 借鉴 tmustier/clean-slides 的 pptx validate 思路
#
# 用法:
#   bash scripts/raoqiu-check.sh <file.html>
#
# 检查内容(对应 checklist.md 的 P0-P3):
#   - 结构层(P0):.page 包装 / page-footer 残留 / h2 标题用法 / section 数
#   - 字体层(P0):衬线只用 5 处 / 禁用字体 / 衬线字体名正确
#   - 颜色层(P0):AI 风颜色 / 渐变 / 玻璃拟态
#   - 内容层(P0/P1):emoji 装饰 / 卡片密度 / Ghost Deck Test 提示

set -uo pipefail

F="${1:-}"
if [[ -z "$F" ]]; then
  echo "用法: bash scripts/raoqiu-check.sh <file.html>"
  exit 1
fi
if [[ ! -f "$F" ]]; then
  echo "[错误] 找不到文件: $F"
  exit 1
fi

# ANSI 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# 计数器
PASS=0
FAIL=0
WARN=0

# ======================================================================
# 辅助函数
# ======================================================================
check_zero() {
  local label="$1"; local count="$2"; local hint="$3"
  if [[ "$count" -eq 0 ]]; then
    printf "  ${GREEN}✓${NC} %-50s (%d)\n" "$label" "$count"
    PASS=$((PASS + 1))
  else
    printf "  ${RED}✗${NC} %-50s (%d) ${YELLOW}%s${NC}\n" "$label" "$count" "$hint"
    FAIL=$((FAIL + 1))
  fi
}

check_gt_zero() {
  local label="$1"; local count="$2"; local hint="$3"
  if [[ "$count" -gt 0 ]]; then
    printf "  ${GREEN}✓${NC} %-50s (%d)\n" "$label" "$count"
    PASS=$((PASS + 1))
  else
    printf "  ${RED}✗${NC} %-50s (%d) ${YELLOW}%s${NC}\n" "$label" "$count" "$hint"
    FAIL=$((FAIL + 1))
  fi
}

warn_if() {
  local label="$1"; local count="$2"; local hint="$3"
  if [[ "$count" -gt 0 ]]; then
    printf "  ${YELLOW}!${NC} %-50s (%d) ${YELLOW}%s${NC}\n" "$label" "$count" "$hint"
    WARN=$((WARN + 1))
  else
    printf "  ${GREEN}✓${NC} %-50s (%d)\n" "$label" "$count"
    PASS=$((PASS + 1))
  fi
}

# ======================================================================
# 开始检查
# ======================================================================
echo ""
echo -e "${BOLD}${BLUE}=== 饶秋老师 PPT 合规检查 · raoqiu-check v5 ===${NC}"
echo -e "${BLUE}文件: $F${NC}"
echo ""

# ----------------------------------------------------------------------
# Block 1 · 结构层(P0)
# ----------------------------------------------------------------------
echo -e "${BOLD}--- 结构层 (P0) ---${NC}"

SECTION_COUNT=$(grep -c '<section class="slide' "$F")
check_gt_zero "Section 数(应 ≥ 1)" "$SECTION_COUNT" "至少要 1 张 slide"

PAGE_COUNT=$(grep -c '<div class="page">' "$F")
# 检查信息处理类 section 是否都用 .page 包装
INFO_SECTIONS=$(grep -c 'data-name=\|page-title\|metric-row\|process-flow\|card-grid' "$F")

PAGE_FOOTER_COUNT=$(grep -c '<div class="page-footer">' "$F")
check_zero ".page-footer 残留(v4 已弃用)" "$PAGE_FOOTER_COUNT" "→ 删掉,跟翻页按钮和页码遮挡"

H2_TITLES=$(grep -c '<h2 class="page-title"' "$F")
DIV_TITLES=$(grep -c '<div class="page-title"' "$F")
check_zero "page-title 用 <div>(应该用 h2)" "$DIV_TITLES" "→ 改成 <h2 class=\"page-title\">"

# ----------------------------------------------------------------------
# Block 2 · 字体层(P0)
# ----------------------------------------------------------------------
echo ""
echo -e "${BOLD}--- 字体层 (P0) ---${NC}"

NOTO_SERIF=$(grep -c "Noto Serif SC\|Noto+Serif+SC" "$F")
FRAUNCES=$(grep -c "Fraunces" "$F")
check_gt_zero "Noto Serif SC 字体加载" "$NOTO_SERIF" "→ 缺,衬线 5 处重音用不了"
check_gt_zero "Fraunces 字体加载" "$FRAUNCES" "→ 缺,英文衬线用不了"

# 禁用衬线字体(v5.1 更新白名单:Noto Serif SC + Fraunces + Cormorant Garamond 都允许)
# 真正禁用的:Playfair Display / Bodoni Moda / Times New Roman 等
BAD_SERIF=$(grep -ciE "Playfair Display|Bodoni Moda|Times New Roman" "$F" 2>/dev/null)
BAD_SERIF=${BAD_SERIF:-0}
check_zero "禁用衬线(Playfair/Bodoni Moda/Times New Roman)" "$BAD_SERIF" "→ 白名单:Noto Serif SC + Fraunces + Cormorant"

# 禁用 AI 风字体作为标题
AI_FONTS=$(grep -ciE "font-family:\s*['\"]?(Inter|Roboto|Arial)['\"]?" "$F")
check_zero "禁用 AI 风字体作为主字体" "$AI_FONTS" "→ 用 PingFang SC + Manrope"

# ----------------------------------------------------------------------
# Block 3 · 颜色层(P0)
# ----------------------------------------------------------------------
echo ""
echo -e "${BOLD}--- 颜色层 (P0) ---${NC}"

PURPLE_HEX=$(grep -ciE "#(6366f1|8B5CF6|A855F7|7B68EE|9400D3|9333EA)" "$F")
check_zero "禁用紫色 hex(AI 风标志)" "$PURPLE_HEX" "→ 主色只用 #051C2C"

# 内容层渐变(允许 WebGL 背景遮罩用)
GRADIENTS=$(grep -c "linear-gradient" "$F")
warn_if "linear-gradient 使用" "$GRADIENTS" "→ 检查是否只用在 WebGL 背景"

# ----------------------------------------------------------------------
# Block 4 · 内容层(P0/P1)
# ----------------------------------------------------------------------
echo ""
echo -e "${BOLD}--- 内容层 (P0/P1) ---${NC}"

# emoji 装饰检查(用 -F fixed string + -e 多 pattern,避免 BSD grep unicode 字符类 bug)
# 注意:grep -c 在 BSD 上可能多行输出,用 tr 清理换行
EMOJI=$(grep -cF -e '🎯' -e '💡' -e '✅' -e '🚀' -e '⭐' -e '🔥' -e '📊' -e '🎨' -e '🏆' -e '⚡' "$F" 2>/dev/null | tr -d '\n' | tr -d ' ')
EMOJI=${EMOJI:-0}
check_zero "emoji 装饰" "$EMOJI" "→ 用 Lucide 图标或 mono 文字标签"

# Thank You 结尾页(P0 红线)
THANK_YOU=$(grep -ciE ">Thank You<|>谢谢<|>Q&A<|>QA<" "$F")
check_zero "Thank You / 谢谢 / Q&A 结尾页" "$THANK_YOU" "→ 结尾页留行动建议,不要 Thank You"

# 章节扉页 ≤ 5
CHAPTER_COUNT=$(grep -c '<div class="chapter">' "$F")
if [[ "$CHAPTER_COUNT" -le 5 ]]; then
  printf "  ${GREEN}✓${NC} %-50s (%d)\n" "章节扉页 ≤ 5" "$CHAPTER_COUNT"
  PASS=$((PASS + 1))
else
  printf "  ${YELLOW}!${NC} %-50s (%d) ${YELLOW}%s${NC}\n" "章节扉页 > 5 张" "$CHAPTER_COUNT" "→ 模块切太细,回去看大纲"
  WARN=$((WARN + 1))
fi

# Key Insight ≤ 3
INSIGHT_COUNT=$(grep -c '<div class="insight-page">' "$F")
if [[ "$INSIGHT_COUNT" -le 3 ]]; then
  printf "  ${GREEN}✓${NC} %-50s (%d)\n" "Key Insight ≤ 3" "$INSIGHT_COUNT"
  PASS=$((PASS + 1))
else
  printf "  ${YELLOW}!${NC} %-50s (%d) ${YELLOW}%s${NC}\n" "Key Insight > 3 张" "$INSIGHT_COUNT" "→ 强调价值递减,挑最重要的"
  WARN=$((WARN + 1))
fi

# ----------------------------------------------------------------------
# Block 5 · v5 模板特性信息(只看不评分,因为是模板级一次性事)
# ----------------------------------------------------------------------
echo ""
echo -e "${BOLD}--- v5 模板特性信息(只看不评分) ---${NC}"

STRICT=$(grep -c "overflow: hidden" "$F")
CLAMP_USE=$(grep -c "clamp(" "$F")
REDUCED_MOTION=$(grep -c "prefers-reduced-motion" "$F")
DATA_BG=$(grep -c 'data-bg="fbm"' "$F")

printf "  ${BLUE}i${NC} viewport hard limits(overflow: hidden)         (%d)\n" "$STRICT"
printf "  ${BLUE}i${NC} clamp() 使用(多屏适配)                       (%d)\n" "$CLAMP_USE"
printf "  ${BLUE}i${NC} prefers-reduced-motion 无障碍                  (%d)\n" "$REDUCED_MOTION"
printf "  ${BLUE}i${NC} FBM 纸感背景已开启                              (%d)\n" "$DATA_BG"

if [[ "$REDUCED_MOTION" -eq 0 ]]; then
  echo -e "  ${YELLOW}提示:这份 PPT 用的是 v4 之前的模板,建议升级到 v5 模板重新生成${NC}"
fi

# ----------------------------------------------------------------------
# Ghost Deck Test 标题提取(给人工 review)
# ----------------------------------------------------------------------
echo ""
echo -e "${BOLD}--- Ghost Deck Test · 所有标题串读 ---${NC}"
echo -e "${YELLOW}(人工通读下面所有标题,看能不能讲完整个故事)${NC}"
echo ""
grep -oE '<(h1|h2)[^>]*class[^>]*>[^<]+|<(h1|h2)>[^<]+' "$F" | \
  sed -E 's/<[^>]*>//g; s/&nbsp;/ /g; s/<br>/ /g' | \
  awk 'NF' | head -30 | nl -w3 -s'. '

# ----------------------------------------------------------------------
# 汇总
# ----------------------------------------------------------------------
echo ""
echo -e "${BOLD}=== 汇总 ===${NC}"
TOTAL=$((PASS + FAIL + WARN))
printf "  ${GREEN}✓ 通过: %d${NC}  ${RED}✗ 不通过: %d${NC}  ${YELLOW}! 警告: %d${NC}  (共 %d 项)\n" \
  "$PASS" "$FAIL" "$WARN" "$TOTAL"

if [[ "$FAIL" -eq 0 ]]; then
  echo ""
  echo -e "${GREEN}${BOLD}P0 全部通过 · 合格的饶秋老师 PPT${NC}"
  if [[ "$WARN" -gt 0 ]]; then
    echo -e "${YELLOW}有 $WARN 个警告,看清楚是否真的有问题${NC}"
  fi
  exit 0
else
  echo ""
  echo -e "${RED}${BOLD}P0 有 $FAIL 项不通过 · 必须修完才能交付${NC}"
  exit 1
fi
