pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /root/.m2:/root/.m2 -v /home/rezar2p/Documents/0-reza/jenkins/simple-java-maven-app/maspangsor.pem:/maspangsor.pem'
        }
    }

    stages {
        stage('Build') {
            steps {
                sh '''
                    rm -rf target/
                    mvn -B -DskipTests clean package
                '''
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
                sh 'rm -rf /var/lib/dpkg/lock-frontend'
                sh 'rm -rf /var/lib/dpkg/frontend'
                sh 'apt-get install -y sshpass openssh-client'
                sh 'chmod 600 /maspangsor.pem'
                sh 'ssh -o StrictHostKeyChecking=no -i "/maspangsor.pem" ubuntu@ec2-3-0-102-131.ap-southeast-1.compute.amazonaws.com "echo SSH connection successful"'
                sh 'scp -i "/maspangsor.pem" target/*.jar ubuntu@ec2-3-0-102-131.ap-southeast-1.compute.amazonaws.com:/home/ubuntu/'
                sleep(time: 1, unit: 'MINUTES')
            }
        }
    }
}