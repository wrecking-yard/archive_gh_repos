defmodule ArchiveGHRepos do
  defdelegate all_repos(user_or_org, timeout), to: ArchiveGHRepos.List
  defdelegate clone_all_repos(user_or_org, timeout), to: ArchiveGHRepos.Coordinate
end
