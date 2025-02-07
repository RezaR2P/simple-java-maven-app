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
        PROJECT_NAME = "simple-java-maven-app"  // Nama proyek
        PROJECT_DIR = "/home/ubuntu/simple-java-maven-app"
        CREDENTIAL_ID = "ec2-key"
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
                withCredentials([sshUserPrivateKey(credentialsId: "${CREDENTIAL_ID}", keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh '''
                        echo "Installing SCP and SSH client..."
                        apt update && apt install -y openssh-client

                        echo "Uploading entire project to EC2..."
                        scp -o StrictHostKeyChecking=no -i $SSH_KEY -r . $SSH_USER@$EC2_HOST:$PROJECT_DIR

                        echo "Setting executable permission for deploy script..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@$EC2_HOST "chmod +x $PROJECT_DIR/jenkins/scripts/deliver.sh"

                        echo "Executing deploy script on EC2..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@$EC2_HOST "cd $PROJECT_DIR && jenkins/scripts/deliver.sh"

                        echo "Sleeping for 1 minute to allow services to stabilize..."
                        sleep 60
                    '''
                }
            }
        }
    }
}
