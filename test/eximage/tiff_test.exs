defmodule ExImage.TIFFTest do
  use ExUnit.Case
  doctest Eximage
  alias ExImage.TIFF

  describe "ifd entry" do
    alias ExImage.TIFF.IFDEntry

    test "read if" do
      header = <<73, 73, 42, 0, 8, 0, 0, 0>>
      entry = <<0x0, 0x1, 0x3, 0x0, 0x1, 0x0, 0x0, 0x0, 0x0c, 0x0, 0x0, 0x0>>

      assert %IFDEntry{} = ifd = IFDEntry.new entry, header <> entry, <<0x49, 0x49>>
      assert ifd.count == 1
      assert ifd.offset == nil
      assert ifd.tag == :image_width
      assert ifd.type == :short
      assert ifd.value == 12

      entry = <<0x1, 0x1, 0x3, 0x0, 0x1, 0x0, 0x0, 0x0, 0x0c, 0x0, 0x0, 0x0>>
      assert %IFDEntry{} = ifd = IFDEntry.new entry, header <> entry, <<0x49, 0x49>>
      assert ifd.count == 1
      assert ifd.offset == nil
      assert ifd.tag == :image_length
      assert ifd.type == :short
      assert ifd.value == 12
    end
  end

  describe "tiff" do

    test "parse/1 extracts exif information from an image" do
      header = <<73, 73, 42, 0, 8, 0, 0, 0>>
      entry = <<0x0, 0x1, 0x3, 0x0, 0x1, 0x0, 0x0, 0x0, 0x16, 0x0, 0x0, 0x0>>

      assert %TIFF{} = tiff = TIFF.parse header <> <<0x1, 0x0>> <> entry
      assert tiff.signature == "II"

      assert [entry] = tiff.entries
      assert entry.count == 1
      assert entry.offset == nil
      assert entry.tag == :image_width
      assert entry.type == :short
      assert entry.value == 22
    end
  end
end
