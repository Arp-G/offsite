defmodule OffsiteWeb.Components.AddTorrentDownloadComponent do
  use OffsiteWeb, :live_component

  import ShorterMaps
  alias Offsite.Downloaders.Torrent

  @impl true
  def mount(socket) do
    {:ok, assign(socket, %{magnet: "", download_disabled: true})}
  end

  @impl true
  def handle_event("validate", %{"torrent" => ~m{magnet}}, socket) do
    {
      :noreply,
      assign(
        socket,
        :download_disabled,
        if(String.trim(magnet) == "", do: true, else: false)
      )
    }
  end

  @impl true
  def handle_event("add-torrent-download", %{"torrent" => ~m{magnet}}, socket) do
    socket =
      case Torrent.add(magnet) do
        {:error, reason} ->
          socket
          |> put_flash(:error, String.capitalize(reason))
          |> push_patch(to: "/")

        _ ->
          socket
          |> put_flash(:info, "Torrent download added succesfully!")
          |> push_patch(to: "/")
      end

    {:noreply, assign(socket, %{magnet: "", download_disabled: true})}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <section class="mb-6">
        <.form
          let={f}
          for={:torrent}
          phx-change="validate"
          phx-submit="add-torrent-download"
          phx_target={@myself}
          id="new_torrent_download_form"
          class="w-full relative left-16"
          >

          <%= text_input f, :magnet, value: @magnet, placeholder: "Paste your magnet link here...", class: "pl-2 w-10/12 inline-block text-gray-500 pr-4 h-9 border-2 border-neutral-800 rounded mr-4" %>
          <%= submit class: "bg-green-600 hover:bg-green-700 py-1 px-2 rounded inline-flex items-center disabled:opacity-50 disabled:cursor-no-drop", disabled: @download_disabled do %>
            <svg class="w-4 h-4 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M13 8V2H7v6H2l8 8 8-8h-5zM0 18h20v2H0v-2z"/></svg>
            <span>Add Torrent</span>
          <% end %>
        </.form>
        <div class="underline text-xs font-semibold text-blue-600 hover:text-blue-800 relative left-16 mt-2">
          <a href="/transmission/index.original.html"> Detailed torrents view </a>
        </div>
      </section>
    """
  end
end
