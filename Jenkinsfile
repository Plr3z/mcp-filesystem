pipeline {
    agent any

    environment {
        NAMESPACE = 'mcp'
        APP_NAME  = 'supergateway-s3'
    }

    stages {
        stage('Prepare') {
            steps {
                script {
                    // Garante que estamos no projeto correto
                    sh "oc project ${NAMESPACE}"
                }
            }
        }

        stage('Build Image') {
            steps {
                echo "Enviando código do workspace para o OpenShift Build..."
                script {
                    // O Jenkins envia o conteúdo atual do diretório para o BuildConfig
                    // Isso ignora a necessidade do OpenShift acessar o Git diretamente
                    sh "oc start-build ${APP_NAME}-build --from-dir=. --follow --wait"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Verificando Rollout..."
                script {
                    // O OpenShift normalmente inicia o deploy automaticamente ao atualizar o ImageStream
                    // Este comando apenas monitora até que o deploy esteja pronto
                    sh "oc rollout status deployment/${APP_NAME} --timeout=5m"
                }
            }
        }
    }

    post {
        success {
            echo "Deploy realizado com sucesso em: http://seu-route-ou-ip:3001"
        }
    }
}
