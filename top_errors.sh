#!/bin/bash
cat access-4560-644067.log | grep ".*HTTP/1\.1\" [3,4,5].." | cut -d\  -f9- | sort | uniq -c | sort -nr