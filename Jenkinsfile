#!/usr/bin/env groovy

def gitCommit
node('default-slave') {
    stage('Checkout') {
        checkout scm
        gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
    }
    stage('Check Style') {
        dir('mattermost-helm') {
            sh 'helm lint'
            sh 'helm inspect .'
        }
    }
}
