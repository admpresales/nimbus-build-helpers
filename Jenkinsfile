pipeline {
    agent any

    environment {
        IMAGE = "admpresales/nimbus-build-helpers"
    }

    parameters {
        booleanParam(
            name: 'PUSH',
            defaultValue: true,
            description: 'Push image to Docker Hub'
        )

        booleanParam(
            name: 'NO_CACHE',
            defaultValue: false,
            description: 'Disable caching'
        )

        string(
            name: 'TAG',
            defaultValue: 'latest',
            description: 'Set the tag name to be built and pushed'
        )
    }

    stages {
        stage('Notify Start') {
            steps {
                script {
                    slackSend(
                        channel: 'nimbus',
                        message: "${env.JOB_NAME} - ${currentBuild.displayName} ${currentBuild.buildCauses[0].shortDescription} (<${env.JOB_URL}|Open>)",
                        color: (currentBuild.previousBuild?.result == 'SUCCESS') ? 'good' : 'danger'
                    )
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: '840e6510-16af-4402-9095-a92f40ff4099', passwordVariable: 'HUB_PASS', usernameVariable: 'HUB_USER')]) {
                    sh 'docker login --username "$HUB_USER" --password-stdin <<< $HUB_PASS'
                }

                sh "docker build . -t ${IMAGE}:${params.TAG} --network demo-net --no-cache=${params.NO_CACHE}"
            }
        }

        stage('Push') {
            when {
                expression { params.PUSH }
            }
            steps {
                script {
                    currentBuild.displayName += " ${params.TAG}"
                }
                sh "docker push ${IMAGE}:${params.TAG}"
            }
        }
    }
    post {
        always {
            slackSend(
                channel: 'nimbus',
                message: "${env.JOB_NAME} - ${currentBuild.displayName} *${currentBuild.currentResult}* in ${currentBuild.durationString.replaceAll(' and counting', '')}" + ((currentBuild.currentResult != 'SUCCESS') ? " (<${env.BUILD_URL}console|Console>)" : ''),
                color: (currentBuild.currentResult == 'SUCCESS') ? 'good' : 'danger'
            )
        }
    }
}

