defmodule ArchiveGHRepos.Application do
  alias ArchiveGHRepos.List
  alias ArchiveGHRepos.Coordinate
  alias ArchiveGHRepos.Clone

  use Application

  def start(_type, _args) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      %{
        id: List,
        start: {GenServer, :start_link, [List, nil, [{:name, ArchiveGHRepos.Application.List}]]}
      },
      %{
        id: Coordinate,
        start: {GenServer, :start_link, [Coordinate, nil, [{:name, ArchiveGHRepos.Application.Coordinate}]]}
      },
      %{
        id: Clone,
        start: {GenServer, :start_link, [Clone, ".", [{:name, ArchiveGHRepos.Application.Clone}]]}
      },
      %{
        id: Task.Supervisor,
        start: {Task.Supervisor, :start_link, [[{:name, ArchiveGHRepos.Application.TaskSupervisor}]]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
