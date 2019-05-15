defmodule LassoWeb.HookView do
  use LassoWeb, :view

  def render("get.json", %{uuid: uuid}) do
    %{data: %{id: uuid}}
  end
end
