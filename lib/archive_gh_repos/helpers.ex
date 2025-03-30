defmodule ArchiveGHRepos.Helpers do
  def uuidv4() do
    :rand.bytes(16)
    |> :binary.decode_unsigned()
    |> Integer.to_string(16)
    |> (fn <<a::binary-size(8), b::binary-size(4), c::binary-size(4), d::binary-size(4),
             e::binary-size(12)>> ->
          "#{a}-#{b}-#{c}-#{d}-#{e}"
        end).()
  end
end
