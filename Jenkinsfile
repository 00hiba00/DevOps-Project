pipeline {
	agent any

	tools {
		jdk 'Java-17'
		maven 'Maven-3.9'
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
	}

	post {
		always {
			echo 'Pipeline terminé.'
		}
		success {
			echo 'Build réussi!'
		}
		failure {
			echo 'Build échoué.'
		}
	}
}