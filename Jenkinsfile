pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /root/.m2:/root/.m2 -v /home/rezar2p/Documents/0-reza/jenkins/simple-java-maven-app/maspangsor.pem:/simple-java-maven-app/maspangsor.pem'
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
                sh './jenkins/scripts/deliver.sh'
                sh '''
                    set -e
                    apt-get install -y sshpass openssh-client
                    SSH_KEY="/simple-java-maven-app/maspangsor.pem"
                    chmod 600 "$SSH_KEY"
                    EC2_HOST="ubuntu@ec2-3-0-102-131.ap-southeast-1.compute.amazonaws.com"
                    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" $EC2_HOST 'echo "SSH connection successful"'
                    scp -i "$SSH_KEY" target/*.jar $EC2_HOST:/home/ubuntu/
                '''
                sleep(time: 1, unit: 'MINUTES')
            }
        }
    }
}