#!/usr/bin/env pwsh

# dgit 版本管理器 (PowerShell版本)
# 支持更新和回退到指定版本

# 加载公共配置
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$SCRIPT_DIR\common.ps1"

# 显示帮助信息
function Show-VersionHelp {
    Write-Host ""
    Write-Host "dgit version 命令使用说明"
    Write-Host "=========================="
    Write-Host ""
    Write-Host "用法: dgit version <子命令> [参数...]"
    Write-Host ""
    Write-Host "子命令:"
    Write-Host "  list                    # 显示可用版本列表"
    Write-Host "  current                 # 显示当前版本"
    Write-Host "  update [版本号]         # 更新到指定版本（默认最新版本）"
    Write-Host "  rollback [版本号]       # 回退到指定版本"
    Write-Host "  info [版本号]           # 显示指定版本的详细信息"
    Write-Host "  help                    # 显示此帮助信息"
    Write-Host ""
    Write-Host "示例:"
    Write-Host "  dgit version list                    # 查看所有可用版本"
    Write-Host "  dgit version current                 # 查看当前版本"
    Write-Host "  dgit version update                  # 更新到最新版本"
    Write-Host "  dgit version update 1.1.0            # 更新到指定版本"
    Write-Host "  dgit version rollback 1.0.0          # 回退到指定版本"
    Write-Host "  dgit version info 1.1.0              # 查看版本信息"
    Write-Host ""
}

# 获取可用版本列表
function Get-AvailableVersions {
    $projectRoot = Get-ProjectRoot
    
    # 检查是否是Git仓库
    if (-not (Test-Path (Join-Path $projectRoot ".git"))) {
        Write-Host "❌ 错误: 当前目录不是Git仓库" -ForegroundColor Red
        return $null
    }
    
    # 获取所有标签
    $tags = git -C $projectRoot tag --sort=-version:refname 2>$null | Select-Object -First 20
    
    if (-not $tags) {
        Write-Host "⚠️  警告: 没有找到版本标签" -ForegroundColor Yellow
        return $null
    }
    
    return $tags
}

# 显示版本列表
function Show-VersionList {
    Write-Host "📋 可用版本列表:"
    Write-Host "----------------------------------------"
    
    $versions = Get-AvailableVersions
    
    if ($versions) {
        $count = 0
        foreach ($version in $versions) {
            if ($version) {
                $count++
                Write-Host "$count. $version"
            }
        }
        
        Write-Host ""
        Write-Host "共找到 $count 个版本"
    } else {
        Write-Host "无法获取版本列表"
    }
}

# 显示当前版本
function Show-CurrentVersion {
    Write-Host "📋 当前版本信息:"
    Write-Host "----------------------------------------"
    Write-Host "版本号: $DGIT_VERSION"
    Write-Host "发布日期: $DGIT_RELEASE_DATE"
    Write-Host "GitHub仓库: $DGIT_GITHUB_REPO"
    
    # 获取Git标签信息
    $projectRoot = Get-ProjectRoot
    
    if (Test-Path (Join-Path $projectRoot ".git")) {
        $currentTag = git -C $projectRoot describe --tags --exact-match 2>$null
        if (-not $currentTag) { $currentTag = "未标记" }
        Write-Host "Git标签: $currentTag"
        
        $commitHash = git -C $projectRoot rev-parse --short HEAD 2>$null
        if (-not $commitHash) { $commitHash = "未知" }
        Write-Host "提交哈希: $commitHash"
    }
}

# 验证版本号格式
function Test-VersionFormat {
    param([string]$Version)
    
    # 检查版本号格式 (x.y.z 或 vx.y.z)
    if ($Version -match '^v?[0-9]+\.[0-9]+\.[0-9]+$') {
        # 移除v前缀
        return $Version -replace '^v', ''
    } else {
        Write-Host "❌ 错误: 无效的版本号格式 '$Version'" -ForegroundColor Red
        Write-Host "版本号格式应为: x.y.z 或 vx.y.z" -ForegroundColor Red
        return $null
    }
}

# 检查版本是否存在
function Test-VersionExists {
    param([string]$TargetVersion)
    
    $projectRoot = Get-ProjectRoot
    
    # 检查标签是否存在
    $tagExists = git -C $projectRoot tag -l $TargetVersion 2>$null | Where-Object { $_ -eq $TargetVersion }
    if ($tagExists) {
        return $true
    }
    
    # 检查带v前缀的标签
    $vTagExists = git -C $projectRoot tag -l "v$TargetVersion" 2>$null | Where-Object { $_ -eq "v$TargetVersion" }
    if ($vTagExists) {
        return $true
    }
    
    return $false
}

