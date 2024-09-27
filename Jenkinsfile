pipeline {
    agent {
        node {
            label agent1
        }
    }
       environment { 
        CC = 'clang'   
       }
         options {
        timeout(time: 1, unit: 'HOURS') 
    }
    


stage ('VPC')
{
        steps {
          sh  """
              cd 01-vpc
              terrfom init
              terraform plan
              terraform apply -auto-approve
            """
        }
    }

stage ('SG')
{
        steps {
            sh """
              cd 02-Sg
              terrfom init
              terraform plan
              terraform apply -auto-approve
            """
        }
    }

stage ('VPN')
{
        steps {
           sh """
              cd 03-vpn
              terrfom init
              terraform plan
              terraform apply -auto-approve
            """
        }
    }

stage ('Database')
{
        steps {
          sh  """
              cd 04-databses
              terrfom init
              terraform plan
              terraform apply -auto-approve
            """
        }
    }
     
           stage ('appalb')
                 {
       
                steps {
           sh"""
               cd 05-app_alb
               terrfom init
               terraform plan
               terraform apply -auto-approve
                """
        }
    }
}