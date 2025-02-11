Pipeline {
    agent {
        node {
            label agent1
        }
    }

Stages {

    Stage ('VPC')
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

    Stage ('SG')
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

    Stage ('VPN')
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

    Stage ('Database')
      {
        steps {
            sh  """
              cd 04-databases
              terrfom init
              terraform plan
              terraform apply -auto-approve
            """
        }
     }
     
    Stage ('appalb')
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
}