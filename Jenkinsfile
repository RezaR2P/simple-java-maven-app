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
        JAR_NAME = "target/*.jar" // Sesuaikan dengan nama file jar yang dihasilkan
        REMOTE_PATH = "/home/ubuntu/" // Direktori tujuan di EC2
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
                withCredentials([sshUserPrivateKey(credentialsId: "${CREDENTIAL_ID}", keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                        echo "Uploading JAR file to EC2..."
                        scp -o StrictHostKeyChecking=no -i $SSH_KEY $JAR_NAME $EC2_USER@$EC2_HOST:$REMOTE_PATH
                        
                        echo "Executing deploy script on EC2..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY $EC2_USER@$EC2_HOST "chmod +x /home/ubuntu/jenkins/scripts/deliver.sh && /home/ubuntu/jenkins/scripts/deliver.sh"
                    '''
                }
            }
            sleep(time: 1, unit: 'MINUTES')
        }
    }
}
