docker-build:
	docker build --rm -t puckel/docker-airflow .
docker-tag:
	docker tag puckel/docker-airflow registry.dpool.sina.com.cn/sinadbp/docker-airflow.1.10.2
start-all:
	docker-compose -f docker-compose-CeleryExecutor.yml up -d
start-webserver:
	docker-compose -f docker-compose-CeleryExecutor.yml up -d webserver
start-flower:
	docker-compose -f docker-compose-CeleryExecutor.yml up -d flower
start-scheduler:
	docker-compose -f docker-compose-CeleryExecutor.yml up -d scheduler
start-worker:
	# worker 在服务器上启动、不用docker
	# docker-compose -f docker-compose-CeleryExecutor.yml up -d worker
	export C_FORCE_ROOT=true && export AIRFLOW_HOME=/data1/airflow && airflow worker > /data1/airflow/worker.log 2>&1 &
