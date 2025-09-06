defmodule ShopWeb.DressStyle.DressStyleJSON do
  alias Shop.Schema.DressStyle

  def index(%{dress_styles: dress_styles}) do
    %{data: for(dress_style <- dress_styles, do: data(dress_style))}
  end

  def show(%{dress_style: dress_style}) do
    %{data: data(dress_style)}
  end

  defp data(%DressStyle{} = dress_style) do
    %{
      id: dress_style.id,
      name: dress_style.name,
      cover_photo: dress_style.cover_photo,
      description: dress_style.description
    }
  end
end
