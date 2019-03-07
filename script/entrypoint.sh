#!/usr/bin/env bash

TRY_LOOP="20"

: "${REDIS_HOST:="rm31027.randa.grid.sina.com.cn"}"
: "${REDIS_PORT:="31027"}"
: "${REDIS_PASSWORD:=""}"

# Defaults and back-compat
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"
: "${AIRFLOW__CORE__EXECUTOR:=${EXECUTOR:-Sequential}Executor}"

export \
  AIRFLOW__CELERY__BROKER_URL \
  AIRFLOW__CELERY__RESULT_BACKEND \
  AIRFLOW__CORE__EXECUTOR \
  AIRFLOW__CORE__FERNET_KEY \
  AIRFLOW__CORE__LOAD_EXAMPLES \
  AIRFLOW__CORE__SQL_ALCHEMY_CONN \

# Load DAGs exemples (default: Yes)
if [[ -z "$AIRFLOW__CORE__LOAD_EXAMPLES" && "${LOAD_EX:=n}" == n ]]
then
  AIRFLOW__CORE__LOAD_EXAMPLES=False
fi

# Install custom python package if requirements.txt is present
if [ -e "/requirements.txt" ]; then
    $(which pip) install --user -r /requirements.txt
fi

if [ -n "$REDIS_PASSWORD" ]; then
    REDIS_PREFIX=:${REDIS_PASSWORD}@
else
    REDIS_PREFIX=
fi

if [ "$AIRFLOW__CORE__EXECUTOR" != "SequentialExecutor" ]; then
  AIRFLOW__CORE__SQL_ALCHEMY_CONN="mysql://airflow:a2iF2SowNib1aBau@m3304i.mars.grid.sina.com.cn:3304/airflow" 
  AIRFLOW__CELERY__RESULT_BACKEND="redis://$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT/0"
fi

if [ "$AIRFLOW__CORE__EXECUTOR" = "CeleryExecutor" ]; then
  AIRFLOW__CELERY__BROKER_URL="redis://$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT/0"
fi

case "$1" in
  webserver)
    airflow initdb
    if [ "$AIRFLOW__CORE__EXECUTOR" = "LocalExecutor" ]; then
      # With the "Local" executor it should all run in one container.
      airflow scheduler --debug -l /airflow/logs/webserver.log &
    fi
    exec airflow webserver --debug --log-file /airflow/logs/webserver.log -A /airflow/logs/webserver.access -E /airflow/logs/webserver.err
    ;;
  worker)
    sleep 10
    exec airflow worker --log-file /airflow/logs/worker.log
    ;;
  scheduler)
    sleep 10
    exec airflow scheduler --log-file /airflow/logs/scheduler.log
    ;;
  flower)
    sleep 10
    exec airflow flower --log-file /airflow/logs/flower.log
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    # exec "$@"
    exec sleep 999999999999999
    ;;
esac
