defmodule SmuggleTest do
  use ExUnit.Case
  use ExUnitProperties

  test "encode/1" do
    assert Smuggle.encode(true) == "g2QABHRydWU="
  end

  test "encode/1 (large enough to force line breaks)" do
    encoded = Smuggle.encode(%Inspect.Opts{})
    assert encoded |> String.split("\n") |> Enum.count() > 1
    assert encoded |> String.split("\n") |> Enum.map(&String.length/1) |> Enum.max() == 76
  end

  property "encode/1" do
    check all original <- StreamData.term() do
      encoded = Smuggle.encode(original)
      decoded = Smuggle.decode(encoded)
      assert decoded == original, "failed encode |> decode round trip"

      for line <- String.split(encoded, "\n") do
        assert String.length(line) <= 76, "failed line breaking"
        assert String.match?(line, ~r/^[A-Za-z0-9+\/]+={0,2}$/), "not Base64"
      end
    end
  end

  test "decode/1" do
    assert Smuggle.decode("g2QABHRydWU=") == true
  end

  test "gen_sfx/1" do
    assert Smuggle.gen_sfx("BASE64 GOES HERE") <> "\n" == ~S'''
           (fn v -> v |> Base.decode64!(ignore: :whitespace) |> :erlang.binary_to_term() end).(~S"""
           BASE64 GOES HERE
           """)
           '''
  end

  test "gfm/1" do
    assert Smuggle.gfm("SFX CODE GOES HERE") == ~S'''
           <details>
           <summary>
           Self-extracting gzip base64 to paste at the iex prompt:
           </summary>

           ```elixir
           SFX CODE GOES HERE
           ```
           </details>
           '''
  end
end
