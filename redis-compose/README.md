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

Использование ACL улучшает безопасность, так как позволяет минимизировать риски, связанные с неправильным или нежелательным доступом к данным Redis.





