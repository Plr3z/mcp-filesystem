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
                    openshift.withCluster() {
                        openshift.withProject(PROJECT) {
                            echo "Build da imagem ${APP_NAME}:latest"
                            openshift.startBuild(
                                APP_NAME,
                                "--from-dir=.",
                                "--follow"
                            )
                        }
                    }
                }
            }
        }

        stage('Tag da imagem com BUILD_NUMBER') {
            steps {
                script {
                    echo "Criando tag ${IMAGE_TAG} para a imagem buildada"
                    sh "oc tag mcp/${APP_NAME}:latest mcp/${APP_NAME}:${IMAGE_TAG} --alias"
                }
            }
        }

        stage('Atualizar Deployment para nova tag') {
            steps {
                script {
                    echo "Atualizando Deployment para tag ${IMAGE_TAG}"
                    sh "oc set image deployment/${APP_NAME} ${APP_NAME}=image-registry.openshift-image-registry.svc:5000/${PROJECT}/${APP_NAME}:${IMAGE_TAG} -n ${PROJECT}"
                }
            }
        }

        stage('Aguardar Rollout') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(PROJECT) {
                            openshift.selector('deployment', APP_NAME).rollout().status('--watch=true')
                        }
                    }
                }
            }
        }
    }

    post {
        success { echo "🚀 Deploy ${APP_NAME}:${IMAGE_TAG} realizado com sucesso" }
        failure { echo "❌ Falha no deploy da tag ${IMAGE_TAG}" }
    }
}
