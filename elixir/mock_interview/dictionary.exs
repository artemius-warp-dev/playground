# Task

# input: "cat", "car", "bar"

# function: setup(input)
# function: is_in_dict(word)

# setup(["cat", "car", "bar"])
# is_in_dict("cat") -> true
# is_in_dict("bat") -> false

# Wildcard

# is_in_dict("*at") -> true
# is_in_dict("b*t") -> false



# dict = {cat, car, bar}

# is_in_dict("*at") -> true
# *(c)at -> true
# *(b)at -> ?

# [
#   'cat'
#   'car'
#   'bar'
# ]

# '*at' ? ['cat', 'car', 'bar']




defmodule Dictionary do

  def setup(words) do
    words
    |> Enum.reduce(%{}, fn word, acc -> Map.put(acc, word, true)  end)
  end

  def dict?(dict, word) do
    cond do
      dict[word] -> true
      String.contains?(word, "*") and wildcard_match?(dict, word) -> true
      true -> false
    end
  end

  defp wildcard_match?(dict, word) do
    Map.keys(dict)
    |> Enum.any?(&(letters_match(&1, word)))
  end

  defp letters_match(word1, word2) do
    letters_1 = String.graphemes(word1)
    letters_2 = String.graphemes(word2)
    #IO.inspect({letters_1, letters_2, letters_1 -- letters_2, letters_2 -- letters_1})

    length(letters_1 -- letters_2) == 1 and length(letters_2 -- letters_1) == 1
  end

end

dict = ["cae", "can", "bar"]
|> Dictionary.setup()

Dictionary.dict?(dict, "cat")
|> IO.inspect()


Dictionary.dict?(dict, "*ar")
|> IO.inspect()

Dictionary.dict?(dict, "c*t")
|> IO.inspect()

Dictionary.dict?(dict, "*at")
|> IO.inspect()

Dictionary.dict?(dict, "b*t")
|> IO.inspect()
