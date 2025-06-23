#!/usr/bin/env bash

# dgit 版本管理器 (Bash版本)
# 支持更新和回退到指定版本

# 加载公共配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 显示帮助信息
show_version_help() {
    echo ""
    echo "dgit version 命令使用说明"
    echo "=========================="
    echo ""
    echo "用法: dgit version <子命令> [参数...]"
    echo ""
    echo "子命令:"
    echo "  list                    # 显示可用版本列表"
    echo "  current                 # 显示当前版本"
    echo "  update [版本号]         # 更新到指定版本（默认最新版本）"
    echo "  rollback [版本号]       # 回退到指定版本"
    echo "  info [版本号]           # 显示指定版本的详细信息"
    echo "  help                    # 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  dgit version list                    # 查看所有可用版本"
    echo "  dgit version current                 # 查看当前版本"
    echo "  dgit version update                  # 更新到最新版本"
    echo "  dgit version update 1.1.0            # 更新到指定版本"
    echo "  dgit version rollback 1.0.0          # 回退到指定版本"
    echo "  dgit version info 1.1.0              # 查看版本信息"
    echo ""
}

# 获取可用版本列表
get_available_versions() {
    local project_root
    project_root=$(get_project_root)
    
    # 检查是否是Git仓库
    if [[ ! -d "$project_root/.git" ]]; then
        echo "❌ 错误: 当前目录不是Git仓库" >&2
        return 1
    fi
    
    # 获取所有标签
    local tags
    tags=$(git -C "$project_root" tag --sort=-version:refname 2>/dev/null | head -20)
    
    if [[ -z "$tags" ]]; then
        echo "⚠️  警告: 没有找到版本标签" >&2
        return 1
    fi
    
    echo "$tags"
}

# 显示版本列表
show_version_list() {
    echo "📋 可用版本列表:"
    echo "----------------------------------------"
    
    local versions
    versions=$(get_available_versions)
    
    if [[ $? -eq 0 ]]; then
        local count=0
        while IFS= read -r version; do
            if [[ -n "$version" ]]; then
                ((count++))
                echo "$count. $version"
            fi
        done <<< "$versions"
        
        echo ""
        echo "共找到 $count 个版本"
    else
        echo "无法获取版本列表"
    fi
}

# 显示当前版本
show_current_version() {
    echo "📋 当前版本信息:"
    echo "----------------------------------------"
    echo "版本号: $DGIT_VERSION"
    echo "发布日期: $DGIT_RELEASE_DATE"
    echo "GitHub仓库: $DGIT_GITHUB_REPO"
    
    # 获取Git标签信息
    local project_root
    project_root=$(get_project_root)
    
    if [[ -d "$project_root/.git" ]]; then
        local current_tag
        current_tag=$(git -C "$project_root" describe --tags --exact-match 2>/dev/null || echo "未标记")
        echo "Git标签: $current_tag"
        
        local commit_hash
        commit_hash=$(git -C "$project_root" rev-parse --short HEAD 2>/dev/null || echo "未知")
        echo "提交哈希: $commit_hash"
    fi
}

