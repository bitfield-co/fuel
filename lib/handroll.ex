defmodule Handroll do
  require Logger

  import Nx.Defn

  @epochs 30

  @input_columns [
    "Cylinders",
    "Displacement",
    "Horsepower"
  ]

  def run_example() do
    # split the data into test and train sets, each with inputs and targets
    {test_inputs, test_targets, train_inputs, train_targets} =
      AutoData.split_inputs(
        "./auto-mpg.data",
        input_columns: @input_columns,
        target_column: "MPG",
        test_train_ratio: 0.01
      )

    # train the model
    model = train(train_inputs, train_targets)

    # make some predictions
    test_inputs
    |> Enum.zip(test_targets)
    |> Enum.each(fn {car_input, actual_mpg} ->
      predicted_mpg =
        predict(model, car_input)
        |> scalar()

      Logger.info("Actual: #{scalar(actual_mpg)}. Predicted: #{predicted_mpg}")
    end)
  end

  def train(training_data, targets) do
    init_params = init_random_params()

    data = Enum.zip([training_data, targets])

    Enum.reduce(1..@epochs, init_params, fn epoch, params ->
      IO.write("#{epoch} ")

      Enum.reduce(data, params, fn {input, target}, cur_params ->
        update(cur_params, input, target)
      end)
    end)
  end

  defn update({m, b} = params, input, target) do
    {grad_m, grad_b} = grad(params, &loss(&1, input, target))

    {
      m - grad_m * 0.01,
      b - grad_b * 0.01
    }
  end

  defn loss(params, x, y) do
    y_pred = predict(params, x)
    Nx.mean(Nx.power(y - y_pred, 2))
  end

  defn predict({m, b}, x) do
    x
    |> Nx.dot(m)
    |> Nx.add(b)
  end

  defn init_random_params do
    weights = Nx.random_normal({3, 1}, 0.0, 0.1)
    bias = Nx.random_normal({1, 1}, 0.0, 0.1)
    {weights, bias}
  end

  defp scalar(tensor) do
    tensor |> Nx.to_flat_list() |> List.first()
  end
end
