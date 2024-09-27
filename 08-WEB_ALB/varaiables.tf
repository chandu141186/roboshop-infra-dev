variable "zone_name" {
  default = "chandulearn.online"

}
 variable "environment" {
   default = "dev"
   
 }

 variable "project_name" {
   
   default = "roboshop"
 }

 variable "tags" {

  default = {
    Component = "web-alb"
  }
   
 }
 
 variable "common_tags" {
  default = {
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = "true"
  }
}