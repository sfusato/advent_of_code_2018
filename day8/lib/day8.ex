defmodule Day8 do
  @moduledoc """
  Documentation for Day8.
  """
  def part_1(input) do
    input
    |> parse_input()
    |> process_tree()
    |> sum_metadata()
  end

  def part_2(input) do
    input
    |> parse_input()
    |> process_tree()
    |> indexed_sum()
  end

  @doc """
      iex> Day8.parse_input("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")
      [2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]
  """
  def parse_input(input) do
    input
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def process_tree(input) do
    {root, []} = tree_node(input)

    root
  end

  def tree_node([children_count, metadata_count | rest]) do
    {children, rest} = children(children_count, rest, [])
    {metadata, rest} = Enum.split(rest, metadata_count)
    {{children, metadata}, rest}
  end

  def children(0, rest, children) do
    {Enum.reverse(children), rest}
  end

  def children(count, rest, acc) do
    {node, rest} = tree_node(rest)
    children(count - 1, rest, [node | acc])
  end

  def sum_metadata(tree) do
    sum_metadata(tree, 0)
  end

  def sum_metadata({children, metadata}, acc) do
    acc + Enum.sum(metadata) + Enum.reduce(children, 0, &sum_metadata/2)
  end

  def indexed_sum({[], metadata}) do
    Enum.sum(metadata)
  end

  def indexed_sum({children, metadata}) do
    indexed_sums = Enum.map(children, &indexed_sum/1)

    for index <- metadata,
        sum = Enum.at(indexed_sums, index - 1) do
      sum
    end
    |> Enum.sum()
  end
end
