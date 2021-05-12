vpc_cidr = "10.0.0.0/16"
vpc_availability_zones = [
  "eu-central-1a",
  "eu-central-1b",
]
vpc_private_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_public_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
ec2_ssh_public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBjZ/tOu3UdUT3Q8jDAivKM+tW0PnHH5Jc+8NedDk7cTZzfIPZMLxf4iF633HFwjwBmadNDmcoAaGhu8s+WjFIUiWcq9vvHmS/DXexEeoRthEXjFgl6x2vNg+yGADdDKg0cdeMMBqVxqKbFpiaj+Bhkup0WSQ+vKkwhkknxwTFV8ixLWer1liE1jDhmnjgg+bz0FMfh1U0qmLcL9Khktu7P4D1Zz9+0aOAx1UigXvvlQ+k4WF5GMG4UTSKw2J0i8Ayzojm7ZwVZ0Km/iTg19emPtBizOFxcx7OvqSnz4ZIKeoss5Bimd2vVOvZqwJEC2LCVJbdAIwxxQTkWk2i5mduKBnZ+ukuf7ov8Vt5rVkOmkZJvStGSDZmVwRghvzSrS9Cp8bLeiLFwIr7u5QmxyFn8hdMgiNoKUFXJKopLYRLN/X4qGa03ogLeQVFwLmP9GnjFI3WOAAr8MW02SKb82cqzXLNPeZBIEAkSPGHLesczzFkyHSG/xAkStzXsnQfGy8= demo@key"
s3_bucket_name_prefix = "gd"
tags = {
  Managed-by = "Terraform"
}
enable_termination_protection     = false
wg_allow_connections_from_subnets = ["0.0.0.0/0"]
dns_zone_name                     = "egorzp.info"
wg_peers = {
  yurii = {
    public_key  = "dRWcZBv2++23GZ0DdoFLrXvGch4lcZ2Fj7yeaSAUB2I="
    allowed_ips = "10.0.44.2/32"
  }
  alex = {
    public_key  = "D9HA+Qhe/kR0nwVxId2vNSuP0SozOh3umC5PKvL3b1Y="
    allowed_ips = "10.0.44.3/32"
  }
  roman = {
    public_key  = "U/2FptGTCVaY3laN49blUv1zf8KcD8oVALzQ0j/HSzY="
    allowed_ips = "10.0.44.4/32"
  }
}
