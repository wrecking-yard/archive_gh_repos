defmodule ArchiveGHRepos.Clone do
  use GenServer

  @impl true
  def init(root_dir, reflect_path \\ true, add_git_postfix \\ true) do
    {:ok,
     %{
       root_dir: root_dir,
       reflect_path: reflect_path,
       add_git_postfix: add_git_postfix
     }}
  end

  @impl true
  def handle_call({:clone_repo, org, repo}, _from, state) do
    {:reply, clone(org, repo, state.root_dir, state.reflect_path, state.add_git_postfix), state}
  end

  @impl true
  def handle_call({:clone_all_repos, org, timeout}, _from, state) do
    {:reply,
     for(
       repo <- ArchiveGHRepos.all_repos(org, timeout),
       do: clone(org, repo, state.root_dir, state.reflect_path, state.add_git_postfix)
     ), state}
  end

  def clone(org, repo, root_dir, true, true) do
    System.cmd(
      "git",
      [
        "clone",
        "--recursive",
        "https://github.com/#{org}/#{repo}.git",
        root_dir <> "/" <> "github.com/#{org}/#{repo}.git"
      ],
      lines: 8192
    )
  end

  def clone_all_repos(gh_org, timeout \\ 240_000) do
    GenServer.call(ArchiveGHRepos.Clone, {:clone_all_repos, gh_org, timeout}, timeout)
  end
end
