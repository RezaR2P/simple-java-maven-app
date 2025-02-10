pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /root/.m2:/root/.m2 -v /var/jenkins_home:/var/jenkins_home --user root --privileged'
        }
    }
    environment {
        EC2_USER = "ubuntu"
        EC2_HOST = "3.0.102.131"
        PROJECT_DIR = "/home/ubuntu/simple-java-maven-app"
        CREDENTIAL_ID = "ec2-key"
    }
    stages {
        stage('Build') {
            steps {
                echo "Building Java application..."
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            steps {
                echo "Running tests..."
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Manual Approval') {
            steps {
                input(message: 'Lanjutkan ke tahap Deploy?', ok: 'Proceed')
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: "${CREDENTIAL_ID}", keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh '''
                        echo "Menginstal SSH client..."
                        apt-get update && apt-get install -y openssh-client

                        echo "Membuat direktori proyek di EC2..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST "mkdir -p $PROJECT_DIR && logger 'DIRECTORY_CREATED: $PROJECT_DIR'"

                        echo "Mengupload file..."
                        scp -o StrictHostKeyChecking=no -i $SSH_KEY -r * $EC2_USER@$EC2_HOST:$PROJECT_DIR && logger 'Deploy Project Ke EC2 Sukses!'

                        echo "Memberikan izin eksekusi..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST "chmod +x $PROJECT_DIR/jenkins/scripts/deliver.sh && logger 'PERMISSIONS_GRANTED: deliver.sh'"

                        echo "Menjalankan deploy script..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST "cd $PROJECT_DIR && ./jenkins/scripts/deliver.sh && logger 'DEPLOY_EXECUTED: deliver.sh'"

                        echo "Menunggu stabilisasi..."
                        sleep 60
                    '''
                }
            }
        }
    }
}