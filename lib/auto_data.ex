defmodule AutoData do
  @column_names %{
    "MPG" => 0,
    "Cylinders" => 1,
    "Displacement" => 2,
    "Horsepower" => 3,
    "Weight" => 4,
    "Acceleration" => 5,
    "Model Year" => 6,
    "USA" => 7,
    "Europe" => 8,
    "Japan" => 9,
    "Name" => 10
  }

  def split_inputs(filename, opts \\ []) do
    input_columns = Keyword.fetch!(opts, :input_columns)
    target_column = Keyword.fetch!(opts, :target_column)
    test_train_ratio = Keyword.fetch!(opts, :test_train_ratio)

    parsed =
      filename
      |> File.stream!()
      |> Enum.map(&convert/1)
      |> Enum.reject(&is_nil/1)

    {test_inputs, train_inputs} =
      parsed
      |> slice_columns(input_columns)
      |> HackyTools.hacky_normalize()
      |> Enum.map(&Nx.tensor/1)
      |> split(test_train_ratio)

    {test_targets, train_targets} =
      parsed
      |> slice_columns([target_column])
      |> Enum.map(fn a ->
        Nx.tensor([a])
      end)
      |> split(test_train_ratio)

    {
      test_inputs,
      test_targets,
      train_inputs,
      train_targets
    }
  end

  defp split(rows, ratio) do
    count = Enum.count(rows)
    Enum.split(rows, ceil(count * ratio))
  end

  def convert(line) do
    <<
      mpg::binary-size(7),
      cylinders::binary-size(4),
      displacement::binary-size(11),
      horsepower::binary-size(11),
      weight::binary-size(11),
      acceleration::binary-size(7),
      model_year::binary-size(4),
      country_code::binary-size(1),
      name::binary
    >> = line

    [
      mpg |> String.trim() |> String.to_float(),
      cylinders |> String.trim() |> String.to_integer(),
      displacement |> String.trim() |> String.to_float(),
      horsepower |> String.trim() |> String.to_float(),
      weight |> String.replace(".", "") |> String.trim() |> String.to_integer(),
      acceleration |> String.trim() |> String.to_float(),
      (model_year |> String.trim() |> String.to_integer()) + 1900
    ] ++
      one_hot_country(country_code) ++
      [name |> String.trim() |> String.replace("\"", "")]
  rescue
    e in ArgumentError ->
      unless e.message =~ "not a textual representation of a float" do
        raise e
      end
  end

  defp slice_columns(data, columns) do
    column_indexes =
      columns
      |> Enum.map(fn name -> Map.get(@column_names, name) end)
      |> Enum.reverse()

    data
    |> Stream.map(fn row ->
      column_indexes
      |> Enum.reduce([], fn index, out ->
        value = Enum.at(row, index)
        [value | out]
      end)
    end)
  end

  defp one_hot_country("1"), do: [1, 0, 0]
  defp one_hot_country("2"), do: [0, 1, 0]
  defp one_hot_country("3"), do: [0, 0, 1]
end
