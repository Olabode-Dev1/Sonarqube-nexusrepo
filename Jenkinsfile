pipeline {
    agent any
    environment {
        MAVEN_OPTS = "--add-opens java.base/java.lang=ALL-UNNAMED"
    }
    
    stages {   
        stage('Build with Maven') {
            steps {
                sh 'cd SampleWebApp && mvn clean install'
            }
        }
        
        stage('Test') {
            steps {
                sh 'cd SampleWebApp && mvn test'
            }
        }
        
        stage('Code Quality Scan') {
            steps {
                withSonarQubeEnv('Sonar-password') {
                    sh 'mvn -f SampleWebApp/pom.xml sonar:sonar'
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: true
            }
        }
        
        stage('Push to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'SampleWebApp', classifier: '', file: 'SampleWebApp/target/SampleWebApp.war', type: 'war']], credentialsId: '', groupId: 'SampleWebApp', nexusUrl: '54.224.233.152:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: '1.0-SNAPSHOT'
            }
        }
        
        stage('Deploy to Tomcat') {
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat-passnew', path: '', url: 'http://54.224.233.152:80')], contextPath: 'myapp', war: '**/*.war'
            }
        }
    }
}
