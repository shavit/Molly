defmodule ExImage.PNG do
  @moduledoc """
  PNG

  https://en.wikipedia.org/wiki/Portable_Network_Graphics

  File Header (8 bytes)
    0-1 - 0x89 (137)
    1-4 - 0x50, 0x3e, 0x47 (80,78,71) - PNG
    4-6 - 0x0d, 0x0a (13, 10) - Line break
    6-7 - 0x1a (26)
    7-8 - 0x0a (10) - Line end

  Chunks:
    IDHR
    PLTE
    IDAT
    IEND

    4 bytes - Length
    4 bytes - Type
    [length] - Data
    4 bytes - CRC

  IDHR (13 bytes)
    Length - 13
    Type - "IDHR"

    Data:
      4 bytes - Width
      4 bytes - Height
      1 bytes - Depth
      1 bytes - Color type
      1 bytes - Compression method
      1 bytes - Filter method
      1 bytes - Interlace method

    CRC - <<118, 177, 54, 30>>
  """

  def parse(png) do
    case png do
      <<137, 80, 78, 71, 13, 10, 26, 10, body::bits>> -> read_chunks(body)
      _ -> :error
    end
  end

  # IDHR
  defp read_chunks(<<_length::bytes-size(4), 73, 72, 68, 82, data::bytes-size(13), crc::bytes-size(4), rest::bits>> = body) do
    read_chunks([{"IDHR", data}], rest)
  end

  # IEND
  defp read_chunks(chunks, <<length::unsigned-32, 73, 69, 78, 68, _rest::bits>>) do
    chunks
  end

  defp read_chunks(chunks, <<length::unsigned-32, type::bytes-size(4), _rest::bits>> = body) do
    IO.inspect "[Type]"
    IO.inspect type
    <<_length_type::bytes-size(8), chunk::bytes-size(length), crc::bytes-size(4), rest::bits>> = body

    chunks
    |> List.insert_at(-1, {type, chunk})
    |> read_chunks(rest)
  end


  defp read_chunks(_, <<>>), do: :error
end
