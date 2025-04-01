defmodule ArchiveGHRepos.Coordinate.Workflow do
  use ArchiveGHRepos.Coordinate.Workflow.Access

  @type status :: nil | :in_progress | :timed_out | :error | :completed

  @type t :: %__MODULE__{
          start: {
            {:get_repos, status: status(), result_ref: nil},
            {
              :clone,
              [
                {
                  String.t(),
                  status: status(), result_ref: nil
                }
              ],
              status: status()
            },
            {
              :submodules,
              [
                {
                  String.t(),
                  String.t(),
                  status: status(), result_ref: nil
                }
              ],
              status: status()
            }
          }
        }

  defstruct(
    start: {
      {
        :get_repos,
        status: nil, result_ref: nil
      },
      {
        :clone,
        nil,
        status: nil
      },
      {
        :submodules,
        nil,
        status: nil
      }
    }
  )

  @spec new() :: %__MODULE__{}
  def new() do
    %__MODULE__{}
  end

  @spec add_repo(%__MODULE__{}, String.t()) :: %__MODULE__{}
  def add_repo(
        %__MODULE__{start: {get_repos, {:clone, nil, status}, submodules}},
        repo
      )
      when is_bitstring(repo) do
    %__MODULE__{
      start: {get_repos, {:clone, [{repo, status: nil, result_ref: nil}], status}, submodules}
    }
  end

  def add_repo(
        %__MODULE__{
          start: {get_repos, {:clone, repos = [_h | _t], status}, submodules}
        },
        repo
      )
      when is_bitstring(repo) do
    %__MODULE__{
      start:
        {get_repos, {:clone, repos ++ [{repo, status: nil, result_ref: nil}], status}, submodules}
    }
  end

  def add_submodules(
        %__MODULE__{start: {get_repos, clone, {:submodules, nil, status}}},
        repo,
        submodules = [_h | _t]
      ) do
    %__MODULE__{
      start:
        {get_repos, clone,
         {:submodules,
          for(submodule <- submodules, do: {repo, submodule, status: nil, result_ref: nil}),
          status}}
    }
  end

  def add_submodules(
        %__MODULE__{start: {get_repos, clone, {:submodules, submodules = [_h | _t], status}}},
        repo,
        submodules_ = [_a | _b]
      ) do
    %__MODULE__{
      start:
        {get_repos, clone,
         {:submodules,
          submodules ++
            for(submodule <- submodules_, do: {repo, submodule, status: nil, result_ref: nil}),
          status}}
    }
  end

  @spec next_to_run(%__MODULE__{}) :: nonempty_list(term()) | nil
  def next_to_run(%__MODULE__{start: {:get_repos, [{:status, nil}, {:result_ref, nil}]}}) do
    [:start, Access.elem(0)]
  end
end
