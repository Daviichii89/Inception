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
COMPOSE_FILE	:= srcs/docker-compose.yml

DATA_DIR	:= /home/davifer2/data
WP_DIR		:= $(DATA_DIR)/wordpress
DB_DIR		:= $(DATA_DIR)/mariadb

all: up
	@echo "🎉 $(GREEN)$(BOLD)Server created successfully!$(RESET)"
setup:
	@echo "$(YELLOW)Creating folders...$(RESET)"
	@created=0; \
	for dir in $(DATA_DIR) $(WP_DIR) $(DB_DIR); do \
		if [ ! -d "$$dir" ]; then \
			mkdir -p "$$dir"; \
			echo "$(GREEN)Created folder: $$dir$(RESET)"; \
			created=1; \
		fi; \
	done; \
	if [ $$created -eq 0 ]; then \
		echo "$(MID_GRAY)Folders already exist.$(RESET)"; \
	fi

certs:
	@./srcs/requirements/nginx/tools/generate_certs.sh $${DOMAIN_NAME:-localhost}

up: setup certs
	@echo "$(YELLOW)Starting the server...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "\n"

down:
	@echo "$(RED)Stopping the server...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down

clean:
	@echo "$(RED)Stopping server...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down -v --rmi all >/dev/null 2>&1
	@echo ""
	@echo "$(GREEN)$(BOLD)🎉 Server unmounted succesfully!$(RESET)"

fclean: clean
	@if [ -d /home/davifer2/data ] && [ "$$(ls -A /home/davifer2/data)" ]; then \
		echo "$(RED)Removing data...$(RESET)"; \
		sudo rm -rf /home/davifer2/data; \
		echo ""; \
		echo "$(GREEN)$(BOLD)🎉 Server destroyed succesfully!$(RESET)"; \
	else \
		echo "$(YELLOW)No data to clean.$(RESET)"; \
	fi


re: fclean all

.PHONY: build certs up down clean logs
