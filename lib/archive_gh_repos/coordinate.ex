defmodule ArchiveGHRepos.Coordinate do
  use GenServer

  alias ArchiveGHRepos.Helpers
  alias ArchiveGHRepos.Coordinate
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

    Task.Supervisor.start_child(ArchiveGHRepos.Application.TaskSupervisor, fn -> process(ticket) end)

    {:reply, ticket, state}
  end

  @impl true
  def handle_call({:clone_status, ticket, _timeout}, _from, state) do
    {:reply, :ets.lookup(journal_table(), ticket), state}
  end

  def clone_all_repos(gh_org, timeout \\ 240_000) do
    GenServer.call(Coordinate, {:clone_all_repos, gh_org, timeout}, timeout)
  end

  def clone_status(ticket, timeout \\ 240_000) do
    GenServer.call(Coordinate, {:clone_status, ticket, timeout}, timeout)
  end

  def process(ticket) do
    :timer.sleep(60 * 1000)
  end
end
