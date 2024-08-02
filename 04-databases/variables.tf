variable "common_tags" {
    default = { 
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = "true"
  }
  
}

variable "zone_name" {
  default = "chandulearn.online"

}

variable "project_name" {
    default = "roboshop"
  
}

variable "environment" {
  default = "dev"
}