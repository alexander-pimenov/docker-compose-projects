## [Как запускать RabbitMQ в Docker](https://habr.com/ru/companies/slurm/articles/704208/)

1. Requires [docker](https://docs.docker.com/get-docker/) and [compose](https://docs.docker.com/compose/install/)
2. Parameterized using variables in the [`.env`](.env) file
3. Up the project using command:

```
docker compose up -d
```

### Запуск в Docker

Самый простой и быстрый способ запустить RabbitMQ:

```
docker run --rm -p 15672:15672 rabbitmq:3.10.7-management
```

После этого можно открыть веб-интерфейс RabbitMQ в браузере по ссылке http://127.0.0.1:15672/<br>
Рекомендуется, даже для локальной разработки, использовать `docker-compose` для работы с окружениями.

### После запуска `docker-compose`

Попробуем открыть веб-интерфейс в браузере. Теперь можем авторизоваться в веб-интерфейсе.
`Логин и пароль по умолчанию — guest/guest`
<p>
 Мы добавили поле hostname в файле compose.yaml, которое зафиксирует имя сервера и переменные окружения с указанием логина и пароля для
 авторизации (RABBITMQ_DEFAULT_USER и RABBITMQ_DEFAULT_PASS). После применения этих изменений авторизация под
 guest/guest будет невозможна.

## Консольные команды

Войдём в контейнер через RabbitMQ (чтобы выполнять команды Rabbit надо находиться на сервере с Rabbit):

```
docker exec -it rabbitmq bash
docker-compose exec -it rabbitmq bash
```

`rabbitmqctl` — утилита, работающая без авторизации, но только локально рядом с RabbitMQ. Нужна для обслуживания
сервера/кластера, в том числе для решения проблем.

### Основные кейсы использования:

- настройка кластера;
- сброс авторизации. Например, если вы потеряли доступ к RabbitMQ, или он перешёл вам исторически и реквизиты доступа не
  передавали;
- принудительная очистка очередей. Если веб интерфейс/AMQP не отвечает из-за слишком большого количества сообщений в
  очередях.

### Можно посмотреть список очередей, exchanges:

```
rabbitmqctl list_queues
rabbitmqctl list_exchanges
```

Вы можете удалить, почистить очередь. Но возможности создать очередь или удалить `exchange` нет.

### Список всех возможных команд:

```
rabbitmqctl help
```

`rabbitmqadmin` — утилита, работающая через протокол AMQP (требует авторизации, но предоставляет более полный спектр
возможностей). Полезна для автоматизации, и если по какой-либо причине вам неудобно пользоваться веб-интерфейсом.

```
rabbitmqadmin help subcommands
```

### Примеры команд:
```
rabbitmqadmin -urmuser -prmpassword declare queue name=console_queue
rabbitmqadmin -urmuser -prmpassword declare exchange name=console_exchange type=direct
rabbitmqadmin -urmuser -prmpassword declare binding source=console_exchange destination=console_queue routing_key=test
rabbitmqadmin -urmuser -prmpassword publish routing_key=console_queue payload="test message from rabbitmqadmin"
rabbitmqadmin -urmuser -prmpassword publish exchange=console_exchange routing_key=test payload="test message from rabbitmqadmin"
rabbitmqadmin -urmuser -prmpassword get queue=console_queue count=10
rabbitmqadmin -urmuser -prmpassword list queues
rabbitmqadmin -urmuser -prmpassword list exchanges
rabbitmqadmin -urmuser -prmpassword list bindings
```

Для экспорта всех сущностей (кроме сообщений) можно использовать команду экспорт:

```
rabbitmqadmin -urmuser -prmpassword export backup.json
```

Аналогично с импортом:
```
rabbitmqadmin -urmuser -prmpassword import backup.json
```

# Веб-интерфейс

Основная страница — `Overview`.

Сверху справа — имя кластера@сервера, имя пользователя.

Сверху — версия RabbitMQ и Erlang, чуть ниже вкладки:

- `Overview` — общие данные для всего кластера (в данном случае кластер из одной ноды);
- `Connections` — сведения о соединениях;
- `Channels` — сведения о каналах;
- `Exchanges` — сведения о exchanges;
- `Queues` — сведения об очередях;
- `Admin` — функции администрирования.
- `Queues` - Страница со списком очередей. Пожалуй, самая активно используемая на практике. Рекомендую добавить столбец 
Consumers, показывающий количество подключенных к очереди консьюмеров. Добавляется через кнопку +/-. Также вы 
увидите список подключенных consumer и их `prefetch_count`. При нажатии на IP Consumer откроется страница его канала.

<p>
Если выбрать automatic ack, сообщения отобразятся и автоматически подтвердятся из очереди. Это полезно, если нужно удалить одно проблемное сообщение из головы очереди.


========================================


| Useful commands             | Description                                                                                                                                             
|-----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------
| `docker stats`              | Containers resource usage (`--no-stream` only pull the first result)                                                                                    
| `docker compose logs`       | Shows logs of containers (`-f` to follow logs)                                                                                                          
| `docker compose down`       | Stop and remove containers (`-v` remove named volumes declared in the volumes section of the Compose file and anonymous volumes attached to containers) 
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



