#!/bin/sh

# Load quotes from CSV into Redis if empty
if [ "$(redis-cli DBSIZE)" -eq 0 ]; then
  while IFS=, read -r id quote; do
    redis-cli SET "quote:$id" "$quote"
  done < /docker-entrypoint-initdb.d/quotes.csv
fi