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

  sudo su - deploywhaticketplus <<EOF
  cd /home/deploywhaticketplus/whaticket/frontend
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

  sudo su - deploywhaticketplus << EOF
  cat <<[-]EOF > /home/deploywhaticketplus/whaticket/frontend/.env
REACT_APP_BACKEND_URL=${backend_url}
REACT_APP_ENV_TOKEN=210897ugn217204u98u8jfo2983u5
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=9999999
REACT_APP_FACEBOOK_APP_ID=1005318707427295
REACT_APP_NAME_SYSTEM=whaticketplus
REACT_APP_VERSION="1.0.0"
REACT_APP_PRIMARY_COLOR=$#fffff
REACT_APP_PRIMARY_DARK=2c3145
REACT_APP_NUMBER_SUPPORT=51997059551
SERVER_PORT=3333
WDS_SOCKET_PORT=0
[-]EOF
EOF

  # Execute the substitution commands
  sudo su - deploywhaticketplus <<EOF
  cd /home/deploywhaticketplus/whaticket/frontend

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

  sudo su - deploywhaticketplus <<EOF
  cd /home/deploywhaticketplus/whaticket/frontend
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


  sudo rm -r /home/deploywhaticketplus/whaticket/frontend/whaticketplus
  sudo rm -r /home/deploywhaticketplus/whaticket/frontend/package.json
  sudo rm -r /home/deploywhaticketplus/whaticket/backend/whaticketplus
  sudo rm -r /home/deploywhaticketplus/whaticket/backend/package.json
  sudo rm -rf /home/deploywhaticketplus/whaticket/frontend/node_modules
  sudo rm -rf /home/deploywhaticketplus/whaticket/backend/node_modules

  sudo mv /root/whaticket/frontend/whaticketplus /home/deploywhaticketplus/whaticket/frontend
  sudo mv /root/whaticket/frontend/package.json /home/deploywhaticketplus/whaticket/frontend
  sudo mv /root/whaticket/backend/whaticketplus /home/deploywhaticketplus/whaticket/backend
  sudo mv /root/whaticket/backend/package.json /home/deploywhaticketplus/whaticket/backend
  sudo rm -rf /root/whaticket
  sudo apt update
  sudo apt install ffmpeg

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
  cd /home/deploywhaticketplus/whaticket/frontend

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

  sudo su - deploywhaticketplus <<EOF
  cd /home/deploywhaticketplus/whaticket/frontend
  npm install --force
EOF

  sleep 2
}

frontend_restart_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhaticketplus <<EOF
  cd /home/deploywhaticketplus/whaticket/frontend
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

  sudo su - deploywhaticketplus <<EOF
  cd /home/deploywhaticketplus/whaticket/backend
  npm install --force
EOF

  sleep 2
}

backend_db_migrate1() {
  print_banner
  printf "${WHITE} 💻 Executando db:migrate...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhaticketplus <<EOF
  cd /home/deploywhaticketplus/whaticket/backend
  npx sequelize db:migrate

EOF

  sleep 2

  sudo su - deploywhaticketplus <<EOF
  cd /home/deploywhaticketplus/whaticket/backend
  npx sequelize db:migrate
  
EOF

  sleep 2
}

backend_restart_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploywhaticketplus <<EOF
    cd /home/deploywhaticketplus/whaticket/backend
    pm2 stop all
    sudo rm -rf /root/Whaticket-Saas-Completo
EOF

  sleep 2

  sudo su - <<EOF
    usermod -aG sudo deploywhaticketplus

    grep -q "^deploywhaticketplus ALL=(ALL) NOPASSWD: ALL$" /etc/sudoers || echo "deploywhaticketplus ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    echo "deploywhaticketplus ALL=(ALL) NOPASSWD: ALL" | EDITOR='tee -a' visudo
EOF

  sudo su - deploywhaticketplus <<EOF
    pm2 start all
EOF

  sleep 2
}