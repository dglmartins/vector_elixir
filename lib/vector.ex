defmodule Vector do
  @moduledoc """
  Elixir Vector calculations. Create vectors with Vector.new(list)
  """
  defstruct coordinates: %{}, dimension: 0

  @doc """
  Creates a new Vector with pre-defined struct

  ## Examples

      iex> Vector.new([1, 2, 3])
      %Vector{coordinates: %{0 => 1, 1 => 2, 2 => 3}, dimension: 3}

  """

  def new(list) do
    coordinates =
      list
      |> Stream.with_index()
      |> Stream.map(fn {a, b} -> {b, a} end)
      |> Map.new()
    dimension = map_size(coordinates)
    %Vector{coordinates: coordinates, dimension: dimension}
  end

  @doc """
  Adds two vectors. Assumes missing coordinates in any one of the vectors to be zero.

  ## Examples
      iex> vec1 = Vector.new([1, 2, 3])
      iex> vec2 = Vector.new([5, 6, -8, 2])
      iex> Vector.plus(vec1, vec2)
      %Vector{coordinates: %{0 => 6, 1 => 8, 2 => -5, 3 => 2}, dimension: 4}

  """
  def plus(%Vector{coordinates: coord1}, %Vector{coordinates: coord2}) do
    coordinates = Map.merge(coord1, coord2, fn _k, v1, v2 -> v1 + v2 end)
    dimension = map_size(coordinates)
    %Vector{coordinates: coordinates, dimension: dimension}
  end

  @doc """
  Subtracts two vectors. Assumes missing coordinates in any one of the vectors to be zero.

  ## Examples

      iex> vec1 = Vector.new([1, 2, 3])
      iex> vec2 = Vector.new([5, 6, -8, 2])
      iex> Vector.minus(vec1, vec2)
      %Vector{coordinates: %{0 => -4, 1 => -4, 2 => 11, 3 => -2}, dimension: 4}

  """
  def minus(vector1, vector2) do
    neg_vector2 = Vector.times_scalar(vector2, -1)
    Vector.plus(vector1, neg_vector2)
  end

  @doc """
  Multiples a Vector by a scalar.

  ## Examples

      iex> vec1 = Vector.new([1, 2, 3])
      iex> Vector.times_scalar(vec1, 3)
      %Vector{coordinates: %{0 => 3, 1 => 6, 2 => 9}, dimension: 3}

  """
  def times_scalar(%Vector{coordinates: coord} = vector, scalar) do
    coordinates =
      coord
      |> Enum.map(fn {k, v} -> {k, v * scalar} end)
      |> Map.new()
    %Vector{vector | coordinates: coordinates}
  end

  @doc """
  Calculates the magnitude of a vector.

  ## Examples

      iex> vector = Vector.new([2, 5, 7])
      iex> Vector.magnitude(vector) |> Float.round(2)
      8.83

  """
  def magnitude(%Vector{coordinates: coord}) do
    coord
    |> Stream.map(fn {_, v} -> v * v end)
    |> Enum.reduce(0, fn(v, acc) -> v + acc end)
    |> :math.pow(0.5)
  end


  @doc """
  Normalizes a vector.

  ## Examples

      iex> vector = Vector.new([2, 1])
      iex> Vector.normalize(vector)
      %Vector{
        coordinates: %{0 => 0.8944271909999159, 1 => 0.4472135954999579},
        dimension: 2
      }

  """
  def normalize(vector) do
    case Vector.is_zero_vector?(vector) do
      true ->
        IO.puts "Cannot normalize the zero vector"
        vector
      _ ->
        inverse = 1.0 / Vector.magnitude(vector)
        Vector.times_scalar(vector, inverse)
    end
  end

  @doc """
  Calculates the dot product a two vectors.

  ## Examples

      iex> vec1 = Vector.new([1, 2, 3])
      iex> vec2 = Vector.new([4, 5, 6.5])
      iex> Vector.dot_product(vec1, vec2)
      33.5

  """

  def dot_product(%Vector{coordinates: coord1}, %Vector{coordinates: coord2}) do
    coord1_list =
      Map.to_list(coord1)
      |> Enum.map(fn {_, v} -> v end)

    coord2_list =
      Map.to_list(coord2)
      |> Enum.map(fn {_, v} -> v end)

    Stream.zip(coord1_list, coord2_list)
    |> Stream.map(fn({k, v}) -> k * v end)
    |> Enum.reduce(0, fn(coord, acc) -> coord + acc end)
  end

  @doc """
  Calculates the degree and rad angles between two vectors.

  ## Examples

      iex> vec1 = Vector.new([5, 2, 6])
      iex> vec2 = Vector.new([6, 2, -7])
      iex> Vector.angle_between(vec1, vec2)
      %{deg_angle: 96.03760893210496, rad_angle: 1.6761724816079466}

  """
  def angle_between(vector1, vector2) do
    u2 = Vector.normalize(vector2)
    rad_angle =
      Vector.normalize(vector1)
      |> Vector.dot_product(u2)
      |> :math.acos()
    deg_angle =
      rad_angle
      |> (fn(x) -> x * 180.0 / :math.pi() end).()
    %{deg_angle: deg_angle, rad_angle: rad_angle}
  end

  @doc """
  Checks if is vector with zero magnitude

  ## Examples

      iex> zero_vector = Vector.new([0,0])
      iex> Vector.is_zero_vector?(zero_vector)
      true

  """
  def is_zero_vector?(vector, tolerance \\ 1.0e-10) do
    Vector.magnitude(vector) < tolerance
  end

  @doc """
  Checks if two vectors are the same to a tolerance defaulted to 1.0e-10

  ## Examples

      iex> vec1 = Vector.new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1.01])
      iex> vec2 = Vector.new([1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
      iex> Vector.are_equal?(vec1, vec2, 1.0e-1)
      true
      iex> Vector.are_equal?(vec1, vec2)
      false

  """
  def are_equal?(vector1, vector2, tolerance \\ 1.0e-10) do
    Vector.minus(vector1, vector2).coordinates
    |> Enum.reduce(0, fn({_, v}, acc) -> v + acc end)
    |> abs() <= tolerance
  end

  @doc """
  Checks if two vectors are parallel

  ## Examples

      iex> vec1 = Vector.new([3, 2, 1])
      iex> vec2 = Vector.new([7.5, 5, 2.5])
      iex> vec3 = Vector.new([7.5, 5, 2])
      iex> Vector.are_parallel?(vec1, vec2)
      true
      iex> Vector.are_parallel?(vec1, vec3)
      false

  """
  def are_parallel?(vector1, vector2) do
    case {Vector.is_zero_vector?(vector1), Vector.is_zero_vector?(vector2)} do
      {false, false} ->
        scalar = vector1.coordinates[0] / vector2.coordinates[0]
        Vector.times_scalar(vector2, scalar)
        |> Vector.are_equal?(vector1)
      _ -> true
      end
  end

  @doc """
  Checks if two vectors are orthogonal

  ## Examples

      iex> vec1 = Vector.new([0, 1, 0])
      iex> vec2 = Vector.new([1, 0, 1])
      iex> Vector.are_orthogonal?(vec1, vec2)
      true

  """
  def are_orthogonal?(vector1, vector2, tolerance \\ 1.0e-10) do
    case {Vector.is_zero_vector?(vector1), Vector.is_zero_vector?(vector2)} do
      {false, false} ->
        Vector.dot_product(vector1, vector2)
        |> abs() < tolerance
      _ ->
        true
    end
  end

  @doc """
  Computes the scalar projection of a vector onto a base vector

  ## Examples

      iex> vector = Vector.new([2, 4, 3])
      iex> base = Vector.new([2, 4, 0])
      iex> Vector.scalar_project(vector, base) |> Float.round(2)
      4.47


  """
  def scalar_project(vector, base) do
    dot = Vector.dot_product(vector, base)
    case Vector.is_zero_vector?(base) do
      true ->
        IO.puts "Cannot normalize the zero vector"
        base
      false ->
        mag_base = Vector.magnitude(base)
        dot / mag_base
    end
  end

  @doc """
  Projects a vector onto another as the base

  ## Examples

      iex> vector = Vector.new([2, 4, 3])
      iex> base = Vector.new([2, 4, 0])
      iex> Vector.project(vector, base)
      %Vector{
        coordinates: %{0 => 2.0, 1 => 4.0, 2 => 0.0},
        dimension: 3
      }

  """
  def project(vector, base) do
    unit_base = Vector.normalize(base)
    v_dot_base_scalar = Vector.dot_product(vector, unit_base)
    Vector.times_scalar(unit_base, v_dot_base_scalar)
  end

  @doc """
  Calculates cross product vector of two vectors of dim = 3

  ## Examples

      iex> vec1 = Vector.new([1, 2, 3])
      iex> vec2 = Vector.new([1, 5, 7])
      iex> Vector.cross_product(vec1, vec2)
      %Vector{
        coordinates: %{0 => -1, 1 => -4, 2 => 3},
        dimension: 3
      }

  """
  def cross_product(%Vector{coordinates: coord1, dimension: dim1} = vector1, %Vector{coordinates: coord2, dimension: dim2} = vector2) do
    case {dim1, dim2} do
      {3, 3} ->
        cross_coord0 = coord1[1]*coord2[2] - coord1[2]*coord2[1]
        cross_coord1 = coord1[2]*coord2[0] - coord1[0]*coord2[2]
        cross_coord2 = coord1[0]*coord2[1] - coord1[1]*coord2[0]
        Vector.new([cross_coord0, cross_coord1, cross_coord2])
      {_, _} ->
        IO.puts "Both vectors need to be o dimension 3"
        [vector1, vector2]
    end
  end

end
