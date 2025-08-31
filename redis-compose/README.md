### [Keycloak](https://github.com/keycloak/keycloak) with [PostgreSQL](https://www.postgresql.org), which includes Keycloak's monitoring using [Prometheus](https://github.com/prometheus/prometheus) and [Grafana](https://github.com/grafana/grafana)


## Что такое Redis и зачем он нужен
`Redis (Remote Dictionary Server)` — это высокопроизводительная система управления базами данных типа "ключ-значение", 
работающая в оперативной памяти. Redis часто используется для кэширования данных, управления сессиями, очередей сообщений 
и в качестве базы данных NoSQL для быстрого доступа к данным.<br>
Основные преимущества Redis:
- `Скорость`: работа в памяти обеспечивает быструю обработку запросов.
- `Простота`: простая модель данных "ключ-значение" с поддержкой сложных структур данных.
- `Гибкость`: поддержка различных структур данных, таких как строки, списки, множества, хеши и т.д.
- `Масштабируемость`: легкость масштабирования и поддержки репликации.
<br>

1. Requires [docker](https://docs.docker.com/get-docker/) and [compose](https://docs.docker.com/compose/install/)
2. Parameterized using variables in the [`.env`](.env) file
3. Up the project using command:
```
docker compose up -d
```

| App | Port | Username | Password
|-|-|-|-
| Keycloak | http://localhost:8080 | `admin` | `keycloak`
| Prometheus | http://localhost:9090 | |
| Grafana | http://localhost:3000 | `admin` | `grafana`

| Useful commands | Description
|-|-
| `docker stats` | Containers resource usage (`--no-stream` only pull the first result)
| `docker compose logs` | Shows logs of containers (`-f` to follow logs)
| `docker compose down` | Stop and remove containers (`-v` remove named volumes declared in the volumes section of the Compose file and anonymous volumes attached to containers)
| `docker system prune -a -f` | Remove all unused containers, networks, images (`--volumes` prune volumes)


# Initializing Postgres database at startup

## Docker
```shell
docker run --name habr-pg-16 -p 6432:5432 -e POSTGRES_USER=habrpguser -e POSTGRES_PASSWORD=pgpwd4habr -e POSTGRES_DB=habrdb -d -v "/absolute/path/to/directory-with-init-scripts":/docker-entrypoint-initdb.d postgres:16.1-alpine3.18
```

### Auto-detect current directory (for macOS and Linux)
```shell
docker run --name habr-pg-16 -p 6432:5432 -e POSTGRES_USER=habrpguser -e POSTGRES_PASSWORD=pgpwd4habr -e POSTGRES_DB=habrdb -d -v "$(pwd)":/docker-entrypoint-initdb.d postgres:16.1-alpine3.18
```

### Run psql
```shell
psql -U habrpguser -d habrdb
```

## Docker Compose
### Start
```shell
docker-compose --project-name="habr-pg-16" up -d
```

### Stop
```shell
docker-compose --project-name="habr-pg-16" down
```

## Explore volumes
### List all volumes
```shell
docker volume ls
```

## Access to PgAdmin

Open in browser [http://localhost:5050](http://localhost:5050)

## Add a new server in PgAdmin

* Host name/address `postgres` (as Docker-service name)
* Port `5432` (inside Docker)
* Maintenance database `habrdb` (as `POSTGRES_DB`)
* Username `habrpguser` (as `POSTGRES_USER`)
* Password `pgpwd4habr` (as `POSTGRES_PASSWORD`)

## Explore volumes

### List all volumes

```shell
docker volume ls
```

### Delete specified volume

```shell
docker volume rm habr-pg-16_habrdb-data
docker volume rm habr-pg-16_pgadmin-data
```

## Что значит +@pubsub?
Это ACL-категория, которая дает права на все Pub/Sub-команды, такие как:
- PUBLISH
- SUBSCRIBE
- UNSUBSCRIBE
- PSUBSCRIBE
- PUNSUBSCRIBE

### Что происходит когда есть ошибка "NOPERM No permissions to access a channel"?
В вашем docker-compose.yaml Redis конфигурируется с ACL (через файл users.acl), где вы задаете разрешения для пользователей.
Ошибка NOPERM No permissions to access a channel означает, что пользователю, которого вы указали в переменных окружения (REDIS_USER), 
не хватает прав для работы с Redis Pub/Sub (например, подписки на каналы или публикации сообщений).
### Решение
Вам нужно обновить ACL-файл, чтобы добавить права на работу с каналами. Например, права на команды Pub/Sub (+@pubsub) нужно добавить вашему пользователю в users.acl.

## Что делает команда "user default on nopass ~* +@all +@read +@write +cluster|nodes" 
Эта команда в `users.acl` задает настройки для пользователя Redis с именем `default`. Давайте разберем её по частям:

### Команда
```plaintext
user default on nopass ~* +@all +@read +@write +cluster|nodes
```

### Разбор

1. **`user default`**  
   Это указывает, что вы настраиваете права для встроенного пользователя `default`, который существует в Redis по умолчанию. Этот пользователь всегда есть и используется, если другой пользователь не указан.

2. **`on`**  
   Это включает учетную запись пользователя `default`. Если указать `off`, этот пользователь будет отключен, и Redis не позволит использовать его для подключения.

3. **`nopass`**  
   Это означает, что пользователь может подключаться без пароля. В сочетании с `on` это делает пользователя открытым для доступа (что небезопасно в производственной среде). Обычно его следует заменять на `>` с указанием пароля (например, `>somepassword`).

4. **`~*`**  
   Это шаблон доступа к ключам.
    - `~*` означает, что пользователь имеет доступ ко всем ключам в Redis.
    - Вы можете ограничить доступ к определенным ключам, например, `~myprefix*` даст доступ только к ключам, начинающимся с `myprefix`.

5. **`+@all`**  
   Это категория разрешений, которая включает все команды Redis. То есть этот пользователь может выполнять любые команды, доступные в Redis.

6. **`+@read`**  
   Это категория разрешений, которая позволяет выполнять команды чтения, такие как `GET`, `MGET`, `LRANGE`, и так далее.

7. **`+@write`**  
   Это категория разрешений, которая позволяет выполнять команды записи, такие как `SET`, `DEL`, `LPUSH`, `HSET`, и так далее.

8. **`+cluster|nodes`**  
   Это дополнительное разрешение на выполнение команды `CLUSTER NODES`, которая используется для управления кластером Redis.

---

### Полезные детали

- **ACL категории**  
  Категории в ACL начинаются с `+@` и объединяют группы команд Redis. Например:
    - `@all` — все команды.
    - `@read` — команды для чтения данных.
    - `@write` — команды для записи данных.
    - `@pubsub` — команды Pub/Sub (например, `PUBLISH`, `SUBSCRIBE`).
    - `@admin` — команды администрирования (например, `CONFIG`, `SHUTDOWN`).

  Полный список доступных категорий можно найти в документации Redis.

- **Шаблоны доступа к ключам (`~`)**  
  Шаблоны позволяют ограничить доступ пользователя к определенным наборам ключей:
    - `~myprefix*` — доступ только к ключам, начинающимся с `myprefix`.
    - `~foo* bar*` — доступ к ключам, начинающимся с `foo` или `bar`.

- **Пароли (`>` и `nopass`)**
    - Если используется `nopass`, пользователь может подключаться без пароля.
    - Если используется `>mypassword`, пользователь должен указать пароль `mypassword` при подключении.

---

### Зачем это нужно?
Эта команда позволяет гибко настраивать права доступа для пользователей Redis. Например:
- Для разработчиков можно создать пользователя с полными правами (`+@all`).
- Для приложений — пользователя с ограниченными правами, только на чтение и запись (`+@read +@write`).
- Для аналитики — пользователя, который может только читать данные (`+@read`).

Использование ACL улучшает безопасность, так как позволяет минимизировать риски, связанные 
с неправильным или нежелательным доступом к данным Redis.


---

Конечно, остаемся в контексте! Это прекрасный и очень практичный вопрос. **Да, для Redis существует отличный набор инструментов для просмотра и управления данными,** очень похожий на PgAdmin для PostgreSQL.

Инструменты для работы с Redis делятся на две большие категории: **GUI-клиенты** (графические, как DBeaver) и **CLI** (командная строка).

---

### 1. Графические интерфейсы (GUI)

Это самые удобные инструменты для разработки и отладки.

#### a. RedisInsight (Официальный инструмент от Redis)

**Это — ваш "PgAdmin для Redis"**. Бесплатный, мощный и от создателей Redis.

*   **Что умеет:**
    *   Просматривать все базы данных и ключи в древовидной структуре.
    *   Видеть значение любого ключа (строки, хеши, списки, sets) в удобном формате.
    *   Выполнять любые команды Redis в консоли.
    *   Анализировать использование памяти и мониторить производительность.
    *   Управлять кластерами и облачными инстансами Redis.

*   **Ссылка:** [https://redis.com/redis-enterprise/redis-insight/](https://redis.com/redis-enterprise/redis-insight/)

*   **Как выглядит:**
    ![RedisInsight Interface](https://redis.com/wp-content/uploads/2021/02/RedisInsight-2.0-Overview.png)

#### b. Another Redis Desktop Manager

Очень популярный и быстрый open-source менеджер.

*   **Плюсы:** Очень легкий, интуитивно понятный, отлично работает с большими объемами данных.
*   **Ссылка:** [https://github.com/qishibo/AnotherRedisDesktopManager](https://github.com/qishibo/AnotherRedisDesktopManager)

#### c. Medis (только для macOS)

Элегантный и мощный клиент для пользователей Mac.

---

### 2. Командная строка (CLI)

Это "родной" способ общения с Redis. Если вы работаете с Docker или на сервере, он всегда под рукой.

#### Команды для просмотра данных:

Допустим, мы сохраняли ключи через наш код по шаблону `processed_event:some-uuid-here`.

1.  **Подключиться к Redis:** Чаще всего это делается через Docker.
    ```bash
    # Если Redis запущен в Docker контейнере с именем 'my-redis'
    docker exec -it my-redis redis-cli
    ```
    Или если Redis установлен локально/на сервере:
    ```bash
    redis-cli -h <hostname> -p <port> -a <password>
    ```

2.  **Найти все ключи, подходящие под шаблон:**
    ```bash
    # Команда SCAN или KEYS (осторожно с KEYS на продакшене!)
    127.0.0.1:6379> SCAN 0 MATCH "processed_event:*"
    ```
    **Внимание:** Команда `KEYS "processed_event:*"` на большой базе может заблокировать сервер на время выполнения. Всегда предпочтительнее использовать `SCAN`.

3.  **Посмотреть значение конкретного ключа и его TTL:**
    ```bash
    # Получить значение ключа (для типа String)
    127.0.0.1:6379> GET "processed_event:123e4567-e89b-12d3-a456-426614174000"
    > "processed" # Именно то значение, что мы записывали в коде на Kotlin

    # Узнать, сколько секунд осталось жить ключу (TTL)
    127.0.0.1:6379> TTL "processed_event:123e4567-e89b-12d3-a456-426614174000"
    > (integer) 3540 # Осталось 3540 секунд (~59 минут)

    # Если TTL возвращает -1 — у ключа нет времени жизни (живет вечно).
    # Если возвращает -2 — ключ уже удален (не существует).
    ```

4.  **Посмотреть все ключи (с осторожностью!):**
    ```bash
    # Только для разработки и маленьких баз данных!
    127.0.0.1:6379> KEYS *
    1) "processed_event:123e4567-e89b-12d3-a456-426614174000"
    2) "processed_event:another-uuid-here"
    3) "some_other_key"
    ```

---

### Практический пример: Что мы увидим для нашего кода?

Вспомним наш код:
```kotlin
val wasSet = redisTemplate.opsForValue().setIfAbsent(redisKey, "processed")
```

После его работы для `eventId = "abc123"` в Redis мы сможем найти:

```bash
# В RedisInsight или Another Redis Desktop Manager:
# Мы увидим ключ с именем `processed_event:abc123` и значением `"processed"`.

# Через CLI:
127.0.0.1:6379> GET "processed_event:abc123"
"processed"

127.0.0.1:6379> TTL "processed_event:abc123"
(integer) 3562  # Ключ самоуничтожится через ~59 минут.
```

### Итог для собеседования

Если на собеседовании спросят про мониторинг Redis, можно блеснуть знаниями:

**"Для визуальной работы с Redis, особенно при разработке и отладке, я использую GUI-клиенты, например, официальный RedisInsight или Another Redis Desktop Manager. Они позволяют просматривать ключи, их TTL и значения в удобном интерфейсе, аналогично DBeaver для PostgreSQL. Для администрирования и быстрых проверок на сервере я использую консольную утилиту `redis-cli` с командами `SCAN`, `GET` и `TTL`, всегда помня о том, что команду `KEYS *` не стоит использовать на production-инстансах из-за ее блокирующей природы."**

Это покажет, что вы не только умеете писать код, но и знаете, как работать с инструментом в реальной жизни.






