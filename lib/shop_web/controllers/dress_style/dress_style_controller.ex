defmodule ShopWeb.DressStyle.DressStyleController do
  use ShopWeb, :controller
  use OpenApiSpex.ControllerSpecs

  require Logger
  alias Shop.Schema.DressStyle
  alias Shop.Products.DressStyles
  alias Shop.Helpers.ImageUploader

  alias ShopWeb.Schemas.DressStyle.{
    CreateDressStyleRequest,
    UpdateDressStyleWithPhotoRequest,
    DressStyleResponse,
    DressStylesListResponse,
    ErrorResponse
  }

  action_fallback ShopWeb.FallbackController

  operation(:list_styles,
    summary: "List all dress styles",
    description: "Retrieve a list of all available dress styles",
    responses: [
      ok: {"List of dress styles", "application/json", DressStylesListResponse}
    ],
    tags: ["Dress Styles"]
  )

  def list_styles(conn, _params) do
    dress_styles = DressStyles.list_dress_styles()
    render(conn, :index, dress_styles: dress_styles)
  end

  operation(:add_dress_style,
    summary: "Create new dress style",
    description: "Create a new dress style with cover photo upload",
    request_body:
      {"Dress style data with cover photo", "multipart/form-data", CreateDressStyleRequest},
    responses: [
      created: {"Dress style created successfully", "application/json", DressStyleResponse},
      internal_server_error: {"File upload error", "application/json", ErrorResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Dress Styles"]
  )

  def add_dress_style(conn, %{"cover_photo" => cover_photo} = params) do
    case ImageUploader.upload(cover_photo.path) do
      {:ok, url} ->
        params = params |> Map.put("cover_photo", url)

        with {:ok, %DressStyle{} = dress_style} <- DressStyles.create_dress_style(params) do
          conn
          |> put_status(:created)
          |> render(:show, dress_style: dress_style)
        end

      {:error, reason} ->
        Logger.info("Error uploading cover photo: #{reason}")
        {:error, :internal_server_error}
    end
  end

  operation(:update,
    summary: "Update dress style",
    description:
      "Update an existing dress style by ID. Can update with or without new cover photo.",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Dress style ID",
        example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
      }
    ],
    request_body:
      {"Updated dress style data", "multipart/form-data", UpdateDressStyleWithPhotoRequest},
    responses: [
      ok: {"Dress style updated successfully", "application/json", DressStyleResponse},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"Dress style not found", "application/json", ErrorResponse},
      internal_server_error: {"File upload error", "application/json", ErrorResponse},
      unprocessable_entity: {"Validation errors", "application/json", ErrorResponse}
    ],
    tags: ["Dress Styles"]
  )

  def update(conn, %{"id" => id, "cover_photo" => cover_photo} = params)
      when map_size(params) > 1 do
    case DressStyles.get_dress_style(id) do
      nil ->
        {:error, :item_not_found}

      dress_style ->
        case ImageUploader.upload(cover_photo.path) do
          {:ok, url} ->
            dress_style_params =
              params
              |> Map.delete("id")
              |> Map.put("cover_photo", url)

            with {:ok, %DressStyle{} = dress_style} <-
                   DressStyles.update_dress_style(dress_style, dress_style_params) do
              render(conn, :show, dress_style: dress_style)
            end

          {:error, reason} ->
            Logger.info("Error uploading cover photo: #{reason}")
            {:error, :internal_server_error}
        end
    end
  end

  def update(conn, %{"id" => id} = params) when map_size(params) > 1 do
    dress_style_params = params |> Map.delete("id")

    case DressStyles.get_dress_style(id) do
      nil ->
        {:error, :item_not_found}

      dress_style ->
        with {:ok, %DressStyle{} = updated_dress_style} <-
               DressStyles.update_dress_style(dress_style, dress_style_params) do
          render(conn, :show, dress_style: updated_dress_style)
        end
    end
  end

  def update(_conn, _params) do
    {:error, :bad_request}
  end

  operation(:delete,
    summary: "Delete dress style",
    description: "Delete an existing dress style by ID",
    parameters: [
      %OpenApiSpex.Parameter{
        name: :id,
        in: :path,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Dress style ID",
        example: "b7a97530-e65f-40b8-843b-b6c2eb5f75bf"
      }
    ],
    responses: [
      no_content:
        {"Dress style deleted successfully", "application/json",
         %OpenApiSpex.Schema{type: :string}},
      bad_request: {"Invalid request", "application/json", ErrorResponse},
      not_found: {"Dress style not found", "application/json", ErrorResponse}
    ],
    tags: ["Dress Styles"]
  )

  def delete(conn, %{"id" => id}) do
    case DressStyles.get_dress_style(id) do
      nil ->
        {:error, :item_not_found}

      dress_style ->
        with {:ok, %DressStyle{}} <- DressStyles.delete_dress_style(dress_style) do
          send_resp(conn, :no_content, "")
        end
    end
  end

  def delete(_conn, _params) do
    {:error, :bad_request}
  end
end
