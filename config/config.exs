use Mix.Config

config :chaps,
  coverage_options: [
    treat_no_relevant_lines_as_covered: false,
    html_filter_fully_covered: false,
    minimum_coverage: 0.0,
    template_path: "lib/templates/html/htmlcov/"
  ],
  terminal_options: [
    file_column_width: 40
  ]
