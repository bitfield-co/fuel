defmodule Fuel do
  require Axon
  require Logger

  @epochs 30
  @learning_rate 0.001
  @loss :mean_absolute_error
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
    model = train(train_inputs, train_targets)

    # make some predictions
    test_inputs
    |> Enum.zip(test_targets)
    |> Enum.each(fn {car_input, actual_mpg} ->
      predicted_mpg = predict(model, car_input)
      Logger.info("Actual: #{scalar(actual_mpg)}. Predicted: #{predicted_mpg}")
    end)
  end

  def train(inputs, targets) do
    model =
      Axon.input({nil, Enum.count(@input_columns)})
      |> Axon.dense(10)
      |> Axon.dropout(rate: @dropout_rate)
      |> Axon.dense(1)

    Logger.info(inspect(model))

    optimizer = Axon.Optimizers.adamw(@learning_rate)

    %{params: trained_params} =
      model
      |> Axon.Training.step(@loss, optimizer)
      |> Axon.Training.train(inputs, targets, epochs: @epochs)

    {model, trained_params}
  end

  def predict({model, trained_params}, car_input) do
    model
    |> Axon.predict(trained_params, car_input)
    |> Nx.to_flat_list()
    |> List.first()
  end

  def scalar(tensor) do
    tensor |> Nx.to_flat_list() |> List.first()
  end
end
