defmodule ExImage.TIFF do
  @moduledoc """
  TIFF

  A TIFF file contains a 8-byte header and a linked list of image objects.
  https://en.wikipedia.org/wiki/TIFF
  """

  defmodule IFDEntry do
    @moduledoc """

    IFD Entry (12 bytes)

    0-1 - Tag
    2-3 - Type
    4-7 - Number of values
    8-11 - Value offset that can point anywhere in the file

    """
    defstruct [:tag, :type, :count, :offset, :value]

    @tag_map %{
      0x100 => :image_width,
      0x101 => :image_length,
      0x102 => :bits_per_sample,
      0x103 => :compression,
      0x106 => :photo_metric_interpretation,
      0x10e => :image_description,
      0x10f => :make,
      0x110 => :model,
      0x111 => :strip_offsets,
      0x112 => :orientation,
      0x115 => :samples_per_pixel,
      0x116 => :rows_per_strip,
      0x117 => :strip_byte_counts,
      0x11a => :x_resolution,
      0x11b => :y_resolution,
      0x11c => :planar_configuration,
      0x128 => :resolution_unit,
      0x12d => :transfer_function,
      0x131 => :software,
      0x132 => :datetime,
      0x13b => :artist,
      0x13e => :white_point,
      0x13f => :primary_chromaticities,
      0x211 => :ycbcr_coefficients,
      0x212 => :ycbcr_subsampling,
      0x213 => :ycbcr_positioning,
      0x214 => :reference_blackwhite,
      0x8298 => :copyright,
      0x8769 => :exif_ifd_pointer,
      0x8825 => :gps_info_ifd_pointer,
      0x829A  => :exposure_time,
      0x829D  => :f_number,
      0x8822  => :exposure_program,
      0x8824  => :spectra_sensitivity,
      0x8827  => :ios_speed_ratings,
      0x8829  => :oecf,
      0x9000  => :exif_version,
      0x900 => :datetime_original,
      0x9004  => :datetime_digitized,
      0x9101 => :components_configuration,
      0x9102  => :compressed_bits_per_pixel,
      0x9201 => :shutter_speed_value,
      0x9202 => :aperture_value,
      0x9203 => :brightness_value,
      0x9204 => :exposure_bias_value,
      0x9205 => :max_aperture_value,
      0x9206 => :subject_distance,
      0x9207 => :metering_mode,
      0x9208 => :light_source,
      0x9209 => :flash,
      0x920a => :focal_length,
      0x927C  => :maker_note,
      0x9286 => :user_comment,
      0x9290  => :sub_sec_time,
      0x9291 => :sub_sec_time_original,
      0x9292  => :sub_sec_time_digitized,
      0xA000  => :flashpix_version,
      0xA001  => :colorspace,
      0xA002  => :pixel_x_dimension,
      0xA003  => :pixel_y_dimension,
      0xA004  => :related_sound_file,
      0xA20B  => :flash_energy,
      0xA20C  => :spatial_frequency_response,
      0xA20E  => :focal_plane_x_resolution,
      0xA20F  => :focal_plane_y_resolution,
      0xA210  => :focal_plane_resolution_unit,
      0xA214  => :subject_location,
      0xA215  => :exposure_index,
      0xA217  => :sensing_method,
      0xA300  => :file_source,
      0xA301  => :scene_type,
      0xA302  => :cfa_pattern,

      0x00 => :gps_version_id,
      0x01 => :gps_latitude_ref,
      0x02 => :gps_latitude,
      0x03 => :gps_longtitude_ref,
      0x04 => :gps_longtitude,
      0x05 => :gps_altitude_ref,
      0x06 => :gps_altitude,
      0x07 => :gps_timestamp,
      0x08 => :gps_satellites,
      0x09 => :gps_status,
      0xa => :gps_measure_mode,
      0xb => :gps_dop,
      0xc => :gps_speed_ref,
      0xd => :gps_speed,
      0xe => :gps_track_ref,
      0xf => :gps_track,
      0x10 => :gps_img_direction_ref,
      0x11 => :gps_img_direction,
      0x12 => :gps_map_datum,
      0x13 => :gps_dest_latitude_ref,
      0x14 => :gps_dest_latitude,
      0x15 => :gps_dest_longtitude_ref,
      0x16 => :gps_dest_longtitude,
      0x17 => :gps_dest_bearing_ref,
      0x18 => :gps_dest_bearing,
      0x19 => :gps_dest_distance_ref,
      0x1a => :gps_dest_distance,
    }

    @doc """
    II
    """
    def new(entry, img, <<0x49, 0x49>>) do
      case entry do
        <<tag::size(16)-little,
          type::size(16)-little,
          1::size(32)-little,
          value::size(32)-little>> ->
            %__MODULE__{
              tag: Map.get(@tag_map, tag),
              type: type_for_entry(type),
              count: 1,
              offset: nil,
              value: value,
            }

        <<tag::size(16)-little,
          type::size(16)-little,
          count::size(32)-little,
          offset::size(32)-little>> ->
            %__MODULE__{
              tag: Map.get(@tag_map, tag),
              type: type_for_entry(type),
              count: count,
              offset: offset,
              value: value_for_entry(img, offset, count),
            }

        _ -> nil
      end
    end

    # TODO: Implement
    @doc """
    MM
    """
    def new(_entry, _img, 0x4d, 0x4d), do: nil

    defp type_for_entry(type) do
      case type do
        1 -> :byte
        2 -> :ascii
        3 -> :short
        4 -> :long
        5 -> :rational
        6 -> :sbyte
        7 -> :undefined
        8 -> :sshort
        9 -> :sslong
        10 -> :srational
        11 -> :float
        12 -> :double
        _ -> type
      end
    end

    defp value_for_entry(img, offset, count) do
      with bsize <- (count-1) * 8,
        <<v::size(bsize)>> <- binary_part(img, offset, count-1) do v
        else _ -> nil
      end
    end

  end

  defstruct [:signature, :entries]

  @doc """
  Parse a TIFF file

  Extract the Exif data
  """
  def parse(img) do
    case img do
      <<0x49, 0x49, 0x2A, 0x0, offset::little-size(32), _rest::bits>> -> parse(%__MODULE__{signature: "II"}, img, offset)
      <<0x4d, 0x4d, 0x0, 0x2A, offset::unsigned-32, _rest::bits>> -> parse(%__MODULE__{signature: "MM"}, img, offset)
      _ -> :error
    end
  end

  def parse(%__MODULE__{} = tiff, img, offset) do
    n = case tiff do
      %{signature: "II"} ->
        <<number_of_entries::size(16)-little>> = binary_part(img, offset, 2)
        number_of_entries * 12
      %{signature: "MM"} ->
        <<number_of_entries::size(16)-little>> = binary_part(img, offset, 2)
        number_of_entries * 12
    end

    <<_header::bytes-size(offset), _number_of_entries::bytes-size(2), entries::bytes-size(n), _rest::bits>> = img
    entries = read_entry([], entries, img, tiff.signature)

    Map.put(tiff, :entries, entries)
  end

  @doc """
  Iterate over the entries
  """
  def read_entry(entry_list, <<>>, _img, _byte_order), do: entry_list
  def read_entry(entry_list, entries, img, byte_order) do
    <<entry_bytes::bytes-size(12), rest::bits>> = entries
    entry = IFDEntry.new(entry_bytes, img, byte_order)

    entry_list
    |> List.insert_at(-1, entry)
    |> read_entry(rest, img, byte_order)
  end
end
