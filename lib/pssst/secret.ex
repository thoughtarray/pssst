defmodule Pssst.Secret do
  @moduledoc """
  Once-viewable secrets.
  """

  use GenServer

  @type mgmt_id :: binary
  @type view_id :: binary

  # --- API

  @doc since: "0.1.0"
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Stores a secret for later viewing.

      iex> Pssst.Secret.create("Hello, world!")
      {"PjkV5yJUSNOgzypkdOYqNA", "iXfhjPZgT3qy63blp0JbSw"}
  """
  @doc since: "0.1.0"
  @spec create(binary) :: {mgmt_id, view_id}
  def create(content) when is_binary(content) do
    #TODO: content size check
    mgmt_id = UUID.uuid4(:slug)
    view_id = UUID.uuid4(:slug)
    GenServer.call(__MODULE__, {:create, {mgmt_id, view_id, content}})
  end

  @doc """
  Views a secret (secret is only viewable once).

      iex> Pssst.Secret.view("PjkV5yJUSNOgzypkdOYqNA")
      {:error, :noexist}

      iex> Pssst.Secret.view("iXfhjPZgT3qy63blp0JbSw")
      "Hello, world!"

      iex> Pssst.Secret.view("iXfhjPZgT3qy63blp0JbSw")
      {:error, :noexist}
  """
  @doc since: "0.1.0"
  @spec view(view_id) :: binary | {:error, :noexist}
  def view(view_id) do
    GenServer.call(__MODULE__, {:view, view_id})
  end

  @doc """
  Burs a secret making it unviewable forever.

      iex> Pssst.Secret.burn("PjkV5yJUSNOgzypkdOYqNA")
      :ok

      iex> Pssst.Secret.burn("PjkV5yJUSNOgzypkdOYqNA")
      {:error, :noexist}
  """
  @doc since: "0.1.0"
  @spec burn(mgmt_id) :: :ok, {:error, :noexist}
  def burn(mgmt_id) do
    GenServer.call(__MODULE__, {:burn, mgmt_id})
  end

  @doc """
  See if a secret exists with management id.

      iex> Pssst.Secret.mgmt_stat("PjkV5yJUSNOgzypkdOYqNA")
      :exist

      iex> Pssst.Secret.mgmt_stat("iXfhjPZgT3qy63blp0JbSw")
      :noexist
  """
  @doc since: "0.1.0"
  @spec mgmt_stat(mgmt_id) :: :exist | :noexist
  def mgmt_stat(mgmt_id) do
    GenServer.call(__MODULE__, {:mgmt_stat, mgmt_id})
  end

  @doc """
  See if a secret exists with view id.

      iex> Pssst.Secret.mgmt_stat("iXfhjPZgT3qy63blp0JbSw")
      :exist

      iex> Pssst.Secret.mgmt_stat("PjkV5yJUSNOgzypkdOYqNA")
      :noexist
  """
  @doc since: "0.1.0"
  @spec view_stat(view_id) :: :exist | :noexist
  def view_stat(view_id) do
    GenServer.call(__MODULE__, {:view_stat, view_id})
  end

  # --- Callbacks

  @impl true
  def init(_) do
    {:ok, %{ auto_id: 1, secrets: %{}, mgmt_id_idx: %{}, view_id_idx: %{} }}
  end

  @impl true
  def handle_call({:create, {mgmt_id, view_id, content}}, _, state) when is_binary(content) do
    secret = %{content: content, mgmt_id: mgmt_id, view_id: view_id, created_at: DateTime.utc_now()}

    new_state = put_secret(state, secret)
    {:reply, {mgmt_id, view_id}, new_state}
  end

  @impl true
  def handle_call({:view, view_id}, _, state) do
    case Map.get(state.view_id_idx, view_id) do
      nil ->
        {:reply, {:error, :noexist}, state}
      secret_id ->
        {state, secret} = pop_secret(state, secret_id)
        {:reply, secret, state}
    end
  end

  @impl true
  def handle_call({:burn, mgmt_id}, _, state) do
    case Map.get(state.mgmt_id_idx, mgmt_id) do
      nil ->
        {:reply, {:error, :noexist}, state}
      secret_id ->
        {state, _} = pop_secret(state, secret_id)
        {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call({:mgmt_stat, mgmt_id}, _, state) do
    case Map.get(state.mgmt_id_idx, mgmt_id) do
      nil -> {:reply, :noexist, state}
      _ -> {:reply, :exist, state}
    end
  end

  @impl true
  def handle_call({:view_stat, view_id}, _, state) do
    case Map.get(state.view_id_idx, view_id) do
      nil -> {:reply, :noexist, state}
      _ -> {:reply, :exist, state}
    end
  end

  # @impl true
  # def handle_call({:list}, _, state) do
  #   {:reply, state.secrets, state}
  # end

  # --- Helpers

  defp put_secret(state, secret) do
    secrets = Map.put(state.secrets, state.auto_id, secret)
    mgmt = Map.put(state.mgmt_id_idx, secret.mgmt_id, state.auto_id)
    view = Map.put(state.view_id_idx, secret.view_id, state.auto_id)
    aid = state.auto_id + 1

    %{state | secrets: secrets, mgmt_id_idx: mgmt, view_id_idx: view, auto_id: aid}
  end

  defp pop_secret(state, secret_id) do
    {secret, secrets} = Map.pop!(state.secrets, secret_id)
    %{content: content, mgmt_id: mgmt_id, view_id: view_id} = secret

    mgmt = Map.delete(state.mgmt_id_idx, mgmt_id)
    view = Map.delete(state.view_id_idx, view_id)

    {%{state | secrets: secrets, mgmt_id_idx: mgmt, view_id_idx: view}, content}
  end
end
