defmodule LassoWeb.LassoViewView do
  use LassoWeb, :view

  @doc """
  Render requests unless the lasso is cleared.

  This is a bit of a hack, since requests are marked as temporary_assigns in the liveview
  clearing the list won't force the DOM to actually remove all elements. This is why
  there is a `cleared` flag.
  """
  def render_requests(_requests, cleared?: true) do
    empty_requests()
  end

  def render_requests(requests, cleared?: false) do
    if requests == [] do
      empty_requests()
    else
      content_tag(:div, class: "col-12", id: "requests", "phx-update": "prepend") do
        for request <- requests do
          render("request.html", request: request)
        end
      end
    end
  end

  defp empty_requests() do
    [
      content_tag(:div, class: "col-12", id: "no_requests") do
        render("no_requests.html")
      end,
      content_tag(:div, class: "col-12", id: "requests") do
      end
    ]
  end
end
