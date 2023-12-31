output "redis_host" {
  description = "Redis Host"
  value       = aws_elasticache_cluster.second-cluster.cache_nodes.0.address
  sensitive   = false
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_cluster.second-cluster.cache_nodes.0.port
  sensitive   = false
}

output "mysql_host" {
  description = "mysql host"
  value       = aws_db_instance.firsTerraDB.address
  sensitive   = false
}

output "mysql_port" {
  description = "mysql port"
  value       = aws_db_instance.firsTerraDB.port
  sensitive   = false
}

output "elasticache-sg" {
  description = "Elasticache security group name"
  value       = aws_elasticache_cluster.second-cluster.security_group_ids
}

output "database-sg" {
  description = "database sg"
  value       = aws_db_instance.firsTerraDB.vpc_security_group_ids
}