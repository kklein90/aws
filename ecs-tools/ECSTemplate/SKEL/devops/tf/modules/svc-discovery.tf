data "aws_service_discovery_dns_namespace" "ecs_namespace" {
  name = var.svc-discovery-dns-namespace
  type = "DNS_PRIVATE"
}

resource "aws_service_discovery_service" "svc_disc_service" {
  name = "dev-portal"
  dns_config {
    namespace_id = data.aws_service_discovery_dns_namespace.ecs_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
