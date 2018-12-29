defmodule StlParser.GeometryTest do
  use ExUnit.Case
  doctest StlParser.Geometry

  # ========
  #   AREA
  # ========

  test "finds the area of a simple triangle" do
    vertices = [
      %{x: 0, y: 0, z: 0},
      %{x: 1, y: 0, z: 0},
      %{x: 0.5, y: 0.5, z: 1}
    ]

    # From online calculator
    expected_area = 0.559

    assert StlParser.Geometry.triangle_area(vertices) == expected_area
  end

  test "finds the area of a more complex triangle" do
    vertices = [
      %{x: -10, y: 20, z: -5},
      %{x: 50, y: 200, z: 40},
      %{x: 0, y: 0, z: 0}
    ]

    # From online calculator
    expected_area = 1750.893

    assert StlParser.Geometry.triangle_area(vertices) == expected_area
  end

  # ================
  #   BOUNDING BOX
  # ================

  test "extends a bounding box properly" do
    simple_box = [
      %{x: 0, y: 0, z: 0},
      %{x: 0, y: 0, z: 1},
      %{x: 0, y: 1, z: 0},
      %{x: 0, y: 1, z: 1},
      %{x: 1, y: 0, z: 0},
      %{x: 1, y: 0, z: 1},
      %{x: 1, y: 1, z: 0},
      %{x: 1, y: 1, z: 1}
    ]

    larger_triangle = [
      %{x: 2, y: 0, z: 0},
      %{x: 1, y: 3, z: 0},
      %{x: 1, y: 1, z: 0}
    ]

    combined_vertices = simple_box ++ larger_triangle

    expected_extended_box = [
      %{x: 0, y: 0, z: 0},
      %{x: 0, y: 0, z: 1},
      %{x: 0, y: 3, z: 0},
      %{x: 0, y: 3, z: 1},
      %{x: 2, y: 0, z: 0},
      %{x: 2, y: 0, z: 1},
      %{x: 2, y: 3, z: 0},
      %{x: 2, y: 3, z: 1}
    ]

    assert StlParser.Geometry.bounding_box(combined_vertices) == expected_extended_box
  end
end
