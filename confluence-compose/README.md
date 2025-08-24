### Контейнер с Kafka

1. Requires [docker](https://docs.docker.com/get-docker/) and [compose](https://docs.docker.com/compose/install/)
2. Parameterized using variables in the [`.env`](.env) file (тут его нет)
3. Up the project using command:
```
docker compose up -d
```
Через 2-5 минут Confluence будет доступна на: http://localhost:8090

Для остановки -> down:
```
docker compose down -v
```

Просмотреть логи:
```
docker compose logs -f confluence
```

### Настройка Confluence после запуска
Выберите лицензию:
 - Можно использовать бесплатную trial-лицензию (60 дней).
 - Для долгого тестирования подойдёт Developer License (бесплатно для небольшой команды).

Создайте тестовую страницу с таблицей:
 - Используйте встроенный редактор (аналогичный продакшн-версии).
 - Проверьте API через http://localhost:8090/rest/api/content.

### Как тестировать Jenkins + Confluence API локально?
Измените URL в Jenkins-скрипте на:
```groovy
def apiUrl = "http://localhost:8090/rest/api/content"
```

Создайте API-токен:
 - Зайдите в Администрирование → Управление пользователями → Создать API-токен.

Проверьте запросы через curl:
```bash
curl -u admin:admin -X GET "http://localhost:8090/rest/api/content?title=Test"
```

### Ограничения локальной версии
⚠ Производительность: Контейнер с Confluence требует минимум 4 ГБ RAM.
⚠ Данные: Для сохранения данных между перезапусками используйте volumes (как в примере выше).
⚠ Версия: Локальная Confluence может немного отличаться от облачной (но API совместим).


### Как проверить структуру таблицы через API?
```
curl -X GET \
  -H "Authorization: Basic $(echo -n 'username:api_token' | base64)" \
  "https://your-wiki.atlassian.net/wiki/rest/api/content/123456?expand=body.storage"
```