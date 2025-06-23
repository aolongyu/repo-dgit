# dgit 公共配置文件 (PowerShell版本)
# 包含所有脚本共享的函数和常量

# 版本信息
$DGIT_VERSION = "1.0.0"
$DGIT_RELEASE_DATE = "2025-01-27"
$DGIT_GITHUB_REPO = "https://github.com/aolongyu/repo-dgit.git"
$DGIT_RELEASE_API = "https://api.github.com/repos/aolongyu/repo-dgit/releases/latest"

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

# 版本检查文件路径
function Get-VersionCheckFile {
    $projectRoot = Get-ProjectRoot
    return Join-Path $projectRoot ".dgit_version_check"
}

# 版本比较函数
function Compare-Versions {
    param(
        [string]$Version1,
        [string]$Version2
    )
    
    $v1Parts = $Version1.Split('.')
    $v2Parts = $Version2.Split('.')
    
    $maxLength = [Math]::Max($v1Parts.Length, $v2Parts.Length)
    
    for ($i = 0; $i -lt $maxLength; $i++) {
        $v1Part = if ($i -lt $v1Parts.Length) { [int]$v1Parts[$i] } else { 0 }
        $v2Part = if ($i -lt $v2Parts.Length) { [int]$v2Parts[$i] } else { 0 }
        
        if ($v1Part -gt $v2Part) {
            return "newer"
        }
        elseif ($v1Part -lt $v2Part) {
            return "older"
        }
    }
    
    return "same"
}

