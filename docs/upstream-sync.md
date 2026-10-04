# Предложение: обновить скиллы из cc-1c-skills

## Проблема

Скиллы в `skills/` — копия `Nikolay-Shirokov/cc-1c-skills` (в шапках скриптов стоит
`# Source: https://github.com/Nikolay-Shirokov/cc-1c-skills`), но на более старой
ревизии. Пока архив отстаёт, агент использует устаревшие форматы и теряет
исправления upstream.

## Свидетельства (версии скриптов)

Сравнение версий в архиве и в актуальном порте upstream:

| Скилл | В архиве | Актуальный порт |
|---|---|---|
| `cf-validate` | v1.10 | v1.12 |
| `cfe-borrow` | v1.37 | v1.43 |
| `cfe-diff` | v1.5 | v1.7 |
| `db-create` | v1.14 | v1.16 |
| `form-compile` | v1.196 | v1.199 |
| `form-validate` | v1.19 | v1.22 |
| `meta-compile` | v1.112 | v1.119 |
| `meta-edit` | v1.52 | v1.64 |
| `meta-validate` | v1.28 | v1.36 |
| `role-compile` | v1.36 | v1.45 |
| `role-validate` | v1.5 | v1.7 |
| `skd-compile` | v1.121 | v1.124 |
| `skd-edit` | v1.39 | v1.42 |
| `web-publish` | v1.9 | v1.12 |

Проверить текущие версии можно так:

```powershell
Get-ChildItem skills -Recurse -File -Include *.ps1,*.py |
  ForEach-Object {
    $m = Select-String -Path $_.FullName -Pattern 'v(\d+\.\d+)' -List | Select-Object -First 1
    if ($m) { "{0}`t{1}" -f $_.FullName, $m.Matches[0].Value }
  }
```

## Отсутствующие скиллы

В upstream есть, а в архиве не было: `role-edit`, `v8-xsd-fetch`, `cfe-dump`.
Добавлены этим PR.

## Процедура синхронизации

1. Получить актуальный `cc-1c-skills` (main) и сверить версии скриптов по таблице выше.
2. Перенести `skills/<имя>/` из upstream; при наличии Python-варианта — брать оба
   (`.ps1` и `.py`), как это уже сделано в архиве.
3. Пути в `SKILL.md` привести к конвенции архива: `.opencode/skills/<имя>/scripts/<скрипт>`.
4. **Не перезаписывать локальные скиллы** (`obsidian-draw`) — они вне upstream.
5. Прогнать `restore.ps1` в тестовом проекте и выполнить smoke-проверку
   (`cf-info`, `meta-info`, `form-info` на реальной выгрузке).
6. Зафиксировать новую ревизию upstream в `docs/external-borrowings.md`.

## Ожидаемый эффект

- Единая версия скиллов с upstream; новые `*-edit`/`*-dump` скиллы доступны.
- Меньше расхождений при копировании архива между машинами.
