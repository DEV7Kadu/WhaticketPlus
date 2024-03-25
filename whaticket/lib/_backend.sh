#!/bin/bash
#
# functions for setting up app backend
#######################################
# creates REDIS db using docker
# Arguments:
#   None
#######################################
backend_redis_create() {
  print_banner
  printf "${WHITE} 💻 Criando Redis & Banco Postgres...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  usermod -aG docker deploywhatstalk
  docker run --name redis-redis -p 6379:6379 --restart always --detach redis redis-server --requirepass ${db_pass}
  
EOF

 sleep 2

}

#######################################
# sets environment variable for backend.
# Arguments:
#   None
#######################################
backend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  # ensure idempotency
  frontend_url=$(echo "${frontend_url/https:\/\/}")
  frontend_url=${frontend_url%%/*}
  frontend_url=https://$frontend_url

sudo su - deploywhatstalk << EOF
  cat <<[-]EOF > /home/deploywhatstalk/whaticket/backend/.env
NODE_ENV=

# VARIÁVEIS DE SISTEMA
BACKEND_URL=${backend_url}
FRONTEND_URL=${frontend_url}
PROXY_PORT=443
PORT=8080

# CREDENCIAIS BANCO DE DADOS
DB_TIMEZONE=-03:00
DB_DIALECT=postgres
DB_HOST=localhost
DB_USER=postgres
DB_PASS=2000@23
DB_NAME=whaticketwhatstalk
DB_PORT=5432
DB_DEBUG=false
DB_BACKUP=/www/wwwroot/backup

JWT_SECRET=53pJTvkL9T6q2jYFFKwXgvLAgQahwbb/BM0opll5NZM=
JWT_REFRESH_SECRET=1/n/QnJtfUphUd9CrXjaxRw+jSAxtRIJwFroFmqrRXY=

REDIS_URI=redis://:${db_pass}@127.0.0.1:6379
REDIS_OPT_LIMITER_MAX=1
REGIS_OPT_LIMITER_DURATION=3000

#MASTER KEY PARA TODOS
MASTER_KEY=

ENV_TOKEN=
WHATSAPP_UNREADS=

# FACEBOOK/INSTAGRAM CONFIGS
VERIFY_TOKEN=Whaticket
FACEBOOK_APP_ID=
FACEBOOK_APP_SECRET=

# BROWSER SETTINGS
BROWSER_CLIENT=
BROWSER_NAME=Chrome
BROWSER_VERSION=10.0
VIEW_QRCODE_TERMINAL=true

# EMAIL
MAIL_HOST=""
MAIL_USER=""
MAIL_PASS=""
MAIL_FROM=""
MAIL_PORT=587

GERENCIANET_SANDBOX=false
GERENCIANET_CLIENT_ID=
GERENCIANET_CLIENT_SECRET=
GERENCIANET_PIX_CERT=
GERENCIANET_PIX_KEY=

OPENAI_API_KEY=


[-]EOF
EOF

  sleep 2
}

#######################################
# install_chrome
# Arguments:
#   None
#######################################
backend_chrome_install() {
  print_banner
  printf "${WHITE} 💻 Vamos instalar o Chrome...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  apt-get update
  apt-get install -y google-chrome-stable
EOF

  sleep 2
}

#######################################
# installs node.js dependencies
# Arguments:
#   None
#######################################
backend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/backend
  npm install --force
EOF

  sleep 2
}

#######################################
# runs db migrate
# Arguments:
#   None
#######################################
backend_db_migrate() {
  print_banner
  printf "${WHITE} 💻 Executando db:migrate...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/backend
  npx sequelize db:migrate
EOF

  sleep 2
}

#######################################
# runs db seed
# Arguments:
#   None
#######################################
backend_db_seed() {
  print_banner
  printf "${WHITE} 💻 Executando db:seed...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/backend
  npx sequelize db:seed:all
EOF

  sleep 2
}

#######################################
# starts backend using pm2 in 
# production mode.
# Arguments:
#   None
#######################################
backend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/backend
  pm2 start whatstalk/server.js --name whaticket-backend
EOF

  sleep 2
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
backend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  backend_hostname=$(echo "${backend_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/whaticket-backend << 'END'
server {
  server_name $backend_hostname;

  location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END

ln -s /etc/nginx/sites-available/whaticket-backend /etc/nginx/sites-enabled
EOF

  sleep 2
}
