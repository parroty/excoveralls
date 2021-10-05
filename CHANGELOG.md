# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.16.0 - 2021-10-04

### Changed

- Changed out three default setting values
    - `file_column_width` increased to 80 columns from 40
    - `treat_no_relevant_lines_as_covered` set to true from false
    - `html_filter_fully_covered` set to true from false

## 0.15.2 - 2021-10-04

### Added

- Added message to HTML report when the `:html_filter_fully_covered` option
  is enabled

### Fixed

- Fixed HTML filtering functionality

## 0.15.1 - 2021-10-04

### Added

- Added LICENSE file to hex tarball

## 0.15.0 - 2021-10-04

### Added

- Added `:html_filter_fully_covered` to the coverage options, allowing one
  to filter out fully covered modules from the HTML reports

### Removed

- Removed mix tasks and code for uploading coverage reports to various
  services

### Changed

- Changed out configuration from the JSON file to Elixir application
  configuration

## 0.0.0 - 2021-10-01

### Added

- This project was forked from
  [`parroty/excoveralls`](https://github.com/parroty/excoveralls)
