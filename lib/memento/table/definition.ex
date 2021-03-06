defmodule Memento.Table.Definition do
  @moduledoc false

  # Helper module to build Memento Tables with the `use` macro.
  # This module is used to define Memento Tables at compile
  # time, so this not be used directly (unless you absolutely
  # know what you're doing).




  @doc """
  Builds the base of the `match_spec`, to be later used
  in `select` calls. Should ideally be called once
  during compile-time.

  Takes attribute keywords or list `[:a, :b, :c, ...]`
  and converts them into `{module, :$1, :$2, ...}`
  """
  @spec build_base(Memento.Table.name, list) :: tuple
  def build_base(module, attributes) do
    attributes =
      attributes
      |> Enum.count
      |> Range.new(1)
      |> Enum.reverse
      |> Enum.map(&:"$#{&1}")

    List.to_tuple([ module | attributes ])
  end



  @doc """
  Builds a map with attributes and their corresponding
  keys, to later help with quickly replacing attributes
  with their ids. Should ideally be called once during
  compile-time.

  Takes attribute keywords `[a: nil, b: nil, ...]` or
  list, and converts them into `%{a: :$1, b: :$2, ...}`
  """
  @spec build_map(list) :: map
  def build_map(attributes) do
    attributes
    |> Enum.reduce({%{}, 1}, &build_reducer/2)
    |> elem(0)
  end



  @doc """
  Builds the list of fields to be passed to `defstruct`
  in the Table definition at compile-time.

  Prepends an extra `:__meta__` field with the default
  value of `Memento.Table`.
  """
  @spec build_map(list) :: list
  def struct_fields(attributes) do
    [{:__meta__, Memento.Table} | attributes]
  end





  # Private Helpers
  # ---------------


  # Helper function for building translation map.
  # Used in the reduce call inside `build_map`
  defp build_reducer(attr, {map, position}) when is_atom(attr) do
    {
      Map.put(map, attr, :"$#{position}"),
      position + 1
    }
  end

end
