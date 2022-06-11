defmodule Poketwo.Database.Utils do
  def string_value(nil), do: nil
  def string_value(""), do: nil
  def string_value(value) when is_binary(value), do: Google.Protobuf.StringValue.new(value: value)

  def if_loaded(%Ecto.Association.NotLoaded{}, _func), do: nil
  def if_loaded(val, func), do: func.(val)
  def map_if_loaded(val, func), do: if_loaded(val, fn x -> Enum.map(x, func) end)

  def unwrap(%mod{value: value})
      when mod in [
             Google.Protobuf.Int32Value,
             Google.Protobuf.UInt32Value,
             Google.Protobuf.UInt64Value,
             Google.Protobuf.Int64Value,
             Google.Protobuf.FloatValue,
             Google.Protobuf.DoubleValue,
             Google.Protobuf.BoolValue,
             Google.Protobuf.StringValue
           ] do
    value
  end

  def unwrap(%{} = message) do
    message
    |> Map.from_struct()
    |> Enum.map(fn {k, v} -> {k, unwrap(v)} end)
    |> Enum.filter(fn {_, v} -> not is_nil(v) end)
    |> Enum.into(%{})
  end

  def unwrap(value) do
    IO.inspect(value)
  end

  defmacro from_info(queryable) do
    quote do
      import Ecto.Query

      from(gi in unquote(queryable),
        left_join: l in assoc(gi, :language),
        order_by: l.order,
        where: l.enabled,
        preload: :language
      )
    end
  end
end
