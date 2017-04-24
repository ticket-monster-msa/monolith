def appName="ticket-monster-full"
def project=""

node("maven") {
    stage 'checkout' 
    git url: 'https://github.com/christian-posta/ticket-monster.git', branch: 'monolith-master'

    stage 'build-war'
    dir('demo'){
        sh "mvn clean package -Pmysql-openshift"
        stash name:"build-context", includes:"target/openshift/**"
    }

    stage 'build-docker'
    unstash name:"build-context"
    sh "oc start-build ${appName} --from-dir=target/openshift --follow"
    
    stage 'deploy'
    openshiftDeploy deploymentConfig: appName 
}