pipeline {

    agent any
    parameters {
        choice(name: 'TERRAFORM_COMMAND', choices: 'Create\nDestroy', description: 'Specify whether Terraform should create, destroy, or configure the EKS cluster.')
        string(name: 'NAME_PREFIX',defaultValue: 'zenrooms', description: 'Name prefix for resources. Must be unique among all deployments')
        string(name: 'REGION', defaultValue: 'us-east-2', description: 'AWS Region.')
        string(name: 'MIN_CAPACITY', defaultValue: '1', description: 'Minimum numbers of nodes.')
        string(name: 'MAX_CAPACITY', defaultValue: '4', description: 'Maximum numbers of nodes.')
        string(name: 'DESIRED_CAPACITY', defaultValue: '2', description: 'Desired numbers of nodes.')
        string(name: 'NODE_VOLUME_SIZE', defaultValue: '100', description: 'Node volume size.')
        string(name: 'NODE_INSTANCE_TYPE', defaultValue: 't2.xlarge', description: 'Node instance type.')
    }

    environment {
        AWS_TIMEOUT_SECONDS             = 600
        TF_STATE_ENV                    = "${params.NAME_PREFIX}-eks-deployment"
        AWS_ACCESS_KEY                  = credentials("aws-access-key")
        AWS_SECRET_ACCESS_KEY           = credentials("aws-secret-access-key")
        TF_VAR_access_key               = credentials("aws-access-key")
        TF_VAR_secret_access_key        = credentials("aws-secret-access-key")
        TF_VAR_name_prefix              = "${params.NAME_PREFIX}"
        TF_VAR_region                   = "${params.REGION}"
        TF_VAR_min_capacity             = "${params.MIN_CAPACITY}"
        TF_VAR_max_capacity             = "${params.MAX_CAPACITY}"
        TF_VAR_desired_capacity         = "${params.DESIRED_CAPACITY}"
        TF_VAR_volume_size              = "${params.NODE_VOLUME_SIZE}"
        TF_VAR_instance_type            = "${params.NODE_INSTANCE_TYPE}"
    }

    options {
        ansiColor('xterm')
    }

    stages {

        stage('Validation') {
            steps {
                // Clean up Jenkins workspace
                sh "git clean -fdx"
            }
        }

        stage('Create EKS Cluster with dependencies') {
            when { expression { params.TERRAFORM_COMMAND == 'Create' } }
            steps {
                dir('.'){
                    withEnv(["PATH+TF=${tool 'terraform-0.11.8'}"]) {
                        sh 'if [ -e terraform.tfstate ] ; then rm terraform.tfstate; fi'
                        sh 'echo "Starting EKS creation"'
                        sh "terraform init -reconfigure -backend-config=\"workspace_key_prefix=${TF_STATE_ENV}\""
                        sh 'terraform workspace list'
                        sh "[ \$(terraform workspace list | grep -cw ${TF_STATE_ENV}) -lt 1 ] && terraform workspace new ${TF_STATE_ENV} || echo found Terraform environment ${TF_STATE_ENV}"
                        sh 'terraform workspace select ${TF_STATE_ENV}'
                        sh 'terraform show'
                        sh "terraform plan"
                        sh "terraform apply -auto-approve"
                        sh 'ls -l'
                        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker-reg-cred',
                                usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                            script {
                                def ekscluster  = sh(returnStdout:true, script: "terraform output -module=eks_cluster eks_cluster")
                                def eksnoderole = sh(returnStdout:true, script: "terraform output -module=eks_cluster eks_node_role")
                                def eksregion   = "${params.REGION}"
                                sh """
                                    #!/bin/bash
                                    dockerrepo="docker.io"
                                    dockeremail="email"

                                    aws-iam-authenticator init -i ${ekscluster}
                                    aws eks update-kubeconfig --name ${ekscluster} --r ${eksregion}

                                    kubectl delete secrets regcred || true
                                    docker login -u ${USERNAME} -p ${PASSWORD} docker.io
                                    kubectl create secret docker-registry regcred --docker-server=\$dockerrepo --docker-username=${USERNAME} --docker-password=${PASSWORD} --docker-email=\$dockeremail || true

                                    cd

                                    echo '
apiVersion: v1
kind: ConfigMap
metadata:
    name: aws-auth
    namespace: kube-system
data:
    mapRoles: |
    - rolearn: ${eksnoderole}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
        - system:bootstrappers
        - system:nodes' > aws-auth-cm.yaml

                                    kubectl apply -f aws-auth-cm.yaml
                                    kubectl --namespace kube-system create serviceaccount tiller || true
                                    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller || true
                                    /usr/local/bin/helm init --service-account tiller || true
                                    /usr/local/bin/helm init --upgrade --service-account tiller || true
                                    kubectl patch deployment tiller-deploy --namespace=kube-system --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]' || true
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Destroy EKS Cluster') {
            when { expression { params.TERRAFORM_COMMAND == 'Destroy' } }
            steps {
                dir('.'){
                    withEnv(["PATH+TF=${tool 'terraform-0.11.8'}"]) {
                        sh "terraform init -reconfigure -backend-config=\"workspace_key_prefix=${TF_STATE_ENV}\""
                        sh "terraform workspace list"
                        sh "terraform workspace select ${TF_STATE_ENV} || terraform workspace new ${TF_STATE_ENV}"
                        sh 'terraform show'
                        sh "terraform plan --destroy"
                        sh "terraform destroy -force"
                        sh "terraform workspace select default"
                        sh "terraform workspace delete ${TF_STATE_ENV}"
                    }
                }
            }
        }
    }
}
