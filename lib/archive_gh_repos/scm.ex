defmodule ArchiveGHRepos.SCM do
  defstruct(
    repo: %{
      type: nil,
      path: nil,
      state: %{
        cloned: nil,
        submodules: %{}
      }
    }
  )
end
