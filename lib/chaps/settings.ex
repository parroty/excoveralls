defmodule Chaps.Settings do
  strip_docs = fn subsection ->
    update_in(
      subsection,
      [
        Access.all(),
        Access.elem(1),
        Access.filter(fn {k, _v} -> k == :doc end)
      ],
      fn {:doc, _doc} -> {:doc, false} end
    )
  end

  @terminal_options [
    print_files: [
      doc: """
      Whether or not to print a table of files with the coverage of each
      file. If set to `false`, the table will not be printed but the overall
      coverage will be printed.
      """,
      type: :boolean,
      default: true
    ],
    file_column_width: [
      doc: """
      The width of the column to fit in file names in the terminal output
      table. Set this option to something larger like `80` or `100` if your
      project has files with long path names.
      """,
      type: :integer,
      default: 40
    ]
  ]

  @coverage_options [
    treat_no_relevant_lines_as_covered: [
      doc: """
      Wether or not to treat files which have no significant lines of code
      as covered (`true`) at 100% or or not covered (`false`) at 0%.
      """,
      type: :boolean,
      default: false
    ],
    output_dir: [
      doc: """
      The output directory to place the HTML report, if generating an HTML
      report with `mix chaps.html`.
      """,
      type: :string,
      default: "cover"
    ],
    template_path: [
      doc: """
      A path to source a custom template for rendering HTML reports.
      Defaults to the internal EEx template within the Chaps library.
      """,
      type: :string
    ],
    xml_base_dir: [
      doc: """
      Where to output the XML report if generating an XML report.
      """,
      type: :string,
      default: ""
    ],
    minimum_coverage: [
      doc: """
      A percentage target for coverage. If the overall coverage falls below
      this target, the `mix chaps` tasks will exit with status code 1.
      Coverage is floored to the tenths place.
      """,
      type: :float,
      default: 100.0
    ]
  ]

  @schema NimbleOptions.new!(
            default_stop_words: [
              doc: """
              A default set of words for which coverage should be ignored. This option
              should not be customized. Instead configure the `:custom_stop_words`
              key.
              """,
              type: {:list, {:custom, __MODULE__, :validate_regex, []}},
              default: [
                ~r/defmodule/,
                ~r/defrecord/,
                ~r/defimpl/,
                ~r/defexception/,
                ~r/defprotocol/,
                ~r/defstruct/,
                ~r/def.+(.+\\.+).+do/,
                ~r/^\s+use\s+/
              ]
            ],
            custom_stop_words: [
              doc: """
              A customizable set of words for which coverage should be ignored. The
              cover module has some difficulty discovering coverage on compile-time
              constructs in Elixir, so it can be useful to fully ignore some words.
              """,
              type: {:list, {:custom, __MODULE__, :validate_regex, []}},
              default: []
            ],
            skip_files: [
              doc: """
              A list of regular expressions to use to ignore matching path names from
              the coverage calculation.
              """,
              type: {:list, {:custom, __MODULE__, :validate_regex, []}},
              default: [~r/^test/, ~r/deps/]
            ],
            print_summary: [
              doc: """
              Whether or not to print the summary of the overall coverage to the
              terminal.
              """,
              type: :boolean,
              default: true
            ],
            terminal_options: [
              doc: """
              A set of terminal-output specific configuration options. See
              the Terminal Options section below for inner configuration.
              """,
              type: :keyword_list,
              keys: strip_docs.(@terminal_options),
              default: []
            ],
            coverage_options: [
              doc: """
              A set of options that configure how Chaps calculates coverage.
              See the Coverage Options section below for inner configuration.
              """,
              type: :keyword_list,
              keys: strip_docs.(@coverage_options),
              default: []
            ]
          )

  @moduledoc """
  Configurable options used for calculating and displaying coverage status

  ## Schema

  #{NimbleOptions.docs(@schema)}

  ### Terminal Options

  #{NimbleOptions.docs(@terminal_options)}

  ### Coverage Options

  #{NimbleOptions.docs(@coverage_options)}
  """

  @doc false
  def get_stop_words do
    read_config(:default_stop_words) ++ read_config(:custom_stop_words)
  end

  @doc false
  def get_coverage_options, do: read_config(:coverage_options)

  @doc false
  def default_coverage_value do
    if get_coverage_options()[:treat_no_relevant_lines_as_covered],
      do: 100.0,
      else: 0.0
  end

  @doc false
  def get_terminal_options, do: read_config(:terminal_options)

  @doc false
  def get_file_col_width do
    get_terminal_options()[:file_column_width]
  end

  @doc false
  def get_print_files do
    get_terminal_options()[:print_files]
  end

  @doc false
  def get_xml_base_dir do
    get_coverage_options()[:xml_base_dir]
  end

  @doc false
  def get_skip_files do
    read_config(:skip_files)
  end

  @doc false
  def get_print_summary do
    read_config(:print_summary)
  end

  @doc false
  def read_config(key) do
    :chaps
    |> Application.get_all_env()
    |> NimbleOptions.validate!(@schema)
    |> Keyword.fetch!(key)
  end

  @doc false
  def validate_regex(%Regex{} = regex), do: {:ok, regex}
  def validate_regex(binary) when is_binary(binary), do: Regex.compile(binary)

  def validate_regex(other),
    do: {:error, "must be a regular expression, got: #{inspect(other)}"}
end
