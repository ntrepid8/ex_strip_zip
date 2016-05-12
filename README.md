# ExStripZip

A helper to strip and zip beam files in Erlang/Elixir releases.

## Build

To build ExStripZip change to the repo directory and do this:

```
$ mix escript.build
```

To build for prod do this:

```
$ MIX_ENV=prod mix escript.build
```

## Usage

Always use the `strip` function first if you are going to both strip && zip. 
Use the `strip` function like this:

```
$ ./ex_strip_zip strip /path/to/erl_dist
```

To use the `zip` function do this:

```
$ ./ex_strip_zip zip /path/to/erl_dist
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add ex_strip_zip to your list of dependencies in `mix.exs`:

        def deps do
          [{:ex_strip_zip, "~> 0.0.1"}]
        end

  2. Ensure ex_strip_zip is started before your application:

        def application do
          [applications: [:ex_strip_zip]]
        end
