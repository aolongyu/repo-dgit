#!/usr/bin/osascript

-- 定义提交类型选项
set commit_types to {"新功能(feature)", "修复缺陷(fix)", "线上问题紧急修复(hotfix)", "代码重构(refactor)", "其他(others)"}

try
  -- 显示提交类型选择对话框
  set commit_type_result to choose from list commit_types with title "Git提交类型" ¬
    with prompt "请选择提交类型:" default items {"新功能(feature)"} ¬
    OK button name "下一步" cancel button name "取消"

  -- 处理用户取消
  if commit_type_result is false then
    return "cancel"
  end if

  set selected_type to item 1 of commit_type_result

  -- 提取类型简写（括号内部分）
  set type_short to do shell script "echo " & quoted form of selected_type & " | sed -E 's/.*\\((.*)\\).*/\\1/'"

  -- 获取问题编号
  set issue_number to text returned of (display dialog "请输入需求单号(必填):" default answer "" ¬
    with title "Git提交信息" buttons {"取消", "下一步"} default button "下一步" ¬
    with icon note)

  -- 验证问题编号不为空
  if issue_number is "" then
    display alert "错误" message "需求单号不能为空!" as warning
    return "errorvalidate"
  end if

  -- 获取提交描述
  set commit_description to text returned of (display dialog "请输入提交描述:" default answer "" ¬
    with title "Git提交信息" buttons {"取消", "确定"} default button "确定" ¬
    with icon note)

  -- 验证提交描述不为空
  if commit_description is "" then
    display alert "错误" message "提交描述不能为空!" as warning
    return "errorvalidate"
  end if

  -- 返回结果（使用|分隔）
  return type_short & "|" & issue_number & "|" & commit_description

on error err_msg number err_num
  -- 用户点击取消按钮
  if err_num = -128 then
    return "cancel"
  else
    display alert "错误" message "发生错误: " & err_msg as warning
    return "cancel"
  end if
end try