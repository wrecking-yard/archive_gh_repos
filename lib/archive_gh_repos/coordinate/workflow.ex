defmodule ArchiveGHRepos.Coordinate.Workflow do
  use ArchiveGHRepos.Coordinate.Workflow.Access

  @type status :: nil | :next | :in_progress | :timed_out | :error | :empty_org? | :completed

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
              :get_submodules,
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

  @spec next_to_run(%__MODULE__{}) ::
          {nil | :next | :in_progress | :timed_out | :error | :empty_org? | :completed,
           nonempty_list(term()) | nil, nonempty_list(term()) | nil}
          | {:none, nil}
  # :get_repos - fresh start
  def next_to_run(%__MODULE__{start: {{:get_repos, status: nil, result_ref: nil}, _, _}}) do
    {:next, [:start, Access.elem(0), Access.elem(0)], nil}
  end

  # :get_repos - try again later, we are getting repo list
  def next_to_run(%__MODULE__{start: {{:get_repos, status: :in_progress, result_ref: _}, _, _}}) do
    {:in_progress, [:start, Access.elem(0), Access.elem(0)], nil}
  end

  # :get_repos - failed
  def next_to_run(%__MODULE__{start: {{:get_repos, status: :error, result_ref: _}, _, _}}) do
    {:error, [:start, Access.elem(0), Access.elem(0)], [:start, Access.elem(0), Access.elem(2)]}
  end

  # :get_repos - org is empty/user has no visible repos etc., or we have repos, but not yet added to struct for cloning
  def next_to_run(%__MODULE__{
        start: {{:get_repos, status: :completed, result_ref: _}, {:clone, [], status: nil}, _}
      }) do
    {:empty_org?, [:start, Access.elem(0), Access.elem(0)],
     [:start, Access.elem(0), Access.elem(2)]}
  end

  # :clone - find next repo to clone
  def next_to_run(%__MODULE__{
        start:
          {{:get_repos, status: :completed, result_ref: _},
           {:clone, repos = [_h | _t], status: nil}, _}
      }) do
    index = Enum.find_index(repos, fn {_, [status: nil, result_ref: nil]} -> true end)

    cond do
      is_integer(index) and index > -1 ->
        {:next, [:start, Access.elem(1), Access.elem(0)],
         [:start, Access.elem(1), Access.elem(1)]}

      # TODO: all in :in_progress, :timed_out, :error?
      is_nil(index) ->
        {:wat?, [:start, Access.elem(1), Access.elem(0)], nil}
    end
  end

  # all done
  def next_to_run(%__MODULE__{
        start: {_, {:clone, _, status: :completed}, {:submodules, _, status: :completed}}
      }) do
    {:completed, nil}
  end
end
