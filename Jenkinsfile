#!/usr/bin/groovy
@Library('github.com/christian-posta/fabric8-pipeline-library@ceposta-profile')

def appName="ticketmonster-monolith"



mavenNode {
    checkout scm

    container(name: 'maven') {
        stage('Build Release'){
            mavenCanaryRelease {
                skipTests = true
                mavenProfiles = "openshift,mysql"
                useContentRepository = false
                runBayesianScanner = false
            }
            openshift.withCluster {
                openshift.selector("bc/${appName}").startBuild("--from-dir=target/openshift", "--follow")
            }
//            sh "oc start-build ${appName} --from-dir=./target/openshift --follow"
//            sh "mvn clean -e -U package -Pmysql,openshift -Dmaven.test.skip=true"
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