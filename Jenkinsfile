pipeline {
	agent any

	tools {
		jdk 'Java-17'
		maven 'Maven-3.9'
	}

	environment {
		DOCKER_HOST = 'tcp://localhost:2375'
		DOCKER_IMAGE = 'bookstore-app'
		DOCKER_TAG = "${BUILD_NUMBER}"
		//DOCKER_REGISTRY = 'docker.io'  // Changez si vous utilisez un autre registry
		//DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'  // ID des credentials Docker Hub dans Jenkins
		DOCKER_USER = 'alaelmh'
		//KUBECONFIG_CREDENTIALS_ID = 'kubeconfig'  // ID du fichier kubeconfig dans Jenkins

	}


	stages {
		stage('Cloner le repo') {
			steps {
				git branch: 'main', url: 'https://github.com/00hiba00/DevOps-Project.git'
			}
		}

		stage('Compiler') {
			steps {
				bat 'mvn clean compile'
			}
		}

		stage('Tests unitaires') {
			steps {
				bat 'mvn clean test jacoco:report'
			}
			post {
				always {
					junit '**/target/surefire-reports/*.xml'
				}
			}
		}

		stage('Générer le package') {
			steps {
				bat 'mvn package -DskipTests'
			}
		}

		stage('SonarQube Analysis') {
			steps {
				script {
					withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_AUTH_TOKEN')]) {
						withSonarQubeEnv('sonar-server') {
							bat """
                         mvn sonar:sonar -Dsonar.projectKey=bookstore -Dsonar.host.url=http://localhost:9000 -Dsonar.login=%SONAR_AUTH_TOKEN%
                      """
						}
					}
				}
			}
		}

		stage('Build Docker Image') {
			steps {
				script {
					echo 'Construction de l\'image Docker...'
					bat """
                   docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                   docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                """
				}
			}
		}
		stage('Push to Docker Hub') {
			steps {
				script {
					echo 'Push vers Docker Hub...'
					withCredentials([usernamePassword(
						credentialsId: 'dockerhub-credentials',
						usernameVariable: 'DOCKER_USERNAME',
						passwordVariable: 'DOCKER_PASSWORD')]) {
						bat """
                      docker login -u %DOCKER_USERNAME% -p %DOCKER_PASSWORD%
                      docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}
                      docker tag ${DOCKER_IMAGE}:latest ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                      docker push ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}
                      docker push ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                   """
					}
				}
			}
		}
		stage('Deploy to Kubernetes') {
			steps {
				script {
					echo 'Déploiement sur Kubernetes...'
					bat """
                   kubectl apply -f k8s/secrets.yaml
                   kubectl apply -f k8s/pvc.yaml
                   kubectl apply -f k8s/deployment.yaml
                   kubectl apply -f k8s/service.yaml
                   kubectl apply -f k8s/ingress.yaml
                """
				}
			}
		}

		stage('Verify Deployment') {
			steps {
				script {
					echo 'Vérification du déploiement...'
					bat """
                   kubectl get pods -l app=bookstore
                   kubectl get services
                   kubectl rollout status deployment/bookstore-app --timeout=5m
                """
				}
			}
		}
	}

	post {
		always {
			echo 'Pipeline terminé.'
			bat """
             docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || exit 0
          """
		}
		success {
			echo 'Build et déploiement réussis!'
		}
		failure {
			echo 'Build ou déploiement échoué.'
		}
	}
}