pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /home/rezar2p/Documents/0-reza/maspangsor.pem:/root/maspangsor.pem:ro --privileged --user root'
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
                    // Install dependencies
                    sh 'apt-get update && apt-get install -y openssh-client file'

                    def ec2User = 'ubuntu'
                    def ec2Host = '3.0.102.131' // Gunakan IP langsung
                    def pemFile = '/root/maspangsor.pem'
                    def artifactPath = 'target/my-app-1.0-SNAPSHOT.jar'

                    // Validasi file .pem bukan direktori
                    sh """
                        if [ ! -f ${pemFile} ]; then
                            echo 'ERROR: ${pemFile} bukan file!'
                            exit 1
                        fi
                    """

                    // Pastikan izin benar
                    sh "chmod 600 ${pemFile}"

                    // Cek koneksi internet
                    sh "ping -c 4 8.8.8.8"
                    sh "ping -c 4 ${ec2Host}"

                    // SCP untuk mengirimkan artifact ke EC2
                    sh "scp -i ${pemFile} -o StrictHostKeyChecking=no ${artifactPath} ${ec2User}@${ec2Host}:/home/ubuntu/"

                    // SSH untuk menjalankan deployment script di EC2
                    sh "ssh -i ${pemFile} -o StrictHostKeyChecking=no ${ec2User}@${ec2Host} 'bash /home/ubuntu/deploy-script.sh'"
                }
                sleep(time: 1, unit: 'MINUTES')
            }
        }
    }
}
