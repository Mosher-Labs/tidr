resource "cloudflare_dns_record" "root" {
  zone_id = data.cloudflare_zones.this.result[0].id
  name    = "z.benniemosher.dev"
  content = module.z.dns_name
  type    = "CNAME"
  ttl     = 1
}
