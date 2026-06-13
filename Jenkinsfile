pipeline {
    agent any
    
    environment {
        APP_NAME = 'flask-app'
        COMPOSE_FILE = 'docker-compose.yml'
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository from GitHub'
                deleteDir()
                git branch: 'main', 
                    url: 'https://github.com/eagar1089/2tier_Flask_App-DevOps_Project.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image'
                script {
                    sh "docker rmi ${APP_NAME}:latest || true"
                    sh "docker build -t ${APP_NAME}:latest ."
                }
            }
        }
        
        stage('Deploy with Docker Compose') {
            steps {
                echo 'Deploying with Docker Compose'
                script {
                    sh "docker compose -f ${COMPOSE_FILE} down || true"
                    
                    sh "docker compose -f ${COMPOSE_FILE} up -d --build"
                    
                    echo 'Waiting for services to start...'
                    sh 'sleep 10'
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Verifying application health'
                script {
                    def containerStatus = sh(script: "docker ps --filter name=two-tier-app --format '{{.Status}}'", returnStdout: true).trim()
                    echo "Container status: ${containerStatus}"
                    
                    def maxRetries = 30
                    def healthy = false
                    
                    for (int i = 1; i <= maxRetries; i++) {
                        try {
                            def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:5000/health", returnStdout: true).trim()
                            echo "Health check attempt ${i}/${maxRetries}: HTTP ${response}"
                            
                            if (response == '200') {
                                healthy = true
                                echo "Health check passed!"
                                break
                            }
                        } catch (Exception e) {
                            echo "Health check attempt ${i}/${maxRetries} failed: ${e.getMessage()}"
                        }
                        sleep 2
                    }
                    
                    if (!healthy) {
                        error "Health check failed after ${maxRetries} attempts"
                    }
                }
            }
        }
        
        stage('Verify Test Endpoint') {
            steps {
                echo 'Verifying test endpoint (MongoDB integration)'
                script {
                    def testResponse = sh(script: "curl -s http://localhost:5000/health", returnStdout: true).trim()
                    echo "Test endpoint response: ${testResponse}"
                }
            }
        }
    }
    
    post {
        success {
            echo '''
            ========================================
            DEPLOYMENT SUCCESSFUL!
            ========================================
            Application is running at: http://localhost:5000
            Test endpoint: http://localhost:5000/test/
            Health check: http://localhost:5000/health
            ========================================
            '''
            
            mail to: 'sgrp9801@gmail.com',
                 subject: "Deployment Successful: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                 body: "New version deployed successfully."
        }
        failure {
            echo '''
            ========================================
            DEPLOYMENT FAILED!
            ========================================
            Check Jenkins console output for details.
            Rollback may be required.
            ========================================
            '''
            
            script {
                echo "Dumping container logs:"
                sh "docker logs two-tier-app --tail 50 || echo 'No logs available'"
                sh "docker logs mongodb --tail 20 || echo 'No logs available'"
            }

            mail to: 'sgrp9801@gmail.com',
                 subject: "Deployment Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                 body: "Build failed. Check Jenkins for details."
        }
        always {
            echo 'Cleaning up old Docker images...'
            script {
                sh "docker image prune -f"
            }
        }
    }
}