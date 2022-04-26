# Пишем скрипт bash
Описание/Пошаговая инструкция выполнения домашнего задания:
Написать скрипт для крона, который раз в час присылает на заданную почту:

- X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- все ошибки c момента последнего запуска;
- список всех кодов возврата с указанием их кол-ва с момента последнего запуска. В письме должно быть прописан обрабатываемый временной диапазон и должна быть реализована защита от мультизапуска.

## 1. Подготовка скриптов
### 1.1 X IP адресов (с наибольшим кол-вом запросов)
В логе access-4560-644067.log найдем топ уникальных ip адресов, отсортируем по уникальности их попаданий в логе:
```
#!/bin/bash
cat access-4560-644067.log | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | uniq -c | sort -nr | head -12
```
12 можно сделать параметром для head
Вывод:
```
     39 109.236.252.130
     36 212.57.117.19
     33 188.43.241.106
     17 217.118.66.161
     17 185.6.8.9
     16 95.165.18.146
     16 148.251.223.21
     12 62.210.252.196
     12 185.142.236.35
     12 162.243.13.195
      8 163.179.32.118
      6 148.251.223.21
```
### 1.2 Y запрашиваемых адресов (с наибольшим кол-вом запросов)
Адреса имеют формат: http(s)://... могут иметь буквы, цифры и знак точка. Аналогично грепом можно найти уникальные, отсортировать их и вывести топ 12:
```
#!/bin/bash
cat access-4560-644067.log | grep -Eo "(http|https)://[a-zA-Z0-9.]*" | sort | uniq -c | sort -nr | head -12
```
Вывод:
```
    166 https://dbadmins.ru
    124 http://yandex.com
     21 http://www.semrush.com
     20 http://www.domaincrawler.com
     16 http://dbadmins.ru
     11 http://www.bing.com
      9 http://www.google.com
      3 http://duckduckgo.com
      3 http://ahrefs.com
      2 http://www.feedly.com
      2 https://www.google.ru
      2 https://go.backupland.com
```
### 1.3 все ошибки c момента последнего запуска
Коды которые не относятся к 200-ым считаются ошибкой начинаются с цифр 3,4,5. Чтобы сократить количество текста, удалим ip адреса, время вызова, и сгруппируем по количеству этих ошибок:
```
cat access-4560-644067.log | grep ".*HTTP/1\.1\" [3,4,5].." | cut -d\  -f9- | sort | uniq -c | sort -nr
```
### 1.4 список всех кодов возврата с указанием их кол-ва с момента последнего запуска.
Аналогично предыдущему скрипту учтем 200ые коды возврата, сгруппируем посчитав общее количество. Также нужно высчитать временной диапозон, для этого обрежем в логе дату/время из первой строки и из последней, запишем результаты во временные файлы, выведем их содержимое, затем удалим:
```
#!/bin/bash
cat access-4560-644067.log | sed -n 1p | grep -Eo "[0-9]{2}\/[A-Z][a-z]{2}\/[0-9]{4}.*" | cut -f1 -d+ > sh_datefrom
cat access-4560-644067.log | tail -n1 | grep -Eo "[0-9]{2}\/[A-Z][a-z]{2}\/[0-9]{4}.*" | cut -f1 -d+ > sh_dateto
cat access-4560-644067.log | grep "HTTP/1\.1\" [2,3,4,5].." | awk '{print $9}' | sort|  uniq -c > sh_errorcount
sh_datefrom="$(cat sh_datefrom)"
sh_dateto="$(cat sh_dateto)"
echo "date_log_from ${sh_datefrom}"
echo "date_log_to ${sh_dateto}"
cat sh_errorcount
rm -rf sh_datefrom
rm -rf sh_dateto
rm -rf sh_errorcount
```

