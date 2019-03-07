docker-build:
	docker build --rm -t puckel/docker-airflow .
start-all:
	docker-compose -f docker-compose-CeleryExecutor.yml up -d
start-webserver:
	docker-compose -f docker-compose-CeleryExecutor.yml up -d webserver
start-flower:
	docker-compose -f docker-compose-CeleryExecutor.yml up -d flower
start-scheduler:
	docker-compose -f docker-compose-CeleryExecutor.yml up -d scheduler
start-worker:
	docker-compose -f docker-compose-CeleryExecutor.yml up -d worker
