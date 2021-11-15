defmodule JiraTrackerWeb.StoryTypeComponent do
  use JiraTrackerWeb, :live_component

  @impl true
  def render(%{type: type} = assigns) do
    case type do
      "Feature" -> feature_svg(assigns)
      "Chore" -> chore_svg(assigns)
      "Bug" -> bug_svg(assigns)
      _ -> default_svg(assigns)
    end
  end

  defp feature_svg(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="orange" viewBox="0 0 30 30" stroke="currentColor">
      <title>Feature</title>
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z" />
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.879 16.121A3 3 0 1012.015 11L11 14H9c0 .768.293 1.536.879 2.121z" />
    </svg>
    """
  end

  defp chore_svg(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 30 30" stroke="currentColor">
      <title>Chore</title>
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
    </svg>
    """
  end

  defp bug_svg(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="red" viewBox="0 0 30 30" stroke="currentColor">
      <title>Bug</title>
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192l-3.536 3.536M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-5 0a4 4 0 11-8 0 4 4 0 018 0z" />
    </svg>
    """
  end

  defp default_svg(assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 30 30" fill="currentColor">
      <title><%= assigns.type %></title>
      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z" clip-rule="evenodd" />
    </svg>
    """
  end
end
