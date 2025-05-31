#!/bin/bash

# Función para comprobar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

echo "Instalando dependencias necesarias..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

if ! command_exists docker; then
    echo "Añadiendo la clave GPG de Docker..."
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo "Añadiendo el repositorio de Docker..."
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "Actualizando los repositorios..."
    sudo apt update

    echo "Instalando Docker..."
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    echo "Habilitando y arrancando Docker..."
    sudo systemctl enable docker
    sudo systemctl start docker

    echo "Docker instalado correctamente."
else
    echo "Docker ya está instalado."
fi

if ! command_exists docker-compose; then
    echo "Instalando Docker Compose..."
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "Docker Compose instalado correctamente en la versión $DOCKER_COMPOSE_VERSION."
else
    echo "Docker Compose ya está instalado."
fi

echo "Verificando las versiones instaladas..."
docker --version
docker-compose --version

echo "Instalación completada."
