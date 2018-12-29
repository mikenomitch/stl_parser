# STL Parser

This is a simple parser of STL files. It takes a file path and outputs information about the shape described.

It returns triangle count, surface area, and the bounding box of the shape.

## Deps and Usage

The stl parser is bundled as an executable that depends on Erlang/Elixir being installed. It takes a path to an stl file as an argument and writes to stdout.

Example usage `./stl_parser ./stl_files/input.stl > ~/Desktop/stl_information`

To re-build the executable, run `mix escript.build`.

## Design Choices

I wanted this solution to generally be scalable to millions of triangles (as the instructions mention). Therefore, I made sure that the file would only be read once and that I wasn't storing too much in memory. I used a file stream with Enum.reduce to only keep one line in memory at a time and store a small amount of state in the reduce functions accumulator. Luckily I think this actually resulted in fairly easy to read & reason about code.

I extracted the math portion of the code into its own module, as this logic was fairly independent from the rest of the problem.

I left the rest of the logic contained in a single file. I debated splitting out the file reading & output into their own module and the reducer logic into an engine module, but decided one file was simpler.

Very light test coverage was added in ./test (though I did not TDD, for what it's worth). Run `mix test` to run them.

As the files are pretty simple, I didn't go heavy on specs/types.

I bundled the main function via escript so it could be run without thinking much about the runtime/implementation details (assuming erlang runtime is available).

## Improvements

#### Performance Improvements

The current implementation should be able to handle millions on triangles in a single pass (untested), but I'm sure various improvements could be made.

The math logic was written for legibility and not performance. Switching to vector-based math would likely be faster.

Parallelizing the reducer count also yield nice results. You would have to write a function that combined information maps and ensure that you did not split up triangles into different processes, so this would take some tweaking, but could be a nice win.

Also, erlang/elixir probably isn't the best choice if we want to squeeze a lot of math-heavy performance out of a machine.

#### Calculation Improvements

If we are given two identical triangles, the triangle count and surface area will double counted. I am ignoring this for now.

A potential fix for this would be to cache each triangle's coordinates as you ran through the list and skip lines that were duplicates. The worst-case memory requirement in this case could end up being roughly the same as the file size though.

Another potential fix is to re-scan the beginning of the list for duplicate triangles on every row. This would greatly increase the runtime, and would scale poorly though.

Even with these improvements you would still need to somehow check for triangles that were fully contained within other triangles though.

#### Material Improvements

Currently the bounding box is locked into the three standard dimensions. We could potentially get a smaller bounding box by rotating the shape within the box or rotating the box. If we wanted to save materials, we should do this projection.
