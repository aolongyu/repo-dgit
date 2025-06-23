# dgit 版本控制功能

dgit 工具集成了智能版本控制功能，能够自动检测新版本并提供更新选项，确保用户始终使用最新版本。

## 功能特性

- 🔄 **自动版本检测**: 每次运行时自动检查是否有新版本
- 📅 **智能检查频率**: 每天最多检查一次，避免频繁网络请求
- 🌐 **网络友好**: 支持离线使用，网络不可用时自动跳过检查
- 🛡️ **安全更新**: 自动备份本地修改，更新后恢复
- ⚙️ **灵活配置**: 支持禁用自动检查或手动更新

## 版本信息

### 当前版本
- **版本号**: 1.0.0
- **发布日期**: 2025-01-27
- **GitHub仓库**: https://github.com/aolongyu/repo-dgit.git

### 查看版本信息

```bash
# 查看当前版本
dgit --version

# 或者使用简写
dgit -v
```

输出示例：
```
dgit version 1.0.0
Release date: 2025-01-27
技术支持：敖龙宇 / longyu.ao@dmall.com
```

## 自动更新机制

### 更新检查流程

1. **启动检查**: 每次运行 `dgit commit` 时自动检查
2. **频率控制**: 每天最多检查一次，避免重复请求
3. **网络检测**: 自动检测网络连接状态
4. **版本比较**: 比较本地版本与远程最新版本
5. **用户选择**: 发现新版本时提供更新选项

### 更新提示界面

当发现新版本时，会显示如下界面：

```
🔄 发现新版本可用!
当前版本: 1.0.0
最新版本: 1.1.0
发布日期: 2025-01-28
更新内容: 修复了剪贴板兼容性问题，优化了别名管理功能...

是否现在更新? [Y/n]
  Y - 立即更新
  n - 跳过本次更新
```

### 用户选择说明

| 选项 | 说明 | 后续行为 |
|------|------|----------|
| **Y** (默认) | 立即更新 | 自动下载并安装最新版本 |
| **n** | 跳过本次更新 | 下次运行时会再次提示 |

## 自动更新过程

### 更新步骤

1. **环境检查**: 验证是否为Git仓库
2. **备份修改**: 自动暂存本地修改
3. **获取更新**: 从远程仓库拉取最新代码
4. **恢复修改**: 自动恢复本地修改
5. **权限设置**: 重新设置执行权限
6. **完成更新**: 提示用户重新运行命令

### 更新日志示例

```
开始更新 dgit...
正在获取最新代码...
正在更新代码...
正在设置执行权限...
✅ 更新完成!
新版本已安装，请重新运行命令
```

## 配置选项

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DGIT_DISABLE_UPDATE_CHECK` | 未设置 | 设置为 `1` 临时禁用自动更新检查 |

### 临时禁用自动更新

```bash
# 临时禁用（当前会话）
export DGIT_DISABLE_UPDATE_CHECK=1

# PowerShell环境
$env:DGIT_DISABLE_UPDATE_CHECK = "1"
```

### 重新启用自动更新

```bash
# 临时启用
unset DGIT_DISABLE_UPDATE_CHECK

# PowerShell环境
$env:DGIT_DISABLE_UPDATE_CHECK = "0"
```

## 手动更新

### 方法1: Git命令更新

```bash
# 进入项目目录
cd /path/to/repo-dgit

# 获取最新代码
git fetch origin

# 切换到主分支
git checkout master

# 拉取最新代码
git pull origin master

# 设置执行权限
chmod +x dgit install.sh scripts/*.sh scripts/*.ps1
```

### 方法2: 重新克隆

```bash
# 备份别名文件（如果有）
cp .dgit_aliases ~/dgit_aliases_backup

# 重新克隆
cd /path/to
rm -rf repo-dgit
git clone https://github.com/aolongyu/repo-dgit.git
cd repo-dgit

# 恢复别名文件
cp ~/dgit_aliases_backup .dgit_aliases

# 重新安装
./install.sh
```

## 故障排除

### 常见问题

#### 1. 更新失败

**问题**: 自动更新过程中出现错误

**解决方案**:
```bash
# 检查网络连接
ping api.github.com

# 检查Git配置
git config --list

# 手动更新
cd /path/to/repo-dgit
git pull origin master
```

#### 2. 权限错误

**问题**: 更新后脚本无法执行

**解决方案**:
```bash
# 重新设置执行权限
chmod +x dgit install.sh scripts/*.sh scripts/*.ps1

# 检查符号链接
ls -la /usr/local/bin/dgit
```

#### 3. 本地修改冲突

**问题**: 更新时提示本地修改冲突

**解决方案**:
```bash
# 查看本地修改
git status

# 暂存修改
git stash

# 更新代码
git pull origin master

# 恢复修改
git stash pop
```

#### 4. 网络连接问题

**问题**: 无法连接到GitHub API

**解决方案**:
```bash
# 检查网络连接
curl -I https://api.github.com

# 使用代理（如果需要）
export https_proxy=http://proxy.example.com:8080

# 临时禁用更新检查
export DGIT_DISABLE_UPDATE_CHECK=1
```

### 调试模式

启用调试信息查看详细更新过程：

```bash
# 启用调试模式
export DGIT_DEBUG=1

# 运行命令查看详细信息
dgit commit
```

## 版本历史

### v1.0.0 (2025-01-27)
- 🎉 初始版本发布
- ✨ 支持跨平台Git提交
- 🔧 别名管理功能
- 📋 剪贴板自动复制
- 🔄 版本控制功能

## 技术支持

- **GitHub仓库**: https://github.com/aolongyu/repo-dgit.git
- **多点Git仓库管理规范**: https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb
- **技术支持**: 敖龙宇 / longyu.ao@dmall.com

## 最佳实践

### 1. 定期更新
- 建议定期运行 `dgit --version` 检查版本
- 关注更新提示，及时获取新功能和修复

### 2. 备份配置
- 定期备份 `.dgit_aliases` 文件
- 记录自定义配置和别名

### 3. 网络环境
- 确保网络连接稳定
- 如使用代理，配置相应的环境变量

### 4. 权限管理
- 确保对项目目录有读写权限
- 定期检查脚本执行权限 