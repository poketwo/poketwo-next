defmodule Poketwo.Database.Filter.Numeric do
  def parse(text, multiply_float_by \\ 1) do
    {op, rest} = parse_op(text)

    case rest |> String.trim() |> Float.parse() do
      {number, ""} -> {op, round(number * multiply_float_by)}
      _ -> nil
    end
  end

  defp parse_op("<=" <> rest), do: {:<=, rest}
  defp parse_op("<" <> rest), do: {:<, rest}
  defp parse_op(">=" <> rest), do: {:>=, rest}
  defp parse_op(">" <> rest), do: {:>, rest}
  defp parse_op("=" <> rest), do: {:==, rest}
  defp parse_op(rest), do: {:==, rest}
end
