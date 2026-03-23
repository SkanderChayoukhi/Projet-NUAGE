locals {
  project_root      = abspath("${path.root}/..")
  healthchecks_path = "${local.project_root}/healthchecks"
}
