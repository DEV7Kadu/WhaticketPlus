#!/bin/bash
# 
# Functions for setting up app frontend

#######################################
# Install node packages for frontend
# Arguments: None
#######################################
frontend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/frontend
  npm install --force
EOF

  sleep 2
}

#######################################
# Set frontend environment variables
# Arguments: None
#######################################
frontend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  sudo su - deploywhatstalk << EOF
  cat <<[-]EOF > /home/deploywhatstalk/whaticket/frontend/.env
REACT_APP_BACKEND_URL=${backend_url}
REACT_APP_ENV_TOKEN=210897ugn217204u98u8jfo2983u5
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=9999999
REACT_APP_FACEBOOK_APP_ID=1005318707427295
REACT_APP_NAME_SYSTEM=whatstalk
REACT_APP_VERSION="1.0.0"
REACT_APP_PRIMARY_COLOR=$#fffff
REACT_APP_PRIMARY_DARK=2c3145
REACT_APP_NUMBER_SUPPORT=51997059551
SERVER_PORT=3333
WDS_SOCKET_PORT=0
[-]EOF
EOF

  # Execute the substitution commands
  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/frontend

  BACKEND_URL=${backend_url}

  sed -i "s|https://autoriza.dominio|\$BACKEND_URL|g" \$(grep -rl 'https://autoriza.dominio' .)
EOF

  sleep 2
}


#######################################
# Start pm2 for frontend
# Arguments: None
#######################################
frontend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/frontend
  pm2 start server.js --name whaticket-frontend
  pm2 save
EOF

  sleep 2
}

#######################################
# Set up nginx for frontend
# Arguments: None
#######################################
frontend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  frontend_hostname=$(echo "${frontend_url/https:\/\/}")

  sudo su - root << EOF

  cat > /etc/nginx/sites-available/whaticket-frontend << 'END'
server {
  server_name $frontend_hostname;

  location / {
    proxy_pass http://127.0.0.1:3333;
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

  ln -s /etc/nginx/sites-available/whaticket-frontend /etc/nginx/sites-enabled
EOF

  sleep 2
}


system_unzip() {
  print_banner
  printf "${WHITE} 💻 Fazendo unzip whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  unzip "${PROJECT_ROOT}"/whaticket.zip
EOF

  sleep 2
}


move_whaticket_files() {
  print_banner
  printf "${WHITE} 💻 Movendo arquivos do WhaTicket...${GRAY_LIGHT}"
  printf "\n\n"
 
  sleep 2

  sudo su - root <<EOF

  sudo rm -r /home/deploywhatstalk/whaticket/frontend/whatstalk
  sudo rm -r /home/deploywhatstalk/whaticket/frontend/package.json
  sudo rm -r /home/deploywhatstalk/whaticket/backend/whatstalk
  sudo rm -r /home/deploywhatstalk/whaticket/backend/package.json
  rm -rf /home/deploywhatstalk/whaticket/frontend/node_modules
  rm -rf /home/deploywhatstalk/whaticket/backend/node_modules

  sudo mv /root/whaticket/frontend/whatstalk /home/deploywhatstalk/whaticket/frontend
  sudo mv /root/whaticket/frontend/package.json /home/deploywhatstalk/whaticket/frontend
  sudo mv /root/whaticket/backend/whatstalk /home/deploywhatstalk/whaticket/backend
  sudo mv /root/whaticket/backend/package.json /home/deploywhatstalk/whaticket/backend
  rm -rf /root/whaticket

EOF
  sleep 2
}


frontend_conf1() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  sudo su - root <<EOF
  cd /home/deploywhatstalk/whaticket/frontend

  BACKEND_URL=${backend_url}

  sed -i "s|https://autoriza.dominio|\$BACKEND_URL|g" \$(grep -rl 'https://autoriza.dominio' .)
EOF

  sleep 2
}

frontend_node_dependencies1() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/frontend
  npm install --force
EOF

  sleep 2
}

frontend_restart_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/frontend
  pm2 stop all
  pm2 start all
EOF

  sleep 2
}  

backend_node_dependencies1() {
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

backend_db_migrate1() {
  print_banner
  printf "${WHITE} 💻 Executando db:migrate...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/backend
  npx sequelize db:migrate

EOF

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/backend
  npx sequelize db:migrate
  
EOF

  sleep 2
}

backend_restart_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhatstalk <<EOF
  cd /home/deploywhatstalk/whaticket/backend
  pm2 stop all
  pm2 start all
  rm -rf /root/Whaticket-Saas-Completo
EOF

  sleep 2
}