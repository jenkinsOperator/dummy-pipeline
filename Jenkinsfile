
#!/usr/bin/env groovy

def label = "k8sagent-e2e"
def home = "/home/jenkins"
def workspace = "${home}/workspace/build-jenkins-operator"
def workdir = "${workspace}/src/github.com/jenkinsci/kubernetes-operator/"

podTemplate(label: label,
        containers: [
                containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest', ttyEnabled: true, command: 'cat'),
        ],
        ) {
    node(label) {
        stage('Run shell') {
            container('jnlp') {
                sh 'echo "hello world"'
            }
        }
    }
}
