pipeline {
    agent {
        docker {
            image 'maven:3.9.0'
            args '-v /root/.m2:/root/.m2 -v /home/rezar2p/Documents/0-reza/maspangsor.pem:/root/maspangsor.pem:rw --privileged --user root' 
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
                    sh 'apt-get update && apt-get install -y openssh-client'

                    def ec2User = 'ubuntu'
                    def ec2Host = 'ec2-3-0-102-131.ap-southeast-1.compute.amazonaws.com' 
                    def pemFile = '/root/maspangsor.pem' 
                    def artifactPath = 'target/my-app-1.0-SNAPSHOT.jar' 

                    // Debugging sebelum SCP
                    sh "ls -lah /root"
                    sh "ls -lah ${pemFile}"
                    sh "test -f ${pemFile} && echo 'PEM File OK' || echo 'ERROR: PEM File NOT FOUND!'"

                    // Pastikan izin benar
                    sh """
                        cp /root/maspangsor.pem /tmp/maspangsor.pem
                        chmod 600 /tmp/maspangsor.pem
                    """

                    sh "scp -i /tmp/maspangsor.pem -o StrictHostKeyChecking=no ${artifactPath} ${ec2User}@${ec2Host}:/home/ubuntu/"
                    sh "ssh -i /tmp/maspangsor.pem -o StrictHostKeyChecking=no ${ec2User}@${ec2Host} 'bash /home/ubuntu/deploy-script.sh'"
                }
                sleep(time: 1, unit: 'MINUTES')
            }
        }
    }
}
