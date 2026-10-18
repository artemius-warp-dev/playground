# Given a list of players. Pair up players so that:
# 1. Each player gives a gift ones
# 2. Each player receives a gift ones
# 3. Players can't receives or gives gifts themselfs
# 4. Selectionss must be random

# Example input: [Barney, Wilma, Fred, Pablo, Bam Bam]
# Example output: [[Barney, Wilma], [Fred, Betty], [etc, etc]]

# [
#   Barney,   
#   Wilma,
#   Fred,
#   Pablo,
#   Bam Bam
# ]

# Pablo

# hat = [
#   Wilma
# ]

# result = [
#   [Barney, Pablo], [Wilma, Barney], [Fred, Bam Bam], [Pablo, Fred], [Bam Bam, Wilma]
# ]

defmodule SecretSanta do
  def go(players) do
    players
    |> Enum.reduce({init_hat(players), []}, &match_players/2)
    |> then(fn {_, result} -> Enum.reverse(result) end)
  end

  defp match_players(name, {hat, result}) do
    player_from_hat = get_from_hat(hat, name)
    {update_hat(hat, player_from_hat), [[name, player_from_hat] | result]}
  end

  defp init_hat(players), do: players

  defp update_hat(hat, name) do
    List.delete(hat, name)
  end

  defp get_from_hat([name], name), do: name
  defp get_from_hat(hat, name) do
    updated_hat = List.delete(hat, name)
    #IO.inspect({updated_hat, name})
    Enum.random(updated_hat)
  end
end

SecretSanta.go([
  "Barney",
  "Wilma",
  "Bam Bam"
])
|> IO.inspect()
