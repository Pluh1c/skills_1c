---
paths: ["**/Form.Module.bsl"]
---

# Form Module Guidelines

## Client-Server Interaction

- Minimize client-server round trips in form modules.
- Group multiple server calls into a single call when possible.
- Avoid calling server methods in loops on the client side.

## Compilation Directives

| Directive | Use Case |
|---|---|
| `&НаКлиенте` | UI interactions, user input handling |
| `&НаСервере` | Server with form context (modify form attributes/items) |
| `&НаСервереБезКонтекста` | **Preferred** for data operations without form context |
| `&НаКлиентеНаСервереБезКонтекста` | Shared utility functions |

- Prefer `&НаСервереБезКонтекста` over `&НаСервере`.

## Async Programming

- Prefer `Асинх` (async) methods over `ОписаниеОповещения`.
- Use `Ждать` (Await) for cleaner async code.
- Mixing `Асинх`/`Ждать` with non-async methods is prohibited.

## Form Data

- Use `ДанныеФормыВЗначение()` / `ЗначениеВДанныеФормы()` for conversions.
- Form attributes are not the same as object attributes.
