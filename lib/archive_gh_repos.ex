defmodule ArchiveGHRepos do
  defdelegate all_repos(user_or_org, timeout \\ :infinity), to: ArchiveGHRepos.List
  defdelegate clone_all_repos(user_or_org, timeout \\ :infinity), to: ArchiveGHRepos.Coordinate
  defdelegate clone_status(ticket, timeout \\ :infinity), to: ArchiveGHRepos.Coordinate
end
