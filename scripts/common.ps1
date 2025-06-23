# dgit PowerShell 公共配置文件
# 包含所有PowerShell脚本共享的函数和常量

# 获取脚本所在目录
function Get-ScriptDirectory {
    $scriptPath = $MyInvocation.MyCommand.Path
    if (-not $scriptPath) {
        $scriptPath = $PSCommandPath
    }
    return Split-Path -Parent $scriptPath
}

# 获取项目根目录
function Get-ProjectRoot {
    $scriptDir = Get-ScriptDirectory
    return Split-Path -Parent $scriptDir
}

# 别名文件路径
function Get-AliasFile {
    $projectRoot = Get-ProjectRoot
    return Join-Path $projectRoot ".dgit_aliases"
}

# 提交类型定义
$COMMIT_TYPES = @(
    "新功能(feature)",
    "修复缺陷(fix)",
    "线上问题紧急修复(hotfix)",
    "代码重构(refactor)",
    "其他(others)"
)

# 需要单号的提交类型
$TYPES_NEED_ISSUE = @("feature", "fix", "hotfix")

# 显示别名选择菜单
function Show-AliasMenu {
    $aliasFile = Get-AliasFile
    
    if (-not (Test-Path $aliasFile) -or (Get-Item $aliasFile).Length -eq 0) {
        return $null
    }
    
    $aliases = @()
    $codes = @()
    $descriptions = @()
    
    # 读取别名数据
    $lines = Get-Content $aliasFile | Where-Object { $_ -notmatch '^#' -and $_.Trim() -ne '' }
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

# 显示帮助信息
function Show-Help {
    Write-Host ""
    Write-Host "多点Git仓库管理规范：https://duodian.feishu.cn/wiki/X9wRwzeM7i39iQk7TxZccBdFnvb"
    Write-Host "更多问题飞书联系：敖龙宇 / longyu.ao@dmall.com"
    Write-Host ""
}

# 复制到剪贴板
function Copy-ToClipboard {
    param([string]$Text)
    
    try {
        $Text | Set-Clipboard
        return $true
    } catch {
        Write-Host "无法复制到剪贴板，请手动复制: $Text"
        return $false
    }
} 