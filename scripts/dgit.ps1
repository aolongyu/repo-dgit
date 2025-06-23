#!/usr/bin/env pwsh

# dgit - PowerShell专用Git提交辅助工具
# 用于生成符合规范的Git提交信息
# 兼容Windows PowerShell

# 获取脚本所在目录
function Get-ScriptDirectory {
    $scriptPath = $MyInvocation.MyCommand.Path
    if (-not $scriptPath) {
        $scriptPath = $PSCommandPath
    }
    return Split-Path -Parent $scriptPath
}

$SCRIPT_DIR = Get-ScriptDirectory
$ALIAS_FILE = Join-Path (Split-Path $SCRIPT_DIR -Parent) ".dgit_aliases"

# 显示别名选择菜单
function Show-AliasMenu {
    if (-not (Test-Path $ALIAS_FILE) -or (Get-Item $ALIAS_FILE).Length -eq 0) {
        return $null
    }
    
    $aliases = @()
    $codes = @()
    $descriptions = @()
    
    # 读取别名数据
    $lines = Get-Content $ALIAS_FILE | Where-Object { $_ -notmatch '^#' -and $_.Trim() -ne '' }
    foreach ($line in $lines) {
        $parts = $line -split '\|'
        if ($parts.Count -ge 2) {
            $aliases += $parts[1].Trim()
            $codes += $parts[0].Trim()
            $descriptions += if ($parts.Count -ge 3) { $parts[2].Trim() } else { "" }
        }
    }
    
    if ($aliases.Count -eq 0) {
        return $null
    }
    
    Write-Host "请选择需求单号别名:"
    
    for ($i = 0; $i -lt $aliases.Count; $i++) {
        $desc = $descriptions[$i]
        if ($desc) {
            Write-Host "$($i+1). $($aliases[$i]) ($($codes[$i])) - $desc"
        } else {
            Write-Host "$($i+1). $($aliases[$i]) ($($codes[$i]))"
        }
    }
    
    # 获取用户选择
    do {
        $choice = Read-Host "请输入选择 (1-$($aliases.Count))"
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $aliases.Count) {
            $selectedIndex = [int]$choice - 1
            return $codes[$selectedIndex]
        } else {
            Write-Host "无效选择，请输入 1-$($aliases.Count) 之间的数字"
        }
    } while ($true)
}

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

# 定义需要单号的提交类型
$typesNeedIssue = @("feature", "fix", "hotfix")

# 显示提交类型选择
Write-Host ""
Write-Host "请选择提交类型:"
for ($i = 0; $i -lt $commitTypes.Count; $i++) {
    Write-Host "$($i+1). $($commitTypes[$i])"
}

# 获取用户选择
do {
    $choice = Read-Host "请输入选择 (1-$($commitTypes.Count))"
    if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $commitTypes.Count) {
        $selectedType = $commitTypes[[int]$choice - 1]
        break
    } else {
        Write-Host "无效选择，请输入 1-$($commitTypes.Count) 之间的数字"
    }
} while ($true)

# 提取类型简写（括号内部分）
$typeShort = $selectedType -replace '.*\((.*)\).*', '$1'

# 检查是否需要输入单号
$needIssue = $false
foreach ($type in $typesNeedIssue) {
    if ($typeShort -eq $type) {
        $needIssue = $true
        break
    }
}

# 获取问题编号（如果需要）
if ($needIssue) {
    Write-Host ""
    Write-Host "(1/3) 需求单号输入:"
    Write-Host "请选择输入方式:"
    Write-Host "1. 使用别名选择"
    Write-Host "2. 手动输入单号"

    # 第一步：选择输入方式
    do {
        $inputChoice = Read-Host "请输入选择 (1-2)"
        if ($inputChoice -eq "1") {
            # 选择使用别名
            Write-Host ""
            $aliasResult = Show-AliasMenu
            if ($aliasResult) {
                # 用户选择了别名
                $issueNumber = $aliasResult
                Write-Host ""
                Write-Host "✓ 已选择别名对应的单号: $issueNumber"
                break
            } else {
                # 没有可用的别名
                Write-Host ""
                Write-Host "没有可用的别名，请选择手动输入"
                continue
            }
        } elseif ($inputChoice -eq "2") {
            # 选择手动输入
            Write-Host ""
            do {
                $issueNumber = Read-Host "请输入需求单号(必填)"
                if ($issueNumber) {
                    break
                } else {
                    Write-Host "需求单号不能为空!"
                }
            } while ($true)
            break
        } else {
            Write-Host "无效选择，请输入 1 或 2"
        }
    } while ($true)
} else {
    # 不需要单号的类型，直接进入描述输入
    $issueNumber = ""
}

# 获取提交描述
Write-Host ""
if ($needIssue) {
    Write-Host "(2/3) 请输入提交描述:"
} else {
    Write-Host "(1/2) 请输入提交描述:"
}
do {
    $commitDescription = Read-Host "请输入提交描述(必填)"
    if ($commitDescription) {
        break
    } else {
        Write-Host "提交描述不能为空!"
    }
} while ($true)

# 生成并显示提交信息
if ($needIssue) {
    $commitMsg = "$typeShort`: $issueNumber, $commitDescription"
    Write-Host ""
    Write-Host "(3/3) 确认提交信息:"
} else {
    $commitMsg = "$typeShort`: $commitDescription"
    Write-Host ""
    Write-Host "(2/2) 确认提交信息:"
}
Write-Host "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
Write-Host "生成的提交信息:"
Write-Host "----------------------------------------"
Write-Host -ForegroundColor Green "git commit -m '$commitMsg'"
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
    # 复制到剪贴板
    $commitMsg | Set-Clipboard
} 