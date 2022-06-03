terraform {
  backend "local" {

  }
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.15.0"
    }
  }
}

provider "gitlab" {
  base_url = var.gitlab_url
  token    = var.gitlab_token
}

resource "gitlab_system_hook" "system-hook" {
  for_each = {
    for hook in local.system_hooks : hook.name => hook
  }
  url                      = each.value.url
  token                    = each.value.token
  push_events              = each.value.push_events
  tag_push_events          = each.value.tag_push_events
  merge_requests_events    = each.value.merge_requests_events
  repository_update_events = each.value.repository_update_events
  enable_ssl_verification  = each.value.enable_ssl_verification
}

resource "gitlab_instance_variable" "instance_variable" {
  for_each = {
    for var in local.instance_variables : var.name => var
  }
  key           = each.value.key
  value         = each.value.value
  protected     = each.value.protected
  masked        = each.value.masked
  variable_type = each.value.variable_type
}

resource "gitlab_user" "user" {
  for_each = {
    for user in local.users : user.username => user
  }
  name              = each.value.name
  username          = each.value.username
  email             = each.value.email
  is_admin          = each.value.is_admin
  projects_limit    = each.value.projects_limit
  can_create_group  = each.value.can_create_group
  is_external       = each.value.is_external
  reset_password    = each.value.reset_password
  skip_confirmation = each.value.skip_confirmation
  state             = each.value.state
}

resource "gitlab_group" "group" {
  for_each = {
    for group in local.groups : group.name => group
  }
  name                              = each.value.name
  path                              = each.value.path
  description                       = each.value.description
  auto_devops_enabled               = each.value.auto_devops_enabled
  default_branch_protection         = each.value.default_branch_protection
  emails_disabled                   = each.value.emails_disabled
  lfs_enabled                       = each.value.lfs_enabled
  mentions_disabled                 = each.value.mentions_disabled
  prevent_forking_outside_group     = each.value.prevent_forking_outside_group
  project_creation_level            = each.value.project_creation_level
  request_access_enabled            = each.value.request_access_enabled
  require_two_factor_authentication = each.value.require_two_factor_authentication
  share_with_group_lock             = each.value.share_with_group_lock
  subgroup_creation_level           = each.value.subgroup_creation_level
  visibility_level                  = each.value.visibility_level
}

resource "gitlab_group_membership" "group_membership" {
  for_each = {
    for gm in local.group_memberships : "${gm.user}@${gm.group}" => gm
  }
  depends_on   = [gitlab_group.group, gitlab_user.user]
  group_id     = gitlab_group.group[each.value.group].id
  user_id      = gitlab_user.user[each.value.user].id
  access_level = each.value.level
}

resource "gitlab_group_variable" "group_var" {
  for_each = {
    for gv in local.group_vars : "${gv.name}@${gv.group}" => gv
  }
  depends_on        = [gitlab_group.group]
  group             = gitlab_group.group[each.value.group].id
  key               = each.value.key
  value             = each.value.value
  protected         = each.value.protected
  masked            = each.value.masked
  variable_type     = each.value.variable_type
  environment_scope = each.value.environment_scope

}

resource "gitlab_project" "project" {
  for_each = {
    for p in local.projects : "${p.name}@${p.group}" => p
  }
  depends_on                                       = [gitlab_group.group]
  name                                             = each.value.name
  description                                      = each.value.description
  namespace_id                                     = gitlab_group.group[each.value.group].id
  visibility_level                                 = gitlab_group.group[each.value.group].visibility_level
  archived                                         = each.value.archived
  ci_forward_deployment_enabled                    = each.value.ci_forward_deployment_enabled
  default_branch                                   = each.value.default_branch
  container_registry_enabled                       = each.value.container_registry_enabled
  container_registry_access_level                  = each.value.container_registry_access_level
  forking_access_level                             = each.value.forking_access_level
  initialize_with_readme                           = each.value.initialize_with_readme
  issues_access_level                              = each.value.issues_access_level
  issues_enabled                                   = each.value.issues_enabled
  merge_method                                     = each.value.merge_method
  merge_requests_enabled                           = each.value.merge_requests_enabled
  only_allow_merge_if_all_discussions_are_resolved = each.value.only_allow_merge_if_all_discussions_are_resolved
  only_allow_merge_if_pipeline_succeeds            = each.value.only_allow_merge_if_pipeline_succeeds
  pipelines_enabled                                = each.value.pipelines_enabled
  squash_option                                    = each.value.squash_option
  auto_devops_enabled                              = false

}

resource "gitlab_project_environment" "project_environment" {
  for_each = {
    for e in local.project_environments : "${e.group}_${e.project}_${e.name}" => e
  }
  project             = gitlab_project.project["${each.value.project}@${each.value.group}"].id
  name                = each.value.name
  stop_before_destroy = true
}

resource "gitlab_project_membership" "project_membership" {
  for_each = {
    for pm in local.project_memberships : "${pm.group}_${pm.project}_${pm.user}" => pm
  }
  depends_on   = [gitlab_group.group, gitlab_user.user, gitlab_project.project]
  project_id   = gitlab_project.project["${each.value.project}@${each.value.group}"].id
  user_id      = gitlab_user.user[each.value.user].id
  access_level = each.value.level
}

