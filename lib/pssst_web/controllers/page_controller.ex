defmodule PssstWeb.PageController do
  use PssstWeb, :controller

  @max_secret_size 1000
  @secret_stub_len 16

  # plug :put_layout, "app2.html"

  def test(conn, params) do
    %{"stuff" => stuff} = params

    conn
    |> assign(:secret, stuff)
    |> render("test.html")
  end

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def new_secret(conn, %{"secret" => secret}) when byte_size(secret) <= @max_secret_size do
    {_mgmt_id, view_id} = Pssst.Secret.create(secret)

    secret_stub = if byte_size(secret) > @secret_stub_len do
      secret |> String.slice(0, @secret_stub_len) |> String.trim_trailing |> Kernel.<>("...")
    else
      secret |> String.trim_trailing
    end

    conn
    |> assign(:view_id, view_id)
    |> assign(:secret_stub, secret_stub)
    |> render("new_secret.html")
  end

  def view_confirm(conn, %{"view_id" => view_id}) do
    secret_exists? = Pssst.Secret.view_stat(view_id) == :exist

    conn
    |> assign(:secret_exists?, secret_exists?)
    |> assign(:view_id, view_id)
    |> render("view_confirm.html")
  end

  def view_secret(conn, %{"view_id" => view_id}) do
    secret = case Pssst.Secret.view_stat(view_id) do
      :noexist -> nil
      :exist -> Pssst.Secret.view(view_id)
    end

    conn
    |> assign(:secret, secret)
    |> render("view_secret.html")
  end
end