# 验证版本号格式
validate_version() {
    local version="$1"
    
    # 检查版本号格式 (x.y.z 或 vx.y.z)
    if [[ "$version" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # 移除v前缀
        echo "${version#v}"
        return 0
    else
        echo "❌ 错误: 无效的版本号格式 '$version'" >&2
        echo "版本号格式应为: x.y.z 或 vx.y.z" >&2
        return 1
    fi
}

# 检查版本是否存在
check_version_exists() {
    local target_version="$1"
    local project_root
    project_root=$(get_project_root)
    
    # 检查标签是否存在
    if git -C "$project_root" tag -l "$target_version" | grep -q "^$target_version$"; then
        return 0
    fi
    
    # 检查带v前缀的标签
    if git -C "$project_root" tag -l "v$target_version" | grep -q "^v$target_version$"; then
        return 0
    fi
    
    return 1
}

# 更新到指定版本
update_to_version() {
    local target_version="$1"
    local project_root
    project_root=$(get_project_root)
    
    # 验证版本号
    local clean_version
    clean_version=$(validate_version "$target_version")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # 检查版本是否存在
    if ! check_version_exists "$clean_version"; then
        echo "❌ 错误: 版本 '$clean_version' 不存在" >&2
        echo "使用 'dgit version list' 查看可用版本" >&2
        return 1
    fi
    
    # 检查是否是Git仓库
    if [[ ! -d "$project_root/.git" ]]; then
        echo "❌ 错误: 当前目录不是Git仓库" >&2
        return 1
    fi
    
    echo "🔄 开始更新到版本 $clean_version..."
    
    # 保存当前分支
    local current_branch
    current_branch=$(git -C "$project_root" branch --show-current 2>/dev/null)
    
    # 获取远程更新
    echo "正在获取最新代码..."
    if ! git -C "$project_root" fetch origin >/dev/null 2>&1; then
        echo "❌ 错误: 无法获取远程更新" >&2
        return 1
    fi
    
    # 检查是否有本地修改
    if ! git -C "$project_root" diff-index --quiet HEAD -- 2>/dev/null; then
        echo "⚠️  警告: 检测到本地修改，正在暂存..." >&2
        git -C "$project_root" stash push -m "dgit version update $(date)" >/dev/null 2>&1
        local has_stash=true
    fi
    
    # 切换到指定版本
    echo "正在切换到版本 $clean_version..."
    if ! git -C "$project_root" checkout "$clean_version" >/dev/null 2>&1; then
        echo "❌ 错误: 无法切换到版本 $clean_version" >&2
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
    echo "已切换到版本 $clean_version"
    
    # 显示新版本信息
    echo ""
    show_current_version
}

# 回退到指定版本
rollback_to_version() {
    local target_version="$1"
    local project_root
    project_root=$(get_project_root)
    
    # 验证版本号
    local clean_version
    clean_version=$(validate_version "$target_version")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # 检查版本是否存在
    if ! check_version_exists "$clean_version"; then
        echo "❌ 错误: 版本 '$clean_version' 不存在" >&2
        echo "使用 'dgit version list' 查看可用版本" >&2
        return 1
    fi
    
    # 检查是否是Git仓库
    if [[ ! -d "$project_root/.git" ]]; then
        echo "❌ 错误: 当前目录不是Git仓库" >&2
        return 1
    fi
    
    echo "🔄 开始回退到版本 $clean_version..."
    
    # 保存当前分支
    local current_branch
    current_branch=$(git -C "$project_root" branch --show-current 2>/dev/null)
    
    # 检查是否有本地修改
    if ! git -C "$project_root" diff-index --quiet HEAD -- 2>/dev/null; then
        echo "⚠️  警告: 检测到本地修改，正在暂存..." >&2
        git -C "$project_root" stash push -m "dgit version rollback $(date)" >/dev/null 2>&1
        local has_stash=true
    fi
    
    # 切换到指定版本
    echo "正在切换到版本 $clean_version..."
    if ! git -C "$project_root" checkout "$clean_version" >/dev/null 2>&1; then
        echo "❌ 错误: 无法切换到版本 $clean_version" >&2
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
    
    echo "✅ 回退完成!"
    echo "已切换到版本 $clean_version"
    
    # 显示新版本信息
    echo ""
    show_current_version
}

# 显示版本详细信息
show_version_info() {
    local target_version="$1"
    local project_root
    project_root=$(get_project_root)
    
    # 验证版本号
    local clean_version
    clean_version=$(validate_version "$target_version")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # 检查版本是否存在
    if ! check_version_exists "$clean_version"; then
        echo "❌ 错误: 版本 '$clean_version' 不存在" >&2
        echo "使用 'dgit version list' 查看可用版本" >&2
        return 1
    fi
    
    echo "📋 版本 $clean_version 详细信息:"
    echo "----------------------------------------"
    
    # 获取版本信息
    local commit_hash
    commit_hash=$(git -C "$project_root" rev-parse "$clean_version" 2>/dev/null || echo "未知")
    echo "提交哈希: $commit_hash"
    
    local commit_date
    commit_date=$(git -C "$project_root" log -1 --format="%cd" --date=short "$clean_version" 2>/dev/null || echo "未知")
    echo "提交日期: $commit_date"
    
    local commit_author
    commit_author=$(git -C "$project_root" log -1 --format="%an" "$clean_version" 2>/dev/null || echo "未知")
    echo "提交作者: $commit_author"
    
    local commit_message
    commit_message=$(git -C "$project_root" log -1 --format="%s" "$clean_version" 2>/dev/null || echo "未知")
    echo "提交信息: $commit_message"
    
    # 获取版本差异
    local current_version
    current_version=$(git -C "$project_root" describe --tags --exact-match 2>/dev/null || echo "未标记")
    
    if [[ "$current_version" != "$clean_version" ]]; then
        echo ""
        echo "与当前版本的差异:"
        local diff_count
        diff_count=$(git -C "$project_root" rev-list --count "$current_version".."$clean_version" 2>/dev/null || echo "0")
        echo "提交数量差异: $diff_count"
    fi
}

# 主函数
main() {
    local subcommand="$1"
    local version="$2"
    
    case "$subcommand" in
        "list")
            show_version_list
            ;;
        "current")
            show_current_version
            ;;
        "update")
            if [[ -n "$version" ]]; then
                update_to_version "$version"
            else
                # 更新到最新版本
                echo "🔄 更新到最新版本..."
                perform_update
            fi
            ;;
        "rollback")
            if [[ -n "$version" ]]; then
                rollback_to_version "$version"
            else
                echo "❌ 错误: 请指定要回退的版本号" >&2
                echo "用法: dgit version rollback <版本号>" >&2
                exit 1
            fi
            ;;
        "info")
            if [[ -n "$version" ]]; then
                show_version_info "$version"
            else
                echo "❌ 错误: 请指定要查看的版本号" >&2
                echo "用法: dgit version info <版本号>" >&2
                exit 1
            fi
            ;;
        "help"|"")
            show_version_help
            ;;
        *)
            echo "❌ 错误: 未知子命令 '$subcommand'" >&2
            echo "使用 'dgit version help' 查看帮助信息" >&2
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@" 