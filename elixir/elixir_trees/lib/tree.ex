defmodule ElixirTrees.Tree do
  defstruct value: nil, key: nil, children: []
  @type t :: %ElixirTrees.Tree{value: any, key: any, children: [t]}
end

defmodule ElixirTrees.BTree do
  defstruct value: nil, left: nil, right: nil
end
