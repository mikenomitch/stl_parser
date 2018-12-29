defmodule StlParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :stl_parser,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # This is used to compile the executable
  defp escript do
    [main_module: StlParser]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:dialyxir, "~> 0.4", only: [:dev]}]
  end
end
