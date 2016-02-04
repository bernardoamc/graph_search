defmodule DepthSearchTest do
  use ExUnit.Case

  setup do
    {:ok, %{matrix: [[0,1,0],[0,0,1],[0,0,0]], root: 0, current_node: 1}}
  end

  test "returns the path taken when an answer is found", %{matrix: matrix, root: root, current_node: cnode} do
    goal = 2
    assert GraphSearch.DepthSearch.search(matrix, goal, [cnode], [root]) == [0,1,2]
  end

  test "returns empty list when no answer is found", %{matrix: matrix, root: root, current_node: cnode} do
    goal = 3
    assert GraphSearch.DepthSearch.search(matrix, goal, [cnode], [root]) == []
  end
end
