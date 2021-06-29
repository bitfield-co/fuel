defmodule FuelTest do
  use ExUnit.Case
  doctest Fuel

  test "greets the world" do
    Fuel.run_example()
  end
end
