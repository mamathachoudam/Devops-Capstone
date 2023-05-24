FROM tomcat:8
ADD http://localhost:5040/artifactory/libs-snapshot-local/BeverageStore.war /usr/local/tomcat/webapps/
EXPOSE 8080