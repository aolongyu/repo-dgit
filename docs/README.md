# dgit 跨平台Git提交辅助工具 - 安装指南

欢迎使用 dgit 跨平台Git提交辅助工具！本工具支持多种执行环境，帮助开发者生成符合规范的Git提交信息。

## 📋 支持的平台

| 平台 | Shell | 文档链接 | 状态 |
|------|-------|----------|------|
| macOS | Zsh/Bash | [macOS 安装指南](./installation-macos.md) | ✅ 完全支持 |
| Linux | Bash | [Linux 安装指南](./installation-linux.md) | ✅ 完全支持 |
| Windows | PowerShell | [Windows 安装指南](./installation-windows.md) | ✅ 完全支持 |
| Windows | Git Bash | [Windows 安装指南](./installation-windows.md) | ✅ 完全支持 |

## 📚 文档目录

### 安装指南
- [📋 完整安装指南](./README.md) - 所有平台的安装指南汇总
- [🍎 macOS 安装指南](./installation-macos.md) - macOS环境安装和使用
- [🐧 Linux 安装指南](./installation-linux.md) - Linux环境安装和使用
- [🪟 Windows 安装指南](./installation-windows.md) - Windows环境安装和使用

### 使用指南
- [📖 使用示例](./usage-examples.md) - 详细的使用示例和最佳实践

## 🚀 快速开始

### 选择你的平台

根据你的操作系统选择对应的安装指南：

- **macOS 用户** → [macOS 安装指南](./installation-macos.md)
- **Linux 用户** → [Linux 安装指南](./installation-linux.md)
- **Windows 用户** → [Windows 安装指南](./installation-windows.md)

### 通用安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/aolongyu/repo-dgit.git
   cd repo-dgit
   ```

2. **运行安装脚本**
   ```bash
   # macOS/Linux
   chmod +x install.sh
   ./install.sh
   
   # Windows PowerShell
   .\install.sh
   ```

3. **验证安装**
   ```bash
   dgit help
   ```

4. **开始使用**
   ```bash
   dgit commit
   ```

## 🎯 功能特性

- 🌍 **跨平台支持**: 支持macOS、Linux和Windows
- ⌨️ **统一命令行**: 所有平台使用相同的命令
- 📋 **自动复制**: 生成的提交信息自动复制到剪贴板
- ✅ **数据验证**: 自动验证输入数据的完整性
- 🎯 **规范遵循**: 符合多点Git仓库管理规范
- 🔧 **别名管理**: 支持需求单号别名管理

## 📖 使用示例

### 基本使用

```bash
# 生成Git提交信息
dgit commit

# 管理需求单号别名
dgit alias add DOP-123 "用户登录功能开发"

# 查看帮助信息
dgit help
```

### 提交类型

- `feature` - 新功能
- `fix` - 修复缺陷
- `hotfix` - 线上问题紧急修复
- `refactor` - 代码重构
- `others` - 其他

### 提交格式

```
type: issue, description
```

示例：
```
feature: DOP-123, 添加用户登录功能
fix: DOP-456, 修复支付接口超时问题
hotfix: DOP-789, 紧急修复数据库连接问题
```

## 🔧 环境配置

### 系统要求

- **macOS**: 10.14+，已安装Git
- **Linux**: Ubuntu 18.04+/CentOS 7+，已安装Git
- **Windows**: Windows 10+，已安装Git for Windows

### 剪贴板支持

| 平台 | 工具 | 安装命令 |
|------|------|----------|
| macOS | pbcopy | 系统自带 |
| Linux | xclip/xsel | `sudo apt-get install xclip` |
| Windows | clip.exe | 系统自带 |

## 🛠️ 故障排除

### 常见问题

1. **权限错误**
   ```bash
   chmod +x dgit install.sh scripts/*.sh scripts/*.ps1
   ```

2. **找不到命令**
   - 检查PATH环境变量
   - 重新加载shell配置文件
   - 使用完整路径运行

3. **剪贴板不工作**
   - 检查剪贴板工具是否安装
   - 设置环境变量禁用剪贴板：`export DGIT_NO_CLIPBOARD=1`

4. **PowerShell执行策略问题**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### 调试模式

启用调试信息：
```bash
# macOS/Linux
export DGIT_DEBUG=1

# Windows PowerShell
$env:DGIT_DEBUG = "1"

# 运行命令
dgit commit
```

## 📚 详细文档

### 平台特定指南

- [macOS 安装和使用指南](./installation-macos.md)
  - 系统要求
  - 安装方法（自动/手动）
  - 环境配置
  - 故障排除

- [Linux 安装和使用指南](./installation-linux.md)
  - 系统要求
  - 剪贴板配置
  - 无头服务器使用
  - 系统集成

- [Windows 安装和使用指南](./installation-windows.md)
  - PowerShell执行策略
  - Git Bash支持
  - 右键菜单集成
  - 编码设置

### 使用指南

- [使用示例](./usage-examples.md)
  - 基本使用场景
  - 别名管理
  - 高级使用场景
  - 故障排除示例
  - 最佳实践
  - 常见问题解答

### 高级功能

- **别名管理**: 管理常用的需求单号别名
- **系统集成**: 桌面快捷方式、右键菜单
- **环境配置**: 剪贴板支持、编码设置

## 🤝 贡献指南

欢迎提交Issue和Pull Request来改进这个工具！

### 开发环境设置

1. 克隆项目
2. 根据平台选择安装方式
3. 运行测试：`dgit help`
4. 提交改进

## 📞 技术支持

- **多点Git仓库管理规范**: https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb
- **技术支持**: 敖龙宇 / longyu.ao@dmall.com
- **项目仓库**: https://github.com/aolongyu/repo-dgit.git

## 📄 许可证

本项目遵循公司内部使用规范。

---

**选择你的平台，开始使用 dgit 吧！** 🎉 