# MCP-инфраструктура

## Серверы

| Сервер | Порт | Тип | Назначение |
|--------|------|-----|-----------|
| `rlm-tools-bsl` | 9000 | HTTP MCP (SSE) | Исследование кода: find_module, grep, read_file, llm_query |
| `bsl-ls` | 8080 | HTTP MCP (Streamable) | Диагностика и навигация BSL через bsl-language-server (`lsp --mcp`) |
| `1c-syntax` | stdio | Python | Справка по встроенным функциям 1С |

`bsl-ls` — комбинированный процесс `bsl-language-server`: один JVM-процесс обслуживает LSP (stdio, редактор) и MCP (Streamable HTTP на `http://127.0.0.1:8080/mcp`). Заменяет прежние `1c-lsp-diagnostics` (9011) и `1c-lsp-navigation` (9014) от `lsp-skill-server`.

## Доступ из агентов

| Сервер | Способ | Скилл |
|--------|--------|-------|
| bsl-ls (8080) | MCP сервер `bsl-ls` из `.kilo/kilo.jsonc` | `1c-check`, `1c-lsp` |
| rlm-tools-bsl (9000) | Подключенные MCP-инструменты; HTTP fallback при их отсутствии | `mcp-tools-bsl` |
| 1c-syntax (stdio) | Алгоритм через MCP | `1cskills` |

## Подъём bsl-ls

Процесс запускает VS Code-плагин **Language 1C (BSL)** (`1c-syntax.language-1c-bsl`).

### Текущие версии

- VS Code-плагин Language 1C (BSL): `2.1.1`;
- BSL Language Server: `1.1.0-rc.4`;
- канал обновлений BSL Language Server: `prerelease`.

Минимальная версия BSL Language Server для MCP: `1.0.0`. Текущая stable-версия `1.0.7`
старше минимальной, но младше установленной prerelease-версии `1.1.0-rc.4`.

### Настройки VS Code

Обязательные для этого workspace параметры хранятся в `.vscode/settings.json`:

```json
{
  "language-1c-bsl.languageServerEnabled": true,
  "language-1c-bsl.languageServerMcpEnabled": true,
  "language-1c-bsl.languageServerMcpPort": "8080",
  "language-1c-bsl.languageServerConfiguration": ".bsl-language-server.json",
  "language-1c-bsl.languageServerJavaOpts": "-Xmx12g -XX:+UseG1GC"
}
```

`languageServerJavaOpts` задаётся на уровне workspace и перекрывает User Settings. `-Xmx12g` нужен для
индексации текущей конфигурации: при `-Xmx8g` зафиксирован `OutOfMemoryError`.

Канал загрузки сервера задаётся в VS Code User Settings (`%APPDATA%\Code\User\settings.json`):

```json
{
  "language-1c-bsl.languageServerReleaseChannel": "prerelease"
}
```

`stable` загружает последний stable-релиз. `prerelease` загружает последний релиз, включая release candidate.

### Конфиг BSL Language Server

Конфиг сервера хранится в `.bsl-language-server.json` в корне репозитория. Критичные параметры:

```json
{
  "language": "ru",
  "configurationRoot": "main",
  "diagnostics": {
    "computeTrigger": "onSave"
  }
}
```

Плагин скачивает сервер в VS Code `globalStorage`. При ошибке GitHub API 403 сервер ставится вручную
(см. `.kilo/guides/mcp.md`, известные проблемы п. 3). На Windows используется `bsl-language-server.exe`
со встроенным runtime; отдельная системная Java не нужна. Сервер работает, пока VS Code открыт с этим
workspace. Открытие первого `.bsl` или `.os` файла активирует плагин и запускает сервер.

**Ключевая настройка — `configurationRoot`:** в `.bsl-language-server.json` задан `"configurationRoot": "main"`. Без него сервер строит модель конфигурации из всего корня репозитория, включая git-worktree `.kilo/worktrees/*` (полные копии конфигурации) и битые XML-фикстуры `tests/` — это зависает на минуты, и `document_symbols`/`analyze_file` падают по таймауту (60-120с). С `configurationRoot: "main"` индексируется только `E:\bases\istk\main`.

## Маршруты

- Capability mapping и единый приоритет: [capability-map.md](capability-map.md).
- Правила вызовов RLM: [rlm-workflow.md](rlm-workflow.md); HTTP fallback BSL-LS: skill `mcp-tools-bsl` соответствующего агента.

