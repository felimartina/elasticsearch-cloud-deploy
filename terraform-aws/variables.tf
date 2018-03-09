### MANDATORY ###
variable "es_cluster" {
  description = "Name of the elasticsearch cluster, used in node discovery"
}

variable "aws_region" {
  type = "string"
}

variable "global_tags" {
  type    = "map"
  default = {}
}

variable "global_tags_for_asg" {
  description = "There is a known issue in terraform where tags for ASG are provided diferently than tags for other resources. ASG tags should have key, value, and propagate_at_launch attributes."
  type        = "list"
  default     = []

  # default = [
  #   {
  #     key = "Foo"
  #     value = "Bar"
  #     propagate_at_launch = true
  #   },
  #   ...
  # ]
}

variable "vpc_id" {
  description = "VPC ID."
}

variable "vpc_private_subnet_ids" {
  description = "Private subnets ids to create."
  type        = "list"
}

variable "vpc_public_subnet_ids" {
  description = "Public subnets ids."
  type        = "list"
}

variable "vpc_public_subnets_cidrs" {
  description = "Private subnets cidrs (ie. ['10.0.1.0/24', '10.0.1.0/24'])"
  type        = "list"
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
}

variable "environment" {
  default = "default"
}

variable "datas_instance_type" {
  type    = "string"
  default = "c4.2xlarge"
}

variable "masters_instance_type" {
  type    = "string"
  default = "t2.medium"
}

variable "clients_instance_type" {
  type    = "string"
  default = "t2.medium"
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
