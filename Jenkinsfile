#!/usr/bin/groovy
@library('github.com/fabric8io/fabric8-pipeline-library@d436410')
def appName="ticketmonster"
def project=""


mavenNode {
    checkout "http://gogs-cicd.192.168.64.2.nip.io/gogsadmin/ticketmonster-monolith"

    container(name: 'maven') {
        stage('Build Release'){
            sh "mvn clean package -Pmysql-openshift"
        }
    }
}



//
//node("maven") {
//    stage 'checkout'
//    git url: 'https://github.com/christian-posta/ticket-monster.git', branch: 'monolith-master'
//
//    stage 'build-war'
//    dir('demo'){
//        sh "mvn clean package -Pmysql-openshift"
//        stash name:"build-context", includes:"target/openshift/**"
//    }
//
//    stage 'build-docker'
//    unstash name:"build-context"
//    sh "oc start-build ${appName} --from-dir=target/openshift --follow"
//
//    stage 'deploy'
//    openshiftDeploy deploymentConfig: appName
//}