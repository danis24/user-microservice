#!/usr/bin/env bash

function test_postgresql {
    pg_isready -h "${POSTGRESQL_HOST}" -U "${POSTGRESQL_USER}"
}

function test_mysql {
    mysqladmin --no-beep -h "${DB_HOST}" ping
}

function test_memcache {
    echo "flush_all" | nc -w1 "${MEMCACHE_HOST}" "${MEMCACHE_PORT}"
}

function test_redis {
    redis-cli -h "${REDIS_HOST}" PING
}

function test_elastic_search {
    curl "${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/?pretty"
}

count=0
# Chain tests together by using &&
until ( test_mysql && test_redis && test_elastic_search )
do
    ((count++))
    if [ ${count} -gt 60 ]
    then
        echo "Services didn't become ready in time"
        exit 1
    fi
    sleep 1
done

echo "Services available"
