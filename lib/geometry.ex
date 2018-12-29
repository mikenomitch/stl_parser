defmodule StlParser.Geometry do
  @moduledoc """
  Contains the math for STL Parsing.

  - Calculates 3D triangles surface area.
  - Calculates a bounding box for set of vertices.
  """

  @type three_d_coordinate :: %{x: number, y: number, z: number}
  @type three_d_coordinates :: list(three_d_coordinate)

  # =============
  #   INTERFACE
  # =============

  @doc """
  Given a list of 3D cooridnates. Returns a float of triangle's area.

  ## Examples
      iex> vertices = [%{x: 0, y: 0, z: 0}, %{x: 0, y: 2, z: 0}, %{x: 0, y: 0, z: 2}]
      iex> StlParser.Geometry.triangle_area(vertices)
      2.0
  """

  @spec triangle_area(three_d_coordinates) :: float
  def triangle_area(vertices) do
    # Uses Heron's formula to calculate area.
    side_a_length = length_of_side(vertices, 0)
    side_b_length = length_of_side(vertices, 1)
    side_c_length = length_of_side(vertices, 2)

    semi_perimeter = (side_a_length + side_b_length + side_c_length) / 2

    unrounded_area =
      :math.sqrt(
        semi_perimeter * (semi_perimeter - side_a_length) * (semi_perimeter - side_b_length) *
          (semi_perimeter - side_c_length)
      )

    Float.round(unrounded_area, 3)
  end

  @doc """
  Takes a list of vertices and returns the bounding box.

  Note: vertices are sometimes from a triangle and sometimes from a box,
  but its the same regardless.

  ## Examples
      iex> vertices = [%{x: 1, y: 0, z: 0}, %{x: 0, y: 2, z: 0}, %{x: 0, y: 0, z: 2}]
      iex> StlParser.Geometry.bounding_box(vertices)
      [%{x: 0, y: 0, z: 0}, %{x: 0, y: 0, z: 2}, %{x: 0, y: 2, z: 0}, %{x: 0, y: 2, z: 2}, %{x: 1, y: 0, z: 0}, %{x: 1, y: 0, z: 2}, %{x: 1, z: 0, y: 2}, %{x: 1, z: 2, y: 2}]
  """

  @spec bounding_box(three_d_coordinates) :: three_d_coordinates
  def bounding_box(vertices) do
    [min_x, max_x] = max_and_min_for_dimension(vertices, :x)
    [min_y, max_y] = max_and_min_for_dimension(vertices, :y)
    [min_z, max_z] = max_and_min_for_dimension(vertices, :z)

    # mentally set min to 0 & max to 1
    # for each combo, count to 8 in binary
    [
      %{x: min_x, y: min_y, z: min_z},
      %{x: min_x, y: min_y, z: max_z},
      %{x: min_x, y: max_y, z: min_z},
      %{x: min_x, y: max_y, z: max_z},
      %{x: max_x, y: min_y, z: min_z},
      %{x: max_x, y: min_y, z: max_z},
      %{x: max_x, y: max_y, z: min_z},
      %{x: max_x, y: max_y, z: max_z}
    ]
  end

  # ===========
  #   HELPERS
  # ===========

  defp max_and_min_for_dimension(vertices, dimension_key) do
    all_magnitudes = Enum.map(vertices, &Map.get(&1, dimension_key))
    [Enum.min(all_magnitudes), Enum.max(all_magnitudes)]
  end

  defp length_of_side(vertices, side_idx) do
    next_side_idx = Integer.mod(side_idx + 1, 3)

    a_coordinates = Enum.at(vertices, side_idx)
    b_coordinates = Enum.at(vertices, next_side_idx)

    x_length = dimensional_magnitude(a_coordinates, b_coordinates, :x)
    y_length = dimensional_magnitude(a_coordinates, b_coordinates, :y)
    z_length = dimensional_magnitude(a_coordinates, b_coordinates, :z)

    :math.sqrt(:math.pow(x_length, 2) + :math.pow(y_length, 2) + :math.pow(z_length, 2))
  end

  defp dimensional_magnitude(a_coordinates, b_coordinates, key) do
    a = Map.get(a_coordinates, key)
    b = Map.get(b_coordinates, key)
    a - b
  end
end
