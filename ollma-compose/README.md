# sentiment-analysis

## Интегрируем Kotlin сервис с AI чат-ботом с помощью Spring AI за 5 минут

Приложение из этой [статьи](https://teletype.in/@javalib/Vqsx8cuunR_).
[GitHub source](https://github.com/ullaes/sentiment-analysis/tree/main)
[GitHub source Ollama](https://github.com/ollama/ollama)
[DockerHub Ollama](https://hub.docker.com/r/ollama/ollama)
[Библиотеки моделей Ollama](https://ollama.com/library)

[Ollama](https://github.com/ollama/ollama) позволяет легко настраивать и запускать большие языковые модели локально.

На DockerHub на страничке Ollama можно прочитать, как запускать её с использованием только CPU, а также с использованием памяти видеокарты.

Для примера, я использовал CPU only:

```bash
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```

Ты можешь запустить его командой:
docker-compose up -d

Это удобно, так как тебе не нужно каждый раз вручную вводить команду docker run. Если нужно остановить контейнер, просто используй:
docker-compose down


После запуска контейнера с Ollama нужно запустить и саму модель. Это выполняется с помощью команды в контейнере Ollama:
Run model locally - Now you can run a model:

```bash
docker exec -it ollama ollama run llama3.1
```

## More models can be found on the Ollama [library](https://ollama.com/library).

Ollama поддерживает список моделей, доступных на [ollama.com/library](https://ollama.com/library)

Вот несколько примеров моделей, которые можно загрузить:

| Model              | Parameters | Size  |            Download            |
|:-------------------|:----------:|:-----:|:------------------------------:|
| DeepSeek-R1        |     7B     | 4.7GB |     ollama run deepseek-r1     |
| DeepSeek-R1        |    671B    | 404GB |  ollama run deepseek-r1:671b   |
| Llama 3.3          |    70B     | 43GB  |      ollama run llama3.3       |
| Llama 3.2          |     3B     | 2.0GB |      ollama run llama3.2       |
| Llama 3.2          |     1B     | 1.3GB |     ollama run llama3.2:1b     |
| Llama 3.2 Vision   |    11B     | 7.9GB |   ollama run llama3.2-vision   |
| Llama 3.2 Vision   |    90B     | 55GB  | ollama run llama3.2-vision:90b |
| Llama 3.1          |     8B     | 4.7GB |      ollama run llama3.1       |
| Llama 3.1          |    405B    | 231GB |    ollama run llama3.1:405b    |
| Phi 4              |    14B     | 9.1GB |        ollama run phi4         |
| Phi 3 Mini         |    3.8B    | 2.3GB |        ollama run phi3         |
| Gemma 2            |     2B     | 1.6GB |      ollama run gemma2:2b      |
| Gemma 2            |     9B     | 5.5GB |       ollama run gemma2        |
| Gemma 2            |    27B     | 16GB  |     ollama run gemma2:27b      |
| Mistral            |     7B     | 4.1GB |       ollama run mistral       |
| Moondream 2        |    1.4B    | 829MB |      ollama run moondream      |
| Neural Chat        |     7B     | 4.1GB |     ollama run neural-chat     | 
| Starling           |     7B     | 4.1GB |     ollama run starling-lm     | 
| Code Llama         |     7B     | 3.8GB |      ollama run codellama      | 
| Llama 2 Uncensored |     7B     | 3.8GB |  ollama run llama2-uncensored  |
| LLaVA              |     7B     | 4.5GB |        ollama run llava        |
| Solar              |   10.7B    | 6.1GB |        ollama run solar        |

### Note

`You should have at least 8 GB of RAM available to run the 7B models, 16 GB to run the 13B models, and 32 GB to run the 33B models.`
`Для работы с моделями 7B у вас должно быть доступно не менее 8 ГБ оперативной памяти, для работы с моделями 13B - 16 ГБ, а для работы с моделями 33B - 32 ГБ.`

------------------------------------------------------

