defmodule ArchiveGHRepos.Coordinate.Workflow do
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
  def add_repo(workflow, repo) when is_struct(workflow, __MODULE__) and is_bitstring(repo) do
    %__MODULE__{}
  end

  @spec add_submodules(%__MODULE__{}, String.t(), [String.t()]) :: %__MODULE__{}
  def add_submodules(workflow, repo, submodules)
      when is_struct(workflow, __MODULE__) and is_bitstring(repo) and is_list(submodules) do
    %__MODULE__{}
  end

  @spec next_to_run(%__MODULE__{}) :: nonempty_list(term()) | nil
  def next_to_run(workflow) do
    workflow
  end
end
