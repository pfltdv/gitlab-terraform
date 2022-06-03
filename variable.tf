locals {

  system_hooks = yamldecode(file("${path.module}/config/hooks.yaml"))

  instance_variables = yamldecode(file("${path.module}/config/instance_variables.yaml"))

  users = flatten([
    for file in fileset("${path.module}/config/users", "**/*.yaml") : [
      for user in yamldecode(file("${path.module}/config/users/${file}")) : user
    ]
  ])

  groups = flatten([
    for file in fileset("${path.module}/config/groups", "**/*.yaml") : [
      for group in yamldecode(file("${path.module}/config/groups/${file}")) : group
    ]
  ])

  projects = flatten([
    for file in fileset("${path.module}/config/projects", "**/*.yaml") :
    yamldecode(file("${path.module}/config/projects/${file}"))
  ])

  group_memberships = flatten([
    for user in local.users : [
      for group in user.groups : {
        user  = user.username
        group = group.name
        level = group.level
      }
    ]
  ])

  group_vars = flatten([
    for group in local.groups : [
      for var in group.vars : {
        group             = group.name
        name              = var.name
        key               = var.key
        value             = var.value
        protected         = var.protected
        masked            = var.masked
        variable_type     = var.variable_type
        environment_scope = var.environment_scope
      }
    ]
  ])

  project_environments = flatten([
    for p in local.projects : [
      for e in p.environments : {
        project = p.name
        group   = p.group
        name    = e
      }
    ]
  ])

  project_memberships = flatten([
    for user in local.users : [
      for project in user.projects : {
        user    = user.username
        project = project.name
        group   = project.group
        level   = project.level
      }
    ]
  ])

}

variable "gitlab_token" {
  description = "Gitlab access token"
  sensitive   = true
  type        = string
  validation {
    condition     = length(var.gitlab_token) > 0
    error_message = "The gitlab_token value must be valid github token. Create an access token!"
  }
}

variable "gitlab_url" {
  description = "Gitlab base url"
  sensitive   = false
  type        = string
  validation {
    condition     = length(var.gitlab_url) > 4 && substr(var.gitlab_url, 0, 4) == "http"
    error_message = "The gitlab_url must be gitlab url. Please provate gitlab base url!"
  }
}