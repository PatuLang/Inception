DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE := srcs/.env
DATA_DIR := $(HOME)/data
WORDPRESS_DATA_DIR := $(DATA_DIR)/wordpress
MARIADB_DATA_DIR := $(DATA_DIR)/mariadb

name = inception

all:	up

up:		create_dirs
	@printf "Building configuration ${name}...\n"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d --build

down:
	@printf "Stopping configuration ${name}...\n"
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down

clean: down
	@printf "Cleaning configuration ${name}...\n"
	@docker system prune --all --force

fclean: down
	@printf "Complete clean of all configurations & directories!\n"
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@sudo rm -rf $(WORDPRESS_DATA_DIR)
	@sudo rm -rf $(MARIADB_DATA_DIR)

re: fclean up

.PHONY: all build down re clean fclean logs create_dirs

create_dirs:
	@printf "Creating data directories...\n"
	@mkdir -p $(WORDPRESS_DATA_DIR)
	@mkdir -p $(MARIADB_DATA_DIR)

logs:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) logs -f
	# @printf "Showing logs for MariaDB...\n"
	# @timeout 10 docker logs -f mariadb || true
	# @printf "Showing logs for WordPress...\n"
	# @timeout 10 docker logs -f wordpress || true
	# @printf "Showing logs for Nginx...\n"
	# @timeout 10 docker logs -f nginx || true
	# @printf "Logs finished.\n"
