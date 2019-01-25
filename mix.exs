defmodule Eximage.MixProject do
  use Mix.Project

  def project do
    [
      app: :eximage,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      name: "Eximage",
      description: "Image library",
      docs: [
        main: "Eximage",
        extras: ["README.md"]
      ],
      package: [
        links: %{
          "Github" => "https://github.com/shavit/eximage"
        },
        licenses: ["Apache 2.0"],
      ],
      source_url: "https://github.com/shavit/eximage",
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19.3", only: :dev, runtime: false},
    ]
  end
end
