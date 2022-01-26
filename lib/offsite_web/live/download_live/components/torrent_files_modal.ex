defmodule OffsiteWeb.Components.TorrentFilesModal do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS
  alias OffsiteWeb.Components.Modal
  alias Offsite.Helpers
  alias Offsite.Downloaders.Torrent
  alias OffsiteWeb.Router.Helpers, as: RouteHelpers

  def render(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
      <Modal.render>
        <div class="w-full h-full border-2 bg-slate-200 overflow-auto">
          <table class="table-fixed w-full shadow">
            <thead class="sticky top-0 bg-slate-200">
              <tr>
                <th class="download-header w-4">SL No</th>
                <th class="download-header w-52">Filename</th>
                <th class="download-header w-24">Progess</th>
                <th class="download-header w-24">Actions</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for {file, index} <- Enum.with_index(@torrent.files) do %>
                <tr id={file["name"]}>
                  <td class="m-2 bg-white shadow overflow-hidden text-center"> <%= index + 1 %> </td>
                  <td class="m-2 bg-white shadow overflow-hidden whitespace-nowrap text-ellipsis text-center" title={file["name"]}> <%= Path.basename(file["name"]) %> </td>
                  <td class="m-2 bg-white shadow overflow-hidden text-center"> <%= progress(file["bytesCompleted"], file["length"], assigns) %> </td>
                  <td class="m-2 bg-white shadow overflow-hidden text-center"> <%= action(file, assigns) %>  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </Modal.render>
    """
  end

  def progress(bytes_downloaded, size, assigns) do
    if bytes_downloaded && size do
      percentage = Helpers.to_int(bytes_downloaded) / Helpers.to_int(size) * 100

      ~H"""
      <div class="p-2">
        <div class="w-full bg-gray-200 rounded-full font-bold">
          <div class="leading-4 bg-green-600 font-bold text-center p-0.5 rounded-full h-5 transition-width text-xs" style={"width: #{percentage}%"}> 
            <%= trunc(percentage) %>% 
          </div>
        </div>
        <div class="text-xs mt-1"> <%= "#{Sizeable.filesize(bytes_downloaded)} / #{Sizeable.filesize(size)}" %> </div>
      </div>
      """
    else
      ~H"""
      NA
      """
    end
  end

  def action(file, assigns) do
    ~H"""
    <div class="flex flex-row text-red justify-center gap-2">
      <%= if file["bytesCompleted"] == file["length"] do %>
        <a title="download" href={
          RouteHelpers.downloads_path(
          OffsiteWeb.Endpoint,
          :download,
          @torrent.id,
          type: "torrent-file",
          path:  file["name"]
        )}>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7 cursor-pointer transition duration-100 hover:scale-110" viewBox="0 0 20 20" fill="green">
            <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </a>
      <% end %>

      <button title="Play" phx-click="open-modal-torrent" phx-value-type={"play-modal-torrent"} phx-value-path={file["name"]}>
        <svg class="h-6 w-6 cursor-pointer transition duration-100 hover:scale-110" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Layer_1" x="0px" y="0px" viewBox="0 0 502.119 502.119" style="enable-background:new 0 0 502.119 502.119;" xml:space="preserve" width="512" height="512"> <g> <g> 
          <path style="fill:#4D93E8;" d="M131.743,17.904L421.08,213.57c26.539,17.947,26.539,57.031,0,74.978L131.743,484.215 c-30.055,20.325-70.609-1.207-70.609-37.489V55.393C61.134,19.111,101.688-2.421,131.743,17.904z"/> <path d="M106.489,502.119c-8.834,0-17.716-2.185-26.01-6.589c-18.375-9.756-29.345-28-29.345-48.804V55.393 c0-20.804,10.97-39.048,29.345-48.804c18.373-9.756,39.634-8.622,56.865,3.032l289.337,195.667 c15.218,10.291,24.303,27.402,24.303,45.772s-9.085,35.481-24.303,45.772L137.345,492.498 C127.892,498.891,117.226,502.119,106.489,502.119z M106.454,20.05c-5.637,0-11.304,1.394-16.596,4.204 c-11.725,6.225-18.724,17.866-18.724,31.14v391.333c0,13.274,6.999,24.915,18.724,31.14c11.723,6.226,25.287,5.501,36.283-1.935 l289.337-195.667c9.854-6.664,15.506-17.309,15.506-29.205c0-11.896-5.651-22.541-15.506-29.205L126.142,26.188 C120.109,22.109,113.304,20.05,106.454,20.05z"/> </g> <g> <path d="M351.051,216.06c-1.932,0-3.882-0.558-5.602-1.723l-16.236-11.003c-4.571-3.098-5.767-9.316-2.668-13.888 c3.1-4.572,9.316-5.765,13.889-2.668l16.236,11.003c4.571,3.098,5.767,9.316,2.668,13.888 C357.404,214.522,354.256,216.06,351.051,216.06z"/> </g> <g> <path d="M304.051,184.209c-1.932,0-3.882-0.558-5.602-1.723l-195-132.149c-4.571-3.099-5.767-9.316-2.668-13.888 c3.1-4.572,9.316-5.765,13.889-2.668l195,132.149c4.571,3.099,5.767,9.316,2.668,13.888 C310.404,182.671,307.256,184.209,304.051,184.209z"/> </g> </g> 
        </svg>
      </button>
    </div>
    """
  end
end
