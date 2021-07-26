defmodule FuelTest do
  use ExUnit.Case
  doctest Fuel

  test "Runs the Axon version" do
    Fuel.run_example()
  end

  test "red riding hood" do
    # destinations
    grandmas_house = 0
    wolfs_den = 1

    # directions
    left = -1.0
    right = 1.0

    # magical params
    params = [-1.0, 1.0]

    assert predict(params, grandmas_house) == left
    assert predict(params, wolfs_den) == right
  end

  def predict(params, destination) do
    Enum.at(params, destination)
  end
end
