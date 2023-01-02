defmodule Fuel do
  require Logger

  @epochs 30
  @learning_rate 0.001
  @dropout_rate 0.1

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
    data = Enum.zip(train_inputs, train_targets)

    model =
      Axon.input("input", shape: {nil, Enum.count(@input_columns)})
      |> Axon.dense(10)
      |> Axon.dropout(rate: @dropout_rate)
      |> Axon.dense(1)

    params =
      model
      |> Axon.Loop.trainer(:mean_squared_error, Axon.Optimizers.adamw(@learning_rate))
      |> Axon.Loop.metric(:accuracy)
      |> Axon.Loop.run(data, %{}, epochs: @epochs, compiler: EXLA)

    {_init_fn, predict_fn} = Axon.build(model)

    # make some predictions
    test_inputs
    |> Enum.zip(test_targets)
    |> Enum.each(fn {car_input, actual_mpg} ->
      predicted_mpg = predict_fn.(params, car_input)
      Logger.info("Actual: #{scalar(actual_mpg)}. Predicted: #{scalar(predicted_mpg)}")
    end)
  end

  def scalar(tensor) do
    tensor |> Nx.to_flat_list() |> List.first()
  end
end
