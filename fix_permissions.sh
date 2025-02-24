#!/bin/bash

# Проблема с правами для пользователя, для группы и для всех остальных, 
# часто встречается на системе Linux.
# Здесь приведен скрипт, который меняет эти права доступа, чтобы контенеры
# корректно загружали настройки из файлов.

# Скрипт для изменения прав доступа к файлам и директориям.


# Переходим внутрь директории docker_compose (если нужно), т.е. там где лежит файл compose.yaml,
# или кладем скрипт рядом с файлом compose.yaml и запускаем его, закомментировав строчку ниже:
cd docker_compose || exit


# Функция для вывода предупреждения и получени согласия пользователя на её выполнение:
confirm() {
	read -p "Этот скрипт изменит права доступа к файлам и директориям в текущей директории. Вы согласны продолжить? (y/n) " answer
	
	case $answer in
		y|Y ) echo "Продолжаем..."; return 0;;
		n|N ) echo "Отмена. Скрипт завершен."; exit 1;;
		* ) echo "Пожалуйста, введите 'y' или 'n'."; return 1;;
	esac	
}

# Основная часть скрипта
attempts=0
while true; do
	if confirm; then
		break
	fi
	attempts=$((attempts + 1))
	if [[ $attempts -eq 3 ]]; then
		echo "Вы не ввели правильный ответ три раза подряд. Скрипт завершен."
		exit 1
	fi
done

echo "Запуск скрипта по изменнению прав доступа..."
# Текущая рабочая директория
WORKING_DIR="$(pwd)"
echo "Находимся в директории: $WORKING_DIR"

# Рекурсивно проходимся по всем файлам и директориям
find ./* -type d -exec chmod 0777 {} \;
#find "$WORKING_DIR" ./* -type d -exec chmod 0777 {} \;
find ./* -type f -exec chmod 766 {} \;
#find "$WORKING_DIR" ./* -type f -exec chmod 766 {} \;

# Снимаем лишний бит setgid для директорий
find ./* -type d -exec chmod g-s {} \;
#find "$WORKING_DIR" ./* -type d -exec chmod g-s {} \;

echo "Права доступа успешно изменены."

