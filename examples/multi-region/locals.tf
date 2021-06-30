locals {
  region_endpoints = [
    {
      "dns_name" : module.wg-a.lb_dns_name,
      "zone_id" : module.wg-a.lb_zone_id
      "region" : data.aws_region.current-a.name
    },
    {
      "dns_name" : module.wg-b.lb_dns_name,
      "zone_id" : module.wg-b.lb_zone_id,
      "region" : data.aws_region.current-b.name
    }
  ]

  wireguard_client_configs   = [for config in module.wg-a.wireguard_client_configs : replace(config, module.wg-a.lb_dns_name, aws_route53_record.main[0].fqdn)]
  wireguard_server_endpoints = [for endpoint in module.wg-a.wireguard_server_endpoints : replace(endpoint, module.wg-a.lb_dns_name, aws_route53_record.main[0].fqdn)]
}
