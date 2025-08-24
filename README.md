### [Keycloak](https://github.com/keycloak/keycloak) with [PostgreSQL](https://www.postgresql.org), which includes Keycloak's monitoring using [Prometheus](https://github.com/prometheus/prometheus) and [Grafana](https://github.com/grafana/grafana)

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

### Узнать сколько ресурсов выделено для контейнеров можно с помощью команды:
```shell
docker stats
```

Так же можно фильтровать вывод по контейнерам:
```shell
docker stats $(docker ps --filter name=engine-app -q)
```
- `docker ps --filter name=engine-app -q` - выводит идентификаторы контейнеров, которые содержат в имени "engine-app".
- `docker stats $(...)` - отобразит ресурсы выбранных контейнеров.

### Посмотреть количество ядер процессора:
```shell
nproc
```

### Посмотреть количество ядер процессора:
```shell
df -h
```
У меня был такой вывод: 
Filesystem            Size  Used Avail Use% Mounted on
C:/Program Files/Git  476G  247G  229G  52% /

### Посмотреть объем оперативной памяти (ОЗУ):
```shell
free -h
```

### Посмотреть :
```shell
docker system df
```

### Посмотреть :
```shell
lscpu
```

### Проверка после запуска в логах Keycloak:
```bash
docker compose logs keycloak | grep "Listening on"
```
```bash
docker compose logs keycloak | grep "Keycloak available at"
```

### Как зайти в контейнер Keycloak из Git Bash (Windows)?
Ошибка "the input device is not a TTY" возникает, потому что Git Bash (на базе mintty) не полностью совместим с Docker в Windows.

🔧 Решение 1: Используйте winpty
Добавьте winpty перед командой:

```bash
winpty docker exec -it keycloak bash
```
Это обходной путь для эмуляции TTY в Git Bash.

### Если не нужен интерактивный режим, можно обойтись без -it:

```bash
docker exec keycloak /bin/bash -c "ваша_команда"
```

```bash
docker exec keycloak /bin/bash -c "ls /opt/keycloak/conf"
```


### Проверка таблиц в базе данных
#### Для PostgreSQL
Подключитесь к контейнеру с PostgreSQL и проверьте список таблиц:

```bash
docker exec -it postgres psql -U keycloak -d keycloak
```
Затем выполните в SQL-консоли:

```sql
\dt
```
