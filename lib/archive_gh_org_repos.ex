defmodule ArchiveGHOrgRepos do
  defdelegate all_repos(gh_org, timeout), to: ArchiveGHOrgRepos.List
  defdelegate clone_all_repos(gh_org, timeout), to: ArchiveGHOrgRepos.Clone
end
