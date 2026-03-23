output "container_ids" {
  value = {
    redis  = module.redis.container_id
    db     = module.postgres.container_id
    vote   = module.vote.container_id
    result = module.result.container_id
    worker = module.worker.container_id
    nginx  = module.nginx.container_id
    seed   = module.seed.container_id
  }
}

output "entrypoint_url" {
  value = "http://localhost:8000"
}
