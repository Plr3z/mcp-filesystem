pipeline {
    agent any

    environment {
        APP_NAME = 'supergateway-mcp'
        PROJECT  = 'mcp'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Build no OpenShift') {
            steps {
                script {
                    echo "Disparando build binário do ${APP_NAME}:latest"

                    // Garantir que o workspace do Jenkins contenha o Dockerfile na raiz
                    sh """
                        if [ ! -f ${WORKSPACE}/Dockerfile ]; then
                            echo "ERRO: Dockerfile não encontrado no workspace!"
                            exit 1
                        fi
                    """

                    // Start build binário no OpenShift
                    sh "oc start-build ${APP_NAME} --from-dir=${WORKSPACE} --follow -n ${PROJECT}"
                }
            }
        }

        stage('Criar tag BUILD_NUMBER') {
            steps {
                script {
                    echo "Criando tag ${IMAGE_TAG} para a imagem buildada"
                    sh "oc tag ${PROJECT}/${APP_NAME}:latest ${PROJECT}/${APP_NAME}:${IMAGE_TAG} --alias"
                }
            }
        }

        stage('Atualizar Deployment para nova tag') {
            steps {
                script {
                    echo "Atualizando Deployment para tag ${IMAGE_TAG}"
                    sh """
                      oc set image deployment/${APP_NAME} \
                        ${APP_NAME}=image-registry.openshift-image-registry.svc:5000/${PROJECT}/${APP_NAME}:${IMAGE_TAG} \
                        -n ${PROJECT}
                    """
                }
            }
        }

        stage('Aguardar Rollout') {
            steps {
                script {
                    echo "Aguardando rollout do deployment"
                    sh "oc rollout status deployment/${APP_NAME} -n ${PROJECT}"
                }
            }
        }
    }

    post {
        success { echo "🚀 Deploy ${APP_NAME}:${IMAGE_TAG} concluído!" }
        failure { echo "❌ Falha no deploy ${APP_NAME}:${IMAGE_TAG}" }
    }
}
