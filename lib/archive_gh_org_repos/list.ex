defmodule List do
  {:ok, _} = Application.ensure_all_started(:req)

  def _parse_link_header([link_header_value]) do
    _parse_link_header(link_header_value)
  end

  def _parse_link_header(link_header_value) do
    Enum.reduce(
      Regex.scan(~r/<([^>]+)> ?; ?rel=\"(first|prev|next|last)\"/, link_header_value,
        capture: :all_but_first
      ),
      %{},
      fn [url, label], acc -> Map.put_new(acc, label, url) end
    )
  end

  def names(org, token, filter) do
    _names("https://api.github.com/orgs/#{org}/repos", token, filter)
  end

  def _names(url, token, filter) do
    {:ok, %{body: body, headers: headers}} = Req.get(url, auth: "token" <> " " <> token)

    filtered_names =
      Enum.filter(body, fn e -> Regex.match?(filter, e["name"]) end)
      |> Enum.map(fn e -> e["name"] end)

    pagination_links = _parse_link_header(headers["link"])

    case Map.get(pagination_links, "next") do
      nil ->
        filtered_names

      _ ->
        filtered_names ++ _names(pagination_links["next"], token, filter)
    end
  end
end
