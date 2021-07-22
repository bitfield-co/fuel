defmodule FuelTest do
  use ExUnit.Case
  doctest Fuel

  test "handroll" do
    Handroll.run_example()
  end

  test "more" do
    inputs = [[8, 307, 130]] |> Nx.tensor()

    weights = Nx.random_normal({3, 4})
    bias = Nx.random_normal({1, 4})

    weights2 = Nx.random_normal({4, 1})
    bias2 = Nx.random_normal({1, 1})

    [mpg] =
      inputs
      |> Nx.dot(weights)
      |> Nx.add(bias)
      |> Nx.dot(weights2)
      |> Nx.add(bias2)
      |> Nx.to_flat_list()

    mpg |> IO.inspect()
    # => [1016]
  end
end
