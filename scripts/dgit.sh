#!/usr/bin/env bash

# dgit - Bash专用Git提交辅助工具
# 用于生成符合规范的Git提交信息
# 兼容Linux Bash和Windows Git Bash

# 获取脚本所在目录
get_script_dir() {
    if [[ -n "$ZSH_VERSION" ]]; then
        local script_path
        script_path=$(readlink -f "$0" 2>/dev/null || echo "$0")
        echo "$(cd "$(dirname "$script_path")" && pwd)"
    else
        local script_path
        script_path=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")
        echo "$(cd "$(dirname "$script_path")" && pwd)"
    fi
}

SCRIPT_DIR=$(get_script_dir)
ALIAS_FILE="$(dirname "$SCRIPT_DIR")/.dgit_aliases"

# 显示别名选择菜单
show_alias_menu() {
    if [[ ! -f "$ALIAS_FILE" ]] || [[ ! -s "$ALIAS_FILE" ]]; then
        return 1
    fi
    
    local aliases=()
    local codes=()
    local descriptions=()
    local count=0
    
    # 读取别名数据
    while IFS='|' read -r code alias_name description; do
        if [[ -n "$code" && -n "$alias_name" && "$code" != "#" ]]; then
            aliases+=("$alias_name")
            codes+=("$code")
            descriptions+=("$description")
            ((count++))
        fi
    done < <(grep -v '^#' "$ALIAS_FILE")
    
    if [[ $count -eq 0 ]]; then
        return 1
    fi
    
    # 显示菜单
    echo "请选择需求单号别名:" >&2
    
    for ((i=0; i<count; i++)); do
        local desc="${descriptions[$i]}"
        if [[ -n "$desc" ]]; then
            echo "$((i+1)). ${aliases[$i]} (${codes[$i]}) - $desc" >&2
        else
            echo "$((i+1)). ${aliases[$i]} (${codes[$i]})" >&2
        fi
    done
    
    # 获取用户选择
    local choice
    while true; do
        echo -n "请输入选择 (1-$count): " >&2
        read choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$count" ]]; then
            local selected_index=$((choice-1))
            echo "${codes[$selected_index]}"
            return 0
        else
            echo "无效选择，请输入 1-$count 之间的数字" >&2
        fi
    done
}

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

# 定义需要单号的提交类型
types_need_issue=("feature" "fix" "hotfix")

# 显示提交类型选择
echo ""
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

# 检查是否需要输入单号
need_issue=false
for type in "${types_need_issue[@]}"; do
    if [[ "$type_short" == "$type" ]]; then
        need_issue=true
        break
    fi
done

# 获取问题编号（如果需要）
if [[ "$need_issue" == "true" ]]; then
    echo ""
    echo "(1/3) 需求单号输入:"
    echo "请选择输入方式:"
    echo "1. 使用别名选择"
    echo "2. 手动输入单号"

    # 第一步：选择输入方式
    while true; do
        read -p "请输入选择 (1-2): " input_choice
        if [[ "$input_choice" == "1" ]]; then
            # 选择使用别名
            echo ""
            alias_result=$(show_alias_menu)
            if [[ $? -eq 0 ]]; then
                # 用户选择了别名
                issue_number="$alias_result"
                echo ""
                echo "✓ 已选择别名对应的单号: $issue_number"
                break
            else
                # 没有可用的别名
                echo ""
                echo "没有可用的别名，请选择手动输入"
                continue
            fi
        elif [[ "$input_choice" == "2" ]]; then
            # 选择手动输入
            echo ""
            while true; do
                read -p "请输入需求单号(必填): " issue_number
                if [[ -n "$issue_number" ]]; then
                    break
                else
                    echo "需求单号不能为空!"
                fi
            done
            break
        else
            echo "无效选择，请输入 1 或 2"
        fi
    done
else
    # 不需要单号的类型，直接进入描述输入
    issue_number=""
fi

# 获取提交描述
echo ""
if [[ "$need_issue" == "true" ]]; then
    echo "(2/3) 请输入提交描述:"
else
    echo "(1/2) 请输入提交描述:"
fi
while true; do
  read -p "请输入提交描述(必填): " commit_description
  if [[ -n "$commit_description" ]]; then
    break
  else
    echo "提交描述不能为空!"
  fi
done

# 生成并显示提交信息
if [[ "$need_issue" == "true" ]]; then
    commit_msg="$type_short: $issue_number, $commit_description"
    echo ""
    echo "(3/3) 确认提交信息:"
else
    commit_msg="$type_short: $commit_description"
    echo ""
    echo "(2/2) 确认提交信息:"
fi
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