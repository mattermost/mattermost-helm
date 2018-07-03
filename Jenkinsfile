#!/usr/bin/env groovy

def gitCommit

pipeline {
    agent { label 'default-slave' }

    options {
        timeout(time:30, unit:'MINUTES')
        buildDiscarder(logRotator(numToKeepStr:'3'))
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                }
            }
        }

        stage('Check Style') {
            steps {
                dir('mattermost-helm') {
                    sh 'helm lint .'
                }
            }
        }

        stage('Deploy MM Helm Chart') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-mm-test-helm', variable: 'config')]) {
                    dir('mattermost-helm') {
                        sh '''#/bin/bash
                        set -ex

                        export KUBECONFIG=${config}

                        helm init --client-only
                        helm repo add mattermost-mysql https://releases.mattermost.com/helm/mysqlha
                        helm repo update
                        helm dependency update

                        BRANCH=`echo "${BRANCH_NAME}" | sed -e "s/\\(.*\\)/\\L\\1/"`

                        kubectl create ns \${BRANCH}-${BUILD_NUMBER}

                        helm install -n \${BRANCH}-${BUILD_NUMBER} \
                            --namespace \${BRANCH}-${BUILD_NUMBER} \
                            --set mattermost-app.image.tag=5.0.0 \
                            --set global.siteUrl="http://\${BRANCH}-${BUILD_NUMBER}.azure.k8s.mattermost.com" \
                            --set tls.enabled=false \
                            --set mattermost-app.replicaCount=1 \
                            --set mysqlha.mysqlha.replicaCount=1 \
                            --set minio.persistence.enabled=false \
                            --wait .

                        STATUS=\$(kubectl get pods --field-selector=status.phase!=Running -n \${BRANCH}-${BUILD_NUMBER})
                        while [ "\$STATUS" != "" ]; do
                          echo "Waiting to pods come up."
                          echo "$STATUS"
                          echo "------"
                          sleep 5
                          STATUS=\$(kubectl get pods --field-selector=status.phase!=Running -n \${BRANCH}-${BUILD_NUMBER})
                        done

                        kubectl get pods -n \${BRANCH}-${BUILD_NUMBER}

                        STATUS="NotReady"
                        JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'
                        while [ "\$STATUS" != "" ]; do
                          echo "Waiting to pods in Ready status."
                          echo "\$STATUS"
                          echo "------"
                          sleep 5
                          STATUS=\$(kubectl get pods -n \${BRANCH}-${BUILD_NUMBER} -o jsonpath="\$JSONPATH" | grep "Ready=False" || echo "")
                        done

                        kubectl get pods -n \${BRANCH}-${BUILD_NUMBER}

                        helm test \${BRANCH}-${BUILD_NUMBER} --cleanup
                        '''
                    }
                }
            }
        }
    }
    post {
        always {
            withCredentials([file(credentialsId: 'kubeconfig-mm-test-helm', variable: 'config')]) {
                dir('mattermost-helm') {
                    sh '''#/bin/bash
                    set -ex

                    export KUBECONFIG=${config}

                    BRANCH=`echo "${BRANCH_NAME}" | sed -e "s/\\(.*\\)/\\L\\1/"`

                    helm init --client-only

                    helm del --purge \${BRANCH}-${BUILD_NUMBER}

                    kubectl delete ns \${BRANCH}-${BUILD_NUMBER}
                    '''
                }
            }
        }
    }
}