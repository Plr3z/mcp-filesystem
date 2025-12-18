pipeline {
    agent any

    environment {
        NAMESPACE = 'mcp'
        APP_NAME  = 'supergateway-s3'
        // Usamos o número do build do Jenkins como tag da imagem
        IMAGE_TAG = "${BUILD_NUMBER}"
        ROUTE_HOST = "filesystem.apps.prd.meuapp.ai"
    }

    stages {
        stage('Prepare') {
            steps {
                script {
                    sh "oc project ${NAMESPACE}"
                }
            }
        }

        stage('Build Image') {
            steps {
                echo "Iniciando Build com a tag: ${IMAGE_TAG}"
                script {
                    // 1. Inicia o build enviando o código local
                    // 2. Após o build, tagueia a imagem no ImageStream com o número do build
                    sh "oc start-build ${APP_NAME}-build --from-dir=. --follow --wait"
                    sh "oc tag ${APP_NAME}:latest ${APP_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy & Route') {
            steps {
                echo "Atualizando Deployment e Garantindo a Route..."
                script {
                    // Atualiza o Deployment para usar a nova tag específica deste build
                    sh "oc set image deployment/${APP_NAME} gateway=${APP_NAME}:${IMAGE_TAG}"
                    
                    // Verifica se a Route já existe; se não, cria.
                    // O '|| true' evita que a pipeline quebre se a rota já existir
                    sh """
                        oc get route ${APP_NAME}-route || \
                        oc create route edge ${APP_NAME}-route --service=${APP_NAME}-service --hostname=${ROUTE_HOST}
                    """

                    // Aplica as anotações necessárias para o SSE funcionar bem no HAProxy
                    sh "oc annotate route ${APP_NAME}-route --overwrite haproxy.router.openshift.io/timeout=60s"
                    sh "oc annotate route ${APP_NAME}-route --overwrite haproxy.router.openshift.io/disable_proxy_headers=true"

                    // Aguarda o rollout completar
                    sh "oc rollout status deployment/${APP_NAME} --timeout=5m"
                }
            }
        }
    }

    post {
        success {
            echo "--------------------------------------------------------"
            echo "DEPLOY SUCESSO! Build: ${IMAGE_TAG}"
            echo "URL: https://${ROUTE_HOST}/sse"
            echo "--------------------------------------------------------"
        }
    }
}
