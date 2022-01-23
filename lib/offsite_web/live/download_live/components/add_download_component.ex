defmodule OffsiteWeb.Components.AddDownloadComponent do
  use OffsiteWeb, :live_component

  import ShorterMaps
  alias Offsite.Downloaders.Direct

  @impl true
  def mount(socket) do
    {:ok, assign(socket, %{url: "", download_disabled: true})}
  end

  @impl true
  def handle_event("validate", %{"download" => ~m{url}}, socket) do
    uri = URI.parse(url)

    {
      :noreply,
      assign(
        socket,
        :download_disabled,
        if(uri.scheme != nil && uri.host =~ ".", do: false, else: true)
      )
    }
  end

  @impl true
  def handle_event("add-download", %{"download" => ~m{url}}, socket) do
    Direct.add(url)

    {
      :noreply,
      assign(socket, %{downloads: Direct.list(), url: nil, download_disabled: true})
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
      <section>
        <.form
          let={f}
          for={:download}
          phx-change="validate"
          phx-submit="add-download"
          phx_target={@myself}
          id="new_download_form"
          class="w-full relative left-16"
          >

          <%= text_input f, :url, value: @url, placeholder: "Paste your download link here...", class: "pl-2 w-10/12 inline-block text-gray-500 pr-4 h-9 border-2 border-neutral-800 rounded mr-4" %>
          <%= submit class: "bg-green-600 hover:bg-green-700 py-1 px-2 rounded inline-flex items-center disabled:opacity-50 disabled:cursor-no-drop", disabled: @download_disabled do %>
            <svg class="w-4 h-4 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M13 8V2H7v6H2l8 8 8-8h-5zM0 18h20v2H0v-2z"/></svg>
            <span>Download</span>
          <% end %>
        </.form>
      </section>
    """
  end
end
