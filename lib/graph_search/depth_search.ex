defmodule GraphSearch.DepthSearch do
  def start_link(matrix, current_node, root, goal, search_ref, owner) do
    Task.start_link(__MODULE__, :fetch, [matrix, goal, [current_node], [root], search_ref, owner])
  end

  def fetch(matrix, goal, nodes, visited, search_ref, owner) do
    result = search(matrix, goal, nodes, visited)
    send(owner, {:results, search_ref, result})
  end

  # Path found
  def search(_, goal, [goal|_], visited) do
    [goal|visited]
      |> Enum.reverse
  end

  # Path not found
  def search(_, _, [], _) do
    []
  end

  # Still searching
  def search(matrix, goal, [current_node|nodes], visited_nodes) do
    child_nodes = search_child_nodes(matrix, current_node)
    node_stack = child_nodes ++ nodes
    new_visited_nodes = [current_node|visited_nodes]

    search(matrix, goal, node_stack, new_visited_nodes)
  end

  def search_child_nodes(adjacency_matrix, node) do
    Enum.at(adjacency_matrix, node)
      |> Enum.with_index
      |> Enum.reduce([], &add_node/2)
  end

  defp add_node({1, node}, paths), do: paths ++ [node]
  defp add_node(_, paths), do: paths
end
