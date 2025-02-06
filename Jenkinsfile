pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /root/.m2:/root/.m2'
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
                script {
                    // Install openssh-client (which includes scp) as root
                    sh 'apt-get update && apt-get install -y openssh-client'

                    // Define variables
                    def ec2User = 'ubuntu' // Your EC2 username
                    def ec2Host = 'ec2-3-0-102-131.ap-southeast-1.compute.amazonaws.com' // Your EC2 instance's public DNS
                    def pemFile = '/home/rezar2p/Documents/0-reza/maspangsor.pem' // Path to your .pem file
                    def artifactPath = 'target/my-app-1.0-SNAPSHOT.jar' // Updated path to your built artifact

                    // Copy the artifact to the EC2 instance
                    sh "scp -i ${pemFile} -o StrictHostKeyChecking=no ${artifactPath} ${ec2User}@${ec2Host}:/path/on/ec2/"

                    // Execute the deployment script on the EC2 instance
                    sh "ssh -i ${pemFile} -o StrictHostKeyChecking=no ${ec2User}@${ec2Host} 'bash /path/on/ec2/deploy-script.sh'"
                }
                sleep(time: 1, unit: 'MINUTES')
            }
        }
    }
}
