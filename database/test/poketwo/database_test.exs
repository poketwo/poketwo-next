defmodule Poketwo.DatabaseTest do
  use ExUnit.Case
  doctest Poketwo.Database

  test "greets the world" do
    assert Poketwo.Database.hello() == :world
  end
end
