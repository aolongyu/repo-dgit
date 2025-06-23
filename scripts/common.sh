#!/usr/bin/env bash

# dgit 公共配置文件
# 包含所有脚本共享的函数和常量

# 版本信息
DGIT_VERSION="1.0.0"
DGIT_RELEASE_DATE="2025-01-27"
DGIT_GITHUB_REPO="https://github.com/aolongyu/repo-dgit.git"
DGIT_RELEASE_API="https://api.github.com/repos/aolongyu/repo-dgit/releases/latest"

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

# 版本检查文件路径
get_version_check_file() {
    local project_root
    project_root=$(get_project_root)
    echo "$project_root/.dgit_version_check"
}

# 版本比较函数
compare_versions() {
    local version1="$1"
    local version2="$2"
    
    # 分割版本号
    IFS='.' read -ra v1_parts <<< "$version1"
    IFS='.' read -ra v2_parts <<< "$version2"
    
    # 获取最大长度
    local max_length=${#v1_parts[@]}
    if [[ ${#v2_parts[@]} -gt $max_length ]]; then
        max_length=${#v2_parts[@]}
    fi
    
    # 比较每个部分
    for ((i=0; i<max_length; i++)); do
        local v1_part=${v1_parts[$i]:-0}
        local v2_part=${v2_parts[$i]:-0}
        
        if [[ $v1_part -gt $v2_part ]]; then
            echo "newer"
            return 0
        elif [[ $v1_part -lt $v2_part ]]; then
            echo "older"
            return 0
        fi
    done
    
    echo "same"
    return 0
}

# 检查网络连接
check_network() {
    if command -v curl >/dev/null 2>&1; then
        curl -s --connect-timeout 5 --max-time 10 https://api.github.com >/dev/null 2>&1
        return $?
    elif command -v wget >/dev/null 2>&1; then
        wget -q --timeout=10 --tries=1 https://api.github.com -O /dev/null 2>&1
        return $?
    else
        return 1
    fi
}

# 获取最新版本信息
get_latest_version() {
    local temp_file
    temp_file=$(mktemp)
    
    if command -v curl >/dev/null 2>&1; then
        curl -s --connect-timeout 10 --max-time 15 "$DGIT_RELEASE_API" > "$temp_file" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q --timeout=15 --tries=2 "$DGIT_RELEASE_API" -O "$temp_file" 2>/dev/null
    else
        rm -f "$temp_file"
        return 1
    fi
    
    if [[ ! -s "$temp_file" ]]; then
        rm -f "$temp_file"
        return 1
    fi
    
    # 解析JSON获取版本信息
    local latest_version
    local release_date
    local release_notes
    
    if command -v jq >/dev/null 2>&1; then
        latest_version=$(jq -r '.tag_name // empty' "$temp_file" 2>/dev/null | sed 's/^v//')
        release_date=$(jq -r '.published_at // empty' "$temp_file" 2>/dev/null | cut -d'T' -f1)
        release_notes=$(jq -r '.body // empty' "$temp_file" 2>/dev/null | head -c 200)
    else
        # 使用grep和sed解析JSON（简化版本）
        latest_version=$(grep -o '"tag_name":"[^"]*"' "$temp_file" 2>/dev/null | sed 's/.*"tag_name":"v\?\([^"]*\)".*/\1/')
        release_date=$(grep -o '"published_at":"[^"]*"' "$temp_file" 2>/dev/null | sed 's/.*"published_at":"\([^"]*\)".*/\1/' | cut -d'T' -f1)
        release_notes=$(grep -o '"body":"[^"]*"' "$temp_file" 2>/dev/null | sed 's/.*"body":"\([^"]*\)".*/\1/' | head -c 200)
    fi
    
    rm -f "$temp_file"
    
    if [[ -n "$latest_version" ]]; then
        echo "$latest_version|$release_date|$release_notes"
        return 0
    else
        return 1
    fi
}

# 检查版本更新
check_version_update() {
    # 如果禁用了版本检查，直接返回
    if [[ "$DGIT_DISABLE_UPDATE_CHECK" == "1" ]]; then
        return 0
    fi
    
    local version_check_file
    version_check_file=$(get_version_check_file)
    
    # 检查是否需要检查更新（每天最多检查一次）
    if [[ -f "$version_check_file" ]]; then
        local last_check
        last_check=$(head -n1 "$version_check_file" 2>/dev/null)
        local current_date
        current_date=$(date +%Y-%m-%d)
        
        if [[ "$last_check" == "$current_date" ]]; then
            return 0
        fi
    fi
    
    # 检查网络连接
    if ! check_network; then
        return 0
    fi
    
    # 获取最新版本信息
    local latest_info
    latest_info=$(get_latest_version)
    if [[ $? -ne 0 ]]; then
        return 0
    fi
    
    # 解析版本信息
    IFS='|' read -r latest_version release_date release_notes <<< "$latest_info"
    
    if [[ -z "$latest_version" ]]; then
        return 0
    fi
    
    # 比较版本
    local version_comparison
    version_comparison=$(compare_versions "$DGIT_VERSION" "$latest_version")
    
    if [[ "$version_comparison" == "older" ]]; then
        # 保存检查时间
        echo "$(date +%Y-%m-%d)" > "$version_check_file"
        
        # 显示更新提示
        show_update_prompt "$latest_version" "$release_date" "$release_notes"
    else
        # 保存检查时间
        echo "$(date +%Y-%m-%d)" > "$version_check_file"
    fi
}

# 显示更新提示
show_update_prompt() {
    local latest_version="$1"
    local release_date="$2"
    local release_notes="$3"
    
    echo ""
    echo "🔄 发现新版本可用!"
    echo "当前版本: $DGIT_VERSION"
    echo "最新版本: $latest_version"
    if [[ -n "$release_date" ]]; then
        echo "发布日期: $release_date"
    fi
    if [[ -n "$release_notes" ]]; then
        echo "更新内容: $release_notes..."
    fi
    echo ""
    echo "是否现在更新? [Y/n]"
    echo "  Y - 立即更新"
    echo "  n - 跳过本次更新"
    echo ""
    
    local choice
    read -r choice
    
    case "${choice,,}" in
        ""|y|yes)
            perform_update
            ;;
        n|no)
            echo "已跳过更新，下次运行时会再次提示"
            ;;
        *)
            echo "无效选择，跳过更新"
            ;;
    esac
}

# 执行更新
perform_update() {
    echo "开始更新 dgit..."
    
    local project_root
    project_root=$(get_project_root)
    
    # 检查是否是Git仓库
    if [[ ! -d "$project_root/.git" ]]; then
        echo "❌ 错误: 当前目录不是Git仓库，无法自动更新"
        echo "请手动下载最新版本: $DGIT_GITHUB_REPO"
        return 1
    fi
    
    # 保存当前分支
    local current_branch
    current_branch=$(git -C "$project_root" branch --show-current 2>/dev/null)
    
    # 获取远程更新
    echo "正在获取最新代码..."
    if ! git -C "$project_root" fetch origin >/dev/null 2>&1; then
        echo "❌ 错误: 无法获取远程更新"
        return 1
    fi
    
    # 检查是否有本地修改
    if ! git -C "$project_root" diff-index --quiet HEAD -- 2>/dev/null; then
        echo "⚠️  警告: 检测到本地修改，正在暂存..."
        git -C "$project_root" stash push -m "dgit auto-update $(date)" >/dev/null 2>&1
        local has_stash=true
    fi
    
    # 切换到主分支并更新
    echo "正在更新代码..."
    if ! git -C "$project_root" checkout master >/dev/null 2>&1; then
        echo "❌ 错误: 无法切换到master分支"
        return 1
    fi
    
    if ! git -C "$project_root" pull origin master >/dev/null 2>&1; then
        echo "❌ 错误: 无法拉取最新代码"
        return 1
    fi
    
    # 恢复本地修改
    if [[ "$has_stash" == "true" ]]; then
        echo "正在恢复本地修改..."
        git -C "$project_root" stash pop >/dev/null 2>&1
    fi
    
    # 设置执行权限
    echo "正在设置执行权限..."
    chmod +x "$project_root/dgit" "$project_root/install.sh" "$project_root/scripts/"*.sh "$project_root/scripts/"*.ps1 2>/dev/null
    
    echo "✅ 更新完成!"
    echo "新版本已安装，请重新运行命令"
    
    # 退出当前进程，让用户重新运行
    exit 0
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