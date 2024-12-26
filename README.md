
# Real-Time CI/CD Project

This project demonstrates the implementation of a **Real-Time CI/CD Pipeline** for a **Java application**. The infrastructure is provisioned using **Terraform**, and the application is deployed on a **Kubernetes cluster** created with **kubeadm**. The CI/CD pipeline is managed by **Jenkins**, with **SonarQube** for static code analysis and **Prometheus** + **Grafana** for monitoring.

## Features

- **CI/CD Automation**: Automatically build, test, and deploy the Java application using Jenkins.
- **Infrastructure as Code (IaC)**: Terraform scripts to provision the Kubernetes cluster, Jenkins, and SonarQube servers.
- **Docker Integration**: Build and push Docker images for the application.
- **Kubernetes Deployment**: Deploy the Java application in a Kubernetes cluster.
- **Monitoring**: Real-time monitoring of the Kubernetes cluster and application using Prometheus and Grafana.
- **Static Code Analysis**: SonarQube is integrated into the pipeline to scan for code quality and security issues.

## Technologies Used

- **Java**: The application is developed using Java.
- **Terraform**: Used to provision the infrastructure (Kubernetes, Jenkins, SonarQube, monitoring).
- **Docker**: For containerizing the Java application.
- **Kubernetes**: Orchestrates the deployment and scaling of containers.
- **Jenkins**: Automates the CI/CD pipeline.
- **SonarQube**: Static code analysis for quality and security checks.
- **Prometheus**: Monitors and collects metrics from the application and Kubernetes cluster.
- **Grafana**: Visualizes the metrics collected by Prometheus.
- **Maven**: Build tool for Java projects.
- **Kubeadm**: Tool for setting up Kubernetes clusters.

## Setup and Installation

### Prerequisites

Before you begin, ensure that the following tools are installed on your system:

- **Terraform**: For provisioning infrastructure.
- **Docker**: For building and running containers.
- **kubectl**: Kubernetes command-line tool.
- **Kubeadm**: For setting up the Kubernetes cluster.
- **Jenkins**: To automate the CI/CD pipeline.
- **SonarQube**: For static code analysis.
- **Prometheus & Grafana**: For monitoring and visualization.

### 1. Clone the Repository

```bash
git clone https://github.com/amoghazy/real-time-CI-CD-Project.git
cd real-time-CI-CD-Project
```

### 2. Provision Infrastructure with Terraform

Terraform is used to create the necessary infrastructure, including the Kubernetes cluster and servers for Jenkins and SonarQbe.

1. **Initialize Terraform**:

    ```bash
    terraform init
    ```

2. **Apply Terraform Configuration** to provision infrastructure:

    ```bash
    terraform apply
    ```

   This will set up:
   - A **Kubernetes cluster**.
   - **Jenkins** for automating the CI/CD pipeline.
   - **SonarQube** for static code analysis.
   - **Prometheus** and **Grafana** for monitoring.

### 3. Jenkins Setup

After provisioning the infrastructure, configure Jenkins to automate the following tasks:

1. **Install Jenkins Plugins**:
   - Docker 
   - Docker Pipeline
   - Kubernetes
   - Kubernetes cli
   - Kubernetes credentials
   - Kubernetes client api
   - SonarQube Scanner
   - Git
   - Pipeline Maven
   - Config File Provider
   - Prometheus 
    
     

  

2. **Configure Jenkins Pipeline**:
   Create a Jenkinsfile for automating the build, test, and deploy process.

#### Example Jenkinsfile

```groovy
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'your_docker_image'
        DOCKER_REGISTRY = 'your_registry'
        KUBE_NAMESPACE = 'your_namespace'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    sh 'mvn clean install'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                }
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_REGISTRY/$DOCKER_IMAGE .'
                    sh 'docker push $DOCKER_REGISTRY/$DOCKER_IMAGE'
                }
            }
        }
        stage('Kubernetes Deploy') {
            steps {
                script {
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
```



### 4. Monitoring Setup with Prometheus and Grafana

- **Prometheus** will collect metrics from your Kubernetes cluster and application .
- **Grafana** will visualize the metrics collected by Prometheus.

Once Prometheus and Grafana are set up, access the Grafana dashboard to monitor the health of your Kubernetes cluster and application.


## Contributing

Feel free to fork this repository, open issues, or submit pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.