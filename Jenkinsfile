pipeline {
    agent any

    environment {
        // Nome do projeto no OpenShift
        NAMESPACE = "mcp"
        // Nome do BuildConfig que criamos no YAML anterior
        BUILD_NAME = "supergateway-mcp"
    }

    stages {
        stage('Prepare') {
            steps {
                echo "Iniciando build para o projeto ${NAMESPACE}..."
                // Garante que estamos no projeto correto
                sh "oc project ${NAMESPACE}"
            }
        }

        stage('Build Image') {
            steps {
                script {
                    echo "Enviando código para o OpenShift Build Service..."
                    // O comando abaixo pega o Dockerfile e arquivos locais e envia para o OpenShift
                    sh "oc start-build ${BUILD_NAME} --from-dir=. --follow"
                }
            }
        }

        stage('Deploy & Verify') {
            steps {
                script {
                    echo "Aguardando o rollout do novo Pod..."
                    // Verifica se o deploy foi concluído com sucesso
                    sh "oc rollout status deployment/${BUILD_NAME}"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline finalizado com sucesso! O S3 foi montado e o Supergateway está online."
        }
        failure {
            echo "Ocorreu um erro no Pipeline. Verifique os logs do build ou as permissões de SCC."
        }
    }
}
