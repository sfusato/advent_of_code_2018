defmodule Day13 do
  defmodule Cart do
    defstruct direction: nil, next_intersection: nil
  end

  defmodule WorldMap do
    defstruct map: %{}, carts: %{}
  end

  @doc """
      iex> Day13.part_1(
      ...> \"""
      ...> |
      ...> v
      ...> |
      ...> |
      ...> |
      ...> ^
      ...> |
      ...> \""")
      {0, 3}
  """
  def part_1(input \\ File.read!("./input.txt")) do
    input
    |> parse_input()
    |> tick()
  end

  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn row -> row |> String.graphemes() |> Enum.with_index() end)
    |> Enum.with_index()
    |> Enum.reduce(%WorldMap{}, fn {row, y}, state ->
      Enum.reduce(row, state, fn {segment, x}, state ->
        case segment do
          h when h in ["<", ">"] ->
            cart = %Cart{direction: h, next_intersection: :left}
            new_carts = Map.put(state.carts, {x, y}, cart)
            new_map = Map.put(state.map, {x, y}, "-")
            %{state | carts: new_carts, map: new_map}

          v when v in ["v", "^"] ->
            cart = %Cart{direction: v, next_intersection: :left}
            new_carts = Map.put(state.carts, {x, y}, cart)
            new_map = Map.put(state.map, {x, y}, "|")
            %{state | carts: new_carts, map: new_map}

          road_segment when road_segment in ["/", "\\", "+", "-", "|"] ->
            new_map = Map.put(state.map, {x, y}, road_segment)
            %{state | map: new_map}

          _ ->
            state
        end
      end)
    end)
  end

  def tick(state) do
    Enum.reduce_while(1..1_000_000, state, fn _i, state ->
      new_carts =
        state.carts
        |> sort_carts()
        |> find_crash(%{}, state.map, nil)

      case new_carts do
        {x, y} -> {:halt, {x, y}}
        new_carts -> {:cont, %{state | carts: new_carts}}
      end
    end)
  end

  def find_crash([], moved_carts, _world_map, nil), do: moved_carts

  def find_crash([{{x, y}, cart} | still_carts], moved_carts, world_map, nil) do
    {{x, y}, cart} = move_cart({x, y}, cart, world_map)

    if Map.has_key?(moved_carts, {x, y}) or
         Enum.find_value(still_carts, false, fn {{xx, yy}, _} -> {xx, yy} == {x, y} end) do
      find_crash([], [], world_map, {x, y})
    else
      moved_carts = Map.put(moved_carts, {x, y}, cart)
      find_crash(still_carts, moved_carts, world_map, nil)
    end
  end

  def find_crash(_, _, _, crash_coordinates), do: crash_coordinates

  def move_cart({x, y}, cart, world_map) do
    {x, y} =
      case cart.direction do
        "^" -> {x, y - 1}
        "v" -> {x, y + 1}
        "<" -> {x - 1, y}
        ">" -> {x + 1, y}
      end

    {new_direction, new_next_intersection} =
      case {Map.fetch!(world_map, {x, y}), cart.direction} do
        {"+", direction} -> handle_intersection(direction, cart.next_intersection)
        {"/", "^"} -> {">", cart.next_intersection}
        {"/", "<"} -> {"v", cart.next_intersection}
        {"/", "v"} -> {"<", cart.next_intersection}
        {"/", ">"} -> {"^", cart.next_intersection}
        {"\\", "^"} -> {"<", cart.next_intersection}
        {"\\", "<"} -> {"^", cart.next_intersection}
        {"\\", "v"} -> {">", cart.next_intersection}
        {"\\", ">"} -> {"v", cart.next_intersection}
        {_, direction} -> {direction, cart.next_intersection}
      end

    {{x, y}, %{cart | direction: new_direction, next_intersection: new_next_intersection}}
  end

  def handle_intersection("<", :left), do: {"v", :straight}
  def handle_intersection(">", :left), do: {"^", :straight}
  def handle_intersection("^", :left), do: {"<", :straight}
  def handle_intersection("v", :left), do: {">", :straight}

  def handle_intersection("<", :right), do: {"^", :left}
  def handle_intersection(">", :right), do: {"v", :left}
  def handle_intersection("^", :right), do: {">", :left}
  def handle_intersection("v", :right), do: {"<", :left}

  def handle_intersection("<", :straight), do: {"<", :right}
  def handle_intersection(">", :straight), do: {">", :right}
  def handle_intersection("^", :straight), do: {"^", :right}
  def handle_intersection("v", :straight), do: {"v", :right}

  @doc """
      iex> Day13.sort_carts(%{{0, 1} => "4", {3, 1} => "5", {0, 0} => "1", {3, 0} => "3", {2, 0} => "2"})
      [{{0, 0}, "1"}, {{2, 0}, "2"}, {{3, 0}, "3"}, {{0, 1}, "4"}, {{3, 1}, "5"}]
  """
  def sort_carts(carts) do
    carts
    |> Enum.sort_by(fn {{x, y}, _} -> [y, x] end)
  end
end
