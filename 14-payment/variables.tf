variable "project_name" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

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
variable "tags" {
  default = {
    Component = "payment"
  }
}