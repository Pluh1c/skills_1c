# cfe-dump v1.0 — Dump 1C configuration extension (CFE) to XML sources
# Uses ibcmd config export with standalone-server temp database
<#
.SYNOPSIS
    Разборка расширения конфигурации 1С в XML-исходники

.DESCRIPTION
    Разбирает CFE-файл во XML-исходники через ibcmd config export.
    При отсутствии базы в standalone-server создает временную и удаляет после выгрузки.

.PARAMETER V8Path
    Путь к каталогу bin платформы или к 1cv8.exe

.PARAMETER InputFile
    Путь к CFE-файлу

.PARAMETER OutputDir
    Каталог для выгрузки исходников

.EXAMPLE
    .\cfe-dump.ps1 -InputFile "ext.cfe" -OutputDir "src"

.EXAMPLE
    .\cfe-dump.ps1 -V8Path "C:\Program Files\1cv8\8.5.1.1150\bin" -InputFile "ext.cfe" -OutputDir "src"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$V8Path,

    [Parameter(Mandatory=$true)]
    [string]$InputFile,

    [Parameter(Mandatory=$true)]
    [string]$OutputDir
)

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Resolve V8Path ---
if (-not $V8Path) {
    $found = Get-ChildItem "C:\Program Files\1cv8\*\bin\1cv8.exe" -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1
    if ($found) {
        $V8Path = Split-Path $found.FullName -Parent
    } else {
        Write-Host "Error: 1cv8.exe not found. Specify -V8Path" -ForegroundColor Red
        exit 1
    }
} elseif (Test-Path $V8Path -PathType Leaf) {
    $V8Path = Split-Path $V8Path -Parent
}

$ibcmd = Join-Path $V8Path "ibcmd.exe"
if (-not (Test-Path $ibcmd)) {
    # Try ibcmd without extension
    $ibcmd = Join-Path $V8Path "ibcmd"
    if (-not (Test-Path $ibcmd)) {
        Write-Host "Error: ibcmd not found in $V8Path" -ForegroundColor Red
        exit 1
    }
}

# --- Validate input file ---
if (-not (Test-Path $InputFile)) {
    Write-Host "Error: input file not found: $InputFile" -ForegroundColor Red
    exit 1
}

# --- Ensure output directory exists ---
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# --- Standalone server data dir ---
$standaloneData = Join-Path $env:LOCALAPPDATA "1C\1cv8\standalone-server"
$dbData = Join-Path $standaloneData "db-data"
$dbFile = Join-Path $dbData "1Cv8.1CD"

# Track whether we created the temp DB
$tempDbCreated = $false

try {
    # --- Ensure database exists ---
    if (-not (Test-Path $dbFile)) {
        Write-Host "Creating temporary database for export..."
        if (-not (Test-Path $dbData)) {
            New-Item -ItemType Directory -Path $dbData -Force | Out-Null
        }
        $createArgs = @("infobase", "create", "--data", $standaloneData)
        $createResult = & $ibcmd @createArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error creating temporary database: $createResult" -ForegroundColor Red
            exit 1
        }
        $tempDbCreated = $true
    } else {
        Write-Host "Using existing database in standalone-server"
    }

    # --- Export ---
    Write-Host "Exporting CFE to XML: $InputFile -> $OutputDir"
    $exportArgs = @("config", "export", "--data", $standaloneData, "-f", $InputFile, $OutputDir)
    $exportResult = & $ibcmd @exportArgs 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        $fileCount = (Get-ChildItem $OutputDir -Recurse -File).Count
        Write-Host "Export completed: $fileCount files written to $OutputDir" -ForegroundColor Green
    } else {
        Write-Host "Error exporting CFE (code: $exitCode)" -ForegroundColor Red
        if ($exportResult) {
            Write-Host $exportResult
        }
    }

    exit $exitCode

} finally {
    # --- Cleanup temp DB ---
    if ($tempDbCreated) {
        Write-Host "Cleaning up temporary database..."
        Remove-Item $dbFile -Force -ErrorAction SilentlyContinue
        Remove-Item (Join-Path $dbData "1Cv8.cgr.cfl") -Force -ErrorAction SilentlyContinue
    }
}