# 更新到指定版本
function Update-ToVersion {
    param([string]$TargetVersion)
    
    $projectRoot = Get-ProjectRoot
    
    # 验证版本号
    $cleanVersion = Test-VersionFormat $TargetVersion
    if (-not $cleanVersion) {
        return $false
    }
    
    # 检查版本是否存在
    if (-not (Test-VersionExists $cleanVersion)) {
        Write-Host "❌ 错误: 版本 '$cleanVersion' 不存在" -ForegroundColor Red
        Write-Host "使用 'dgit version list' 查看可用版本" -ForegroundColor Red
        return $false
    }
    
    # 检查是否是Git仓库
    if (-not (Test-Path (Join-Path $projectRoot ".git"))) {
        Write-Host "❌ 错误: 当前目录不是Git仓库" -ForegroundColor Red
        return $false
    }
    
    Write-Host "🔄 开始更新到版本 $cleanVersion..."
    
    # 保存当前分支
    $currentBranch = git -C $projectRoot branch --show-current 2>$null
    
    # 获取远程更新
    Write-Host "正在获取最新代码..."
    $fetchResult = git -C $projectRoot fetch origin 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 错误: 无法获取远程更新" -ForegroundColor Red
        return $false
    }
    
    # 检查是否有本地修改
    $hasChanges = git -C $projectRoot diff-index --quiet HEAD -- 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  警告: 检测到本地修改，正在暂存..." -ForegroundColor Yellow
        git -C $projectRoot stash push -m "dgit version update $(Get-Date)" 2>$null
        $hasStash = $true
    }
    
    # 切换到指定版本
    Write-Host "正在切换到版本 $cleanVersion..."
    $checkoutResult = git -C $projectRoot checkout $cleanVersion 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 错误: 无法切换到版本 $cleanVersion" -ForegroundColor Red
        return $false
    }
    
    # 恢复本地修改
    if ($hasStash) {
        Write-Host "正在恢复本地修改..."
        git -C $projectRoot stash pop 2>$null
    }
    
    # 设置执行权限
    Write-Host "正在设置执行权限..."
    $files = @(
        (Join-Path $projectRoot "dgit"),
        (Join-Path $projectRoot "install.sh"),
        (Join-Path $projectRoot "scripts\*.sh"),
        (Join-Path $projectRoot "scripts\*.ps1")
    )
    
    foreach ($file in $files) {
        if (Test-Path $file) {
            Unblock-File -Path $file -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host "✅ 更新完成!" -ForegroundColor Green
    Write-Host "已切换到版本 $cleanVersion"
    
    # 显示新版本信息
    Write-Host ""
    Show-CurrentVersion
}

# 回退到指定版本
function Rollback-ToVersion {
    param([string]$TargetVersion)
    
    $projectRoot = Get-ProjectRoot
    
    # 验证版本号
    $cleanVersion = Test-VersionFormat $TargetVersion
    if (-not $cleanVersion) {
        return $false
    }
    
    # 检查版本是否存在
    if (-not (Test-VersionExists $cleanVersion)) {
        Write-Host "❌ 错误: 版本 '$cleanVersion' 不存在" -ForegroundColor Red
        Write-Host "使用 'dgit version list' 查看可用版本" -ForegroundColor Red
        return $false
    }
    
    # 检查是否是Git仓库
    if (-not (Test-Path (Join-Path $projectRoot ".git"))) {
        Write-Host "❌ 错误: 当前目录不是Git仓库" -ForegroundColor Red
        return $false
    }
    
    Write-Host "🔄 开始回退到版本 $cleanVersion..."
    
    # 保存当前分支
    $currentBranch = git -C $projectRoot branch --show-current 2>$null
    
    # 检查是否有本地修改
    $hasChanges = git -C $projectRoot diff-index --quiet HEAD -- 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  警告: 检测到本地修改，正在暂存..." -ForegroundColor Yellow
        git -C $projectRoot stash push -m "dgit version rollback $(Get-Date)" 2>$null
        $hasStash = $true
    }
    
    # 切换到指定版本
    Write-Host "正在切换到版本 $cleanVersion..."
    $checkoutResult = git -C $projectRoot checkout $cleanVersion 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 错误: 无法切换到版本 $cleanVersion" -ForegroundColor Red
        return $false
    }
    
    # 恢复本地修改
    if ($hasStash) {
        Write-Host "正在恢复本地修改..."
        git -C $projectRoot stash pop 2>$null
    }
    
    # 设置执行权限
    Write-Host "正在设置执行权限..."
    $files = @(
        (Join-Path $projectRoot "dgit"),
        (Join-Path $projectRoot "install.sh"),
        (Join-Path $projectRoot "scripts\*.sh"),
        (Join-Path $projectRoot "scripts\*.ps1")
    )
    
    foreach ($file in $files) {
        if (Test-Path $file) {
            Unblock-File -Path $file -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host "✅ 回退完成!" -ForegroundColor Green
    Write-Host "已切换到版本 $cleanVersion"
    
    # 显示新版本信息
    Write-Host ""
    Show-CurrentVersion
}

# 显示版本详细信息
function Show-VersionInfo {
    param([string]$TargetVersion)
    
    $projectRoot = Get-ProjectRoot
    
    # 验证版本号
    $cleanVersion = Test-VersionFormat $TargetVersion
    if (-not $cleanVersion) {
        return $false
    }
    
    # 检查版本是否存在
    if (-not (Test-VersionExists $cleanVersion)) {
        Write-Host "❌ 错误: 版本 '$cleanVersion' 不存在" -ForegroundColor Red
        Write-Host "使用 'dgit version list' 查看可用版本" -ForegroundColor Red
        return $false
    }
    
    Write-Host "📋 版本 $cleanVersion 详细信息:"
    Write-Host "----------------------------------------"
    
    # 获取版本信息
    $commitHash = git -C $projectRoot rev-parse $cleanVersion 2>$null
    if (-not $commitHash) { $commitHash = "未知" }
    Write-Host "提交哈希: $commitHash"
    
    $commitDate = git -C $projectRoot log -1 --format="%cd" --date=short $cleanVersion 2>$null
    if (-not $commitDate) { $commitDate = "未知" }
    Write-Host "提交日期: $commitDate"
    
    $commitAuthor = git -C $projectRoot log -1 --format="%an" $cleanVersion 2>$null
    if (-not $commitAuthor) { $commitAuthor = "未知" }
    Write-Host "提交作者: $commitAuthor"
    
    $commitMessage = git -C $projectRoot log -1 --format="%s" $cleanVersion 2>$null
    if (-not $commitMessage) { $commitMessage = "未知" }
    Write-Host "提交信息: $commitMessage"
    
    # 获取版本差异
    $currentVersion = git -C $projectRoot describe --tags --exact-match 2>$null
    if (-not $currentVersion) { $currentVersion = "未标记" }
    
    if ($currentVersion -ne $cleanVersion) {
        Write-Host ""
        Write-Host "与当前版本的差异:"
        $diffCount = git -C $projectRoot rev-list --count "$currentVersion..$cleanVersion" 2>$null
        if (-not $diffCount) { $diffCount = "0" }
        Write-Host "提交数量差异: $diffCount"
    }
}

# 主函数
function Main {
    param(
        [string]$Subcommand,
        [string]$Version
    )
    
    switch ($Subcommand) {
        "list" {
            Show-VersionList
        }
        "current" {
            Show-CurrentVersion
        }
        "update" {
            if ($Version) {
                Update-ToVersion $Version
            } else {
                # 更新到最新版本
                Write-Host "🔄 更新到最新版本..."
                Perform-Update
            }
        }
        "rollback" {
            if ($Version) {
                Rollback-ToVersion $Version
            } else {
                Write-Host "❌ 错误: 请指定要回退的版本号" -ForegroundColor Red
                Write-Host "用法: dgit version rollback <版本号>" -ForegroundColor Red
                exit 1
            }
        }
        "info" {
            if ($Version) {
                Show-VersionInfo $Version
            } else {
                Write-Host "❌ 错误: 请指定要查看的版本号" -ForegroundColor Red
                Write-Host "用法: dgit version info <版本号>" -ForegroundColor Red
                exit 1
            }
        }
        { $_ -eq "help" -or $_ -eq "" } {
            Show-VersionHelp
        }
        default {
            Write-Host "❌ 错误: 未知子命令 '$Subcommand'" -ForegroundColor Red
            Write-Host "使用 'dgit version help' 查看帮助信息" -ForegroundColor Red
            exit 1
        }
    }
}

# 运行主函数
Main $args[0] $args[1] 