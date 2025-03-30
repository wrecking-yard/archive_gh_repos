defmodule ArchiveGHRepos.Coordinate.Workflow do
  defstruct(
    start: {
      {
        :get_repos,
        status: nil,
        result_ref: nil
      },
      {
        :clone,
        %{
          # <repo>: {
          #     status: nil,
          #     result_ref: nil
          # }
        },
        status: nil
      },
      {
        :submodules,
        {
          %{
            # <gitmodule>: {
            #   {
            #     status: nil,
            #     result_ref: nil
            #   }
            # }
          },
          status: nil
        }
      }
    }
  )
end
