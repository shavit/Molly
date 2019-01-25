defmodule ExImage.PNGTest do
  use ExUnit.Case
  doctest Eximage

  describe "png" do
    alias ExImage.PNG

    test "parse/1 detects png" do
      # TODO: Complete this
      assert :error == PNG.parse <<>>
    end
  end
end
