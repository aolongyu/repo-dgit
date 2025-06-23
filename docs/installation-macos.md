# macOS 环境安装和使用指南

## 系统要求

- macOS 10.14 (Mojave) 或更高版本
- 已安装 Git
- 支持 Zsh 或 Bash shell

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
# 对于Zsh用户
echo 'export PATH="'$(pwd)':$PATH"' >> ~/.zshrc
source ~/.zshrc

# 对于Bash用户
echo 'export PATH="'$(pwd)':$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

## 验证安装

```bash
# 检查命令是否可用
dgit help

# 检查版本信息
dgit --version
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

请输入选择 (1-5): 1

请输入需求单号: DOP-123

请输入提交描述: 添加用户登录功能

生成的提交信息:
----------------------------------------
git commit -m 'feature: DOP-123, 添加用户登录功能'
----------------------------------------

是否执行命令 [git commit -m 'feature: DOP-123, 添加用户登录功能'] ? [y/N] y
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

### 剪贴板支持
macOS 默认支持剪贴板操作，无需额外配置。

### Git配置
确保已正确配置Git用户信息：
```bash
git config --global user.name "你的姓名"
git config --global user.email "你的邮箱@example.com"
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
   source ~/.zshrc  # 或 ~/.bash_profile
   ```

3. **符号链接问题**
   ```bash
   # 重新创建符号链接
   sudo ln -sf "$(pwd)/dgit" /usr/local/bin/dgit
   ```

### 调试模式

启用调试信息：
```bash
export DGIT_DEBUG=1
dgit commit
```

## 卸载

```bash
# 删除符号链接
sudo rm /usr/local/bin/dgit

# 从PATH中移除（如果使用PATH方式安装）
# 编辑 ~/.zshrc 或 ~/.bash_profile，删除相关export行
```

## 技术支持

- 多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb
- 更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com 