# Plan Controller (DevRails-Kilo) → OpenSpec

> Исторический документ. DevRails и GRACE отключены в ИСТК 2026-10-03.
> Скилы, команды и скрипты обслуживания удалены. Старые артефакты сохранены.
> Действующий маршрут — OpenSpec; см. AGENTS.md и docs/agent-ops.md §12.
> Описанные ниже команды, gates и установка больше не применяются к ИСТК.


> **Статус:** adapted (2026-08-04). Фреймворк — форк
> [DevRails-26](https://github.com/nicelight/DevRails-26) с поддержкой Kilo Code.
> Полный реестр заимствований — [external-borrowings.md](external-borrowings.md).

## Роль

DevRails plan controller владеет **планированием**: от сырой идеи до
согласованного плана фичи (gate `APPROVE`). OpenSpec владеет **реализацией**:
после согласования план переносится в `openspec/changes/<id>/`, и дальнейшую
работу ведут `/openspec-propose` и `/openspec-apply-change`.

Это одна поверхность, а не два параллельных планировщика: план не дублируется,
а передаётся через bridge-команду `/dr-to-openspec`.

## Компоненты

| Компонент | Путь | Назначение |
|---|---|---|
| Форк | `E:\bases\devrails-kilo` | canonical source фреймворка (git-репо, remote `upstream` → DevRails-26) |
| Команды Kilo | `.kilo/command/*.md` | 20 plan-controller slash-команд |
| Скиллы Kilo | `.kilo/skills/*/SKILL.md` | auto-discoverable версии тех же команд (физические копии) |
| Кодекс/Claude | `.agents/skills/`, `.claude/skills/` | те же команды для Codex/Claude Code (физические копии) |
| Durable plan state | `.memory-bank/` | PRD, конституция, спёки, feature plan, task queue (коммитится) |
| Runtime state | `.protocols/`, `.tasks/` | протоколы сессий и отчёты (не коммитятся по умолчанию) |
| Readiness | `scripts/mb-lint.mjs`, `scripts/mb-doctor.mjs` | механические проверки структуры/готовности |

## Канонический flow

```
/cold-start
  -> /brainstorm (сырая идея) | /brief (ясный концепт)
  -> /constitution (если project_principles не ratified|partial)
  -> /write-prd
  -> /spec-init
  -> /prd-to-features
  -> /review-feat-plan (для high-risk/large)
  -> /spec-design          # Global Backbone + Foundation decision
  -> /foundation-to-tasks  # только если Foundation Required: true
  -> /feature-to-tasks FT-<NNN>
  -> /review-tasks-plan FT-<NNN>   # gate APPROVE (REVIEWED_PLANNING_REVISION)
  -> /dr-to-openspec FT-<NNN>      # -> openspec/changes/<id>/
  -> /openspec-propose -> /openspec-apply-change   # реализация
```

Brownfield (текущий контур ИСТК): при наличии кода без PRD/delta сначала
`/map-codebase` для as-is baseline, затем запрос PRD/delta. Декомпозиция
EP/FT/TASK без PRD/delta не выполняется.

## Установка и обновление

Фреймворк уже установлен в ИСТК (`--plan-only` подмножество). Обновление из
форка:

```bash
node E:\bases\devrails-kilo\scripts\install-framework.mjs --plan-only --bootstrap --sync --target E:\bases\istk --yes
```

`--sync` обновляет framework-owned команды и Memory Bank assets; собственные
файлы проекта и AGENTS.md не перезаписываются. Полный набор команд (включая
`exe/verify/red-verify/autopilot`) НЕ устанавливается: реализацию ведёт OpenSpec.

## Общие скиллы между агентами

Codex и Kilo Code работают в одном репозитории. Команды DevRails ставятся
**физическими копиями** на каждой поверхности — `.agents/skills/<name>`
(Codex CLI), `.claude/skills/<name>` (Claude Code), `.kilo/skills/<name>` +
`.kilo/command/<name>.md` (Kilo Code). Копии байт-идентичны, потому что
единственный писатель — инсталлер.

- Обновление: `node …\install-framework.mjs --plan-only --bootstrap --sync
  --target E:\bases\istk --yes` — переписывает все поверхности из спек команд
  форка (единый источник правды). Копии не «расползаются».
- Junction/симлинки между поверхностями **не используются**: сканеры скиллов
  (Kilo/Codex/Claude) пропускают junction-каталоги (`Dirent.isDirectory()` =
  false) — автодискавери молча ломается. Проверено свежей сессией Kilo
  (форк v0.1.1): slash-команды работали, скиллы через junction — нет.
- Git: в `.gitignore` игнорируются дублирующие поверхности
  (`.claude/skills/`, `.kilo/skills/*` уже игнорируется); коммитится одна
  поверхность `.agents/skills/`.
- Конфликт-чек и cleanup работают по маркеру generated: чужой каталог без
  маркера не трогается; оставшиеся от эксперимента junction-каталоги при
  `--sync` заменяются реальными копиями.

## Bridge `/dr-to-openspec`

Переносит согласованный план фичи в OpenSpec change:

- проверяет gate: PRD `clarification_status: complete`, `constitution_checked: true`,
  Global Backbone валиден, review `APPROVE` с совпадающим `REVIEWED_PLANNING_REVISION`;
- создаёт `openspec/changes/<id>/` (`.openspec.yaml` со `schema: spec-driven`);
- заполняет `proposal.md` (Why/What/Capabilities/Impact из feature + IMPL-плана),
  `design.md` (из backbone, Architecture Spine AD-*, boundary-map, ADR),
  `specs/<capability>/spec.md` (требования + `FT-<NNN>-AC-<NNN>` критерии),
  `tasks.md` (пункты из `.memory-bank/tasks/TASK-*.task.json`, `depends_on`,
  tier, done-критерии со статическими gates);
- валидирует через `openspec status --change <id> --json`;
- handoff на `/openspec-propose` для доводки и `/openspec-apply-change` для
  выполнения.

Идентификаторы фич/REQ/AC/tier сохраняются в артефактах OpenSpec, чтобы
трассировка RTM (`docs/agent-ops.md` §5) не рвалась.

## Взаимодействие с остальным контуром

- Тиры T0–T3 и статические gates — `docs/agent-ops.md` §1; карточки задач в
  `tasks.md` OpenSpec используют те же done-критерии.
- Quality-лимиты и ревью — `docs/1c-review-checklist.md`, `docs/query-review.md`,
  `docs/openspec-spec-quality.md`.
- Runtime-проверки остаются deferred (см. `docs/verification-plan.xml`); в
  задачах это явные пункты `runtime-проверка (deferred): ...`.

## Обслуживание

- `node scripts/mb-doctor.mjs` — готовность; `--strict` перед автономным
  прогоном очереди (в ИСТК используется только диагностически).
- `node scripts/mb-lint.mjs` — механическая консистентность `.memory-bank/`.
- `/mb-sync` — согласование уже принятых изменений между файлами Memory Bank
  (после волны/значимого изменения).
- `/mb-garden` — точечные механические правки ссылок/индексов.
- `PAPERCUTS/` — записи о мелких помехах рабочего процесса.

## Уровни риска и передачи

Планирование не создаёт выполнимых задач в OpenSpec до `APPROVE`. `REJECT`
возвращает фичу на repair owner (`/feature-to-tasks FT-<NNN>` →
`/review-tasks-plan FT-<NNN>`). Изменение Global Backbone `Planning Revision`
инвалидирует старые APPROVE и требует повторного планирования.
