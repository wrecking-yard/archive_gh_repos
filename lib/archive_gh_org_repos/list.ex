defmodule ArchiveGHOrgRepos.List do
  {:ok, _} = Application.ensure_all_started(:req)

  use GenServer

  @impl true
  def init(token \\ nil) do
    {:ok,
     %{
       url_fun: fn gh_org -> "https://api.github.com/orgs/#{gh_org}/repos" end,
       token: token
     }}
  end

  @impl true
  def handle_call({:all_repos, gh_org, filter}, _from, state) do
    repo_names = names(state.url_fun.(gh_org), state.token, filter)

    {:reply, repo_names, state}
  end

  def _parse_link_header([link_header_value]) do
    _parse_link_header(link_header_value)
  end

  def _parse_link_header(nil) do
    %{}
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

  def _http_get(url, nil) do
    {:ok, %{body: body, headers: headers}} = Req.get(url)
    {headers, body}
  end

  def _http_get(url, token) do
    {:ok, %{body: body, headers: headers}} = Req.get(url, auth: "token" <> " " <> token)
    {headers, body}
  end

  def names(url, token, filter) do
    {headers, body} = _http_get(url, token)

    filtered_names =
      Enum.filter(body, fn e -> Regex.match?(filter, e["name"]) end)
      |> Enum.map(fn e -> e["name"] end)

    pagination_links = _parse_link_header(headers["link"])

    case Map.get(pagination_links, "next") do
      nil ->
        filtered_names

      _ ->
        filtered_names ++ names(pagination_links["next"], token, filter)
    end
  end

  def all_repos(gh_org, timeout) do
    GenServer.call(ArchiveGHOrgRepos.List, {:all_repos, gh_org, ~r/.+/}, timeout)
  end
end
