defmodule OffsiteWeb.DownloadLive.FormComponent do
  use OffsiteWeb, :live_component

  alias Offsite.Downloads

  def handle_event("save", %{"download" => download_params}, socket) do
    save_download(socket, download_params)
  end

  defp save_download(socket, download_params) do
    {:ok, id} = Downloads.create_download(download_params)

    {:noreply, put_flash(socket, :info, "Download created successfully")}
  end
end
