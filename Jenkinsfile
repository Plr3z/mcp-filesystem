pipeline {
    agent any
    stages {
        stage('Build & Deploy') {
            steps {
                script {
                    // Isso aciona o OpenShift para ler o seu Dockerfile e criar a imagem
                    sh "oc start-build supergateway-mcp --from-dir=. --follow -n mcp"
                    // Isso garante que o Deployment use a nova imagem
                    sh "oc rollout status deployment/supergateway-mcp -n mcp"
                }
            }
        }
    }
}
