defmodule ArchiveGHRepos.Helpers do
  def uuidv4() do
    for byte <- :rand.bytes(16) |> :binary.bin_to_list() do
      cond do
        byte < 16 ->
          "0" <> Integer.to_string(byte, 16)

        true ->
          Integer.to_string(byte, 16)
      end
    end
    |> List.to_string()
    |> (fn <<a::binary-size(8), b::binary-size(4), c::binary-size(4), d::binary-size(4),
             e::binary-size(12)>> ->
          "#{a}-#{b}-#{c}-#{d}-#{e}"
        end).()
  end
end
