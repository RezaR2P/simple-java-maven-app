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
                        echo "Installing SCP and SSH client..."
                        apt update && apt install -y openssh-client
                        logger "Installing SCP and SSH client..."

                        echo "Ensuring project directory exists in EC2..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@$EC2_HOST "mkdir -p $PROJECT_DIR"
                        logger "Ensured project directory exists in EC2 at $PROJECT_DIR"

                        echo "Uploading project files to EC2..."
                        scp -o StrictHostKeyChecking=no -i $SSH_KEY -r * $SSH_USER@$EC2_HOST:$PROJECT_DIR
                        logger "Uploaded project files to EC2"

                        echo "Granting execute permission to deliver.sh..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@$EC2_HOST "chmod +x $PROJECT_DIR/jenkins/scripts/deliver.sh"
                        logger "Granted execute permission to deliver.sh"

                        echo "Executing deliver.sh in the correct directory..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_USER@$EC2_HOST "cd $PROJECT_DIR && ./jenkins/scripts/deliver.sh"
                        logger "Executed deliver.sh in $PROJECT_DIR"

                        echo "Sleeping for 1 minute to allow services to stabilize..."
                        sleep 60
                        logger "Sleeping for 1 minute to allow services to stabilize..."
                    '''
                }
            }
        }
    }
}
