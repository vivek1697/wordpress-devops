// Pipeline 3 of 3 — global edge (CloudFront + WAF). Single stack.
// Run last; it reads Singapore's application state for the origin.
//
// Flow: plan -> review the plan in the log -> approve -> apply.
//
// Agent needs: terraform, awscli on PATH.
// Jenkins credentials (Secret text): aws-access-key-id, aws-secret-access-key
// Prerequisite: the application pipeline has been run for Singapore.
// Note: local state. Real CI must use the S3 backend so this stack can read the
// application state written by another pipeline — see versions.tf.

pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  parameters {
    string(name: 'BLOCKED_COUNTRY_CODES', defaultValue: '[]', description: 'Countries to geo-block, e.g. ["CN","RU"]; [] = allow all')
  }

  environment {
    PATH                  = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    AWS_DEFAULT_REGION    = 'us-east-1'
    AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    // Terraform reads TF_VAR_* automatically; this avoids shell-quoting a list.
    TF_VAR_blocked_country_codes = "${params.BLOCKED_COUNTRY_CODES}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Plan') {
      steps {
        dir('terraform/global') {
          sh 'terraform init -input=false'
          sh 'terraform plan -input=false -out=tfplan'
        }
      }
    }

    stage('Approval') {
      steps {
        input message: 'Review the CloudFront/WAF plan above. Apply?'
      }
    }

    stage('Apply') {
      steps {
        dir('terraform/global') {
          sh 'terraform apply -input=false tfplan'
        }
      }
    }
  }

  post {
    always {
      sh 'rm -f terraform/global/tfplan'
    }
  }
}
