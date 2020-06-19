
defmodule PssstWeb.PssstLive do
  use PssstWeb, :live_view
  alias PssstWeb.ManageSecretComponent

  @max_secret_size 1000

  def mount(_, _, socket) do
    socket = assign(socket, secrets: [], selected_secret: nil, selected_secret_action: nil)
    socket = put_session(socket, :secrets, [%{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"}])
    # socket = assign(socket, secrets: [
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP, you SOB, yo mama's so fat", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    #   %{title: "To DP", expiration: NaiveDateTime.utc_now() |> NaiveDateTime.add(60*60), mgmt_id: "asdf1234", view_id: "qwer7890"},
    # ], selected_secret: nil)
    {:ok, socket}
  end

  def handle_event("create-secret", %{"s-content" => sc}, socket) when byte_size(sc) == 0 do
    {:noreply, put_flash(socket, :error, "Secret is empty...")}
  end

  def handle_event("create-secret", %{"s-content" => sc} = params, socket) when byte_size(sc) <= @max_secret_size do
    socket = clear_flash(socket)

    %{"s-content" => sc, "s-title" => st, "s-expiration" => se} = params

    se = NaiveDateTime.utc_now() |> NaiveDateTime.add(String.to_integer(se) * 60, :second)

    {mgmt_id, view_id} = Pssst.Secret.create(sc)
    s = %{title: String.trim(st), expiration: se, mgmt_id: mgmt_id, view_id: view_id}

    {:noreply, socket |> update(:secrets, &[s | &1]) |> assign(selected_secret: s, selected_secret_action: :new)}
  end

  def handle_event("select-secret", %{"mgmt-id" => mgmt_id}, socket) do
    s = Enum.find(socket.assigns[:secrets], &(&1[:mgmt_id] == mgmt_id))
    {:noreply, assign(socket, selected_secret: s, selected_secret_action: :manage)}
  end

  def handle_event("burn-secret", %{"mgmt-id" => mgmt_id}, socket) do
    :ok = Pssst.Secret.burn(mgmt_id)
    secrets = Enum.reject(socket.assigns[:secrets], &(&1[:mgmt_id] == mgmt_id))

    {:noreply, socket |> assign(secrets: secrets, selected_secret: nil, selected_secret_action: nil)}
  end

  def handle_event("clear-selected-secret", _, socket) do
    {:noreply, assign(socket, selected_secret: nil)}
  end

  def duration_to_short_humanized(seconds) do
    m = 60
    h = m * 60
    d = h * 24

    cond do
      seconds > d + 12 * h ->
        round(seconds / d) |> to_string() |> (&("~" <> &1 <> "d")).()
      seconds > 23 * h + 29 * m + 59 ->
        "~1d"
      seconds > h + 29 * m + 59 ->
        round(seconds / h) |> to_string() |> (&("~" <> &1 <> "h")).()
      seconds > 59 * m + 29 ->
        "~1h"
      seconds > m + 29 + 59 ->
        round(seconds / m) |> to_string() |> (&("~" <> &1 <> "m")).()
      seconds > 59 ->
        "~1m"
      seconds ->
        round(seconds) |> to_string() |> (&("~" <> &1 <> "s")).()
    end
  end
end
