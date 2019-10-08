// Jenkinsfile

pipeline {
  agent {
    kubernetes {
      // this label will be the prefix of the generated pod's name
      label 'jenkins-agent-my-app'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: ci
spec:
  serviceAccountName: jenkins
  containers:
    - name: docker
      image: docker
      command:
        - cat
      tty: true
      volumeMounts:
        - mountPath: /var/run/docker.sock
          name: docker-sock
    - name: kubectl
      image: lachlanevenson/k8s-kubectl:v1.15.4
      command:
        - cat
      tty: true
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
"""
    }
  }

  stages {
    
    stage('Build image') {
      steps {
        container('docker') {
            sh "docker build -t tfrm2019/front-end:latest ./front-end"
        }
      }
    }
    
   stage('Run tests') {
      steps {
         container('docker') {
            sh "echo 'Here be tests...'"
         }
      }
    }
    
   stage('Push image') {
      steps {
        container('docker') {
          withDockerRegistry([ credentialsId: "dockerhub", url: "" ]) {
            sh "docker push tfrm2019/front-end:latest"
          }
        }
      }
    }
    
    
    stage('Deploy to test env') {
      steps {
        container('kubectl') {
          sh "kubectl delete -f ./deploy/kubernetes/complete-demo-latest.yaml || true"
          sh "kubectl apply -f ./deploy/kubernetes/complete-demo-latest.yaml"
        }
      }
    }
    
    
    
    

  }
}
