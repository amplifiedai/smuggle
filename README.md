# Smuggle

[![Build status badge](https://github.com/amplifiedai/smuggle/workflows/Elixir%20CI/badge.svg)](https://github.com/amplifiedai/smuggle/actions)
[![Hex version badge](https://img.shields.io/hexpm/v/smuggle.svg)](https://hex.pm/packages/smuggle)

<!-- MDOC -->
<!-- INCLUDE -->
Pack Elixir data into self-extracting archives to paste elsewhere.

Ever had a large data structure you needed to attach to a ticket to make troubleshooting easier? Worse, was it full of references, pids, and structures with custom `Inspect` protocol installations that made the output of `IO.inspect/2` _not_ valid Elixir?

`Smuggle` makes it easy to pipe that value to a self-extracting archive you can paste anywhere for someone else to try on _their_ system. It's as easy as:

```elixir
Smuggle.dump(value)
```

The output will be Elixir code to reproduce your `value` on another system. It'll be:

* Portable because `:erlang.term_to_binary/2`
* Short because `compressed: 9`
* Easy to get through anything that carries text because `Base.encode64/1` and line breaks

```elixir
(fn v -> v |> Base.decode64!(ignore: :whitespace) |> :erlang.binary_to_term() end).(~S"""
g20AAABBT2gsIGdvb2Qgb24geW91IGZvciBjaGVja2luZy4gSXQgY291bGQgaGF2ZSBiZWVuIGFu
eXRoaW5nLCByaWdodD8=
""")
```

See [Usage](#usage) below for more details.

Do you _need_ to take a dependency on this? The first few dozen times I did it, I copied or re-invented the `encode/1` and `decode/1` pipelines, but I'm enjoying having it around now. If you're in a hurry and don't want to touch `mix`, loot what you need from below:

```elixir
  def encode(term) do
    term
    |> :erlang.term_to_binary(compressed: 9)
    |> Base.encode64()
    |> Stream.unfold(&String.split_at(&1, 76))
    |> Enum.take_while(&(&1 != ""))
    |> Enum.join("\n")
  end

  def decode(encoded) do
    encoded
    |> Base.decode64!(ignore: :whitespace)
    |> :erlang.binary_to_term()
  end
```

## Usage

If your target is an `iex` prompt:

```elixir
Smuggle.dump(value)
# copy
# paste into other iex
```

The output of `Smuggle.dump(true)` is:

```elixir
(fn v -> v |> Base.decode64!(ignore: :whitespace) |> :erlang.binary_to_term() end).(~S"""
g2QABHRydWU=
""")
```

Paste that back into the `iex` prompt of a local or remote console, and you'll get the value back:

```plain
Erlang/OTP 23 [erts-11.0.3] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [hipe]

Interactive Elixir (1.10.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> (fn v -> v |> Base.decode64!(ignore: :whitespace) |> :erlang.binary_to_term() end).(~S"""
...(1)> g2QABHRydWU=
...(1)> """)
true
```

It's more impressive when it's an `%Ecto.Changeset{}`, but you get the gist. Speaking of which, sometimes you're trying to paste vital troubleshooting information into a GitHub issue, comment, or gist. It's polite to wrap that in a `<details>`, and `Smuggle` does all the hard work:

```elixir
Smuggle.dump(value, wrapper: :gfm)
# copy
# paste into GitHub
```

On GitHub, the self-extracting archive will be hidden behind a friendly summary so it's easy to skip:

> ![gfm-closed](https://user-images.githubusercontent.com/15906/89889168-90803780-dc14-11ea-928e-a89a9eb1f62e.png)

That friendly open source maintainer who'll check it out, though, can click once to see the whole thing:

> ![gfm-open](https://user-images.githubusercontent.com/15906/89889172-91b16480-dc14-11ea-886a-3c53b53f148e.png)

<!-- MDOC -->
## Installation

Add `smuggle` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:smuggle, "~> 1.0.0"}
  ]
end
```

Or, install it globally:

```bash
mix archive.install hex smuggle
```

## Development

`make check` before you commit! If you'd prefer to do it manually:

* `mix do deps.get, deps.unlock --unused, deps.clean --unused` if you change dependencies
* `mix compile --warnings-as-errors` for a stricter compile
* `mix coveralls.html` to check for test coverage
* `mix credo` to suggest more idiomatic style for your code
* `mix dialyzer` to find problems typing might reveal… albeit *slowly*
* `mix docs` to generate documentation
