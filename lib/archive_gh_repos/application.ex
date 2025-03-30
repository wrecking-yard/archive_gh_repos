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
        start: {GenServer, :start_link, [List, nil, [{:name, List}]]}
      },
      %{
        id: Coordinate,
        start: {GenServer, :start_link, [Coordinate, ".", [{:name, Coordinate}]]}
      },
      %{
        id: Clone,
        start: {GenServer, :start_link, [Clone, ".", [{:name, Clone}]]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
