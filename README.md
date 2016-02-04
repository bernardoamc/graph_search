# GraphSearch

**This is a small [Elixir](http://elixir-lang.org/) project that search paths
in graphs built with an adjacency matrix. The current implementation find childs
of the root node and creates a new process for each child, this means that each
process will theoretically search a branch of the graph until one of them find a
path from the root to the target node.**

**It is important to note that this will not always return the shortest path,
it will return the path that was found first. Most of the time it is the
shortest.**

## Example

```elixir
iex(1)> adjacency_matrix = [
#  A  B  C  D  E  F  G
  [0, 1, 1, 1, 0, 0, 0], #A
  [0, 0, 0, 1, 1, 0, 0], #B
  [0, 0, 0, 0, 0, 1, 1], #C
  [0, 0, 0, 0, 1, 0, 0], #D
  [0, 0, 0, 0, 0, 1, 1], #E
  [0, 0, 0, 0, 0, 0, 0], #F
  [0, 0, 0, 0, 0, 0, 0]  #G
]

iex(2)> GraphSearch.compute(matrix, 0, 5)
[0, 3, 4, 5]
```

This means that we want to find a path from node 'A' to node 'F' and the path
found involves the nodes 'A', 'D', 'E' and 'F'.
