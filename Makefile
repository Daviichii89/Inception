DEL_LINE	=	\033[2K
ITALIC		=	\033[3m
BOLD		=	\033[1m
RESET		=	\033[0;39m
GRAY		=	\033[0;90m
RED		=	\033[0;91m
GREEN		=	\033[0;92m
YELLOW		=	\033[0;93m
BLUE		=	\033[0;94m
MAGENTA 	=	\033[0;95m
CYAN		=	\033[0;96m
WHITE		=	\033[0;97m
BLACK		=	\033[0;99m
ORANGE		=	\033[38;5;209m
BROWN		=	\033[38;2;184;143;29m
DARK_GRAY	=	\033[38;5;234m
MID_GRAY	=	\033[38;5;245m
DARK_GREEN	=	\033[38;2;75;179;82m
DARK_YELLOW	=	\033[38;5;143m

NAME		:= inception
COMPOSE_FILE	:= srcs

DATA_DIR	:= /home/davifer2/data
WP_DIR		:= $(DATA_DIR)/wordpress
DB_DIR		:= $(DATA_DIR)/mariadb

all: up
	@echo "🎉 $(GREEN)$(BOLD)Server created successfully!$(RESET)"
setup:
	@echo "$(YELLOW)Creating folders...$(RESET)"
	@sleep 1
	@mkdir -p $(DATA_DIR) $(WP_DIR) $(DB_DIR)
	@echo "$(GREEN)Created folders.$(RESET)"

up: setup
	@echo "$(YELLOW)Starting the server...$(RESET)"
	@cd srcs && docker compose up -d --build
	@sleep 1
	@echo "\n"

down:
	@echo "$(RED)Stopping the server...$(RESET)"
	@cd srcs && docker compose down

clean:
	@if [ -n "$$(cd srcs && docker compose ps -q)" ]; then \
		echo "$(RED)Stopping server...$(RESET)"; \
		cd srcs && docker compose down -v --rmi all >/dev/null 2>&1; \
		sleep 1; \
		echo ""; \
		echo "$(GREEN)$(BOLD)🎉 Server unmounted succesfully!$(RESET)"; \
		sleep 1; \
	fi

fclean: clean
	@if [ -d /home/davifer2/data ] && [ "$$(ls -A /home/davifer2/data)" ]; then \
		echo "$(RED)Removing data...$(RESET)"; \
		sudo rm -rf /home/davifer2/data; \
		mkdir /home/davifer2/data; \
		echo ""; \
		sleep 2; \
		echo "$(GREEN)$(BOLD)🎉 Server destroyed succesfully!$(RESET)"; \
	else \
		echo "$(YELLOW)No data to clean, recreating data folder...$(RESET)"; \
		sudo rm -rf /home/davifer2/data >/dev/null 2>&1; \
		mkdir /home/davifer2/data; \
		sleep 1; \
		echo "\n"; \
		echo "$(GREEN)$(BOLD)🎉 Recreated data folder.$(RESET)"; \
	fi


re: fclean all

.PHONY: build up down clean logs
