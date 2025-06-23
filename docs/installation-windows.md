# Windows 环境安装和使用指南

## 系统要求

- Windows 10 或更高版本
- 已安装 Git for Windows
- PowerShell 5.1+ 或 Git Bash
- 可选：Windows Terminal（推荐）

## 安装方法

### 方法1: 使用安装脚本（推荐）

#### PowerShell 环境
```powershell
# 克隆项目到本地
git clone https://github.com/aolongyu/repo-dgit.git
cd repo-dgit

# 运行安装脚本
.\install.sh
```

#### Git Bash 环境
```bash
# 克隆项目到本地
git clone https://github.com/aolongyu/repo-dgit.git
cd repo-dgit

# 运行安装脚本
chmod +x install.sh
./install.sh
```

安装脚本会自动：
- 检查必要文件完整性
- 设置正确的执行权限
- 提供安装选项

### 方法2: 手动安装

1. 下载项目文件到本地目录
2. 设置执行权限（Git Bash）：
   ```bash
   chmod +x dgit install.sh scripts/dgit.sh scripts/dgit.ps1 scripts/common.sh scripts/common.ps1 scripts/alias_manager.sh scripts/alias_manager.ps1
   ```

3. 选择安装方式：

#### 选项A: 添加到PATH（推荐）

**PowerShell 方式**：
```powershell
# 获取当前目录路径
$currentPath = (Get-Location).Path

# 添加到用户PATH
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
[Environment]::SetEnvironmentVariable("PATH", "$userPath;$currentPath", "User")

# 刷新当前会话的PATH
$env:PATH = [Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [Environment]::GetEnvironmentVariable("PATH", "Machine")
```

**Git Bash 方式**：
```bash
# 添加到 ~/.bashrc
echo 'export PATH="'$(pwd)':$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### 选项B: 创建批处理文件

在 `C:\Windows\System32` 或 `C:\Windows\SysWOW64` 创建 `dgit.bat`：
```batch
@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0\dgit" %*
```

## PowerShell 执行策略配置

如果遇到执行策略限制，需要配置PowerShell执行策略：

```powershell
# 查看当前执行策略
Get-ExecutionPolicy

# 设置执行策略（推荐）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 或者设置为更宽松的策略（不推荐）
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

## 验证安装

### PowerShell 环境
```powershell
# 检查命令是否可用
dgit help

# 检查版本信息
dgit --version
```

### Git Bash 环境
```bash
# 检查命令是否可用
dgit help

# 检查版本信息
dgit --version
```

## 使用方法

### 基本命令

```powershell
# 生成Git提交信息
dgit commit

# 管理需求单号别名
dgit alias

# 显示帮助信息
dgit help
```

### 使用流程

1. **进入Git仓库目录**
   ```powershell
   cd C:\path\to\your\git\repository
   ```

2. **运行提交命令**
   ```powershell
   dgit commit
   ```

3. **按提示操作**：
   - 选择提交类型（feature/fix/hotfix/refactor/others）
   - 输入需求单号（必填）
   - 输入提交描述（必填）
   - 确认生成的提交信息
   - 选择是否自动执行提交

### 示例操作

```powershell
PS C:\project> dgit commit

多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb

请选择提交类型:
1) feature - 新功能
2) fix - 修复缺陷
3) hotfix - 线上问题紧急修复
4) refactor - 代码重构
5) others - 其他

请输入选择 (1-5): 3

请输入需求单号: DOP-789

请输入提交描述: 紧急修复支付接口超时问题

生成的提交信息:
----------------------------------------
git commit -m 'hotfix: DOP-789, 紧急修复支付接口超时问题'
----------------------------------------

是否执行命令 [git commit -m 'hotfix: DOP-789, 紧急修复支付接口超时问题'] ? [y/N] y
提交成功
```

## 别名管理

### 添加别名
```powershell
dgit alias add DOP-123 "用户登录功能开发"
```

### 查看别名列表
```powershell
dgit alias list
```

### 删除别名
```powershell
dgit alias remove DOP-123
```

## 环境配置

### Git配置
确保已正确配置Git用户信息：
```powershell
git config --global user.name "你的姓名"
git config --global user.email "你的邮箱@example.com"
```

### 剪贴板支持
Windows 默认支持剪贴板操作，无需额外配置。

### 编码设置
如果遇到中文显示问题，设置控制台编码：
```powershell
# 设置控制台编码为UTF-8
chcp 65001
```

## 故障排除

### 常见问题

1. **执行策略错误**
   ```powershell
   # 设置执行策略
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **找不到命令**
   ```powershell
   # 检查PATH
   $env:PATH
   
   # 重新加载环境变量
   refreshenv
   ```

3. **权限错误**
   ```powershell
   # 以管理员身份运行PowerShell
   # 或者检查文件权限
   Get-Acl dgit
   ```

4. **编码问题**
   ```powershell
   # 设置控制台编码
   chcp 65001
   
   # 或者设置环境变量
   $env:PYTHONIOENCODING = "utf-8"
   ```

### 调试模式

启用调试信息：
```powershell
$env:DGIT_DEBUG = "1"
dgit commit
```

### Git Bash 环境问题

如果在Git Bash中遇到问题：
```bash
# 检查bash版本
bash --version

# 检查脚本权限
ls -la dgit scripts/

# 重新设置权限
chmod +x dgit scripts/dgit.sh scripts/common.sh scripts/alias_manager.sh
```

## 系统集成

### 创建桌面快捷方式

1. 右键桌面 → 新建 → 快捷方式
2. 输入位置：`powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\repo-dgit\dgit" commit`
3. 输入名称：`dgit`
4. 右键快捷方式 → 属性 → 更改图标

### 添加到右键菜单

创建注册表项：
```powershell
# 创建注册表项（需要管理员权限）
New-Item -Path "HKCR:\Directory\Background\shell\dgit" -Force
New-ItemProperty -Path "HKCR:\Directory\Background\shell\dgit" -Name "MUIVerb" -Value "dgit Commit" -PropertyType String
New-ItemProperty -Path "HKCR:\Directory\Background\shell\dgit" -Name "Icon" -Value "C:\path\to\repo-dgit\dgit" -PropertyType String

New-Item -Path "HKCR:\Directory\Background\shell\dgit\command" -Force
New-ItemProperty -Path "HKCR:\Directory\Background\shell\dgit\command" -Name "(Default)" -Value "powershell.exe -ExecutionPolicy Bypass -File `"C:\path\to\repo-dgit\dgit`" commit" -PropertyType String
```

### 设置别名（可选）

在PowerShell配置文件中添加：
```powershell
# 编辑PowerShell配置文件
notepad $PROFILE

# 添加别名
Set-Alias -Name dg -Value "dgit commit"
Set-Alias -Name dga -Value "dgit alias"
```

## 卸载

### 从PATH中移除
```powershell
# 获取当前用户PATH
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")

# 移除项目路径
$newPath = ($userPath.Split(';') | Where-Object { $_ -notlike "*repo-dgit*" }) -join ';'
[Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
```

### 删除文件
```powershell
# 删除项目目录
Remove-Item -Path "C:\path\to\repo-dgit" -Recurse -Force

# 删除桌面快捷方式（如果创建了）
Remove-Item -Path "$env:USERPROFILE\Desktop\dgit.lnk" -Force
```

## 技术支持

- 多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb
- 更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com 