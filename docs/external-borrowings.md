# Матрица заимствований из внешних репозиториев

Реестр материалов, из которых собран этот архив, и их лицензионный статус.
Обновляется при каждом новом заимствовании или пересмотре.

## Соглашение о статусах

- **adopted** — взято как есть, только локальная адаптация имён/путей
- **adapted** — взято с существенной переработкой
- **referenced** — только ссылка, содержимое не копируется
- **skipped** — рассмотрено и отклонено (с причиной)
- **watching** — интересно, но ещё не взято

## Источник: Nikolay-Shirokov/cc-1c-skills

URL: <https://github.com/Nikolay-Shirokov/cc-1c-skills> · MIT · основной источник `skills/`.

| Материал (в источнике) | Где в архиве | Статус | Примечания |
|---|---|---|---|
| скиллы `cf-*`, `meta-*`, `form-*`, `skd-*`, `mxl-*`, `role-*`, `subsystem-*`, `xdto-*`, `db-*`, `web-*`, `epf/erf-*`, `template-*`, `interface-*`, `support-edit`, `img-grid` | `skills/` | adopted | PowerShell и Python-варианты; источник и версия — в шапках скриптов (`# Source: ...`) |
| `role-edit`, `v8-xsd-fetch`, `cfe-dump` | `skills/` | adopted | Отсутствовали в архиве, добавлены из актуального порта upstream |
| Обновление версий остальных скиллов | — | watching | Архив отстаёт от upstream, см. [upstream-sync.md](upstream-sync.md) |

## Источник: comol/ai_rules_1c

URL: <https://github.com/comol/ai_rules_1c> · лицензия не объявлена, README разрешает использование.

| Материал (в источнике) | Где в архиве | Статус | Примечания |
|---|---|---|---|
| `async-methods`, `bsp-access-rights`, `integrations-add`, `locks-and-transactions`, `logging-strategy`, `dcs-design`, `query-optimization` | `docs/rules.md`, `skills/*/references/` | adapted | Оставлены проектно-независимые инварианты; проверка через `*-validate` |

## Источник: SteelMorgan/1c-agent-based-dev-framework

URL: <https://github.com/SteelMorgan/1c-agent-based-dev-framework> · PolyForm Small Business 1.0.0 (актуальная), прежняя запись — MIT.

| Материал (в источнике) | Где в архиве | Статус | Примечания |
|---|---|---|---|
| чек-листы ревью, tiering моделей, compaction, SDD | `docs/rules.md` | referenced | Изложены общие принципы, код не копировался |

## Источник: Dach-Coin/rlm-tools-bsl

URL: <https://github.com/Dach-Coin/rlm-tools-bsl>.

| Материал | Где | Статус | Примечания |
|---|---|---|---|
| RLM-навигация по 1С | — | referenced | Внешний контур; в архив не входит |

## Источник: yellow-hammer/namespace-forest

URL: <https://github.com/yellow-hammer/namespace-forest>.

| Материал | Где | Статус | Примечания |
|---|---|---|---|
| `schemas/designer/<версия>/` XSD | — | referenced | Схемы формата выгрузки скачивает скилл `v8-xsd-fetch` |

## Внешние MCP-интеграции

| Инструмент | Где | Статус | Примечания |
|---|---|---|---|
| Obsidian (`@bitbonsai/mcpvault`) | `skills/obsidian-draw`, `opencode.jsonc.tpl` | referenced | Устанавливается на машине; путь vault — в `restore.local.json` |
| Excel (`excel-mcp-server`) | `opencode.jsonc.tpl`, `skills/obsidian-draw` | referenced | Запуск через `uvx` |
| DXF (`aiblueprint-mcp.exe`) | `opencode.jsonc.tpl` | referenced | Локальный бинарь, в архив не входит |
| Remote MCP `1c` (:6003), `edt` (:8765) | `opencode.jsonc.tpl` | referenced | Внешние серверы, запускаются отдельно |

## Процедура обновления

1. Новое заимствование → добавить строку со статусом и датой.
2. При изменении контура → пересмотреть `skipped`/`watching` строки.
3. Пересмотр статусов — не реже раза в квартал или при смене версии upstream.
4. Удалять строки нельзя — только менять статус (история сохраняется).
