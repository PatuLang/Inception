DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE := srcs/.env
DATA_DIR := $(HOME)/data
WORDPRESS_DATA_DIR := $(DATA_DIR)/wordpress
MARIADB_DATA_DIR := $(DATA_DIR)/mariadb

name = inception

all:	build

up:		create_dirs
	@printf "Starting configuration of ${name}...\n"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d

build:	create_dirs
	@printf "Building configuration of ${name}...\n"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d --build

down:
	@printf "Stopping configuration of ${name}...\n"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down

clean:	down
	@printf "Cleaning configuration of ${name}...\n"
	@docker system prune --all --force

fclean:	down
	@printf "Complete clean of all configurations & directories!\n"
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@sudo rm -rf $(WORDPRESS_DATA_DIR)
	@sudo rm -rf $(MARIADB_DATA_DIR)

re:		fclean up

.PHONY:	all build down re clean fclean logs create_dirs

create_dirs:
	@printf "Creating data directories for ${name}...\n"
	@mkdir -p $(WORDPRESS_DATA_DIR)
	@mkdir -p $(MARIADB_DATA_DIR)

logs:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) logs -f
