pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '--dns=8.8.8.8 --network=host -v /root/.m2:/root/.m2 --user root'
        }
    }

    stages {
        stage('Setup') {
            steps {
                script {
                    // Install dependencies (Git dan OpenSSH)
                    sh 'apt-get update && apt-get install -y git openssh-client'

                    // Cek koneksi internet sebelum build
                    sh 'ping -c 4 8.8.8.8'
                    sh 'ping -c 4 repo.maven.apache.org'
                }
            }
        }

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
                    def ec2User = 'ubuntu'
                    def ec2Host = '3.0.102.131'
                    def artifactPath = 'target/my-app-1.0-SNAPSHOT.jar'

                    // Ambil file .pem dari Jenkins Credentials Manager
                    withCredentials([file(credentialsId: 'ec2-key', variable: 'PEM_FILE')]) {

                        // Pastikan file .pem ada dan memiliki izin yang benar
                        sh """
                            if [ ! -f $PEM_FILE ]; then
                                echo 'ERROR: $PEM_FILE bukan file!'
                                exit 1
                            fi
                            chmod 600 $PEM_FILE
                        """

                        // Cek koneksi internet & server EC2
                        sh "ping -c 4 8.8.8.8"
                        sh "ping -c 4 ${ec2Host}"

                        // SCP untuk mengirimkan artifact ke EC2
                        sh "scp -i $PEM_FILE -o StrictHostKeyChecking=no ${artifactPath} ${ec2User}@${ec2Host}:/home/ubuntu/"

                        // SSH untuk menjalankan deployment script di EC2
                        sh "ssh -i $PEM_FILE -o StrictHostKeyChecking=no ${ec2User}@${ec2Host} 'bash /home/ubuntu/deploy-script.sh'"
                    }
                }
                sleep(time: 1, unit: 'MINUTES')
            }
        }
    }
}
