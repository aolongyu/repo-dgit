#!/usr/bin/env bash

# 别名管理脚本
# 用于管理需求单号的别名

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
ALIAS_FILE="$SCRIPT_DIR/../.dgit_aliases"

# 确保别名文件存在
ensure_alias_file() {
    if [[ ! -f "$ALIAS_FILE" ]]; then
        touch "$ALIAS_FILE"
        echo "# dgit 需求单号别名文件" > "$ALIAS_FILE"
        echo "# 格式: 单号|别名|描述" >> "$ALIAS_FILE"
    fi
}

# 添加别名
add_alias() {
    local code="$1"
    local alias_name="$2"
    local description="$3"
    
    # 验证参数
    if [[ -z "$code" || -z "$alias_name" ]]; then
        echo "错误: 单号和别名不能为空"
        echo "用法: dgit alias add <单号> <别名> [描述]"
        exit 1
    fi
    
    ensure_alias_file
    
    # 检查别名是否已存在
    if grep -q "^[^|]*|$alias_name|" "$ALIAS_FILE"; then
        echo "错误: 别名 '$alias_name' 已存在"
        exit 1
    fi
    
    # 添加新别名
    echo "$code|$alias_name|$description" >> "$ALIAS_FILE"
    echo "✓ 别名添加成功: $alias_name -> $code"
}

# 删除别名
delete_alias() {
    local alias_name="$1"
    
    if [[ -z "$alias_name" ]]; then
        echo "错误: 别名不能为空"
        echo "用法: dgit alias delete <别名>"
        exit 1
    fi
    
    ensure_alias_file
    
    # 检查别名是否存在
    if ! grep -q "^[^|]*|$alias_name|" "$ALIAS_FILE"; then
        echo "错误: 别名 '$alias_name' 不存在"
        exit 1
    fi
    
    # 删除别名
    sed -i.tmp "/^[^|]*|$alias_name|/d" "$ALIAS_FILE"
    rm -f "$ALIAS_FILE.tmp"
    echo "✓ 别名删除成功: $alias_name"
}

# 列出所有别名
list_aliases() {
    ensure_alias_file
    
    if [[ ! -s "$ALIAS_FILE" ]]; then
        echo "暂无别名记录"
        return
    fi
    
    echo "需求单号别名列表:"
    echo "----------------------------------------"
    echo "单号\t\t别名\t\t描述"
    echo "----------------------------------------"
    
    # 跳过注释行，显示别名
    grep -v '^#' "$ALIAS_FILE" | while IFS='|' read -r code alias_name description; do
        printf "%-15s\t%-15s\t%s\n" "$code" "$alias_name" "$description"
    done
}

# 根据别名获取单号
get_code_by_alias() {
    local alias_name="$1"
    
    if [[ -z "$alias_name" ]]; then
        return 1
    fi
    
    ensure_alias_file
    
    local code
    code=$(grep "^[^|]*|$alias_name|" "$ALIAS_FILE" | cut -d'|' -f1)
    
    if [[ -n "$code" ]]; then
        echo "$code"
        return 0
    else
        return 1
    fi
}

# 显示别名选择菜单
show_alias_menu() {
    ensure_alias_file
    
    if [[ ! -s "$ALIAS_FILE" ]]; then
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
    
    echo "请选择需求单号别名 (或直接输入单号):"
    echo "0. 直接输入单号"
    
    for ((i=0; i<count; i++)); do
        local desc="${descriptions[$i]}"
        if [[ -n "$desc" ]]; then
            echo "$((i+1)). ${aliases[$i]} (${codes[$i]}) - $desc"
        else
            echo "$((i+1)). ${aliases[$i]} (${codes[$i]})"
        fi
    done
    
    # 获取用户选择
    while true; do
        read -p "请输入选择 (0-$count): " choice
        if [[ "$choice" == "0" ]]; then
            return 1  # 表示用户选择直接输入
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$count" ]]; then
            local selected_index=$((choice-1))
            echo "${codes[$selected_index]}"
            return 0
        else
            echo "无效选择，请输入 0-$count 之间的数字"
        fi
    done
}

# 主函数
main() {
    local action="$1"
    local arg1="$2"
    local arg2="$3"
    local arg3="$4"
    
    case "$action" in
        "add")
            add_alias "$arg1" "$arg2" "$arg3"
            ;;
        "delete"|"del"|"remove"|"rm")
            delete_alias "$arg1"
            ;;
        "list"|"ls"|"show")
            list_aliases
            ;;
        "get")
            get_code_by_alias "$arg1"
            ;;
        "menu")
            show_alias_menu
            ;;
        *)
            echo "用法: dgit alias <命令> [参数...]"
            echo ""
            echo "命令:"
            echo "  add <单号> <别名> [描述]    添加别名"
            echo "  delete <别名>              删除别名"
            echo "  list                       列出所有别名"
            echo "  get <别名>                 获取别名对应的单号"
            echo "  menu                       显示别名选择菜单"
            echo ""
            echo "示例:"
            echo "  dgit alias add DOP-123 商品需求v1.1 商品模块需求"
            echo "  dgit alias delete 商品需求v1.1"
            echo "  dgit alias list"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 