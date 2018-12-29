#! /usr/bin/env elixir

defmodule StlParser do
  @moduledoc """
  Contains the core logic for simple parsing of STL files.

  Returns triangle count, area, and bounding box for a 3d shape.

  Bundled into executable by escript. Takes file path as argument and writes to stdout.
  """

  alias StlParser.Geometry

  # =====================
  #   CONSTANTS & TYPES
  # =====================

  @type stl_file_information :: %{
          triangles: integer,
          area: float,
          bounding_box: list(%{x: number, y: number, z: number})
        }

  @base_coordinate %{x: 0, y: 0, z: 0}
  @base_bounding_box List.duplicate(@base_coordinate, 8)

  @initial_info %{
    triangles: 0,
    area: 0.0,
    bounding_box: @base_bounding_box
  }

  @initial_accumulator %{
    info: @initial_info,
    vertices: []
  }

  @parsing_error "There was an error parsing this file: "

  # ======================
  #   INTERFACE & OUTPUT
  # ======================

  @doc """
  Takes a path to an stl file and outputs information about the described shape to STDOUT.
  """

  @spec main([binary]) :: binary
  def main([stl_path]) do
    try do
      stl_path
      |> extract_info()
      |> format_info()
      |> write_to_stdout()
    rescue
      error -> write_to_stdout(@parsing_error <> error.message)
    end
  end

  @doc """
  Takes a path to an stl file and outputs information about the described shape.
  Public mostly for testing purposes.
  """
  @spec extract_info(binary) :: stl_file_information
  def extract_info(file_path) do
    file_path
    |> File.stream!()
    |> Enum.reduce(@initial_accumulator, &handle_line/2)
    |> Access.get(:info)
  end

  defp format_info(%{triangles: triangles, area: area, bounding_box: bounding_box}) do
    show_area = Float.round(area, 3)

    """
    Number of Triangles: #{triangles}
    Surface Area: #{show_area} mm
    Bounding Box: #{inspect(bounding_box)}
    """
  end

  # ===========
  #   REDUCER
  # ===========

  defp handle_line(line, acc) do
    # Only recognizes vertexes and end of triangle loops,
    # can be extended by adding more conditions
    cond do
      vertex_line?(line) -> store_vertex(line, acc)
      triangle_end?(line) -> merge_triangle_into_info(acc)
      true -> acc
    end
  end

  # =====================
  #   LINE CONDITIONALS
  # =====================

  defp vertex_line?(line), do: starts_with?(line, "vertex")
  defp triangle_end?(line), do: starts_with?(line, "endloop")

  # =======================
  #   ACCUMULATOR CHANGES
  # =======================

  defp store_vertex(line, acc) do
    vertex = extract_vertex_from_line(line)

    Map.update(acc, :vertices, [], fn vertices ->
      vertices ++ [vertex]
    end)
  end

  defp merge_triangle_into_info(acc) do
    # Adds 1 to triangle count
    # Adds areas together
    # Extends bounding box with new vertices
    # Clears out vertices for next triangle
    new_triangle = acc.vertices

    acc
    |> Map.put(:vertices, [])
    |> Map.update(:info, @initial_info, fn info ->
      %{
        triangles: info.triangles + 1,
        area: info.area + Geometry.triangle_area(new_triangle),
        bounding_box: Geometry.bounding_box(info.bounding_box ++ new_triangle)
      }
    end)
  end

  # ===========
  #   HELPERS
  # ===========

  def parse_float(str) do
    {num, _} = Float.parse(str)
    num
  end

  defp starts_with?(line, substring) do
    line
    |> String.trim()
    |> String.starts_with?(substring)
  end

  defp extract_vertex_from_line(line) do
    [_, x, y, z] =
      line
      |> String.trim()
      |> String.split(" ")

    %{
      x: parse_float(x),
      y: parse_float(y),
      z: parse_float(z)
    }
  end

  defp write_to_stdout(str), do: IO.write(:stdio, str)
end
