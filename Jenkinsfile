pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /root/.m2:/root/.m2 -v /home/rezar2p/Documents/0-reza:/home/rezar2p/Documents/0-reza'
        }
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }

        stage('Test') {
            steps {
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
        sh '''
            set -e
            
            SSH_KEY="/home/rezar2p/Documents/0-reza/maspangsor.pem"
            
            if [ ! -f "$SSH_KEY" ]; then
                echo "ERROR: SSH Key not found at $SSH_KEY"
                exit 1
            fi

            chmod 600 "$SSH_KEY"

            EC2_HOST="ubuntu@ec2-3-0-102-131.ap-southeast-1.compute.amazonaws.com"

            # Install dependency jika belum tersedia
            USER root
            apt-get update && apt-get install -y sshpass openssh-client

            # Test SSH connection
            ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" $EC2_HOST 'echo "SSH connection successful"'

            # Copy JAR file to EC2
            scp -o StrictHostKeyChecking=no -i "$SSH_KEY" target/*.jar $EC2_HOST:/home/ubuntu/

            # (Opsional) Jalankan aplikasi di EC2
            ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" $EC2_HOST 'nohup java -jar /home/ubuntu/*.jar > /home/ubuntu/app.log 2>&1 &'
        '''
    }
}
