node {
    stage('SCM Checkout'){
        git url: 'https://topgear-training-gitlab.wipro.com/CH20088451/DevOps_CapStone.git'
    }
 
     
    stage('MVN Package'){
        withMaven(maven: 'MAVEN_HOME',options:[pipelineGraphPublisher(disabled:true),junitPublisher(disabled:false),openTasksPublisher(disabled:true)]) {
            dir('BeverageStore'){
                try{
                    sh 'mvn clean package'
                    currentBuild.result ='Success'
                }
                catch (err) {
                    currentBuild.result ='Failure'
                }
            }
        }
    }

  stage('Post-Build'){
        if(currentBuild.result == 'SUCCESS') {
         stage('SonarQube Analysis'){
         dir('BeverageStore'){
            withSonarQubeEnv('scan') {
                def mvnHome = tool name: 'MAVEN_HOME', type:'maven'
                def mvnCMD = "${mvnHome}/bin/mvn"
                sh "${mvnCMD} org.sonarsource.scanner.maven:sonar-maven-plugin:3.6.0.1398:sonar " + '-f pom.xml'
                 }
        }
    }

    stage ('Artifactory Deploy'){
        def server = Artifactory.newServer url: 'http://localhost:5040/artifactory', username: 'devops', password: 'devops' 
        def buildInfo = Artifactory.newBuildInfo()
        buildInfo.env.capture = true
        buildInfo.env.collect()
        def uploadSpec = """{
            "files": [
             {
                "pattern": "**/target/*.pom",
                "target": "libs-snapshot-local"
            }, {
                "pattern": "**/target/*.war",
                "target": "libs-snapshot-local/$BUILD_NUMBER/"
                }
                , {
                "pattern": "**/target/*.war",
                "target": "libs-snapshot-local"
                }
        ]
      }"""
      
      server.upload spec: uploadSpec, buildInfo: buildInfo
      server.publishBuildInfo buildInfo
    }
    
        stage("Ansible Deploy"){
        sh 'docker build -t nkumarv/myjenkins:1.0.0 .'
        ansiblePlaybook installation: 'ansible 2.4.2.0', playbook: 'ansible_deploy.yml'
        sh 'docker stack deploy -c docker-compose.yml BeverageStore'
    }
    }
    else {
        echo "Build Failed"
    }
    }
}
