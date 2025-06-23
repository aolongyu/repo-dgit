#!/usr/bin/env bash

# dgit 公共配置文件
# 包含所有脚本共享的函数和常量

# 获取脚本所在目录（兼容zsh和bash，处理符号链接）
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

# 获取项目根目录
get_project_root() {
    local script_dir
    script_dir=$(get_script_dir)
    echo "$(dirname "$script_dir")"
}

# 别名文件路径
get_alias_file() {
    local project_root
    project_root=$(get_project_root)
    echo "$project_root/.dgit_aliases"
}

# 提交类型定义
COMMIT_TYPES=(
    "新功能(feature)"
    "修复缺陷(fix)"
    "线上问题紧急修复(hotfix)"
    "代码重构(refactor)"
    "其他(others)"
)

# 需要单号的提交类型
TYPES_NEED_ISSUE=("feature" "fix" "hotfix")

# 显示别名选择菜单
show_alias_menu() {
    local alias_file
    alias_file=$(get_alias_file)
    
    if [[ ! -f "$alias_file" ]] || [[ ! -s "$alias_file" ]]; then
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
    done < <(grep -v '^#' "$alias_file")
    
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

# 显示帮助信息
show_help() {
    echo ""
    echo "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
    echo "更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com"
    echo ""
}

# 跨平台复制到剪贴板
copy_to_clipboard() {
    local text="$1"
    
    if command -v clip.exe >/dev/null 2>&1; then
        # Windows Git Bash
        echo "$text" | clip.exe
    elif command -v xclip >/dev/null 2>&1; then
        # Linux with xclip
        echo "$text" | xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        # Linux with xsel
        echo "$text" | xsel --clipboard --input
    elif command -v pbcopy >/dev/null 2>&1; then
        # macOS
        echo "$text" | pbcopy
    else
        echo "无法复制到剪贴板，请手动复制: $text"
        return 1
    fi
    return 0
} 