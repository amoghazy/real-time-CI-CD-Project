pipeline {
    agent any
    tools {
    
        maven 'maven3'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('Checkout the Project') {
            steps {
                // when use SCM to clone the code from git repo not need to use git command
                // git branch: 'main', credentialsId: 'git-cred', url: '<code_repo_url>'

            }
        }
        stage('Compile the Source Code') {
            steps {
                sh "mvn compile"
            }
        }
        stage('Test unit test cases') {
            steps {
                sh "mvn test"
            }
        }
         stage('Vulnerability Scan by trivy') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report-dependencies.html ."
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
               sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=techgame -Dsonar.projectKey=techgame \
               -Dsonar.java.binaries=. '''
               }
            }
        }
        // need here webhook in sonar server to get the status of the pipeline
            stage('WaitforQualityGate') {
            steps {
             script {
                 waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
             }
               }
            }
               stage('Build the package') {
            steps {
                sh "mvn package"
             }
               }
                 stage ('Build & tag the Docker Image') {
                     steps {
                         script {
                             withDockerRegistry(credentialsId: 'dock-cred', toolName: 'docker') {
                               sh "docker build -t amoghazy/techgame:latest ."
                            }
                         }
                     }
                 }
                 stage('Docker Image Scanning by trivy') {
                   steps {
                    sh "trivy image --format table -o trivy-image-report.html amoghazy/techgame"
                }
               }
               stage ('Push the Docker Image to Docker Hub') {
                     steps {
                         script {
                             withDockerRegistry(credentialsId: 'dock-cred', toolName: 'docker') {
                               sh "docker push amoghazy/techgame:latest"
                            }
                         }
                     }
                 }
                 stage ('Deploy the Docker Image to k8s Cluster') {
                     steps {
                     withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8s-cred', namespace: 'java-app', restrictKubeConfigAccess: false, serverUrl: '<endpoint>') {
                     sh 'kubectl apply -f deployment-service.yaml'
                    }
                 }
             }
              stage ('Verify the Resources like POD, SVC on k8s cluster') {
                     steps {
                     withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8s-cred', namespace: 'java-app', restrictKubeConfigAccess: false, serverUrl: '<endpoint>') {
                     sh 'kubectl get pods -n java-app'
                     sh 'kubectl get svc -n java-app'
                    }
                 }
             }
           }
}