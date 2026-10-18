defmodule ElixirTrees do
  alias ElixirTrees.Tree
  alias ElixirTrees.BTree

  @moduledoc """
  Documentation for `ElixirTrees`.
  """

  @data [8,12,4,7,1,0,5,2,7,4]

  def main() do
    # IO.inspect(@data)
    # build_btree(@data)
    # |> in_order()
    build_tree(@data)
  end

  # defp build_btree(data) do
  #   {root, rest_list} =
  #     List.pop_at(
  #       data,
  #       0..length(data) -1 |> Enum.random
  #     )

  #   Enum.reduce(rest_list, %BTree{value: root}, fn e, acc ->
  #     insert_node(acc, e)
  #   end)
  # end

  # defp insert_node(nil, elem) do
  #   %BTree{value: elem}
  # end

  # defp insert_node(%BTree{value: value} = btree, elem) when elem > value do
  #   Map.update!(btree, :right, &insert_node(&1, elem))
  # end

  # defp insert_node(%BTree{value: value} = btree, elem) when elem <= value do
  #   Map.update!(btree, :left, &insert_node(&1, elem))
  # end

  # defp in_order(nil), do: []

  # defp in_order(tree) do
  #   in_order(tree.left) ++ [tree.value] ++ in_order(tree.right)
  # end

  defp build_tree(data) do
    {root, rest_list} =
      List.pop_at(
        data,
        0
      )

    Enum.reduce(rest_list, %Tree{value: root}, fn e, acc ->
      insert_node(acc, e)
    end)
  end

  defp insert_node(%Tree{children: children} = tree, elem) when length(children) < 2 do
    %{tree | children: [%Tree{value: elem} | tree.children]}
    |>IO.inspect()
  end

  defp insert_node(tree, elem) do
    Map.update!(tree, :children, fn ch ->
      {branch, rest} = select_child(tree, ch, elem)
      [insert_node(branch, elem), rest] 
    end)
  end

  defp select_child(parent, children, elem) when length(children) == 2 do
    [left, right] = children

    case elem >= parent.value do
      true ->
        {right, left}

      false ->
        {left, right}
    end
  end

  defp select_child(parent, _children, _elem), do: parent
end
