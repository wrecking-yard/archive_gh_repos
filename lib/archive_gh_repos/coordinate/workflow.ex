defmodule ArchiveGHRepos.Coordinate.Workflow do
  use ArchiveGHRepos.Coordinate.Workflow.Access

  @type ref :: nonempty_list(term())
  @type task_ref :: ref()
  @type item_ref :: ref()
  @type status :: :next | :in_progress | :timed_out | :error | :empty_org? | :completed
  @type result_ref :: ref()

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
        :get_submodules,
        status: nil, result_ref: nil
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
  def add_repo(%__MODULE__{start: {get_repos, {:clone, nil, status}, get_submodules, submodules}}, repo)
      when is_bitstring(repo) do
    %__MODULE__{start: {get_repos, {:clone, [{repo, status: nil, result_ref: nil}], status}, get_submodules, submodules}}
  end

  def add_repo(%__MODULE__{start: {get_repos, {:clone, repos = [_h | _t], status}, get_submodules, submodules}}, repo)
      when is_bitstring(repo) do
    %__MODULE__{
      start: {get_repos, {:clone, repos ++ [{repo, status: nil, result_ref: nil}], status}, get_submodules, submodules}
    }
  end

  def add_submodules(
        %__MODULE__{start: {get_repos, clone, get_submodules, {:submodules, nil, status}}},
        repo,
        submodules = [_h | _t]
      ) do
    %__MODULE__{
      start: {
        get_repos,
        clone,
        get_submodules,
        {:submodules, for(submodule <- submodules, do: {repo, submodule, status: nil, result_ref: nil}), status}
      }
    }
  end

  def add_submodules(
        %__MODULE__{start: {get_repos, clone, get_submodules, {:submodules, submodules = [_h | _t], status}}},
        repo,
        submodules_ = [_a | _b]
      ) do
    %__MODULE__{
      start: {
        get_repos,
        clone,
        get_submodules,
        {
          :submodules,
          submodules ++
            for(submodule <- submodules_, do: {repo, submodule, status: nil, result_ref: nil}),
          status
        }
      }
    }
  end

  @spec next_to_run(%__MODULE__{}) ::
          {
            status(),
            task_ref() | nil,
            result_ref() | nil
          }
          | {:none | :completed, nil}
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
    {:empty_org?, [:start, Access.elem(0), Access.elem(0)], [:start, Access.elem(0), Access.elem(2)]}
  end

  # :clone - find next repo to clone
  def next_to_run(%__MODULE__{
        start: {{:get_repos, status: :completed, result_ref: _}, {:clone, repos = [_h | _t], status: nil}, _}
      }) do
    # ugly, TODO: redo. ideally we should not generate all of that data if we don't need it, because we scan repo list multime times.
    # if: 
    # - there is anything not/never started, it's :next.
    # - all was already started and there is at least one :in_progress repo, it's :in_progress.
    # - there are only/or :timed_out or/and :error, :timed_out is :next.
    # - all is :completed, task is :completed
    # - all is :error, we have task :error.

    not_started_index = Enum.find_index(repos, fn {_, [status: nil, result_ref: nil]} -> true end)
    in_progress_index = Enum.find_index(repos, fn {_, [status: :in_progress, result_ref: nil]} -> true end)
    timed_out_index = Enum.find_index(repos, fn {_, [status: :timed_out, result_ref: nil]} -> true end)
    all_completed = Enum.all?(repos, fn {_, [status: :completed, result_ref: _]} -> true end)
    all_error = Enum.all?(repos, fn {_, [status: :error, result_ref: _]} -> true end)

    cond do
      is_integer(not_started_index) and not_started_index > -1 ->
        {
          :next,
          [:start, Access.elem(1), Access.elem(0)],
          [:start, Access.elem(1), Access.elem(1), Access.at(not_started_index)]
        }

      is_integer(in_progress_index) and in_progress_index > -1 ->
        {
          :in_progress,
          [:start, Access.elem(1), Access.elem(0)],
          nil
        }

      is_integer(timed_out_index) and timed_out_index > -1 ->
        {
          :next,
          [:start, Access.elem(1), Access.elem(0)],
          [:start, Access.elem(1), Access.elem(1), Access.at(timed_out_index)]
        }

      all_completed === true ->
        {
          :completed,
          [:start, Access.elem(1), Access.elem(0)],
          nil
        }

      all_error === true ->
        {
          :error,
          [:start, Access.elem(1), Access.elem(0)],
          nil
        }
    end
  end

  # all done
  def next_to_run(%__MODULE__{
        start: {
          {:get_repos, status: :completed, result_ref: _},
          {:clone, _, status: :completed},
          {:get_submodules, status: :completed, result_ref: _},
          {:submodules, _, status: :completed}
        }
      }) do
    {:completed, nil}
  end
end
