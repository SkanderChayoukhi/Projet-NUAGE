module "redis" {
  source = "./modules/redis"

  container_name    = "redis"
  network_name      = docker_network.back_net.name
  healthchecks_path = local.healthchecks_path
}

module "postgres" {
  source = "./modules/postgres"

  container_name    = "db"
  network_name      = docker_network.back_net.name
  healthchecks_path = local.healthchecks_path
  volume_name       = docker_volume.db_data.name
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  postgres_db       = var.postgres_db
}

module "vote" {
  source = "./modules/vote"

  image_name         = var.image_vote
  push_image         = var.push_to_registry
  container_name     = "vote"
  project_root       = local.project_root
  front_network_name = docker_network.front_net.name
  back_network_name  = docker_network.back_net.name

  depends_on = [module.redis]
}

module "result" {
  source = "./modules/result"

  image_name         = var.image_result
  push_image         = var.push_to_registry
  container_name     = "result"
  project_root       = local.project_root
  front_network_name = docker_network.front_net.name
  back_network_name  = docker_network.back_net.name

  depends_on = [module.postgres]
}

module "worker" {
  source = "./modules/worker"

  image_name        = var.image_worker
  push_image        = var.push_to_registry
  container_name    = "worker"
  project_root      = local.project_root
  back_network_name = docker_network.back_net.name

  depends_on = [module.redis, module.postgres]
}

module "nginx" {
  source = "./modules/nginx"

  image_name         = var.image_nginx
  push_image         = var.push_to_registry
  container_name     = "nginx"
  project_root       = local.project_root
  front_network_name = docker_network.front_net.name

  depends_on = [module.vote, module.result]
}

module "seed" {
  source = "./modules/seed"

  image_name         = var.image_seed
  push_image         = var.push_to_registry
  container_name     = "seed"
  project_root       = local.project_root
  front_network_name = docker_network.front_net.name

  depends_on = [module.nginx]
}
