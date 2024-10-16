#!/bin/bash
# Тест 1: Проверка создания временного файла размером 0,5 GB и его монтирования.
test_create_and_mount() {
echo "Тест 1: Проверка создания и монтирования временного файла размером 0,5 GB"
# Параметры
tmpdir="/tmp/test_mount_dir"
limit=$(( 512 * 1024 * 1024 )) # 0,5 GB (в байтах)
# Запуск скрипта создания временной файловой системы
./script2.sh $tmpdir $limit
# Проверка, что папка была создана
if [ ! -d "$tmpdir" ]; then
echo "Ошибка: Папка не была создана."
return 1
fi
# Проверка, что файл монтирован
if ! mount | grep -q "$tmpdir"; then
echo "Ошибка: Файл не был смонтирован."
return 1
fi
echo "Тест 1 прошел успешно!"
}
# Вызов функции теста
test_create_and_mount

# Тест 2: Проверка архивации файлов, если процент использования диска больше порога.
test_disk_usage_and_backup() {
echo "Тест 2: Проверка архивации файлов при превышении порога использования диска"
# Параметры
test_dir="/tmp/test_disk_usage"
limit=$(( 512 * 1024 * 1024 )) # 0,5 GB (в байтах)
usage_threshold=90 # Порог 90%
num_files=5 # Количество файлов для архивации
# Создаем тестовую папку
mkdir -p "$test_dir"
# Заполняем папку случайными файлами размером 100 MB (чтобы достичь 0,5 GB)
for i in $(seq 1 $num_files); do
dd if=/dev/urandom of="$test_dir/file$i" bs=20M count=5 &> /dev/null
done
# Запуск скрипта для проверки использования диска
./script.sh $test_dir $usage_threshold 2
# Проверка, что архив был создан
if [ ! -f "$test_dir/backup.tar.gz" ]; then
echo "Ошибка: Архив не был создан."
return 1
fi
# Проверка, что файлы были удалены после архивации
for i in $(seq 1 $num_files); do
if [ -f "$test_dir/file$i" ]; then
echo "Ошибка: Файл $test_dir/file$i не был удален."
return 1
fi
done
echo "Тест 2 прошел успешно!"
}
# Вызов функции теста
test_disk_usage_and_backup

# Тест 3: Проверка, что архив не создается, если процент использования диска не
превышает порог.
test_no_backup_when_usage_low() {
echo "Тест 3: Проверка, что архив не создается при низком использовании диска"
# Параметры
test_dir="/tmp/test_no_backup"
limit=$(( 512 * 1024 * 1024 )) # 0,5 GB (в байтах)
usage_threshold=10 # Порог 10%
num_files=1 # 1 файл, чтобы использование было низким
# Создаем тестовую папку
mkdir -p "$test_dir"
# Заполняем папку одним файлом размером 100 MB
dd if=/dev/urandom of="$test_dir/file1" bs=100M count=1 &> /dev/null
# Запуск скрипта для проверки использования диска
./script.sh $test_dir $usage_threshold 2
# Проверка, что архив не был создан
if [ -f "$test_dir/backup.tar.gz" ]; then
echo "Ошибка: Архив был создан, хотя использование диска не превышает порог."
return 1
fi
echo "Тест 3 прошел успешно!"
}
# Вызов функции теста
test_no_backup_when_usage_low

# Тест 4: Проверка корректности архивации при разных порогах.
test_backup_with_different_thresholds() {
echo "Тест 4: Проверка архивации при разных порогах использования"
# Параметры
test_dir="/tmp/test_different_thresholds"
limit=$(( 512 * 1024 * 1024 )) # 0,5 GB
num_files=5 # Количество файлов для архивации
# Создаем тестовую папку
mkdir -p "$test_dir"
# Заполняем папку случайными файлами размером 100 MB
for i in $(seq 1 $num_files); do
dd if=/dev/urandom of="$test_dir/file$i" bs=20M count=5 &> /dev/null
done
# Тест с порогом 80%
usage_threshold=80
./script.sh $test_dir $usage_threshold 2
# Проверка, что архив был создан при использовании выше порога
if [ ! -f "$test_dir/backup.tar.gz" ]; then
echo "Ошибка: Архив не был создан при использовании больше 80%."
return 1
fi
# Тест с порогом 50%
usage_threshold=50
./script.sh $test_dir $usage_threshold 2
# Проверка, что архив не был создан при использовании меньше 50%
if [ -f "$test_dir/backup.tar.gz" ]; then
echo "Ошибка: Архив был создан при использовании меньше 50%."
return 1
fi
echo "Тест 4 прошел успешно!"
}
# Вызов функции теста
test_backup_with_different_thresholds