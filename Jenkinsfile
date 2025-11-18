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
			//
		}

		// ceci cree un fichier executable qui va etre utilisé pour Docker et le deploiement sur Kubernetes
		stage('Générer le package') {
			steps {
				bat 'mvn package'
			}
		}
		// le package dans $JENKINS_HOME/workspace/<NOM_DU_JOB>/target/

		//stage('SonarQube Analysis') {
		//	environment {
		//		scannerHome = tool 'sonar-scanner'  // li kayna f tools
		//	}
		//	steps {
		//		withSonarQubeEnv('sonar-server') {  // li kayn f Systems
		//			bat "mvn sonar:sonar -Dsonar.projectKey=bookstore -Dsonar.host.url=http://localhost:9000 -Dsonar.login=${sonar-token}"
		//		}
		//	}
		//}

		stage('SonarQube Analysis') {
			environment {
				scannerHome = tool 'sonar-scanner'
			}
			steps {
				withSonarQubeEnv('sonar-server') {
					withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
						bat "mvn sonar:sonar -Dsonar.projectKey=bookstore -Dsonar.host.url=http://localhost:9000 -Dsonar.login=%SONAR_TOKEN%"
					}
				}
			}
		}


	}

	// le message s'affiche dans les logs
	post {
		always {
			echo 'Pipeline terminé.'
		}
	}
}