NAME		:= inception
COMPOSE_FILE	:= srcs

DATA_DIR	:= /home/davifer2/data
WP_DIR		:= $(DATA_DIR)/wordpress
DB_DIR		:= $(DATA_DIR)/mariadb

all: up

setup:
	mkdir -p $(DATA_DIR) $(WP_DIR) $(DB_DIR)

up: setup
	cd srcs && docker compose up -d --build

down:
	cd srcs && docker compose down

clean:
	cd srcs && docker compose down -v --rmi all

fclean: clean
	sudo rm -rf /home/davifer2/data
	mkdir /home/davifer2/data

re: fclean all

.PHONY: build up down clean logs
