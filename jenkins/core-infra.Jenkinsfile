// Pipeline 1 of 3 — network layer (VPC, subnets, NAT) for both regions.
// Run this first; the application pipeline reads its state.
//
// Flow per region: plan -> review the plan in the log -> approve -> apply.
// The two regions are independent, so order between them doesn't matter.
//
// Agent needs: terraform, awscli on PATH.
// Jenkins credentials (Secret text): aws-access-key-id, aws-secret-access-key
// Note: local state via -state. Real CI must use the S3 backend so state is
// shared across pipelines — see the commented block in versions.tf.

pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  environment {
    PATH                  = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    AWS_DEFAULT_REGION    = 'ap-southeast-1'
    AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Plan Singapore') {
      steps {
        dir('terraform/core-infra') {
          sh 'terraform init -input=false'
          sh '''
            terraform plan -input=false \
              -var-file=env/singapore.tfvars \
              -state=terraform.singapore.tfstate \
              -out=tfplan.singapore
          '''
        }
      }
    }

    stage('Approval Singapore') {
      steps {
        input message: 'Review the Singapore plan above. Apply?'
      }
    }

    stage('Apply Singapore') {
      steps {
        dir('terraform/core-infra') {
          sh 'terraform apply -input=false -state=terraform.singapore.tfstate tfplan.singapore'
        }
      }
    }

    stage('Plan Ireland') {
      steps {
        dir('terraform/core-infra') {
          sh '''
            terraform plan -input=false \
              -var-file=env/ireland.tfvars \
              -state=terraform.ireland.tfstate \
              -out=tfplan.ireland
          '''
        }
      }
    }

    stage('Approval Ireland') {
      steps {
        input message: 'Review the Ireland plan above. Apply?'
      }
    }

    stage('Apply Ireland') {
      steps {
        dir('terraform/core-infra') {
          sh 'terraform apply -input=false -state=terraform.ireland.tfstate tfplan.ireland'
        }
      }
    }
  }

  post {
    always {
      sh 'rm -f terraform/core-infra/tfplan.singapore terraform/core-infra/tfplan.ireland'
    }
  }
}
