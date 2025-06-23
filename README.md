# dgit - 跨平台Git提交辅助工具

一个智能的Git提交信息生成工具，支持macOS、Linux和Windows平台，帮助开发者生成符合规范的Git提交信息。

## 功能特性

- 🌍 **跨平台支持**: 支持macOS、Linux和Windows
- ⌨️ **命令行**: 所有平台统一命令行交互
- 📋 **自动复制**: 生成的提交信息自动复制到剪贴板
- ✅ **数据验证**: 自动验证输入数据的完整性
- 🎯 **规范遵循**: 符合多点Git仓库管理规范

## 支持的平台

| 平台    | Shell         | 文件路径             |
|---------|---------------|---------------------|
| macOS   | Bash/Zsh      | `scripts/dgit.sh`   |
| Linux   | Bash          | `scripts/dgit.sh`   |
| Windows | Git Bash      | `scripts/dgit.sh`   |
| Windows | PowerShell    | `scripts/dgit.ps1`  |

## 安装方法

### 方法1: 使用安装脚本（推荐）

```bash
# 克隆或下载项目
git clone <repository-url>
cd repo-dgit

# 运行安装脚本
chmod +x install.sh
./install.sh
```

安装脚本会自动：
- 检查必要文件
- 设置正确的执行权限
- 创建符号链接或添加到PATH环境变量

### 方法2: 手动安装

1. 下载所有脚本文件到本地目录
2. 设置执行权限：
   ```bash
   chmod +x dgit install.sh scripts/dgit.sh scripts/dgit.ps1
   ```
3. 将脚本目录添加到PATH或创建符号链接

## 使用方法

### 基本用法

```bash
# 生成Git提交信息
dgit commit

# 显示帮助信息
dgit help
```

### 使用流程

1. 运行 `dgit commit` 命令
2. 选择提交类型：
   - 新功能(feature)
   - 修复缺陷(fix)
   - 线上问题紧急修复(hotfix)
   - 代码重构(refactor)
   - 其他(others)
3. 输入需求单号（必填）
4. 输入提交描述（必填）
5. 确认生成的提交信息
6. 选择是否自动执行提交或复制到剪贴板

### 示例输出

```
多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb
生成的提交信息:
----------------------------------------
git commit -m 'feature: DOP-123, 添加用户登录功能'
----------------------------------------

当前git config user.name: 
张三
当前git config user.email: 
zhangsan@example.com

是否执行命令 [git commit -m 'feature: DOP-123, 添加用户登录功能'] ? [y/N] y
提交成功
```

## 项目结构

```
repo-dgit/
├── dgit                # 通用启动脚本（自动检测平台和Shell）
├── install.sh          # 安装脚本
├── scripts/
│   ├── dgit.sh         # Bash/Zsh版本（macOS/Linux/Windows Git Bash）
│   └── dgit.ps1        # PowerShell版本（Windows）
└── README.md           # 项目文档
```

## 技术实现

### 平台和Shell检测

通用启动脚本 `dgit` 会自动检测：
- 操作系统类型（macOS/Linux/Windows）
- Shell类型（Zsh/Bash/PowerShell）
- 根据检测结果调用相应的实现版本

### 剪贴板支持

- **macOS**: `pbcopy`
- **Linux**: `xclip` 或 `xsel`
- **Windows Git Bash**: `clip.exe`
- **Windows PowerShell**: `Set-Clipboard`

## 开发规范

本项目遵循多点Git仓库管理规范：
- 提交类型：feature/fix/hotfix/refactor/others
- 格式：`type: issue, description`
- 详细规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb

## 故障排除

### 常见问题

1. **权限错误**
   ```bash
   chmod +x dgit install.sh scripts/dgit.sh scripts/dgit.ps1
   ```

2. **找不到命令**
   - 确保脚本已添加到PATH
   - 或使用完整路径：`./dgit commit`

3. **剪贴板不工作**
   - Linux: 安装 `xclip` 或 `xsel`
   - Windows: 确保在Git Bash或PowerShell中运行

4. **PowerShell执行策略问题**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### 调试模式

可以通过设置环境变量启用调试信息：
```bash
export DGIT_DEBUG=1
dgit commit
```

## 贡献指南

欢迎提交Issue和Pull Request来改进这个工具！

## 联系方式

- 多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb
- 更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com

## 许可证

本项目遵循公司内部使用规范。