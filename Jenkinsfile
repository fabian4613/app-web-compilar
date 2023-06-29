pipeline {
    agent any

    environment {
        // Definimos las variables de entorno necesarias en español
        LC_ALL = 'es_ES.UTF-8'
        LANG = 'es_ES.UTF-8'
    }

    stages {
        stage('Clone App Repo') {
            steps {
                echo 'Clonando el repositorio de la aplicación...'
                git 'https://github.com/fabian4613/app-web-compilar.git'
            }
        }
        stage('Build WAR') {
            steps {
                echo 'Compilando los archivos WAR...'
                sh 'mvn clean install'
            }
        }
        stage('Backup WAR') {
            steps {
                echo 'Creando el backup del archivo WAR...'
                sh "mkdir -p backup/\$(date +%Y%m%d%H%M%S)"
                sh "cp target/*.war backup/\$(date +%Y%m%d%H%M%S)"
            }
        }
        stage('Push Backup to GitHub') {
            steps {
                echo 'Subiendo el backup al repositorio en GitHub...'
                git credentialsId: 'github-credentials', url: 'https://github.com/fabian4613/backup-Wars.git'
                sh "cp backup/* ."
                sh 'git add .'
                sh "git commit -m 'Backup - \$(date)'"
                sh 'git push'
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Construyendo la imagen de Docker...'
                sh 'docker build -t myapp .'
            }
        }
        stage('Push Docker Image to Docker Hub') {
            steps {
                echo 'Subiendo la imagen de Docker a Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh 'docker login -u $DOCKERHUB_USER -p $DOCKERHUB_PASS'
                    sh 'docker tag myapp:latest $DOCKERHUB_USER/myapp:latest'
                    sh 'docker push $DOCKERHUB_USER/myapp:latest'
                }
            }
        }
    }
}
