defmodule BinarySearch do
  use Task

  @moduledoc """
  Documentation for `BinarySearch`.
  """

  @doc """
  """

  def binary_search_launch() do
    Task.async(fn ->
      Process.sleep(:timer.seconds(10))
      IO.inspect("hello")
    end)
    |> Task.await(15000)
  end

  @spec binary_search(tuple, integer) :: {:ok, integer} | :not_found
  def binary_search({}, _key), do: :not_found

  def bianry_search(tuple, key) do
    binary_search(tuple, key, 0, tuple_size(tuple))
  end

  def binary_search(tuple, key, low, high) do
    mid_index = div(low + high, 2)

    case elem(tuple, mid_index) do
      ^key -> {:ok, mid_index}
      element when element > key -> binary_search(tuple, key, low, mid_index - 1)
      element when element < key -> binary_search(tuple, key, mid_index + 1, high)
    end
  end
end
