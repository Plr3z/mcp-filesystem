pipeline {
    agent any
    environment {
        NAMESPACE = "mcp"
        BUILD_NAME = "supergateway-mcp"
    }
    stages {
        stage('Build Image') {
            steps {
                script {
                    echo "Enviando código para o OpenShift..."
                    // O Jenkins faz o upload do seu Dockerfile com Rclone
                    sh "oc start-build ${BUILD_NAME} --from-dir=. --follow --namespace=${NAMESPACE}"
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo "Atualizando Deployment..."
                    // Força o rollout para garantir que o novo container suba
                    sh "oc rollout restart deployment/${BUILD_NAME} --namespace=${NAMESPACE}"
                    sh "oc rollout status deployment/${BUILD_NAME} --namespace=${NAMESPACE}"
                }
            }
        }
    }
}