# 检查网络连接
function Test-NetworkConnection {
    try {
        $response = Invoke-WebRequest -Uri "https://api.github.com" -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# 获取最新版本信息
function Get-LatestVersion {
    try {
        $response = Invoke-WebRequest -Uri $DGIT_RELEASE_API -TimeoutSec 15 -UseBasicParsing -ErrorAction Stop
        $releaseData = $response.Content | ConvertFrom-Json
        
        $latestVersion = $releaseData.tag_name -replace '^v', ''
        $releaseDate = $releaseData.published_at.Split('T')[0]
        $releaseNotes = $releaseData.body.Substring(0, [Math]::Min(200, $releaseData.body.Length))
        
        if ($latestVersion) {
            return "$latestVersion|$releaseDate|$releaseNotes"
        }
    }
    catch {
        return $null
    }
    
    return $null
}

# 检查版本更新
function Check-VersionUpdate {
    # 如果禁用了版本检查，直接返回
    if ($env:DGIT_DISABLE_UPDATE_CHECK -eq "1") {
        return
    }
    
    $versionCheckFile = Get-VersionCheckFile
    
    # 检查是否需要检查更新（每天最多检查一次）
    if (Test-Path $versionCheckFile) {
        $lastCheck = Get-Content $versionCheckFile -TotalCount 1
        $currentDate = Get-Date -Format "yyyy-MM-dd"
        
        if ($lastCheck -eq $currentDate) {
            return
        }
    }
    
    # 检查网络连接
    if (-not (Test-NetworkConnection)) {
        return
    }
    
    # 获取最新版本信息
    $latestInfo = Get-LatestVersion
    if (-not $latestInfo) {
        return
    }
    
    # 解析版本信息
    $parts = $latestInfo.Split('|')
    $latestVersion = $parts[0]
    $releaseDate = $parts[1]
    $releaseNotes = $parts[2]
    
    if (-not $latestVersion) {
        return
    }
    
    # 比较版本
    $versionComparison = Compare-Versions -Version1 $DGIT_VERSION -Version2 $latestVersion
    
    if ($versionComparison -eq "older") {
        # 保存检查时间
        Get-Date -Format "yyyy-MM-dd" | Out-File -FilePath $versionCheckFile -Encoding UTF8
        
        # 显示更新提示
        Show-UpdatePrompt -LatestVersion $latestVersion -ReleaseDate $releaseDate -ReleaseNotes $releaseNotes
    }
    else {
        # 保存检查时间
        Get-Date -Format "yyyy-MM-dd" | Out-File -FilePath $versionCheckFile -Encoding UTF8
    }
}

# 显示更新提示
function Show-UpdatePrompt {
    param(
        [string]$LatestVersion,
        [string]$ReleaseDate,
        [string]$ReleaseNotes
    )
    
    Write-Host ""
    Write-Host "🔄 发现新版本可用!" -ForegroundColor Yellow
    Write-Host "当前版本: $DGIT_VERSION"
    Write-Host "最新版本: $LatestVersion"
    if ($ReleaseDate) {
        Write-Host "发布日期: $ReleaseDate"
    }
    if ($ReleaseNotes) {
        Write-Host "更新内容: $ReleaseNotes..."
    }
    Write-Host ""
    Write-Host "是否现在更新? [Y/n]"
    Write-Host "  Y - 立即更新"
    Write-Host "  n - 跳过本次更新"
    Write-Host ""
    
    $choice = Read-Host "请选择"
    
    switch ($choice.ToLower()) {
        { $_ -eq "" -or $_ -eq "y" -or $_ -eq "yes" } {
            Perform-Update
        }
        { $_ -eq "n" -or $_ -eq "no" } {
            Write-Host "已跳过更新，下次运行时会再次提示"
        }
        default {
            Write-Host "无效选择，跳过更新"
        }
    }
}

# 执行更新
function Perform-Update {
    Write-Host "开始更新 dgit..."
    
    $projectRoot = Get-ProjectRoot
    
    # 检查是否是Git仓库
    if (-not (Test-Path (Join-Path $projectRoot ".git"))) {
        Write-Host "❌ 错误: 当前目录不是Git仓库，无法自动更新" -ForegroundColor Red
        Write-Host "请手动下载最新版本: $DGIT_GITHUB_REPO"
        return
    }
    
    # 保存当前分支
    $currentBranch = git -C $projectRoot branch --show-current 2>$null
    
    # 获取远程更新
    Write-Host "正在获取最新代码..."
    $fetchResult = git -C $projectRoot fetch origin 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 错误: 无法获取远程更新" -ForegroundColor Red
        return
    }
    
    # 检查是否有本地修改
    $hasChanges = git -C $projectRoot diff-index --quiet HEAD -- 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  警告: 检测到本地修改，正在暂存..." -ForegroundColor Yellow
        git -C $projectRoot stash push -m "dgit auto-update $(Get-Date)" 2>$null
        $hasStash = $true
    }
    
    # 切换到主分支并更新
    Write-Host "正在更新代码..."
    $checkoutResult = git -C $projectRoot checkout master 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 错误: 无法切换到master分支" -ForegroundColor Red
        return
    }
    
    $pullResult = git -C $projectRoot pull origin master 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 错误: 无法拉取最新代码" -ForegroundColor Red
        return
    }
    
    # 恢复本地修改
    if ($hasStash) {
        Write-Host "正在恢复本地修改..."
        git -C $projectRoot stash pop 2>$null
    }
    
    # 设置执行权限（在PowerShell中主要是确保文件可执行）
    Write-Host "正在设置执行权限..."
    $files = @(
        (Join-Path $projectRoot "dgit"),
        (Join-Path $projectRoot "install.sh"),
        (Join-Path $projectRoot "scripts\*.sh"),
        (Join-Path $projectRoot "scripts\*.ps1")
    )
    
    foreach ($file in $files) {
        if (Test-Path $file) {
            # 在PowerShell中，主要是确保文件没有被阻止
            Unblock-File -Path $file -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host "✅ 更新完成!" -ForegroundColor Green
    Write-Host "新版本已安装，请重新运行命令"
    
    # 退出当前进程，让用户重新运行
    exit 0
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
    $count = 0
    
    # 读取别名数据
    $lines = Get-Content $aliasFile | Where-Object { $_ -notmatch '^#' }
    foreach ($line in $lines) {
        $parts = $line.Split('|')
        if ($parts.Length -ge 2 -and $parts[0] -and $parts[1]) {
            $aliases += $parts[1]
            $codes += $parts[0]
            $descriptions += if ($parts.Length -ge 3) { $parts[2] } else { "" }
            $count++
        }
    }
    
    if ($count -eq 0) {
        return $null
    }
    
    # 显示菜单
    Write-Host "请选择需求单号别名:" -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $count; $i++) {
        $desc = $descriptions[$i]
        if ($desc) {
            Write-Host "$($i+1). $($aliases[$i]) ($($codes[$i])) - $desc"
        }
        else {
            Write-Host "$($i+1). $($aliases[$i]) ($($codes[$i]))"
        }
    }
    
    # 获取用户选择
    do {
        $choice = Read-Host "请输入选择 (1-$count)"
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $count) {
            $selectedIndex = [int]$choice - 1
            return $codes[$selectedIndex]
        }
        else {
            Write-Host "无效选择，请输入 1-$count 之间的数字" -ForegroundColor Red
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
        Set-Clipboard -Value $Text
        return $true
    }
    catch {
        Write-Host "无法复制到剪贴板，请手动复制: $Text" -ForegroundColor Yellow
        return $false
    }
} 