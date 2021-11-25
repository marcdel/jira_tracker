defmodule JiraTrackerWeb.StoryPointComponent do
  use JiraTrackerWeb, :live_component

  @impl true
  def render(%{points: nil, id: id} = assigns) do
    ~H"""
    <div>
      <span phx-click="point_story" phx-value-id={id} phx-value-points="0" phx-disable-with="..." title="Point this story a 0" class="inline-flex items-center cursor-pointer px-1.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 hover:bg-gray-200">
        0
      </span>
      <span phx-click="point_story" phx-value-id={id} phx-value-points="1" phx-disable-with="..." title="Point this story a 1" class="inline-flex items-center cursor-pointer px-1.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 hover:bg-gray-200">
        1
      </span>
      <span phx-click="point_story" phx-value-id={id} phx-value-points="2" phx-disable-with="..." title="Point this story a 2" class="inline-flex items-center cursor-pointer px-1.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 hover:bg-gray-200">
        2
      </span>
      <span phx-click="point_story" phx-value-id={id} phx-value-points="3" phx-disable-with="..." title="Point this story a 3" class="inline-flex items-center cursor-pointer px-1.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 hover:bg-gray-200">
        3
      </span>
      <span phx-click="point_story" phx-value-id={id} phx-value-points="5" phx-disable-with="..." title="Point this story a 5" class="inline-flex items-center cursor-pointer px-1.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 hover:bg-gray-200">
        5
      </span>
      <span phx-click="point_story" phx-value-id={id} phx-value-points="8" phx-disable-with="..." title="Point this story an 8" class="inline-flex items-center cursor-pointer px-1.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 hover:bg-gray-200">
        8
      </span>
    </div>
    """
  end

  @impl true
  def render(%{points: points} = assigns) do
    ~H"""
    <span class="inline-flex items-center px-1.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
      <%= points %>
    </span>
    """
  end
end
