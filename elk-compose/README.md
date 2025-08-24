### Как попробовать ELK-стек за один вечер и наконец-то перестать grep'ать логи

https://habr.com/ru/articles/671344/

Что такое ELK?
`ELK` - это (вдруг вы не знали):

✅ `Elasticsearch` (хранение и поиск данных)

✅ `Logstash` (конвеер для обработки, фильтрации и нормализации логов)

✅ `Kibana` (интерфейс для удобного поиска и администрирования)

Все эти три компонента располагаются на вашем сервере.
На клиент (сервер с приложением, допустим) устанавливается `Beat`.
Именно `Beat` шуршит в ваших логах на клиенте. Beat'ы бывают разные (найдете), но в рамках данной статьи нас интересует только `Filebeat`.

Как это все работает вместе?
Достаточно просто для восприятия, на самом деле:

✅ `Beat` следит за изменениями логов (`Filebeat` следит за файлами) и пушит логи в Logstsash

✅ `Logstash` фильтрует эти логи, производит с ними некоторые манипуляции и кладет их в нужный индекс `Elasticsearch` (таблицу в терминах привычных баз данных)

✅ `Kibana` визуализирует эти логи и позволяет вам удобно искать нужные события

---

#### Code in github:
https://github.com/blohinn/elk-article

---


При запуске в Windows
ошибка:

>Exiting: error loading config file: config file ("filebeat.yml") can only be writable by the owner but the permissions are "-rwxrwxrwx" (to fix the permissions use: 'chmod go-w /usr/share/filebeat/filebeat.yml')

лечится
https://discuss.elastic.co/t/volume-mapped-filebeat-yml-permissions-from-docker-on-windows-host/91893

добавлением строки
```yaml
command: filebeat -e -strict.perms=false
```

в `docker-compose.yml` для компонента `beats`

```yaml
beats:
  image: elastic/filebeat:7.16.2
  command: filebeat -e -strict.perms=false
  volumes:
    - ./configs/filebeat/config.yml:/usr/share/filebeat/filebeat.yml:ro
    - ./host_metrics_app/:/host_metrics_app/:ro
  networks:
    - elk
  depends_on:
    - elasticsearch
```

---

#### Убеждаемся, что мы можем попасть в kibana (в админку):

Переходим по адресу http://localhost:5601 и вводим логин/пароль из docker-compose.yml конфига 
(секция environment сервиса elasticsearch) - `elastic` / `MyPw123`

Сервисы стартуют долго. Kibana может смело стартовать 3-5 минут, так что не торопитесь лезть в конфиги и искать ошибки.

После того, как попали в админку - смело закрывайте ее. До нее мы еще доберемся.

---



