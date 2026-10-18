for _ <- 1..100 do
    case :rand.uniform(100) do
      hit when hit in [1,2,3,4,5] -> true
      _ -> false
    end
end
|> IO.inspect()
