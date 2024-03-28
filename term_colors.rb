#!/usr/bin/env ruby

# Run this script with this:
#
#     ruby term_colors.rb | less -R
#
# From Wikipedia:
# https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
#
# ESC[38;5;⟨n⟩m Select foreground color      where n is a number from the table below
# ESC[48;5;⟨n⟩m Select background color
#   0-  7:  standard colors (as in ESC [ 30–37 m)
#   8- 15:  high intensity colors (as in ESC [ 90–97 m)
#  16-231:  6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (0 ≤ r, g, b ≤ 5)
# 232-255:  grayscale from dark to light in 24 steps
#
# Algorithm for turning R, G, B into ANSI color number:
# 16 + (36 × r) + (6 × g) + b

module TerminalColorsDemo

  # Generate X, Y, Z coordinates for the color cube
  # X == Red
  # Y == Green
  # Z == Blue
  #
  # View the coordinates with the following
  # ColorCubeCoordinates.each { |a| puts a.inspect }
  ColorCubeCoordinates = (0..5).to_a.repeated_permutation(3).to_a

  # Use the ANSI algorithm to convert color cube coordinates into an ANSI color number
  # Turns out it's just (16..231) :shrug:
  ColorNumbers = ColorCubeCoordinates.map { |r,g,b| 16 + (36 * r) + (6 * g) + b }

  class TileLayerColorPair
    attr_reader :fg, :bg

    def initialize(fg, bg)
      @fg = fg
      @bg = bg
    end
  end

  # A space char pads blue++ across layers in a line of tiles.
  # A single newline sets up for the next layer in a line of tiles to blue++ across green++.
  # Two newlines set up a new line of tiles for red++.
  #
  # 16 is essentially 0 in color value.
  # To get a newline on a modulus of 0, we only subtract 15.
  def tile_separator(color)

    # ANSI RGB numbers start at 16. Subtracting 15 allows for modulo 0.
    ansi_adjusted = color - 15

    case
    when ansi_adjusted % 36 == 0; "\n\n"  # Red changes
    when ansi_adjusted % 6 == 0; "\n"     # Green changes
    else " "                              # Blue changes
    end
  end

  def show_colors_and_text(color_pair, separator)

    # Format the color numbers for display
    fmt_fg_color = color_pair.fg.to_s.rjust(3, " ")
    fmt_bg_color = color_pair.bg.to_s.rjust(3, " ")
    color_code_text = %Q(  #{fmt_fg_color}  #{fmt_bg_color}  )

    # ANSI magic!
    # Color numbers in foreground color on top of background color
    ansi_output = "\e[48;5;#{color_pair.bg};38;5;#{color_pair.fg}m#{color_code_text}\e[0m#{separator}"

    # The money shot
    print ansi_output
  end
end

# Each layer across a line of tiles shows each progessive background value of Blue.
# Each layer across a line of tiles shows a progressive background value of Green.
# Each line of tiles shows a progressive background value of Red for 6 lines / 36 tiles.
# Each set of 36 tiles shows a single progression of foreground color through B, G, and R.
class BackgroundColorByForegroundColor
  include TerminalColorsDemo

  def show_tiles()
    ColorNumbers.repeated_permutation(2).each do |fg, bg|
      cp  = TileLayerColorPair.new(fg, bg)
      sep = tile_separator(bg)
      show_colors_and_text(cp, sep)
    end
  end
end

# Each layer across a line of tiles shows each progessive foreground value of Blue.
# Each layer across a line of tiles shows a progressive foreground value of Green.
# Each line of tiles shows a progressive foreground value of Red for 6 lines / 36 tiles.
# Each set of 36 tiles shows a single progression of background color through B, G, and R.
class ForegroundColorByBackgroundColor
  include TerminalColorsDemo

  def show_tiles()
    ColorNumbers.repeated_permutation(2).each do |bg, fg| # reversed!
      cp  = TileLayerColorPair.new(fg, bg)
      sep = tile_separator(fg)
      show_colors_and_text(cp, sep)
    end
  end
end

#include TerminalColorsDemo
#BackgroundColorByForegroundColor.new.show_tiles
#oregroundColorByBackgroundColor.new.show_tiles
