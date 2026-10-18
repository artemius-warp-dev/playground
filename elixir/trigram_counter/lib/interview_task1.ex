defmodule InterviewTask1 do
  @moduledoc """
  Documentation for `InterviewTask1`.
  """

  @doc """
  The program accepts as arguments a list of one or more file paths (e.g. ./solution.rb file1.txt file2.txt ...).
  The program also accepts input on stdin (e.g. cat file1.txt | ./solution.rb).
  The program outputs a list of the 100 most common three word sequences in the text, along with a count of how many times each occurred in the text. For example: 231 - i will not, 116 i do not, 105 - there is no, 54 - i know not, 37 - i am not …
  The program ignores punctuation, line endings, and is case insensitive (e.g. “I love\nsandwiches.” should be treated the same as "(I LOVE SANDWICHES!!)")
  The program is capable of processing large files and runs as fast as possible.
  The program should be tested. Provide a test file for your solution.

  So, set your own pace. No rush. And just so you have some bounds, the challenge was designed to take somewhere between 2 and 3 hours. You could try it against "Origin Of Species" as a test: http://www.gutenberg.org/cache/epub/2009/pg2009.txt .
  """
  def main(args) do
    build_context(args, [])
    |> transform()
    |> output()
  end

  defp output(list) do
    list
    |> Enum.each(fn {{a, b, c}, count} ->
      IO.inspect("#{a} #{b} #{c} - #{count}")
    end)
  end

  defp transform(list) do
    map_build(%{}, list)
    |> Map.to_list()
    |> Enum.sort(fn {_, c1}, {_, c2} -> c1 >= c2 end)
    |> Enum.take(100)
  end

  def build_context([], list) do
    case IO.read(:stdio, :line) do
      :eof ->
        list

      {:error, reason} ->
        IO.inspect("Error: #{inspect(reason)}")

      line ->
        list = list ++ text_process(line)
        build_context([], list)
    end
  end

  def build_context(files, list) when is_list(files) do
    Enum.map(
      files,
      fn f ->
        File.stream!(f)
        |> Enum.to_list()
        |> Enum.reduce([], fn e, acc -> acc ++ text_process(e) end)
        |> transform()
        |> output()
      end
    )
  end

  defp text_process(text) do
    text
    |> String.upcase()
    |> String.trim()
    |> String.replace([",", ".", "!", ":"], "")
    |> String.split(" ")
  end

  defp map_build(map, []) do
    map
  end

  defp map_build(map, list) do
    {a, b, c, tail} = list_parse(list)

    count =
      case map[{a, b, c}] do
        nil ->
          0

        count ->
          count
      end

    add(map, {a, b, c}, count)
    |> map_build(tail)
  end

  defp add(map, {a, b, c}, count) when a != "" and b != "" and c != "" do
    Map.put(map, {a, b, c}, count + 1)
  end

  defp add(map, _, _) do
    map
  end

  defp list_parse(list) when length(list) == 2 do
    [a, b | tail] = list
    {a, b, "", tail}
  end

  defp list_parse(list) when length(list) == 1 do
    [a | tail] = list
    {a, "", "", tail}
  end

  defp list_parse(list) do
    [a, b, c | tail] = list
    {a, b, c, tail}
  end
end
