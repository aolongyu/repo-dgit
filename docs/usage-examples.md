# dgit 使用示例

本文档提供了 dgit 工具在不同场景下的使用示例，帮助用户更好地理解和使用该工具。

## 基本使用场景

### 1. 新功能开发

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

### 2. 缺陷修复

```bash
$ dgit commit

请选择提交类型:
1) feature - 新功能
2) fix - 修复缺陷
3) hotfix - 线上问题紧急修复
4) refactor - 代码重构
5) others - 其他

请输入选择 (1-5): 2

请输入需求单号: DOP-456

请输入提交描述: 修复支付接口超时问题

生成的提交信息:
----------------------------------------
git commit -m 'fix: DOP-456, 修复支付接口超时问题'
----------------------------------------

是否执行命令 [git commit -m 'fix: DOP-456, 修复支付接口超时问题'] ? [y/N] y
提交成功
```

### 3. 紧急修复

```bash
$ dgit commit

请选择提交类型:
1) feature - 新功能
2) fix - 修复缺陷
3) hotfix - 线上问题紧急修复
4) refactor - 代码重构
5) others - 其他

请输入选择 (1-5): 3

请输入需求单号: DOP-789

请输入提交描述: 紧急修复数据库连接问题

生成的提交信息:
----------------------------------------
git commit -m 'hotfix: DOP-789, 紧急修复数据库连接问题'
----------------------------------------

是否执行命令 [git commit -m 'hotfix: DOP-789, 紧急修复数据库连接问题'] ? [y/N] y
提交成功
```

## 别名管理

### 添加常用别名

```bash
# 添加功能开发别名
$ dgit alias add DOP-123 "用户登录功能开发"
别名添加成功: DOP-123 -> 用户登录功能开发

# 添加修复别名
$ dgit alias add DOP-456 "支付接口优化"
别名添加成功: DOP-456 -> 支付接口优化

# 添加紧急修复别名
$ dgit alias add DOP-789 "数据库连接优化"
别名添加成功: DOP-789 -> 数据库连接优化
```

### 查看别名列表

```bash
$ dgit alias list
当前别名列表:
DOP-123: 用户登录功能开发
DOP-456: 支付接口优化
DOP-789: 数据库连接优化
```

### 使用别名快速提交

```bash
$ dgit commit

请选择提交类型:
1) feature - 新功能
2) fix - 修复缺陷
3) hotfix - 线上问题紧急修复
4) refactor - 代码重构
5) others - 其他

请输入选择 (1-5): 1

请输入需求单号: DOP-123

检测到别名: 用户登录功能开发
是否使用别名作为提交描述? [Y/n] y

生成的提交信息:
----------------------------------------
git commit -m 'feature: DOP-123, 用户登录功能开发'
----------------------------------------

是否执行命令 [git commit -m 'feature: DOP-123, 用户登录功能开发'] ? [y/N] y
提交成功
```

### 删除别名

```bash
$ dgit alias remove DOP-123
别名删除成功: DOP-123
```

## 高级使用场景

### 1. 批量提交

```bash
#!/bin/bash
# 批量提交脚本示例

issues=("DOP-123" "DOP-456" "DOP-789")
descriptions=("功能A" "功能B" "功能C")

for i in "${!issues[@]}"; do
    echo "提交 ${issues[$i]}: ${descriptions[$i]}"
    echo "feature: ${issues[$i]}, ${descriptions[$i]}" | dgit commit
done
```

### 2. 自动化脚本

```bash
#!/bin/bash
# 自动化提交脚本

# 检查是否有未提交的更改
if [[ -n $(git status --porcelain) ]]; then
    echo "发现未提交的更改，开始提交..."
    
    # 添加所有更改
    git add .
    
    # 使用dgit提交
    dgit commit
else
    echo "没有需要提交的更改"
fi
```

### 3. 环境变量配置

```bash
# macOS/Linux - 设置环境变量
export DGIT_DEBUG=1
export DGIT_NO_CLIPBOARD=0

# Windows PowerShell - 设置环境变量
$env:DGIT_DEBUG = "1"
$env:DGIT_NO_CLIPBOARD = "0"
```

## 故障排除示例

### 1. 权限问题

```bash
# 错误信息
-bash: ./dgit: Permission denied

# 解决方案
chmod +x dgit install.sh scripts/dgit.sh scripts/dgit.ps1
```

### 2. 剪贴板问题

```bash
# Linux环境剪贴板错误
xclip: Error: Can't open display: (null)

# 解决方案
export DISPLAY=:0
# 或者安装xclip
sudo apt-get install xclip
```

### 3. PowerShell执行策略

```powershell
# 错误信息
无法加载文件，因为在此系统上禁止运行脚本

# 解决方案
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. 编码问题

```bash
# 中文显示乱码
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

# Windows PowerShell
chcp 65001
```

### 5. Git配置问题

```bash
# 检查Git配置
git config --list

# 设置Git用户信息
git config --global user.name "你的姓名"
git config --global user.email "你的邮箱@example.com"
```

## 最佳实践

### 1. 提交信息规范

- 使用清晰的描述
- 包含需求单号
- 遵循团队规范

```bash
# 好的提交信息
feature: DOP-123, 添加用户登录功能
fix: DOP-456, 修复支付接口超时问题
hotfix: DOP-789, 紧急修复数据库连接问题

# 避免的提交信息
update
fix bug
new feature
```

### 2. 别名管理

- 为常用需求单号创建别名
- 定期清理不需要的别名
- 使用描述性的别名名称

### 3. 环境配置

- 确保Git配置正确
- 配置剪贴板支持
- 设置适当的执行权限

### 4. 团队协作

- 统一使用相同的工具版本
- 遵循团队的提交规范
- 及时更新工具版本

### 5. 脚本集成

```bash
# 在项目根目录创建提交脚本
cat > commit.sh << 'EOF'
#!/bin/bash
# 项目提交脚本

echo "开始提交代码..."
dgit commit

if [ $? -eq 0 ]; then
    echo "提交成功！"
else
    echo "提交失败，请检查错误信息"
    exit 1
fi
EOF

chmod +x commit.sh
```

## 常见问题解答

### Q: 如何修改默认的提交类型？

A: 目前不支持修改默认提交类型，但可以通过别名功能快速选择常用类型。

### Q: 支持哪些Git操作？

A: 目前主要支持 `git commit` 操作，未来可能扩展支持其他Git操作。

### Q: 如何备份别名数据？

A: 别名数据存储在本地文件中，可以手动备份或使用版本控制管理。

### Q: 支持自定义提交模板吗？

A: 目前使用固定的提交格式，未来可能支持自定义模板。

### Q: 如何在无头服务器上使用？

A: 在Linux无头服务器上，可以设置 `export DGIT_NO_CLIPBOARD=1` 禁用剪贴板功能。

### Q: 支持批量提交吗？

A: 可以通过脚本实现批量提交，但建议每次提交都有明确的目的和描述。

## 技术支持

- 多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb
- 更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com 