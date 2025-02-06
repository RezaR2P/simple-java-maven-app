pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /root/.m2:/root/.m2 -v /home/rezar2p/Documents/0-reza/maspangsor.pem:/home/jenkins/Documents/maspangsor.pem --privileged --user root'
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
                    // Instal openssh-client (yang termasuk scp) sebagai root
                    sh 'apt-get update && apt-get install -y openssh-client'

                    // Definisikan variabel
                    def ec2User = 'ubuntu' // Nama pengguna EC2 Anda
                    def ec2Host = 'ec2-3-0-102-131.ap-southeast-1.compute.amazonaws.com' // DNS publik instance EC2 Anda
                    def pemFile = '/home/jenkins/Documents/maspangsor.pem' // Path ke file .pem di dalam kontainer
                    def artifactPath = 'target/my-app-1.0-SNAPSHOT.jar' // Path ke artefak yang telah dibangun

                    // Set izin untuk file .pem
                    sh "chmod 400 ${pemFile}"

                    // Salin artefak ke instance EC2
                    sh "scp -i ${pemFile} -o StrictHostKeyChecking=no ${artifactPath} ${ec2User}@${ec2Host}:/path/on/ec2/"

                    // Jalankan skrip deployment di instance EC2
                    sh "ssh -i ${pemFile} -o StrictHostKeyChecking=no ${ec2User}@${ec2Host} 'bash /path/on/ec2/deploy-script.sh'"
                }
                sleep(time: 1, unit: 'MINUTES')
            }
        }
    }
}