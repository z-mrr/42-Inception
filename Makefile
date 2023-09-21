NAME =		inception

YML =		./srcs/docker-compose.yml

all:		build $(NAME)

check-prerequisites: check-hosts check-volumes check-env

check-hosts:
	@if ! grep -q "27.0.0.1 jdias-mo.42.fr" /etc/hosts; then \
		sudo sh -c 'echo "127.0.0.1 jdias-mo.42.fr" >> /etc/hosts'; \
	fi

check-volumes:
	@if [ ! -d "/home/jdias-mo/data/db" ] || [ ! -d "/home/jdias-mo/data/wp" ]; then \
		mkdir -p /home/jdias-mo/data/wp /home/jdias-mo/data/db; \
	fi

check-env:
	@if [ ! -f ./srcs/.env ]; then \
		cp ./srcs/requirements/tools/.env-setup ./srcs/.env; \
	fi

build:		check-prerequisites
			@docker compose -f $(YML) build

$(NAME):	up
		
up:			build
			@docker compose -f $(YML) up -d

down:
			@docker compose -f $(YML) down

start:
			@docker compose -f $(YML) start

stop:
			@docker compose -f $(YML) stop

rm:			stop
			@docker compose -f $(YML) rm

rmi:		
			@docker compose -f $(YML) down --rmi all

rmv:		
			@docker compose -f $(YML) down --volumes

clean:		
			@docker compose -f $(YML) down --rmi all --volumes

fclean:		clean
			@sudo rm -rf ./srcs/.env /home/jdias-mo/data

re: 		fclean all

.PHONY:		all up down start stop rm rmi rmv clean fclean re








