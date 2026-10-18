defmodule Todo.List do
  @moduledoc """
  Module to operate with to-do entries
  """

  defstruct auto_id: 1, entries: %{}

  @doc """
  Creating the new to-do list
  """
  @spec new(list()) :: %Todo.List{}
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{},
      &add_entry(&2, &1)
    )
  end

  @doc """
  Getting size of to-do list
  """
  @spec size(%Todo.List{}) :: integer()
  def size(todo_list) do
    map_size(todo_list.entries)
  end

  @doc """
  Adding new entry to the to-do list
  """
  @spec add_entry(%Todo.List{}, any()) :: %Todo.List{}
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %Todo.List{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  @doc """
  Getting entries from to-do list
  """
  @spec entries(%Todo.List{}, any()) :: list()
  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  @doc """
  Updating entry from to-do list
  """
  @spec update_entry(%Todo.List{}, map()) :: %Todo.List{}
  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  @spec update_entry(%Todo.List{}, integer, fun()) :: %Todo.List{}
  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  @doc """
  Deleting entry from to-do list
  """
  @spec delete_entry(%Todo.List{}, integer) :: %Todo.List{}
  def delete_entry(todo_list, entry_id) do
    %Todo.List{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end
