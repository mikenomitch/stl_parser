defmodule StlParserTest do
  use ExUnit.Case

  test "extracts info for a simple file" do
    simple_file_path = "./stl_files/input.stl"

    %{triangles: triangle_count, area: area, bounding_box: box} =
      StlParser.extract_info(simple_file_path)

    [minimum_vertex | rest] = box

    assert triangle_count == 2
    assert area == 1.414
    assert minimum_vertex == %{x: 0, y: 0, z: 0}
  end

  test "extracts info for a complex file" do
    complex_file_path = "./stl_files/moon.stl"
    %{triangles: triangle_count} = StlParser.extract_info(complex_file_path)

    # just ensure no errors
    assert triangle_count == 116
  end
end
