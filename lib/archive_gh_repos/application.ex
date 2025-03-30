defmodule ArchiveGHRepos.Application do
  alias ArchiveGHRepos.List
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
        id: Clone,
        start: {GenServer, :start_link, [Clone, ".", [{:name, Clone}]]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
