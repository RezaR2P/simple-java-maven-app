#!/usr/bin/env bash

EC2_USER="ubuntu"
EC2_HOST="3.0.102.131"
EC2_KEY="../../maspangsor.pem"
APP_JAR="target/simple-java-maven-app.jar"
DEPLOY_DIR="/home/ubuntu/simple-java-maven-app"

echo "Mengirim file JAR ke EC2 instance..."
scp -i "$EC2_KEY" "$APP_JAR" "$EC2_USER@$EC2_HOST:$DEPLOY_DIR/"

echo "Aplikasi berhasil dihentikan."