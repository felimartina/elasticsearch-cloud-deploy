### MANDATORY ###
variable "es_cluster" {
  description = "Name of the elasticsearch cluster, used in node discovery"
}

variable "aws_region" {
  type = "string"
}

variable "vpc_cidr" {
  description = "VPC CIDR to use. Defaults to 10.0.0.0/16"
  type        = "string"
  default     = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  description = "Private subnets cidrs to create."
  type        = "list"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  description = "Public subnets cidrs to create."
  type        = "list"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "AWS region to launch servers; if not set the available zones will be detected automatically"
  type        = "list"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "admin_cidrs" {
  description = "List of CIDRs to whitelist for SSH access"
  type        = "list"
  default     = []
}

variable "key_name" {
  description = "Key name to be used with the launched EC2 instances."
  default     = "elasticsearch"
}

variable "environment" {
  default = "default"
}

variable "data_instance_type" {
  type    = "string"
  default = "c4.2xlarge"
}

variable "master_instance_type" {
  type    = "string"
  default = "m4.large"
}

variable "elasticsearch_volume_size" {
  type    = "string"
  default = "100"    # gb
}

variable "volume_name" {
  default = "/dev/xvdh"
}

variable "volume_encryption" {
  default = true
}

variable "elasticsearch_data_dir" {
  default = "/opt/elasticsearch/data"
}

variable "elasticsearch_logs_dir" {
  default = "/var/log/elasticsearch"
}

# default elasticsearch heap size
variable "data_heap_size" {
  type    = "string"
  default = "7g"
}

variable "master_heap_size" {
  type    = "string"
  default = "2g"
}

variable "masters_count" {
  default = "0"
}

variable "datas_count" {
  default = "0"
}

variable "clients_count" {
  default = "0"
}

# whether or not to enable x-pack security on the cluster
variable "security_enabled" {
  default = "false"
}

# whether or not to enable x-pack monitoring on the cluster
variable "monitoring_enabled" {
  default = "true"
}

# client nodes have nginx installed on them, these credentials are used for basic auth
variable "client_user" {
  default = "exampleuser"
}

variable "client_pwd" {
  default = "changeme"
}

# the ability to add additional existing security groups. In our case
# we have consul running as agents on the box
variable "additional_security_groups" {
  default = ""
}
