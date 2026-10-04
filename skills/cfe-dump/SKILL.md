---
name: cfe-dump
description: Разобрать CFE-файл расширения конфигурации 1С в XML-исходники. Используй когда пользователь просит разобрать, декомпилировать расширение, получить исходники из CFE файла
argument-hint: <CfeFile>
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# /cfe-dump — Разборка расширения конфигурации

## Usage

```
/cfe-dump <CfeFile> [OutDir]
```

| Параметр | Обязательный | По умолчанию | Описание                            |
|----------|:------------:|--------------|-------------------------------------|
| CfeFile  | да           | —            | Путь к CFE-файлу                    |
| OutDir   | нет          | `src`        | Каталог для выгрузки исходников     |

## Принцип работы

Разборка CFE выполняется через `ibcmd config export`, который требует наличия информационной базы в standalone-server. Если база отсутствует — скрипт создаст временную и удалит после выгрузки.

1. Прочитай `.v8-project.json` из корня проекта для `v8path` (путь к платформе)
2. Если `v8path` не задан — автоопределение: `Get-ChildItem "C:\Program Files\1cv8\*\bin\1cv8.exe" | Sort -Desc | Select -First 1`

## Команда

```powershell
powershell.exe -NoProfile -File ".opencode/skills/cfe-dump/scripts/cfe-dump.ps1" <параметры>
```

### Параметры скрипта

| Параметр | Обязательный | Описание |
|----------|:------------:|----------|
| `-V8Path <путь>` | нет | Каталог bin платформы (или полный путь к 1cv8.exe) |
| `-InputFile <путь>` | да | Путь к CFE-файлу |
| `-OutputDir <путь>` | да | Каталог для выгрузки исходников |

## Примеры

```powershell
# Разборка расширения
powershell.exe -NoProfile -File ".opencode/skills/cfe-dump/scripts/cfe-dump.ps1" -InputFile "Расширения/МоеРасширение.cfe" -OutputDir "src/ext"

# С явным указанием платформы
powershell.exe -NoProfile -File ".opencode/skills/cfe-dump/scripts/cfe-dump.ps1" -V8Path "C:\Program Files\1cv8\8.5.1.1150\bin" -InputFile "Расширения/МоеРасширение.cfe" -OutputDir "src/ext"
```
