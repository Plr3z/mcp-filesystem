pipeline {
    agent any

    environment {
        // Nome dos recursos (Deployment, Service, BuildConfig)
        APP_NAME = 'supergateway-mcp' 
        // Nome do projeto onde todos os recursos estão (o novo namespace)
        PROJECT  = 'mcp' 
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Preparando código-fonte do ${APP_NAME}"
                // Garante que o Dockerfile e o código estejam no workspace
                checkout scm 
            }
        }

        stage('Build Image no OpenShift') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(PROJECT) {
                            
                            echo "Disparando build binário do ${APP_NAME} no projeto ${PROJECT}"

                            // 1. Inicia o Build Binário (oc start-build)
                            // Envia o conteúdo do workspace (incluindo o Dockerfile) para o BuildConfig
                            openshift.startBuild(
                                APP_NAME,
                                "--from-dir=.",
                                "--follow" // Aguarda a conclusão do build
                            )
                            
                            echo "Build finalizado. Imagem 'supergateway-mcp:latest' atualizada."
                        }
                    }
                }
            }
        }

        stage('Deploy Rollout') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(PROJECT) {

                            // 2. CORREÇÃO PRINCIPAL: Usa 'oc rollout restart'
                            // Força o Deployment a puxar a nova imagem 'latest' que o build criou.
                            sh "oc rollout restart deployment/${APP_NAME} -n ${PROJECT}"
                            
                            echo "Rollout iniciado. Aguardando o novo Pod ficar 'Ready' (Porta 3001 e S3FS montado)..."

                            // 3. Aguarda o Deployment concluir (status)
                            // A conclusão depende da imagem ser puxada, da aplicação rodar,
                            // E da montagem do S3FS (se estiver rodando no ENTRYPOINT) ser rápida.
                            openshift.selector('deployment', APP_NAME).rollout().status('--watch=true')
                            
                            echo "Deployment do Supergateway concluído com sucesso!"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline do Supergateway executado com sucesso 🚀"
        }
        failure {
            echo "Pipeline FALHOU! Verifique o log do BuildConfig ${APP_NAME} no projeto ${PROJECT}"
        }
    }
}