defmodule Day13 do
  defmodule Cart do
    defstruct position: nil, direction: nil, next_intersection: nil
  end

  defmodule WorldMap do
    defstruct map: %{}, carts: %{}
  end

  # 1. {81, 30}
  def part_1(input \\ File.read!("./default_input.txt")) do
    input
    |> parse_input()
    |> thick()
  end

  def parse_input(input) do
    input
    |> String.split("\r\n")
    |> Enum.map(fn row -> row |> String.graphemes() |> Enum.with_index() end)
    |> Enum.with_index()
    |> Enum.reduce(%WorldMap{}, fn {row, y}, state ->
      Enum.reduce(row, state, fn {segment, x}, state ->
        case segment do
          "<" ->
            cart = %Cart{position: {x, y}, direction: "<", next_intersection: :left}
            new_carts = Map.put(state.carts, {x, y}, cart)
            new_map = Map.put(state.map, {x, y}, "-")
            %{state | carts: new_carts, map: new_map}

          ">" ->
            cart = %Cart{position: {x, y}, direction: ">", next_intersection: :left}
            new_carts = Map.put(state.carts, {x, y}, cart)
            new_map = Map.put(state.map, {x, y}, "-")
            %{state | carts: new_carts, map: new_map}

          "v" ->
            cart = %Cart{position: {x, y}, direction: "v", next_intersection: :left}
            new_carts = Map.put(state.carts, {x, y}, cart)
            new_map = Map.put(state.map, {x, y}, "|")
            %{state | carts: new_carts, map: new_map}

          "^" ->
            cart = %Cart{position: {x, y}, direction: "^", next_intersection: :left}
            new_carts = Map.put(state.carts, {x, y}, cart)
            new_map = Map.put(state.map, {x, y}, "|")
            %{state | carts: new_carts, map: new_map}

          " " ->
            state

          road_segment ->
            new_map = Map.put(state.map, {x, y}, road_segment)
            %{state | map: new_map}
        end
      end)
    end)
  end

  def thick(state) do
    Enum.reduce_while(1..1_000_000, state, fn i, state ->
      IO.inspect(i)

      new_carts =
        state.carts
        |> Enum.sort_by(&{&1 |> elem(0) |> elem(1), &1 |> elem(0) |> elem(0)})
        |> Enum.reduce_while(%{}, fn {{x, y}, cart}, seen_carts ->
          {{x, y}, cart} = move_cart({{x, y}, cart}, state.map)

          if Map.has_key?(seen_carts, {x, y}) do
            {:halt, {x, y}}
          else
            {:cont, Map.put(seen_carts, {x, y}, cart)}
          end
        end)

      case new_carts do
        {x, y} -> {:halt, {x, y}}
        new_carts -> {:cont, %{state | carts: new_carts}}
      end
    end)
  end

  def move_cart({{x, y}, cart}, world_map) do
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

    {{x, y},
     %{
       cart
       | direction: new_direction,
         next_intersection: new_next_intersection,
         position: {x, y}
     }}
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
end
