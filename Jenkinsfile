pipeline {
    agent any

    environment {
        APP_NAME = 'supergateway-mcp'
        PROJECT  = 'mcp'
    }

    stages {

        stage('Build no OpenShift') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(PROJECT) {

                            echo "Disparando build binário do ${APP_NAME}"

                            openshift.startBuild(
                                APP_NAME,
                                "--from-dir=.",
                                "--follow"
                            )

                            echo "Build concluído com sucesso"
                        }
                    }
                }
            }
        }

        stage('Deploy (Rollout Restart)') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(PROJECT) {

                            echo "Forçando rollout do Deployment ${APP_NAME}"

                            sh """
                              oc rollout restart deployment/${APP_NAME} -n ${PROJECT}
                            """

                            echo "Aguardando rollout finalizar"

                            openshift
                                .selector('deployment', APP_NAME)
                                .rollout()
                                .status('--watch=true')
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🚀 Deploy do ${APP_NAME} realizado com sucesso"
        }
        failure {
            echo "❌ Pipeline falhou — verifique o BuildConfig ${APP_NAME}"
        }
    }
}
