#!/usr/bin/env bash

# dgit 安装脚本
# 自动将dgit命令安装到系统PATH中

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 获取用户shell配置文件路径
get_shell_config() {
    if [[ -n "$ZSH_VERSION" ]]; then
        if [[ -f "$HOME/.zshrc" ]]; then
            echo "$HOME/.zshrc"
        else
            echo "$HOME/.zprofile"
        fi
    elif [[ -n "$BASH_VERSION" ]]; then
        if [[ -f "$HOME/.bashrc" ]]; then
            echo "$HOME/.bashrc"
        elif [[ -f "$HOME/.bash_profile" ]]; then
            echo "$HOME/.bash_profile"
        else
            echo "$HOME/.profile"
        fi
    else
        echo "$HOME/.profile"
    fi
}

# 主安装函数
main() {
    echo "=== dgit 跨平台Git提交辅助工具安装程序 ==="
    echo ""
    echo "脚本目录: $SCRIPT_DIR"
    echo ""
    
    # 检查必要文件是否存在
    local required_files=("dgit" "scripts/dgit.sh" "scripts/dgit.ps1")
    echo "检查必要文件..."
    for file in "${required_files[@]}"; do
        if [[ -f "$SCRIPT_DIR/$file" ]]; then
            echo "✓ $file"
        else
            echo "✗ $file (缺失)"
            echo "错误: 缺少必要文件 $file"
            exit 1
        fi
    done
    echo ""
    
    # 设置执行权限
    echo "设置执行权限..."
    chmod +x "$SCRIPT_DIR/dgit"
    chmod +x "$SCRIPT_DIR/scripts/dgit.sh"
    chmod +x "$SCRIPT_DIR/scripts/dgit.ps1"
    echo "✓ 执行权限设置完成"
    echo ""
    
    # 创建符号链接或添加到PATH
    echo "选择安装方式:"
    echo "1. 创建符号链接到 /usr/local/bin (推荐)"
    echo "2. 添加到PATH环境变量"
    echo "3. 仅显示使用说明"
    echo ""
    
    read -p "请选择 (1-3): " choice
    
    case "$choice" in
        1)
            # 创建符号链接
            echo "创建符号链接..."
            if [[ -w "/usr/local/bin" ]]; then
                ln -sf "$SCRIPT_DIR/dgit" "/usr/local/bin/dgit"
                echo "✓ 符号链接创建成功"
                echo "现在可以在任何地方使用 'dgit commit' 命令"
            else
                echo "需要管理员权限，请运行:"
                echo "sudo ln -sf '$SCRIPT_DIR/dgit' /usr/local/bin/dgit"
                exit 1
            fi
            ;;
        2)
            # 添加到PATH
            local config_file=$(get_shell_config)
            local export_line="export PATH=\"$SCRIPT_DIR:\$PATH\""
            
            echo "添加到PATH环境变量..."
            if grep -q "$SCRIPT_DIR" "$config_file" 2>/dev/null; then
                echo "✓ PATH已包含脚本目录"
            else
                echo "" >> "$config_file"
                echo "# dgit 跨平台Git提交辅助工具" >> "$config_file"
                echo "$export_line" >> "$config_file"
                echo "✓ 已添加到 $config_file"
                echo "请重新加载配置文件或重启终端:"
                echo "source $config_file"
            fi
            ;;
        3)
            echo "跳过安装，仅显示使用说明"
            ;;
        *)
            echo "无效选择"
            exit 1
            ;;
    esac
    
    echo ""
    echo "=== 安装完成 ==="
    echo ""
    echo "使用方法:"
    echo "  dgit commit    # 生成Git提交信息"
    echo "  dgit help      # 显示帮助信息"
    echo ""
    echo "支持的平台:"
    echo "  - macOS (zsh/bash) - 命令行模式"
    echo "  - Linux (bash) - 命令行模式"
    echo "  - Windows (PowerShell/Git Bash) - 命令行模式"
    echo ""
    echo "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
    echo "更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com"
}

# 执行主函数
main "$@" 