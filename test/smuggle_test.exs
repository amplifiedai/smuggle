defmodule SmuggleTest do
  use ExUnit.Case
  doctest Smuggle

  test "greets the world" do
    assert Smuggle.hello() == :world
  end
end
