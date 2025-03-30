defmodule ArchiveGHRepos.Coordinate do
  use GenServer

  alias ArchiveGHRepos.Helpers
  alias ArchiveGHRepos.Workflow

  defstruct(
    ticket: nil,
    user_or_org: nil,
    workflow: nil
  )

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:clone_repos, _user_or_org}, _from, state) do
    {:reply, Helpers.uuidv4(), state}
  end
end
