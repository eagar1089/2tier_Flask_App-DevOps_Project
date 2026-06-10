pipeline{
    agent any
    stages{
        stage('Clone repo'){
            steps{
                echo 'Cloning repository'
                git branch: 'main', url: 'https://github.com/eagar1089/2tier_Flask_App-DevOps_Project.git'
            }
        }
        stage('Build image'){
            steps{
                echo 'Building Docker image'
                sh 'docker build -t flask-app .'
            }
        }
        stage('Deploy with docker compose'){
            steps{
                echo 'Deploying with Docker Compose'
                // existing container if they are running
                sh 'docker compose down || true'
                // start app, rebuilding flask image
                sh 'docker compose up -d --build'
            }
        }
    }
}