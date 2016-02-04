defmodule GraphSearch do
  use Application

  alias GraphSearch.DepthSearch

  def start(_type, _args) do
    GraphSearch.Supervisor.start_link()
  end

  def start_link(search_type, matrix, current_node, root, goal, search_ref, owner) do
    search_type.start_link(matrix, current_node, root, goal, search_ref, owner)
  end

  def compute(matrix, root, goal, opts \\ []) do
    search_type = opts[:search_type] || DepthSearch

    matrix
      |> search_type.search_child_nodes(root)
      |> Enum.map(&spawn_search(search_type, matrix, &1, root, goal))
      |> await_results(opts)
  end

  defp spawn_search(search_type, matrix, current_node, root, goal) do
    search_ref = make_ref()
    opts = [search_type, matrix, current_node, root, goal, search_ref, self()]
    {:ok, pid} = Supervisor.start_child(GraphSearch.Supervisor, opts)
    monitor_ref = Process.monitor(pid)
    {pid, monitor_ref, search_ref}
  end

  defp await_results(children, opts) do
    timeout = opts[:timeout] || 10000
    timer = Process.send_after(self(), :timedout, timeout)
    result = await_result(children, [], :infinity)
    cleanup(timer)
    result
  end

  defp await_result([head|tail], result, timeout) do
    {pid, monitor_ref, search_ref} = head

    receive do
      {:results, ^search_ref, []} ->
        Process.demonitor(monitor_ref, [:flush])
        await_result(tail, [], timeout)
      {:results, ^search_ref, answer} ->
        Process.demonitor(monitor_ref, [:flush])
        await_result(tail, answer, 0)
      {:DOWN, ^monitor_ref, :process, ^pid, _reason} ->
        await_result(tail, result, timeout)
      :timedout ->
        kill(pid, monitor_ref)
        await_result(tail, result, 0)
    after
      timeout ->
        kill(pid, monitor_ref)
        await_result(tail, result, 0)
    end
  end

  defp await_result([], result, _) do
    result
  end

  defp kill(pid, ref) do
    Process.demonitor(ref, [:flush])
    Process.exit(pid, :kill)
  end

  defp cleanup(timer) do
    :erlang.cancel_timer(timer)
    receive do
      :timedout -> :ok
    after
      0 -> :ok
    end
  end
end
