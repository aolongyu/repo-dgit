#!/usr/bin/env zsh

# dgit - Zsh专用Git提交辅助工具
# 用于生成符合规范的Git提交信息

# 检查命令参数
if [[ "$1" == "help" ]]; then
  echo ""
  echo "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
  echo "更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com"
  echo ""
  exit 1
fi
if [[ "$1" != "commit" ]]; then
  echo "用法: dgit commit"
  exit 1
fi

# 获取脚本目录（兼容Zsh的$0处理）
SCRIPT_DIR="${0:a:h}"
DIALOG_SCRIPT="$SCRIPT_DIR/dgit_dialog.applescript"

# 检查对话框脚本是否存在
if [[ ! -f "$DIALOG_SCRIPT" ]]; then
  echo "错误: 找不到对话框脚本 $DIALOG_SCRIPT"
  exit 1
fi

# 执行AppleScript对话框并获取结果
RESULT=$(osascript "$DIALOG_SCRIPT")

# 处理取消结果
if [[ "$RESULT" == "cancel" ]]; then
  echo "dgit commit 命令已终止(用户触发取消操作)"
  exit 0
fi

# 处理校验失败结果
if [[ "$RESULT" == "errorvalidate" ]]; then
  echo "dgit commit 命令已终止(用户触发录入数据校验未通过)"
  exit 0
fi

# 解析结果（使用Zsh的字符串分割）
IFS='|' read -r TYPE ISSUE DESC <<< "$RESULT"

# 验证结果完整性
if [[ -z "$TYPE" || -z "$ISSUE" || -z "$DESC" ]]; then
  echo "错误: 提交信息不完整"
  dgit help
  exit 1
fi

# 生成并显示提交信息
COMMIT_MSG="$TYPE: $ISSUE, $DESC"
echo ""
echo "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
echo "生成的提交信息:"
echo "----------------------------------------"
echo "\033[32mgit commit -m '$COMMIT_MSG'\033[0m"
echo "----------------------------------------"


# 确认是否执行提交（取消注释以下行启用自动提交）
echo ""
echo "当前git config user.name: "
git config user.name
echo "当前git config user.email: "
git config user.email
echo ""

echo -n "是否执行命令 [git commit -m '$COMMIT_MSG'] ? [y/N] "
read answer
if [[ "$answer" == [Yy]* ]]; then
  git commit -m "$COMMIT_MSG"
  echo "提交成功"
else
  echo "已复制\033[47;30m $COMMIT_MSG \033[0m到剪贴板，可自行执行提交"
  echo "$COMMIT_MSG" | pbcopy
fi