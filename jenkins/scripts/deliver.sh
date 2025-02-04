#!/usr/bin/env bash

EC2_USER="ubuntu"
EC2_HOST="3.0.102.131"
EC2_KEY="../../maspangsor.pem"
APP_JAR="target/simple-java-maven-app.jar"
DEPLOY_DIR="/home/ubuntu/simple-java-maven-app"

echo "Mengirim file JAR ke EC2 instance..."
scp -i "$EC2_KEY" "$APP_JAR" "$EC2_USER@$EC2_HOST:$DEPLOY_DIR/"

echo "Menghentikan aplikasi yang sedang berjalan (jika ada)..."
ssh -i "$EC2_KEY" "$EC2_USER@$EC2_HOST" "pkill -f simple-java-maven-app.jar || echo 'Tidak ada aplikasi yang berjalan'"

echo "Menjalankan aplikasi Java di EC2 instance..."
ssh -i "$EC2_KEY" "$EC2_USER@$EC2_HOST" "nohup java -jar $DEPLOY_DIR/$(basename $APP_JAR) > /dev/null 2>&1 &"

echo "Deploy selesai. Aplikasi berjalan di http://$EC2_HOST:8080"