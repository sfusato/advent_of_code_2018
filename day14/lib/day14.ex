defmodule Day14 do
  defmodule Recipes do
    defstruct scoreboard: %{{3, 0} => {7, 1}},
              elf_1: {3, 0},
              elf_2: {7, 1},
              first_recipe_added: {3, 0},
              last_recipe_added: {7, 1},
              no_recipes: nil,
              last_ten: [],
              recipe_sequence: nil,
              last_ten_sequence: ""
  end

  @doc """
      iex> Day14.part_1(9)
      "5158916779"

      iex> Day14.part_1(5)
      "0124515891"

      iex> Day14.part_1(18)
      "9251071085"

      iex> Day14.part_1(2018)
      "5941429882"
  """
  def part_1(no_recipes \\ 503_761) do
    %Recipes{no_recipes: no_recipes}
    |> cook()
  end

  @doc """
      iex> Day14.part_2("51589")
      9

      iex> Day14.part_2("01245")
      5

      iex> Day14.part_2("92510")
      18

      iex> Day14.part_2("59414")
      2018
  """

  def part_2(recipe_sequence \\ "503761") do
    %Recipes{recipe_sequence: recipe_sequence}
    |> cook_part_2()
  end

  def cook(state) do
    Enum.reduce_while(1..1_000_000_000, state, fn _i, state ->
      new_recipe = Integer.digits(elem(state.elf_1, 0) + elem(state.elf_2, 0))

      {new_last_recipe_added, new_scoreboard} = add_recipe_to_scoreboard(new_recipe, state)

      new_elf_1 = move_elf_forward(state.elf_1, new_scoreboard)
      new_elf_2 = move_elf_forward(state.elf_2, new_scoreboard)

      new_last_ten =
        cond do
          map_size(new_scoreboard) == state.no_recipes + 1 and length(new_recipe) == 2 ->
            state.last_ten ++ tl(new_recipe)

          map_size(new_scoreboard) > state.no_recipes ->
            state.last_ten ++ new_recipe

          true ->
            state.last_ten
        end

      if length(new_last_ten) > 10 do
        {:halt, new_last_ten |> Enum.slice(0..9) |> Enum.join()}
      else
        {:cont,
         %{
           state
           | scoreboard: new_scoreboard,
             last_recipe_added: new_last_recipe_added,
             elf_1: new_elf_1,
             elf_2: new_elf_2,
             last_ten: new_last_ten
         }}
      end
    end)
  end

  def add_recipe_to_scoreboard(new_recipe, state) do
    case new_recipe do
      [x, y] ->
        {{y, elem(state.last_recipe_added, 1) + 2},
         state.scoreboard
         |> Map.put(state.last_recipe_added, {x, elem(state.last_recipe_added, 1) + 1})
         |> Map.put(
           {x, elem(state.last_recipe_added, 1) + 1},
           {y, elem(state.last_recipe_added, 1) + 2}
         )
         |> Map.put({y, elem(state.last_recipe_added, 1) + 2}, state.first_recipe_added)}

      [x] ->
        {{x, elem(state.last_recipe_added, 1) + 1},
         state.scoreboard
         |> Map.put(
           state.last_recipe_added,
           {x, elem(state.last_recipe_added, 1) + 1}
         )
         |> Map.put({x, elem(state.last_recipe_added, 1) + 1}, state.first_recipe_added)}
    end
  end

  def move_elf_forward(current_recipe, scoreboard) do
    Stream.iterate(current_recipe, &Map.fetch!(scoreboard, &1))
    |> Enum.at(elem(current_recipe, 0) + 1)
  end

  def cook_part_2(state) do
    Enum.reduce_while(1..1_000_000_000, state, fn _i, state ->
      new_recipe = Integer.digits(elem(state.elf_1, 0) + elem(state.elf_2, 0))

      {new_last_recipe_added, new_scoreboard} = add_recipe_to_scoreboard(new_recipe, state)

      new_elf_1 = move_elf_forward(state.elf_1, new_scoreboard)
      new_elf_2 = move_elf_forward(state.elf_2, new_scoreboard)

      new_recipe = Enum.join(new_recipe)
      new_last_ten = state.last_ten_sequence <> new_recipe

      new_last_ten =
        if String.length(new_last_ten) > 10 do
          String.slice(new_last_ten, -10..-1)
        else
          new_last_ten
        end

      if String.contains?(new_last_ten, state.recipe_sequence) do
        {:halt, map_size(state.scoreboard) - String.length(state.recipe_sequence) + 1}
      else
        {:cont,
         %{
           state
           | scoreboard: new_scoreboard,
             last_recipe_added: new_last_recipe_added,
             elf_1: new_elf_1,
             elf_2: new_elf_2,
             last_ten_sequence: new_last_ten
         }}
      end
    end)
  end
end
