defmodule Smuggle do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.filter(&(&1 =~ ~R{<!\-\-\ INCLUDE\ \-\->}))
             |> Enum.join("\n")
             # compensate for anchor id differences between ExDoc and GitHub
             |> (&Regex.replace(~R{\(\#\K(?=[a-z][a-z0-9-]+\))}, &1, "module-")).()

  @typedoc "Encoded terms."
  @type encoded :: binary()

  @typedoc "Self-extraction code."
  @type sfx :: binary()

  @doc "Encode a term to a compressed binary in Base64."
  @spec encode(term()) :: encoded()
  def encode(term) do
    term
    |> :erlang.term_to_binary(compressed: 9)
    |> Base.encode64()
    |> Stream.unfold(&String.split_at(&1, 76))
    |> Enum.take_while(&(&1 != ""))
    |> Enum.join("\n")
  end

  @doc "Decode a compressed binary in Base64."
  @spec decode(encoded()) :: term()
  def decode(encoded) do
    encoded
    |> Base.decode64!(ignore: :whitespace)
    |> :erlang.binary_to_term()
  end

  @doc "Generate self-extraction code."
  @spec gen_sfx(encoded()) :: sfx()
  def gen_sfx(encoded) do
    encoded = if String.ends_with?(encoded, "\n"), do: encoded, else: encoded <> "\n"

    sigil = {
      :sigil_S,
      [delimiter: "\"\"\"", context: Elixir, import: Kernel],
      [{:<<>>, [], [encoded]}, []]
    }

    quote do
      # credo:disable-for-next-line
      (fn v ->
         v
         |> Base.decode64!(ignore: :whitespace)
         |> :erlang.binary_to_term()
       end).(unquote(sigil))
    end
    # credo:disable-for-next-line
    |> Macro.to_string()
  end

  @doc "Dump self-extracted."
  @spec dump(term(), [{:wrapper, atom()}]) :: :ok
  def dump(term, opts \\ []) do
    {wrapper, opts} = Keyword.pop(opts, :wrapper, :noop)
    for {k, _} <- opts, do: raise(ArgumentError, "no such option: #{k}")
    term |> encode() |> gen_sfx() |> wrap(wrapper) |> IO.puts()
  end

  defp wrap(sfx, wrapper) when is_atom(wrapper), do: wrap(sfx, {__MODULE__, wrapper, []})
  defp wrap(sfx, {m, f, args}), do: Kernel.apply(m, f, [sfx | args])

  @doc "No-op wrapper."
  @spec noop(sfx()) :: sfx()
  def noop(sfx), do: sfx

  @doc "Wrap in a details tag for GitHub-flavoured markdown."
  @spec gfm(sfx()) :: binary()
  def gfm(sfx) do
    IO.iodata_to_binary([
      ~S"""
      <details>
      <summary>
      Self-extracting gzip base64 to paste at the iex prompt:
      </summary>

      ```elixir
      """,
      sfx,
      "\n",
      ~S"""
      ```
      </details>
      """
    ])
  end
end
