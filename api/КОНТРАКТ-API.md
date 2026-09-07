# Учебный REST API библиотеки

Базовый префикс: `/api`

Общие query-параметры отладки (любой запрос):

- `__delay=1500` — задержать ответ на указанное число миллисекунд
- `__fail=500` — вернуть указанный код ошибки

Постраничный ответ списка:

```json
{ "items": [], "page": 1, "size": 10, "total": 24 }
```

Ошибки:

- `401` / `403` — `{ "message": "..." }`
- `404` — `{ "message": "Запись не найдена." }`
- `409` — `{ "message": "Нельзя удалить издательство: на него ссылаются 7 книг(и)." }`
- `422` — `{ "message": "Ошибка валидации", "errors": { "isbn": "ISBN уже используется" } }`
- `5xx` — `{ "message": "Ошибка на сервере." }`

## Эндпоинты

| Метод | Путь | Назначение |
| --- | --- | --- |
| GET | `/__health` | Проверка, что сервер запущен |
| GET | `/books` | Список. Параметры: `search`, `genreId`, `publisherId`, `yearFrom`, `yearTo`, `sort`, `page`, `size`, `includeDeleted` |
| GET | `/books/:id` | Карточка. В ответе развёрнуты `publisher`, `authors`, `genres` |
| POST | `/books` | Создание. Тело: `title`, `isbn`, `year`, `pages`, `publisherId`, `authorIds`, `genreIds`, `copiesTotal`, `copiesAvailable` |
| PUT | `/books/:id` | Изменение |
| DELETE | `/books/:id` | Логическое удаление |
| DELETE | `/books/:id?hard=true` | Физическое удаление |
| POST | `/books/:id/restore` | Восстановление |
| POST | `/books/bulk-delete` | `{ "ids": [1, 2] }` → `{ "deleted": 2 }` |
| POST | `/books/:id/issue` | Выдача экземпляра. `409`, если `copiesAvailable == 0` |

Те же операции есть для `/authors`, `/genres`, `/publishers`, `/readers`.

Уникальность: `isbn` у книг, `email` у читателей — ответ `422` с ошибкой в поле.

Удаление издательства, на которое ссылаются книги — `409` с числом книг.
