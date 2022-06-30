# Copyright (c) 2022 Oliver Ni
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

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
