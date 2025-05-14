pipeline {
  agent any

  stages {
    stage('Clone Repository') {
      steps {
        git 'https://github.com/newdelthis/end_to_end.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t devops-app .' 
      }
    }

    stage('Run Docker Container') {
      steps {
        sh 'docker rm -f devops-app || true'
        sh 'docker run -d -p 5000:5000 --name devops-app devops-app'
      }
    }
  }
}
