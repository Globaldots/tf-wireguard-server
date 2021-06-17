variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_instance_main_interface_name" {
  type        = string
  description = "EC2 instance primary network interface name"
  default     = "eth0"
}

variable "ec2_iam_policy_names" {
  description = "Additional IAM policies to assign to EC2 instances through instance profiles if needed"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "AWS VPC ID for EC2 instances and all other resources"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "VPC public subnets CIDR to create NLB in. Multiple subnets are used for HA. AZs of public & private subnets must match"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "VPC private subnets CIDR to create EC2 instances in. AZs of public & private subnets must match"
  type        = list(string)
}

variable "tags" {
  description = "Tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "ssh_keypair_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

variable "wg_cidr" {
  description = "Wireguard network subnet CIDR"
  type        = string
  default     = "10.0.44.0/24"
}

variable "wg_listen_ports" {
  description = "Wireguard listen ports. These ports will be opened for inbound Wireguard client connections"
  type        = list(string)
  default     = ["51820", "4500", "53"]
}

variable "wg_private_key" {
  description = "WireGuard server private key"
  type        = string
  sensitive   = true
}

variable "wg_public_key" {
  description = "WireGuard server public key"
  type        = string
}

variable "wg_dns_server" {
  description = "DNS server for Wireguard network"
  type        = string
  default     = "8.8.8.8"
}

variable "wg_peers" {
  description = "Wireguard clients (peers) configuration. `Public_key` is optional — will be automatically generated if empty. `Peer_ip` — desired client IP-address or subnet in CIDR notation within Wireguard network (must be within `wg_cidr` range). `Allowed_subnets` — controls what subnets peer will be able to access through Wireguard network (for bounce server mode set to `0.0.0.0/0`). `Isolated` — if `true` peer won't be able to access other Wireguard peers."
  type        = map(object({ public_key = string, peer_ip = string, allowed_subnets = list(string), isolated = bool }))
  default     = {}
}

variable "wg_mtu" {
  description = "MTU value for Wireguard network"
  type        = number
  default     = "1420"
}

variable "name_suffix" {
  description = "Suffix to be added to all resources to uniquely identify this setup"
  type        = string
}

variable "s3_bucket_name_prefix" {
  description = "Prefix to be added to S3 bucket name"
  type        = string
}

variable "enable_termination_protection" {
  description = "Enable termination protection for resources"
  type        = bool
  default     = true
}

variable "wg_ha_instance_min_count" {
  description = "Minimum number of Wireguard EC2 instances (HA configuration)"
  type        = number
  default     = 2
}

variable "wg_ha_instance_max_count" {
  description = "Maximum number of Wireguard EC2 instances (HA configuration)"
  type        = number
  default     = 2
}

variable "wg_ha_instance_desired_count" {
  description = "Desired number of Wireguard EC2 instances (HA configuration)"
  type        = number
  default     = 2
}

variable "wg_allow_connections_from_subnets" {
  description = "Allow inbound connections to Wireguard server from these networks. To allow all networks set to `0.0.0.0/0`"
  type        = list(string)
}

variable "dns_zone_name" {
  description = "Route53 DNS zone name for Wireguard server endpoint. If not set, AWS LB DNS record is used"
  type        = string
  default     = ""
}

variable "prometheus_exporters_enable" {
  type        = bool
  description = "Run Prometheus Exporters (Node Exporter & Wireguard Exporter) on EC2 instances. Disable if you don't plan to use Prometheus monitoring solution"
  default     = true
}

variable "cloudwatch_monitoring_enable" {
  type        = bool
  description = "Enable CloudWatch monitoring of Wireguard resources. Disable if you don't plan to use CloudWatch monitoring solution"
  default     = true
}

variable "cloudwatch_alerts_phone_numbers" {
  type        = list(string)
  description = "Phone numbers to get monitoring alerts from CloudWatch. Ignored when `cloudwatch_monitoring_enable = false`"
  default     = []
}

variable "cloudwatch_alerts_emails" {
  type        = list(string)
  description = "Email addresses to get monitoring alerts from CloudWatch. Email alert configuration must be manually approved by clicking on the button in confirmation email. Ignored when `cloudwatch_monitoring_enable = false`"
  default     = []
}

variable "cloudwatch_log_retention_days" {
  type        = number
  description = "For how long CloudWatch will store log files (days)"
  default     = 180
}

variable "wg_restart_lambda_timeout_sec" {
  description = "Timeout for Lambda which restarts Wireguard instances when configuration changes occurred"
  type        = number
  default     = 300
}

variable "wg_restart_lambda_max_errors_count" {
  description = "Lambda which restarts Wireguard instances when configuration changes detected will stop execution if number of errors exceed this value"
  type        = number
  default     = 0
}
