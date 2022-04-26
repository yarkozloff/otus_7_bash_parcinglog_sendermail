#!/bin/bash
cat access-4560-644067.log | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | uniq -c | sort -nr | head -12
