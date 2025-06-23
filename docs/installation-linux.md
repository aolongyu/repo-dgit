# Linux 环境安装和使用指南

## 系统要求

- Linux 发行版（Ubuntu 18.04+, CentOS 7+, Debian 9+ 等）
- 已安装 Git
- Bash shell
- 可选：xclip 或 xsel（用于剪贴板支持）

## 安装方法

### 方法1: 使用安装脚本（推荐）

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
- 提供两种安装选项：
  - 创建符号链接到 `/usr/local/bin`（推荐）
  - 添加到 PATH 环境变量

### 方法2: 手动安装

1. 下载项目文件到本地目录
2. 设置执行权限：
   ```bash
   chmod +x dgit install.sh scripts/dgit.sh scripts/common.sh scripts/alias_manager.sh
   ```
3. 选择安装方式：

#### 选项A: 创建符号链接（推荐）
```bash
# 需要管理员权限
sudo ln -sf "$(pwd)/dgit" /usr/local/bin/dgit
```

#### 选项B: 添加到PATH
```bash
# 添加到 ~/.bashrc
echo 'export PATH="'$(pwd)':$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 剪贴板支持配置

### Ubuntu/Debian 系统
```bash
# 安装 xclip
sudo apt-get update
sudo apt-get install xclip

# 或者安装 xsel
sudo apt-get install xsel
```

### CentOS/RHEL/Fedora 系统
```bash
# CentOS/RHEL
sudo yum install xclip

# Fedora
sudo dnf install xclip
```

### 验证剪贴板功能
```bash
# 测试 xclip
echo "test" | xclip -selection clipboard

# 测试 xsel
echo "test" | xsel --clipboard --input
```

## 验证安装

```bash
# 检查命令是否可用
dgit help

# 检查版本信息
dgit --version

# 检查剪贴板支持
dgit commit  # 在提交过程中会测试剪贴板功能
```

## 使用方法

### 基本命令

```bash
# 生成Git提交信息
dgit commit

# 管理需求单号别名
dgit alias

# 显示帮助信息
dgit help
```

### 使用流程

1. **进入Git仓库目录**
   ```bash
   cd /path/to/your/git/repository
   ```

2. **运行提交命令**
   ```bash
   dgit commit
   ```

3. **按提示操作**：
   - 选择提交类型（feature/fix/hotfix/refactor/others）
   - 输入需求单号（必填）
   - 输入提交描述（必填）
   - 确认生成的提交信息
   - 选择是否自动执行提交

### 示例操作

```bash
$ dgit commit

多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb

请选择提交类型:
1) feature - 新功能
2) fix - 修复缺陷
3) hotfix - 线上问题紧急修复
4) refactor - 代码重构
5) others - 其他

请输入选择 (1-5): 2

请输入需求单号: DOP-456

请输入提交描述: 修复用户登录验证bug

生成的提交信息:
----------------------------------------
git commit -m 'fix: DOP-456, 修复用户登录验证bug'
----------------------------------------

是否执行命令 [git commit -m 'fix: DOP-456, 修复用户登录验证bug'] ? [y/N] y
提交成功
```

## 别名管理

### 添加别名
```bash
dgit alias add DOP-123 "用户登录功能开发"
```

### 查看别名列表
```bash
dgit alias list
```

### 删除别名
```bash
dgit alias remove DOP-123
```

## 环境配置

### Git配置
确保已正确配置Git用户信息：
```bash
git config --global user.name "你的姓名"
git config --global user.email "你的邮箱@example.com"
```

### 显示管理器配置
如果使用无头服务器或SSH连接，可能需要配置显示：

```bash
# 设置DISPLAY环境变量
export DISPLAY=:0

# 或者使用虚拟显示
export DISPLAY=:99
```

## 故障排除

### 常见问题

1. **权限错误**
   ```bash
   chmod +x dgit install.sh scripts/dgit.sh scripts/common.sh scripts/alias_manager.sh
   ```

2. **找不到命令**
   ```bash
   # 检查PATH
   echo $PATH
   
   # 重新加载配置
   source ~/.bashrc
   ```

3. **剪贴板不工作**
   ```bash
   # 检查是否安装了xclip或xsel
   which xclip
   which xsel
   
   # 如果没有安装，按上述方法安装
   ```

4. **显示错误**
   ```bash
   # 检查DISPLAY变量
   echo $DISPLAY
   
   # 设置DISPLAY（如果需要）
   export DISPLAY=:0
   ```

### 调试模式

启用调试信息：
```bash
export DGIT_DEBUG=1
dgit commit
```

### 无头服务器使用

在无头服务器上使用时，可以禁用剪贴板功能：
```bash
export DGIT_NO_CLIPBOARD=1
dgit commit
```

## 系统集成

### 创建桌面快捷方式（可选）

创建桌面文件：
```bash
cat > ~/.local/share/applications/dgit.desktop << EOF
[Desktop Entry]
Name=dgit
Comment=Git提交辅助工具
Exec=dgit commit
Terminal=true
Type=Application
Categories=Development;
EOF
```

### 设置别名（可选）

在 `~/.bashrc` 中添加：
```bash
alias dg='dgit commit'
alias dga='dgit alias'
```

## 卸载

```bash
# 删除符号链接
sudo rm /usr/local/bin/dgit

# 从PATH中移除（如果使用PATH方式安装）
# 编辑 ~/.bashrc，删除相关export行

# 删除桌面快捷方式（如果创建了）
rm ~/.local/share/applications/dgit.desktop
```

## 技术支持

- 多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb
- 更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com 