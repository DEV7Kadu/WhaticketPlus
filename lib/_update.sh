 #######################################
# unzip whaticket
# Arguments:
#   None
#######################################
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