## Известные проблемы

1. **`bsl-ls` недоступен** — VS Code закрыт/workspace не открыт/не открыт `.bsl` файл. Перезапустить VS Code.
2. **`File is not part of any registered workspace`** — путь вне workspace или URI вместо пути.
3. **MCP-режим экспериментальный** (Spring AI 2.0 milestone), появился в v1.0.0; бинарник должен быть ≥ 1.0.0.
4. **Индексация заново после перезапуска VS Code** — 31k файлов, несколько минут; результаты частичные.
5. **Нет `workspace-symbols`** — поиск пользовательских методов по имени закрывает RLM (`rlm_execute` search / `git_search`).
6. **`bsl-language-server.exe` — это два процесса** — launcher (stub) и дочерний JVM, который слушает 8080. Убийство одного из них оставляет порт занятым.
7. **`sendErrors` по умолчанию `ask`** — при ошибке разбора метаданных LS шлёт клиенту `window/showMessageRequest` («отправить ошибку в Sentry?») и синхронно ждёт ответа внутри построения конфигурации. Без ответа поток `compute-configuration` висит вечно: CPU/IO нулевые, все вызовы `bsl-ls.*` падают по таймауту. Лечится `"sendErrors": "never"` в `.bsl-language-server.json` (задано).
8. **Битый `Ext/AdditionalIndexes.xml`** у `main/Documents/ноРасчетПремии` и `main/Documents/ноРасчетПремииВЭД` — источник той самой ошибки разбора: у обоих пустые `<Table/>` и `<IndexedFields/>`. Остальные три файла дополнительных индексов в конфигурации заполнены и ошибок не дают.
9. **После сна/гибернации bsl-ls не восстанавливается** — см. раздел ниже.

## Восстановление bsl-ls после сна/гибернации

Симптом: после выхода из сна VS Code и `bsl-language-server` живы, но MCP не отвечает, инструментов
`bsl-ls.*` в сессии Kilo нет; убийство процесса, перезапуск VS Code и повторное убийство не помогают —
работоспособность возвращает только перезагрузка ОС.

Причины (лог расширения `%APPDATA%\Code\logs\<ts>\window*\exthost\1c-syntax.language-1c-bsl\BSL Language Server.log`):

1. `bsl-language-server.exe` запускается как два процесса: launcher и дочерний JVM, который держит 8080.
   Убийство одного из них оставляет JVM с портом, и следующие запуски падают:
   `Web server failed to start. Port 8080 was already in use`. После 5 попыток расширение сдаётся
   до конца сессии окна: `The BSL Language Server server crashed 5 times in the last 3 minutes.
   The server will not be restarted`.
2. Kilo регистрирует MCP-инструменты только при инициализации сессии агента. Если в этот момент 8080
   не отвечает, `bsl-ls.*` не появятся даже после того, как сервер ожил, — нужна новая сессия.
3. Отдельный сценарий «LS поднялся, но не работает»: `MCP server enabled` в логе есть, а любой вызов
   висит по таймауту. Это не порт, а зависшее построение конфигурации из-за `sendErrors: ask`
   (см. известные проблемы 7–8): в логе перед зависанием стоят `Can't convert` / `Can't read file ... broken`.

Порядок восстановления (без перезагрузки ОС):

```powershell
pwsh scripts/bsl-ls-recover.ps1          # статус: процессы, владелец 8080, ответ /mcp
pwsh scripts/bsl-ls-recover.ps1 -Kill    # убить все bsl-language-server, дождаться освобождения 8080
# окно E:\bases\istk -> Developer: Reload Window (Ctrl+R), открыть любой .bsl
pwsh scripts/bsl-ls-recover.ps1 -Wait    # ждать готовности /mcp (до 180 с)
# затем начать новую сессию Kilo
```

Признак успеха: `-Wait` вывел `bsl-ls MCP готов`, в новой сессии Kilo доступны инструменты `bsl-ls.*`.

Профилактика:

- убивать процессы `bsl-language-server` только все сразу (`-Kill`), не по одному в диспетчере задач;
- после сна сначала освободить 8080 (`-Kill`), и только потом перезагружать окно VS Code;
- MCP на 8080 включает только этот workspace (`language-1c-bsl.languageServerMcpPort` в `.vscode/settings.json`);
  другие workspace 1С на этой машине не должны поднимать MCP на том же порту.
