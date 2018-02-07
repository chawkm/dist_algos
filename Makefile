
# distributed algorithms, n.dulay, 18 jan 18
# Makefile, v1

PEERS    = 10
#TIMEOUT = 10
#MAX_BROADCAST = 1000
#SYSTEM   = 1
MAIN     = System$(SYSTEM).main
MAIN_NET = System$(SYSTEM)/System.main_net

PROJECT  = da347
NETWORK  = $(PROJECT)_network

COMMAND = "$(MAIN) $(TIMEOUT), $(MAX_BROADCAST)"
ifneq ($(RELIABILITY),)
COMMAND = "$(MAIN) $(TIMEOUT), $(MAX_BROADCAST), $(RELIABILITY)"
endif

LOCAL	 = mix run --no-halt -e $(COMMAND)
COMPOSE  = COMMAND=$(COMMAND) docker-compose -p $(PROJECT)

compile:
	mix compile

run:
	$(LOCAL)

clean:
	mix clean

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up

down:
	$(COMPOSE) down
	make show

show:
	@echo ----------------------
	@make ps
	@echo ----------------------
	@make network

show2:
	@echo ----------------------
	@make ps2
	@echo ----------------------
	@make network

ps:
	docker ps -a --format 'table {{.Names}}\t{{.Image}}'

ps2:
	docker ps -a -s

network net:
	docker network ls

inspect:
	docker network inspect $(NETWORK)

netrm:
	docker network rm $(NETWORK)
conrm:
	docker rm $(ID)

kill:
	docker rm -f `docker ps -a -q`
	docker network rm $(NETWORK)
