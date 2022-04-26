#!/bin/bash
cat access-4560-644067.log | grep -Eo "(http|https)://[a-zA-Z0-9.]*" | sort | uniq -c | sort -nr | head -12