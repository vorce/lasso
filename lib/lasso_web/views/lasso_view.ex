defmodule LassoWeb.LassoView do
  use LassoWeb, :view

  def render("request.json", %{uuid: uuid}) do
    %{data: %{id: uuid}}
  end
end
