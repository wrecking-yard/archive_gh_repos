defmodule ArchiveGHRepos do
  defdelegate all_repos(gh_org, timeout), to: ArchiveGHRepos.List
  defdelegate clone_all_repos(gh_org, timeout), to: ArchiveGHRepos.Clone
end
