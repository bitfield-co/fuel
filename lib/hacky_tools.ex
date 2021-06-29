defmodule HackyTools do
  @doc """
  Transpose `list`, normalize it, and then transpose it back to it's original shape.
  Uses Enum and is probably horribly naive, slow, and bug-ridden
  """
  def hacky_normalize(list) do
    list
    |> hacky_transpose()
    |> Enum.map(&normalize/1)
    |> hacky_transpose()
  end

  defp hacky_transpose(input) do
    IO.inspect(input)

    input
    |> Enum.reduce([], fn values, output ->
      output =
        values
        |> Enum.with_index()
        |> Enum.reduce(output, fn {v, i}, acc ->
          case Enum.at(acc, i) do
            nil ->
              List.insert_at(acc, i, [v])

            list ->
              list = list ++ [v]
              List.replace_at(acc, i, list)
          end
        end)

      output
    end)
  end

  defp normalize(xs) do
    max = Enum.max(xs)
    min = Enum.min(xs)
    range = max - min

    Enum.map(xs, fn x ->
      case range do
        0 ->
          1.0

        0.0 ->
          1.0

        r ->
          (x - min) / r
      end
    end)
  end
end
