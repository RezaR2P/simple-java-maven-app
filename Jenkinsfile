pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /root/.m2:/root/.m2 --privileged --user root'
        }
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package -X'
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
                    sh 'apt-get update && apt-get install -y openssh-client'

                    def ec2User = env.EC2_USER ?: 'ubuntu'
                    def ec2Host = env.EC2_HOST ?: 'ec2-3-0-102-131.ap-southeast-1.compute.amazonaws.com'
                    def artifactPath = 'target/*.jar' 

                    // Ambil file .pem dari Jenkins Credentials Manager
                    withCredentials([file(credentialsId: 'ec2-key', variable: 'PEM_FILE')]) {
                        // SCP untuk mengirimkan artifact ke EC2
                        def scpCommand = "scp -i $PEM_FILE -o StrictHostKeyChecking=no ${artifactPath} ${ec2User}@${ec2Host}:/home/ubuntu/"
                        sh scpCommand || error("SCP command failed")

                        // SSH untuk menjalankan deployment script di EC2
                        def sshCommand = "ssh -i $PEM_FILE -o StrictHostKeyChecking=no ${ec2User}@${ec2Host} 'bash /home/ubuntu/deploy-script.sh'"
                        sh sshCommand || error("SSH command failed")
                    }
                }
            }
        }
    }
}