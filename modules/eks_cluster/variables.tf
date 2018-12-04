variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "name_prefix" {}

########################### EKS Cluster ##############################
variable "eks_cluster" {
  description = "eks cluster name"
}

########################### VPC Config ###############################
variable "eks_vpc" {
  description = "VPC for eks Cluster"
}

########################### Lanuch Config #######################
variable "volume_size" {
  description = "Desired number of instances in the cluster"
  default     = "100"
}

variable "instance_type" {
  description = "Desired number of instances in the cluster"
  default     = "t2.xlarge"
}

variable "delete_on_termination" {
  description = "Desired number of instances in the cluster"
  default     = "true"
}

########################## eks ASG #################################
variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
  default     = "2"
}

variable "max_capacity" {
  description = "ASG maximum capacity"
  default     = "4"
}

variable "min_capacity" {
  description = "ASG minimum capacity"
  default     = "1"
}

variable "subnets_ids" {
  type        = "list"
  description = "The private subnets to use"
}

variable "public_subnet_ids" {
  type        = "list"
  description = "The public subnets to use"
}