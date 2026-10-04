# OpenCode — глобальные настройки (архив)

Архив глобальных настроек OpenCode для развёртывания в любом проекте.
Источник архива — глобальный каталог конфигурации OpenCode на локальной машине
(стандартное расположение `~/.config/opencode`).

Репозиторий содержит конфигурацию, скиллы и скрипт развёртывания. Пути к
инструментам и каталогам (vault Obsidian, исполняемые файлы MCP) **намеренно не
зашиты в архив** — они локальные и задаются на каждой машине в `restore.local.json`.

## Состав

| Элемент | Назначение |
|---|---|
| `opencode.jsonc.tpl` | Шаблон конфига `opencode.jsonc` с плейсхолдерами `{{...}}`. Используется скриптом развёртывания для генерации рабочего конфига в проект: в него подставляются пути и набор MCP-серверов. |
| `skills/` | Набор скиллов OpenCode (инструкции + вспомогательные скрипты). Каждый скилл — каталог с `SKILL.md` (описание, когда применять) и `scripts/` (PowerShell/Python-реализация). Покрывают работу с 1С: конфигурация, расширения, базы, обработки/отчёты, формы, метаданные, СКД, XDTO, роли, подсистемы, макеты, а также интеграции Obsidian/Excel/DXF и тестирование через веб-клиент. Зависимости (`node_modules`) в архив не входят — ставятся отдельно. |
| `restore.config.json` | **Манифест развёртывания.** Перечисляет все компоненты (скиллы, плагин, конфиг, TUI, Playwright) и MCP-серверы с флагом `enabled`. `false` — компонент/MCP пропускается. Скрипт работает строго по этому манифесту. |
| `restore.local.json` | Локальные пути текущей машины (vault Obsidian, исполняемые файлы). **Не коммитится** (в `.gitignore`), заполняется при первом развёртывании. |
| `package.json`, `package-lock.json` | Зависимость `@opencode-ai/plugin` — набор SDK-типов для разработки плагинов opencode. Копируется в проект вместе со скиллами. |
| `tui.json` | Конфигурация TUI: подключает плагин голосового ввода `@hxnnxs/opencode-voice`. |
| `restore.ps1` | Скрипт развёртывания в проект. Читает манифест и локальные пути, копирует скиллы, генерирует конфиг, при необходимости ставит зависимости. |
| `MODELS.md` | Справка по моделям: как переключать модель (`/models`), задавать уровень рассуждений (`reasoningEffort`), настраивать раздельные модели для Plan/Build. |
| `docs/` | Правила и руководства: `rules.md` (работа со скиллами), `1c-rules.md`/`1c-standards.md`/`query-rules.md`/`1c-skd.md`/`1c-events.md`/`1c-methods.md`/`1c-contexts-and-modules.md`/`1c-bsp-patterns.md`/`1c-review-checklist.md` (разработка 1С), инфраструктурные (`mcp.md`, `capability-map.md`, `agent-ops.md` и др.), а также `external-borrowings.md` и `upstream-sync.md`. Индекс — [`docs/README.md`](docs/README.md). |
| `README.md` | Этот документ. |

## Справочные материалы скиллов

Внутри `skills/` ряд скиллов содержит каталоги/файлы со справочной информацией,
которую они используют при выполнении операций:

- `references/` (например `form-compile/references/`, `db-repo/references/`) —
  детальные справки по отдельным темам: компоновка форм, оформление, таблицы,
  отчёты, работа с хранилищем конфигурации.
- `reference/` (например `meta-compile/reference/`, `meta-edit/reference/`,
  `mxl-compile/reference/`) — справочники по объектам метаданных и макетам:
  типы, свойства, табличные части, правила оформления.
- `dsl-reference.md` (`role-compile/`) — описание DSL-формата прав ролей.
- `xsd-reference.md` (`xdto-compile/`) — описание работы с XSD-схемами.
- `presets/` (`form-compile/`) — готовые пресеты типовых форм.
- `examples/` (`skd-compile/`) — примеры стилей схемы компоновки.

Эти материалы — внутренние справочники скиллов, они не исполняются, а читаются
агентом при генерации/правке объектов и форм.

## Требования на машине

Глобальные зависимости, которые должны быть установлены на машине (пути к ним
определяются автоматически или указываются в `restore.local.json`):

- **OpenCode** — глобальная установка `opencode-ai`.
  - Документация: <https://opencode.ai>
  - Установка: `npm i -g opencode-ai` (источник: <https://www.npmjs.com/package/opencode-ai>)
- **mcpvault** — для MCP Obsidian (`@bitbonsai/mcpvault`).
  - Установка: `npm i -g @bitbonsai/mcpvault` (источник: <https://www.npmjs.com/package/@bitbonsai/mcpvault>)
- **uvx** — пакет `uv` для MCP Excel (`excel-mcp-server`).
  - Документация uv: <https://docs.astral.sh/uv/>
  - Установка: `pip install uv` или инсталлятор с <https://github.com/astral-sh/uv>
  - MCP-сервер: `uvx excel-mcp-server` (источник: <https://pypi.org/project/excel-mcp-server/>)
- **aiblueprint-mcp.exe** — для MCP DXF. Локальный исполняемый файл, путь задаётся в `restore.local.json`. Источник устанавливается вручную на машине (в архиве не распространяется).
- **Remote MCP `1c` (:6003)** и **`edt` (:8765)** — внешние серверы, должны быть запущены отдельно (установка описана в их собственной документации).

## Восстановление в проекте

```powershell
.\restore.ps1 -Project E:\path\to\project
```

Разворачивает в проект (согласно `restore.config.json`, только `enabled`):
- `.opencode\skills\` — скиллы
- `.opencode\opencode.jsonc` — конфиг с включёнными MCP-серверами
- `.opencode\package.json`, `package-lock.json`
- `.opencode\tui.json` (если включён)

### Подготовка (первый запуск)

1. Создайте `restore.local.json` в корне архива, указав локальные пути:

   ```json
   {
     "obsidianVault": "путь_к_vault_Obsidian",
     "aiblueprintExe": "путь_к_aiblueprint-mcp.exe"
   }
   ```

   Если файла нет, скрипт использует переменную окружения `OBSIDIAN_VAULT`
   и авто-поиск `aiblueprint-mcp*` в `%USERPROFILE%\.local\bin`.

2. Запустите `restore.ps1`.

### Параметры

| Параметр | Описание |
|---|---|
| `-Project <путь>` | Обязательный. Проект, куда разворачивать |
| `-Force` | Перезаписать существующий `.opencode\skills` |
| `-Models` | Установить настройку моделей Plan/Build (агент `plan`/`build` в `opencode.jsonc`). Так же включается флагом `models.enabled` в `restore.config.json`. |

> Включение/отключение компонентов и MCP-серверов — только через `restore.config.json`
> (флаг `enabled`). Например, чтобы не ставить Playwright, переключите
> `"playwright".enabled` на `false`.

## Примечания

- Скиллы рассчитаны на размещение в проекте (путь `.opencode/skills/<имя>/scripts/...`).
- `web-test` требует `npm install` (Playwright) — управляется флагом `playwright.enabled` в `restore.config.json`.
- Плагин голосового ввода `@hxnnxs/opencode-voice` в `tui.json` — устанавливается по необходимости.
- Модели Plan/Build настраиваются через `restore.ps1 -Models` или `models.enabled` в `restore.config.json`. Подробности — в `MODELS.md`.