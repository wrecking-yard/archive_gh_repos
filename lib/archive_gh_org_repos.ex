defmodule ArchiveGHOrgRepos do
  def call(:clone_all_repos, gh_org, timeout \\ 120_000) do
    GenServer.call(ArchiveGHOrgRepos.Clone, {:clone_all_repos, gh_org}, timeout)
  end
end
