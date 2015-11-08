0.4.2
------
#### Changes
* Allow to override coveralls endpoint (#34).

0.4.1
------
#### Changes
* Skip a module without __info__/1 function for avoiding UndefinedFunctionError (#33).

0.4.0
------
#### Enhancements
* Add overall reporting for umbrella project (#23).
   - `mix coveralls --umbrella`
* Add `--verbose` option for printing json when posting to coveralls.io.
   - `mix coveralls.travis --verbose`
* Support specifying test runner in mix.esx (#31).
