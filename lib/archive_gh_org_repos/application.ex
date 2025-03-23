defmodule ArchiveGHOrgRepos.Application do
  alias ArchiveGHOrgRepos.List
  alias ArchiveGHOrgRepos.Clone

  use Application

  def start(_type, _args) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      %{
        id: List,
        start: {GenServer, :start_link, [List, "wrecking-yard", [{:name, List}]]}
      },
      %{
        id: Clone,
        start: {GenServer, :start_link, [Clone, ".", [{:name, Clone}]]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
