# Week 03. GraalVM Task (Slurm Навыкум "Build Containers!")

## Задача

Есть проект на чистой Java 17

Проект использует [Native Image](https://www.graalvm.org/native-image/) и [Maven Native Plugin](https://graalvm.github.io/native-build-tools/latest/maven-plugin.html) для компиляции в бинарный исполняемый файл формата ELF

### Сборка

Для сборки нужно использовать [GraalVM CE Image](https://github.com/graalvm/container/pkgs/container/graalvm-ce/65493297?tag=22.3.1)

Сборка проходит стандартным образом, через `mvn verify` с указанием профиля `native`, на выходе &ndash; `target/native.bin`:
```sh
file target/native.bin
target/native.bin: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked
```

### API

Сервер запускается на порту, указанном через параметр `port` или переменную окружения `PORT` и реагирует на команду `UUID`, выдавая в ответ случайный `UUID`

Как проверить:
1. Подключаемся с помощью `nc` (`netcat`) по нужному порту
2. Вводим `UUID⏎`, (где `⏎` &ndash; Enter для отправки данных)
3. Получаем в ответ: `b022e6b9-957a-4f22-b519-2fb57ca76caf` (пример)

<details>
<summary>Спойлеры: пример вызова `nc` для тестирования</summary>

```sh
nc -u localhost 9999
UUID
b022e6b9-957a-4f22-b519-2fb57ca76caf
```
</details>

### Что нужно сделать

1. Собрать всё с помощью Maven и Native Image (параллелить ничего не нужно, т.к. в приложении нет авто-тестов, проверок стиля кода и т.д.)
2. Упаковать всё в [`Scratch`](https://hub.docker.com/_/scratch)
3. Выложить всё в виде публичного образа на GHCR (GitHub Container Registry)

При необходимости, можете внести изменения в `pom.xml` (будем считать, в организации DevOps-инженерам разрешено "корректировать" по своему усмотрению сборку для адаптации к "миру контейнеров")

Рекомендуется, но не обязательно, запускать приложение не от root

### Требования

1. Всё должно быть оформлено в виде публичного репозитория на GitHub
2. Вся сборка образов должна проходить через GitHub Actions
3. Образ должен выкладываться в GitHub Container Registry (GHCR)

К текущему заданию дополнительно предъявляются требования:
1. [Docker Buildx Build](https://docs.docker.com/build/) (указывайте явно при сборке `docker buildx build`)
2. Multi-Stage