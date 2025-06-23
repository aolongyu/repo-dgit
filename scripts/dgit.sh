#!/usr/bin/env bash

# dgit - Bash专用Git提交辅助工具
# 用于生成符合规范的Git提交信息
# 兼容Linux Bash和Windows Git Bash

# 检查命令参数
if [[ "$1" == "help" ]]; then
  echo ""
  echo "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
  echo "更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com"
  echo ""
  exit 1
fi

if [[ "$1" != "commit" ]]; then
  echo "用法: dgit commit"
  exit 1
fi

# 定义提交类型选项
commit_types=(
  "新功能(feature)"
  "修复缺陷(fix)"
  "线上问题紧急修复(hotfix)"
  "代码重构(refactor)"
  "其他(others)"
)

# 显示提交类型选择
echo "请选择提交类型:"
for i in "${!commit_types[@]}"; do
  echo "$((i+1)). ${commit_types[$i]}"
done

# 获取用户选择
while true; do
  read -p "请输入选择 (1-${#commit_types[@]}): " choice
  if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#commit_types[@]}" ]; then
    selected_type="${commit_types[$((choice-1))]}"
    break
  else
    echo "无效选择，请输入 1-${#commit_types[@]} 之间的数字"
  fi
done

# 提取类型简写（括号内部分）
type_short=$(echo "$selected_type" | sed -E 's/.*\((.*)\).*/\1/')

# 获取问题编号
while true; do
  read -p "请输入需求单号(必填): " issue_number
  if [[ -n "$issue_number" ]]; then
    break
  else
    echo "需求单号不能为空!"
  fi
done

# 获取提交描述
while true; do
  read -p "请输入提交描述: " commit_description
  if [[ -n "$commit_description" ]]; then
    break
  else
    echo "提交描述不能为空!"
  fi
done

# 生成并显示提交信息
commit_msg="$type_short: $issue_number, $commit_description"
echo ""
echo "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
echo "生成的提交信息:"
echo "----------------------------------------"
echo -e "\033[32mgit commit -m '$commit_msg'\033[0m"
echo "----------------------------------------"

# 确认是否执行提交
echo ""
echo "当前git config user.name: "
git config user.name
echo "当前git config user.email: "
git config user.email
echo ""

read -p "是否执行命令 [git commit -m '$commit_msg'] ? [y/N] " answer
if [[ "$answer" =~ ^[Yy] ]]; then
  git commit -m "$commit_msg"
  echo "提交成功"
else
  echo "已复制 $commit_msg 到剪贴板，可自行执行提交"
  # 跨平台复制到剪贴板
  if command -v clip.exe >/dev/null 2>&1; then
    # Windows Git Bash
    echo "$commit_msg" | clip.exe
  elif command -v xclip >/dev/null 2>&1; then
    # Linux with xclip
    echo "$commit_msg" | xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then
    # Linux with xsel
    echo "$commit_msg" | xsel --clipboard --input
  elif command -v pbcopy >/dev/null 2>&1; then
    # macOS
    echo "$commit_msg" | pbcopy
  else
    echo "无法复制到剪贴板，请手动复制: $commit_msg"
  fi
fi 