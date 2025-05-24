#!/bin/sh
set -e

wait_for_port() {
  name="$1"
  host="$2"
  port="$3"
  echo "Waiting for $name at $host:$port..."
  while ! nc -z "$host" "$port"; do
    sleep 0.5
  done
  echo "$name is ready!"
}

# Wait for DB
wait_for_port "db" "${POSTGRES_HOST:-db}" "${POSTGRES_PORT:-5432}"

# Wait for Cache
wait_for_port "cache" "cache" "${CACHE_PORT:-6379}"

# Wait for Selenium
wait_for_port "selenium" "${SELENIUM_HOST:-selenium}" "${SELENIUM_PORT:-4444}"

exec "$@"
