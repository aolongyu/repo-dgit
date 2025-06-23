#!/usr/bin/env pwsh

# 别名管理脚本 (PowerShell版本)
# 用于管理需求单号的别名

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

# 确保别名文件存在
function Ensure-AliasFile {
    if (-not (Test-Path $ALIAS_FILE)) {
        New-Item -Path $ALIAS_FILE -ItemType File -Force | Out-Null
        Set-Content -Path $ALIAS_FILE -Value "# dgit 需求单号别名文件"
        Add-Content -Path $ALIAS_FILE -Value "# 格式: 单号|别名|描述"
    }
}

# 添加别名
function Add-Alias {
    param(
        [string]$Code,
        [string]$AliasName,
        [string]$Description = ""
    )
    
    # 验证参数
    if ([string]::IsNullOrWhiteSpace($Code) -or [string]::IsNullOrWhiteSpace($AliasName)) {
        Write-Host "错误: 单号和别名不能为空"
        Write-Host "用法: dgit alias add <单号> <别名> [描述]"
        exit 1
    }
    
    Ensure-AliasFile
    
    # 检查别名是否已存在
    $existingAlias = Get-Content $ALIAS_FILE | Where-Object { $_ -match "^[^|]*\|$AliasName\|" }
    if ($existingAlias) {
        Write-Host "错误: 别名 '$AliasName' 已存在"
        exit 1
    }
    
    # 添加新别名
    Add-Content -Path $ALIAS_FILE -Value "$Code|$AliasName|$Description"
    Write-Host "✓ 别名添加成功: $AliasName -> $Code"
}

# 删除别名
function Remove-Alias {
    param([string]$AliasName)
    
    if ([string]::IsNullOrWhiteSpace($AliasName)) {
        Write-Host "错误: 别名不能为空"
        Write-Host "用法: dgit alias delete <别名>"
        exit 1
    }
    
    Ensure-AliasFile
    
    # 检查别名是否存在
    $existingAlias = Get-Content $ALIAS_FILE | Where-Object { $_ -match "^[^|]*\|$AliasName\|" }
    if (-not $existingAlias) {
        Write-Host "错误: 别名 '$AliasName' 不存在"
        exit 1
    }
    
    # 删除别名
    $content = Get-Content $ALIAS_FILE | Where-Object { $_ -notmatch "^[^|]*\|$AliasName\|" }
    Set-Content -Path $ALIAS_FILE -Value $content
    Write-Host "✓ 别名删除成功: $AliasName"
}

# 列出所有别名
function Show-Aliases {
    Ensure-AliasFile
    
    if (-not (Test-Path $ALIAS_FILE) -or (Get-Item $ALIAS_FILE).Length -eq 0) {
        Write-Host "暂无别名记录"
        return
    }
    
    Write-Host "需求单号别名列表:"
    Write-Host "----------------------------------------"
    Write-Host "单号`t`t别名`t`t描述"
    Write-Host "----------------------------------------"
    
    # 跳过注释行，显示别名
    Get-Content $ALIAS_FILE | Where-Object { $_ -notmatch '^#' } | ForEach-Object {
        $parts = $_ -split '\|'
        if ($parts.Length -ge 2) {
            $code = $parts[0]
            $aliasName = $parts[1]
            $description = if ($parts.Length -ge 3) { $parts[2] } else { "" }
            Write-Host "$($code.PadRight(15))`t$($aliasName.PadRight(15))`t$description"
        }
    }
}

# 根据别名获取单号
function Get-CodeByAlias {
    param([string]$AliasName)
    
    if ([string]::IsNullOrWhiteSpace($AliasName)) {
        return $null
    }
    
    Ensure-AliasFile
    
    $line = Get-Content $ALIAS_FILE | Where-Object { $_ -match "^[^|]*\|$AliasName\|" } | Select-Object -First 1
    if ($line) {
        $parts = $line -split '\|'
        return $parts[0]
    }
    return $null
}

# 显示别名选择菜单
function Show-AliasMenu {
    Ensure-AliasFile
    
    if (-not (Test-Path $ALIAS_FILE) -or (Get-Item $ALIAS_FILE).Length -eq 0) {
        return $null
    }
    
    $aliases = @()
    $codes = @()
    $descriptions = @()
    
    # 读取别名数据
    Get-Content $ALIAS_FILE | Where-Object { $_ -notmatch '^#' } | ForEach-Object {
        $parts = $_ -split '\|'
        if ($parts.Length -ge 2 -and -not [string]::IsNullOrWhiteSpace($parts[0]) -and -not [string]::IsNullOrWhiteSpace($parts[1])) {
            $aliases += $parts[1]
            $codes += $parts[0]
            $descriptions += if ($parts.Length -ge 3) { $parts[2] } else { "" }
        }
    }
    
    if ($aliases.Count -eq 0) {
        return $null
    }
    
    Write-Host "请选择需求单号别名 (或直接输入单号):"
    Write-Host "0. 直接输入单号"
    
    for ($i = 0; $i -lt $aliases.Count; $i++) {
        $desc = $descriptions[$i]
        if (-not [string]::IsNullOrWhiteSpace($desc)) {
            Write-Host "$($i+1). $($aliases[$i]) ($($codes[$i])) - $desc"
        } else {
            Write-Host "$($i+1). $($aliases[$i]) ($($codes[$i]))"
        }
    }
    
    # 获取用户选择
    do {
        $choice = Read-Host "请输入选择 (0-$($aliases.Count))"
        if ($choice -eq "0") {
            return $null  # 表示用户选择直接输入
        } elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $aliases.Count) {
            $selectedIndex = [int]$choice - 1
            return $codes[$selectedIndex]
        } else {
            Write-Host "无效选择，请输入 0-$($aliases.Count) 之间的数字"
        }
    } while ($true)
}

# 主函数
function Main {
    param(
        [string]$Action,
        [string]$Arg1,
        [string]$Arg2,
        [string]$Arg3
    )
    
    switch ($Action) {
        "add" {
            Add-Alias -Code $Arg1 -AliasName $Arg2 -Description $Arg3
        }
        "delete" {
            Remove-Alias -AliasName $Arg1
        }
        "del" {
            Remove-Alias -AliasName $Arg1
        }
        "remove" {
            Remove-Alias -AliasName $Arg1
        }
        "rm" {
            Remove-Alias -AliasName $Arg1
        }
        "list" {
            Show-Aliases
        }
        "ls" {
            Show-Aliases
        }
        "show" {
            Show-Aliases
        }
        "get" {
            $code = Get-CodeByAlias -AliasName $Arg1
            if ($code) {
                Write-Host $code
            }
        }
        "menu" {
            $result = Show-AliasMenu
            if ($result) {
                Write-Host $result
            }
        }
        default {
            Write-Host "用法: dgit alias <命令> [参数...]"
            Write-Host ""
            Write-Host "命令:"
            Write-Host "  add <单号> <别名> [描述]    添加别名"
            Write-Host "  delete <别名>              删除别名"
            Write-Host "  list                       列出所有别名"
            Write-Host "  get <别名>                 获取别名对应的单号"
            Write-Host "  menu                       显示别名选择菜单"
            Write-Host ""
            Write-Host "示例:"
            Write-Host "  dgit alias add DOP-123 商品需求v1.1 商品模块需求"
            Write-Host "  dgit alias delete 商品需求v1.1"
            Write-Host "  dgit alias list"
            exit 1
        }
    }
}

# 执行主函数
Main -Action $args[0] -Arg1 $args[1] -Arg2 $args[2] -Arg3 $args[3] 