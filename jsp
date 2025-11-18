pipeline {
	agent any
	// if it has many agents, any machine could be used specially when many jobs are executed
	// on choisit n'importe quel agent disponible

	tools {
		jdk 'Java-17'
		maven 'Maven-3.9'
	}

	// copier le code source dans un repo temporaire (workspace)
	// each job/pipeline has its workspace in jenkins

	stages {
		stage('Cloner le repo') {
			steps {
				git branch: 'main', url: 'https://github.com/00hiba00/DevOps-Project.git'
				// clone + checkout de la branch main
			}
		}

		stage('Compiler') {
			steps {
				bat 'mvn clean compile'
			}
		}



		stage('Tests unitaires') {
			steps {
				bat 'mvn test'
			}
			post {
				always {
					junit '**/target/surefire-reports/*.xml'
				}
			}
		}

		// ceci cree un fichier executable qui va etre utilisé pour Docker et le deploiement sur Kubernetes
		stage('Générer le package') {
			steps {
				bat 'mvn package'
			}
		}

		stage('SonarQube Analysis') {
			steps {
				withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_AUTH_TOKEN')]) {
					withSonarQubeEnv('sonar-server') {
						bat """
                      mvn sonar:sonar ^
                         -Dsonar.projectKey=bookstore ^
                         -Dsonar.host.url=http://localhost:9000 ^
                         -Dsonar.login=%SONAR_AUTH_TOKEN%
                   """
					}
				}
			}
		}
	}

	// le message s'affiche dans les logs, maert !!!
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

