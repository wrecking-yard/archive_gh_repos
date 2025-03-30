defmodule ArchiveGHRepos.Coordinate do
  use GenServer

  alias ArchiveGHRepos.Helpers
  alias ArchiveGHRepos.Coordinate.Workflow

  defmacrop journal_table do
    :coordinator_journal
  end

  defstruct(
    ticket: nil,
    user_or_org: nil,
    workflow: nil
  )

  @impl true
  def init(_) do
    :ets.new(journal_table(), [:set, :protected, :named_table]) && {:ok, nil}
  end

  @impl true
  def handle_call({:clone_all_repos, user_or_org, _timeout}, _from, state) do
    ticket = Helpers.uuidv4()

    :ets.insert_new(
      journal_table(),
      {ticket, %__MODULE__{ticket: ticket, user_or_org: user_or_org, workflow: %Workflow{}}}
    )

    {:reply, ticket, state}
  end

  def clone_all_repos(gh_org, timeout \\ 240_000) do
    GenServer.call(ArchiveGHRepos.Coordinate, {:clone_all_repos, gh_org, timeout}, timeout)
  end
end
