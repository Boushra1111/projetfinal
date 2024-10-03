pipeline {
    agent any
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        KUBECTL_HOME = '/usr/local/bin/kubectl' // Remplacez par le chemin vers votre fichier kubeconfig
    }

    stages {
        stage('Git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Boushra1111/projetfinal'
            }
        }
        stage('Test') {
            steps {
                script {
                    echo "Vérification de la présence du fichier test_app.py dans l'image Docker"
                    // Exécuter une commande pour lister le contenu du répertoire /app
                    sh 'docker run --rm boushra1138/flaskapp:latest ls -l /app'

                    echo "Exécution des tests avec pytest"
                    // Exécuter pytest pour le fichier de test test_app.py
                    sh 'docker run --rm boushra1138/flaskapp:latest pytest /app/test_app.py --maxfail=1 --disable-warnings -q'
                }
            }
        } 
        
        stage('Owasp') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ ', odcInstallation: 'DC'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
   
        stage('Sonarqube analysis') {
            steps {
                withSonarQubeEnv('Sonar') {
                      sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.url=http://172.25.6.137:9000 -Dsonar.projectName=python-webapp \
                -Dsonar.java.binaries=. \
                -Dsonar.projectKey=python-webapp '''
                }
                
            }
        }
        stage('BUILD & PUSH DOCKER IMAGE') {
            steps {
             script {withDockerRegistry(credentialsId: 'boushra11', toolName: 'Docker') {
                 sh 'docker build -t flaskapp:latest -f ./Dockerfile .'
                 sh ' docker tag flaskapp:latest boushra1138/flaskapp:latest'
                 sh 'docker push boushra1138/flaskapp:latest'
             
                 
             }
            }
        }
    }
        stage('Configure kubectl') {
            steps {
                script {
                    withKubeConfig(credentialsId: 'kube1', namespace: '', restrictKubeConfigAccess: false) {
                        sh "${KUBECTL_HOME} apply -f deployment.yaml"
                    }
                }
            }
        }
        stage('Trigger CD Pipeline') {
            steps {
                build job: 'Final_Project_CD_Pipeline', wait: true
            }
        }
    }

    post {
        always {
            echo 'Pipeline terminé'
        }
        success {
            echo 'Tests réussis'
        }
           failure {
            echo 'Tests échoués'
        }
    }
}
