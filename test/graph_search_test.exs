
defmodule GraphSearchTest do
  use ExUnit.Case
  doctest GraphSearch

  defmodule TestSearch do
    def start_link(matrix, current_node, root, goal, search_ref, owner) do
      Task.start_link(__MODULE__, :fetch, [matrix, goal, [current_node], [root], search_ref, owner])
    end

    def fetch([[0,1],[0,0]], _goal, _nodes, _visited, ref, owner) do
      send(owner, {:results, ref, [0,1]})
    end

    def fetch([[0,0],[0,0]], _goal, _nodes, _visited, ref, owner) do
      send(owner, {:results, ref, []})
    end

    def fetch([[0,1,0],[1,0,0],[0,0,0]], _goal, _nodes, _visited, _ref, owner) do
      send(owner, {:backend, self()})
      :timer.sleep(:infinity)
    end

    def fetch([], _matrix, _goal, _nodes, _visited, _ref, _owner) do
      raise "boom!"
    end

    def search_child_nodes(_matrix, _node) do
      [1]
    end
  end

  test "search with results" do
    assert GraphSearch.compute([[0,1],[0,0]], 0, 1, search_type: TestSearch) == [0,1]
  end

  test "compute with no backend results" do
    assert GraphSearch.compute([[0,0],[0,0]], 0, 1, search_type: TestSearch) == []
  end

  test "compute with timeout returns no results and kills workers" do
    results = GraphSearch.compute([[0,1,0],[1,0,0],[0,0,0]], 0, 2, search_type: TestSearch, timeout: 10)
    assert results == []
    assert_receive {:backend, backend_pid}

    ref = Process.monitor(backend_pid)
    assert_receive {:DOWN, ^ref, :process, _pid, _reason}
    refute_received {:DOWN, _, _, _, _}
    refute_received :timedout
  end

  @tag :capture_log
  test "compute discards backend errors" do
    assert GraphSearch.compute([], 0, 5, search_type: TestSearch) == []
    refute_received {:DOWN, _, _, _, _}
    refute_received :timedout
  end
end
