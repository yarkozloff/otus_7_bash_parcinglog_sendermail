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
