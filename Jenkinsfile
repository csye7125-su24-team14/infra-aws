pipeline {
    agent any
 
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
 
        stage('Validate Commit Messages') {
            steps {
                script {
                    def latestCommitMessage = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
 
                    if (!(latestCommitMessage =~ /^(fix|feat|chore|docs|style|refactor|test|perf|build|ci|revert|version|merge|hotfix|wip): .+/)) {
                        error "The commit message does not follow the Conventional Commit format:\n${latestCommitMessage}"
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform
                    sh 'terraform init'
                }
            }
        }
 
        stage('Terraform fmt') {
            steps {
                script {
                    def result = sh(script: 'terraform fmt -check -recursive', returnStatus: true)
                    if (result != 0) {
                        error "Terraform fmt failed: Some files are not properly formatted"
                    }
                }
            }
        }
 
        stage('Terraform Validate') {
            steps {
                script {
                    def result = sh(script: 'terraform validate', returnStatus: true)
                    if (result != 0) {
                        error "Terraform Validation failed"
                    }
                }
            }
        }
    }
 
    post {
        always {
            cleanWs()
        }
        success {
            echo 'All checks passed successfully'
        }
        failure {
            echo 'One or more checks failed'
        }
    }
}