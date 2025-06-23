#!/usr/bin/env pwsh

# dgit - PowerShell专用Git提交辅助工具
# 用于生成符合规范的Git提交信息

# 检查命令参数
if ($args[0] -eq "help") {
    Write-Host ""
    Write-Host "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
    Write-Host "更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com"
    Write-Host ""
    exit 1
}

if ($args[0] -ne "commit") {
    Write-Host "用法: dgit commit"
    exit 1
}

# 定义提交类型选项
$commitTypes = @(
    "新功能(feature)",
    "修复缺陷(fix)",
    "线上问题紧急修复(hotfix)",
    "代码重构(refactor)",
    "其他(others)"
)

# 显示提交类型选择
Write-Host "请选择提交类型:"
for ($i = 0; $i -lt $commitTypes.Length; $i++) {
    Write-Host "$($i + 1). $($commitTypes[$i])"
}

# 获取用户选择
do {
    $choice = Read-Host "请输入选择 (1-$($commitTypes.Length))"
    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $commitTypes.Length) {
        $selectedType = $commitTypes[[int]$choice - 1]
        break
    } else {
        Write-Host "无效选择，请输入 1-$($commitTypes.Length) 之间的数字"
    }
} while ($true)

# 提取类型简写（括号内部分）
$typeShort = $selectedType -replace '.*\((.*)\).*', '$1'

# 获取问题编号
do {
    $issueNumber = Read-Host "请输入需求单号(必填)"
    if (-not [string]::IsNullOrWhiteSpace($issueNumber)) {
        break
    } else {
        Write-Host "需求单号不能为空!"
    }
} while ($true)

# 获取提交描述
do {
    $commitDescription = Read-Host "请输入提交描述"
    if (-not [string]::IsNullOrWhiteSpace($commitDescription)) {
        break
    } else {
        Write-Host "提交描述不能为空!"
    }
} while ($true)

# 生成并显示提交信息
$commitMsg = "$typeShort: $issueNumber, $commitDescription"
Write-Host ""
Write-Host "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
Write-Host "生成的提交信息:"
Write-Host "----------------------------------------"
Write-Host "git commit -m '$commitMsg'" -ForegroundColor Green
Write-Host "----------------------------------------"

# 确认是否执行提交
Write-Host ""
Write-Host "当前git config user.name: "
git config user.name
Write-Host "当前git config user.email: "
git config user.email
Write-Host ""

$answer = Read-Host "是否执行命令 [git commit -m '$commitMsg'] ? [y/N]"
if ($answer -match '^[Yy]') {
    git commit -m "$commitMsg"
    Write-Host "提交成功"
} else {
    Write-Host "已复制 $commitMsg 到剪贴板，可自行执行提交"
    # 使用PowerShell的剪贴板功能
    try {
        Set-Clipboard -Value $commitMsg
    } catch {
        Write-Host "无法复制到剪贴板，请手动复制: $commitMsg"
    }
} 