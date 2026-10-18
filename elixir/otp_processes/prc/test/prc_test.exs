defmodule PrcTest do
  use ExUnit.Case
  doctest Prc

  test "greets the world" do
    assert Prc.hello() == :world
  end
end
