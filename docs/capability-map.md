# Карта capabilities: что умеем и каким инструментом

> **Provenance:** концепция `framework/capabilities/registry.yaml` из [SteelMorgan/1c-agent-based-dev-framework](https://github.com/SteelMorgan/1c-agent-based-dev-framework), адаптирована под стек ИСТК. Статус: **adapted** (2026-08-04). Полный реестр — [external-borrowings.md](external-borrowings.md).

Единый реестр «какая задача → какой инструмент». Навыки должны ссылаться на **capability по имени**, а не хардкодить имена инструментов в промптах — замена MCP-сервера тогда меняется в одном месте.

Инфраструктура серверов, порты и запуск — [mcp.md](mcp.md). Здесь — только маппинг capability → инструмент и единый приоритет.

Приоритет: RLM для поиска/исследования → BSL-LS для навигации/диагностики → 1c-syntax для API платформы → точечное чтение известного файла.

## 1. Код: поиск и навигация

| Capability | Инструмент | Сервер/команда |
|---|---|---|
| `navigate_symbol` / `definition` | `1c-lsp` definition / document_symbols | bsl-ls 8080 (LSP navigation) |
| `find_references` | `1c-lsp` find_references | bsl-ls 8080 |
| `get_call_graph` (входящие/исходящие) | `1c-lsp` call_hierarchy (один уровень) | bsl-ls 8080 |
| `workspace_symbols` | **нет в bsl-ls** — искать через `rlm_execute` (search / git_search) | rlm-tools-bsl 9000 |
| `find_module` / `find_code_usages` / `git_search` | `rlm_execute` (хелперы) | rlm-tools-bsl 9000 |
| `llm_query` (семантический вопрос по коду) | `rlm_execute` (llm_query) | rlm-tools-bsl 9000 |
| `parse_form` / структура формы | `rlm_execute` (parse_form) или `form-info` | rlm-tools-bsl 9000 / skill |

## 2. Диагностика

| Capability | Инструмент | Сервер/команда |
|---|---|---|
| `get_diagnostics` (синтаксис/статика) | `1c-check` analyze_file | bsl-ls 8080 |
| `cf_validate` (XML-структура метаданных) | skill `cf-validate` / `meta-validate` | CLI-скиллы |

## 3. Работа с метаданными и XML

| Capability | Инструмент | Сервер/команда |
|---|---|---|
| `metadata_compile` | `meta-compile` / `form-compile` / `skd-compile` / `mxl-compile` | skills |
| `metadata_info` | `meta-info` / `form-info` / `skd-info` / `mxl-info` | skills |
| `metadata_edit` | `meta-edit` / `form-edit` / `skd-edit` / `interface-edit` | skills |
| `extension_borrow` / `patch_method` | `cfe-borrow` / `cfe-patch-method` | skills |
| `role_edit` | `role-edit` (права/RLS существующей роли) | skill; после правки `role-validate` |
| `extension_admin` | `db-cfe-admin` (check/set-properties) | CLI; цель базы/расширения явно, мутации по AGENTS |
| `platform_xsd` | `v8-xsd-fetch` | skill; версия формата XML, сеть/кеш по запросу |
| `epf_build` / `erf_build` | `epf-build` / `erf-build` | skills |

## 4. Справка по платформе

| Capability | Инструмент | Сервер/команда |
|---|---|---|
| `syntax_reference` (встроенные функции) | `1c-syntax` | stdio (1cskills) |

## 5. Ревью (cross-provider)

| Capability | Инструмент | Замечания |
|---|---|---|
| `cross_review` | **Codex CLI** (`codex exec`) независимым агентом | Ревьюер не слабее автора; формат BLOCK/WARN/INFO; см. `1c-review-checklist.md` §6 |

## 6. Соглашение для новых навыков

В frontmatter/описании навыка объявлять используемые capabilities:

```yaml
uses_capabilities:
  - navigate_symbol
  - get_call_graph
  - get_diagnostics
```

Правила:
- capability не в реестре → сообщить, а не подменять «похожим» инструментом
- замена сервера (RLM→LSP для конкретной задачи) — осознанное решение, не автоматическое
- новые capabilities добавлять в эту карту в момент появления
