defmodule OffsiteWeb.Components.VideoModal do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Phoenix.LiveView.JS

  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal">
      <div
        id="modal-content"
        class="phx-modal-content absolute left-0 right-0 m-auto top-24 w-2/3 h-3/4 p-4 flex justify-center bg-slate-800 rounded"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <a id="close" href="#" class="phx-modal-close" phx-click="close-play-modal">✖</a>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
