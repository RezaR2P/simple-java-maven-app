pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /root/.m2:/root/.m2 -u root --privileged'
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
                echo "Membangun aplikasi Java..."
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            steps {
                echo "Menjalankan testing..."
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Persetujuan Manual') {
            steps {
                input(message: 'Lanjut ke tahap deploy?', ok: 'Lanjut')
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: "${CREDENTIAL_ID}", keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh '''
                        echo "Memasang SSH client..."
                        apt-get update && apt-get install -y openssh-client

                        echo "Membuat direktori di EC2..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST "mkdir -p $PROJECT_DIR && logger -t DEPLOY_JENKINS 'Direktori $PROJECT_DIR dibuat'"

                        echo "Mengunggah file ke EC2..."
                        scp -o StrictHostKeyChecking=no -i $SSH_KEY -r * $EC2_USER@$EC2_HOST:$PROJECT_DIR

                        echo "Memberi hak akses..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST "chmod +x $PROJECT_DIR/jenkins/scripts/deliver.sh && logger -t DEPLOY_JENKINS 'Izin execute diberikan ke deliver.sh'"

                        echo "Menjalankan script deploy..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST "cd $PROJECT_DIR && ./jenkins/scripts/deliver.sh && logger -t DEPLOY_JENKINS 'Script deliver.sh dijalankan'"

                        echo "Menunggu stabilisasi..."
                        sleep 60
                    '''
                }
            }
        }
    }
}