## 2. Объединение скриптов
Выводим дату с по, результаты работы всех скриптов. По сути модернизируем скрипт 1.4 добавив остальные:
```
#!/bin/bash
mkdir tmp_files
cat access-4560-644067.log | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | uniq -c | sort -nr | head -12 > tmp_files/sh_x
cat access-4560-644067.log | grep -Eo "(http|https)://[a-zA-Z0-9.]*" | sort | uniq -c | sort -nr | head -12 > tmp_files/sh_y
cat access-4560-644067.log | grep ".*HTTP/1\.1\" [3,4,5].." | cut -d\  -f9- | sort | uniq -c | sort -nr > tmp_files/sh_error
cat access-4560-644067.log | sed -n 1p | grep -Eo "[0-9]{2}\/[A-Z][a-z]{2}\/[0-9]{4}.*" | cut -f1 -d+ > tmp_files/sh_datefrom
cat access-4560-644067.log | tail -n1 | grep -Eo "[0-9]{2}\/[A-Z][a-z]{2}\/[0-9]{4}.*" | cut -f1 -d+ > tmp_files/sh_dateto
cat access-4560-644067.log | grep "HTTP/1\.1\" [2,3,4,5].." | awk '{print $9}' | sort|  uniq -c > tmp_files/sh_codes
sh_datefrom="$(cat tmp_files/sh_datefrom)"
sh_dateto="$(cat tmp_files/sh_dateto)"
sh_x="$(cat tmp_files/sh_x)"
sh_y="$(cat tmp_files/sh_y)"
sh_error="$(cat tmp_files/sh_error)"
sh_codes="$(cat tmp_files/sh_codes)"
echo "Обрабатываемый диапозон с ${sh_datefrom} по ${sh_dateto}"
echo " "
echo "12 IP адресов с наибольшим количеством запросов:"
echo "${sh_x}"
echo " "
echo "12 запрашиваемых адресов с наибольшим количеством запросов:"
echo "${sh_y}"
echo " "
echo "Все ошибки с момента запуска:"
echo "${sh_error}"
echo " "
echo "Список всех кодов возврата с указанием их кол-ва с момента последнего запуска:"
echo "${sh_codes}"
rm -r tmp_files
```
## 3. Настройка почтового отправления:
Отправка почты от Postfix через почтовый сервер Яндекса
Нам необходимо иметь почтовые учетные записи в Яндексе. При отправке писем мы будем использовать правила аутентификации на серверах последнего с использованием данных учетных записей.
Также нам нужен пакет cyrus-sasl-plain. 
```
yum install cyrus-sasl-plain
```
Правим конфигурационный файл postfix:
```
relayhost =
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/private/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_type = cyrus
smtp_sasl_mechanism_filter = login
smtp_sender_dependent_authentication = yes
sender_dependent_relayhost_maps = hash:/etc/postfix/private/sender_relay
smtp_tls_CAfile = /etc/postfix/ca.pem
smtp_use_tls = yes
```
Создаем каталог для конфигов и файл с правилами пересылки сообщений:
```
mkdir /etc/postfix/private
vim /etc/postfix/private/sender_relay

@yandex.ru    smtp.yandex.ru
```
Создаем файл с настройкой привязки логинов и паролей:
```
vim /etc/postfix/private/sasl_passwd

alavansh@yandex.ru      alavansh@yandex.ru:мой_пароль
```
Создаем карты для данных файлов:
```
postmap /etc/postfix/private/{sasl_passwd,sender_relay}
```
Получаем сертификат от Яндекса, для этого выполняем запрос:
```
openssl s_client -starttls smtp -crlf -connect smtp.yandex.ru:25
```
Копируем полученную информацию и создаем файл ключа:
```
vim /etc/postfix/ca.pem

-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
```
Перезапускаем Postfix:
```
systemctl restart postfix
```
Для проверки можно использовать консольную команду mail.
```
yum install mailx
```
После отправляем письмо:
```
echo "Test text" | mail -s "Test title" -r alavansh@yandex.ru alavansh@yandex.ru
```
Письмо пришло
Отправляем письмо скриптом:
```
sh echo_for_mail.sh | mail -s "Info from log" -r alavansh@yandex.ru alavansh@yandex.ru
```
Успех

## 4. Настройка cron
Заранее продумаем защиту от мультизапуска.
Ставим утилиту lockrun:
```
wget unixwiz.net/tools/lockrun.c
gcc lockrun.c -o lockrun
sudo cp lockrun /usr/local/bin/
```
Настраиваем планировщик на выполнение скрипта и отправку на почту через crontab -e:
```
0 * * * * /usr/local/bin/lockrun --lockfile=/tmp/parse.lockrun --sh echo_for_mail.sh | mail -s "Info from log" -r alavansh@yandex.ru yarkozloff@gmail.com
```
