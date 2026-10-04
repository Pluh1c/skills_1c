## Быстрые примеры

```powershell
# Добавить права нового регистра, ничего не потеряв
... -RolePath "src/Roles/Менеджер" -Operation add-rights -Value "InformationRegister.Цены: Read, Update"

# Пресет и несколько объектов в одном вызове
... -RolePath "src/Roles/Менеджер" -Operation add-rights -Value "Catalog.Товары: @view ;; Document.Заказ: @edit"

# Снять права; объект без разрешающих прав удаляется целиком
... -RolePath "src/Roles/Менеджер" -Operation remove-rights -Value "Document.Заказ: Delete"

# Закрыть реквизит от роли
... -RolePath "src/Roles/Менеджер" -Operation deny-rights -Value "Catalog.Товары.Attribute.Цена: View"
```

Несколько разных операций — списком в файле:

```json
[
  { "operation": "add-rights", "value": "Catalog.Товары: @view" },
  { "operation": "set-rls", "value": "Catalog.Товары.Read: #ПоОрганизации(\"\")" }
]
```

```powershell
... -RolePath "src/Roles/Менеджер" -DefinitionFile "операции.json"
```

