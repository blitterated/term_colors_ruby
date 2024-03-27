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

  def cycle_216_8bit_rgb_colors
    ColorNumbers.each do |cn|
      yield(cn)
    end
  end

  def show_bg_color_with_fg_color(fg_color, bg_color)

    # The separator pads changes in blue.
    # The newlines keep us withing the same color cube line/slice by green.
    # The ANSI RGB numbers start with 16.
    # 16 is essentially 0 in color value.
    # To get a newline on a modulus of 0, we only subtract 15.
    separator = (bg_color - 15) % 6 == 0 ? "\n" : " "

    # Format the color numbers for display
    fmt_fg_color = fg_color.to_s.rjust(3, " ")
    fmt_bg_color = bg_color.to_s.rjust(3, " ")
    color_code_text = %Q(  #{fmt_fg_color}  #{fmt_bg_color}  )

    # ANSI magic!
    # Color numbers in foreground color on top of background color
    ansi_output = "\e[48;5;#{bg_color};38;5;#{fg_color}m#{color_code_text}\e[0m#{separator}"

    # The money shot
    print ansi_output

    # Output a newline every 36th change to stay within the same color cube slice of red.
    # Same reason for the modulus of 0 as separator above.
    print "\n" if (bg_color - 15) % 36 == 0
  end

  def show_bg_color_for_each_fg_color(fg_color)
    color_closure = Proc.new do |bg_color|
      show_bg_color_with_fg_color(fg_color, bg_color)
    end

    cycle_216_8bit_rgb_colors &color_closure
  end

  def show_all_rgb_color_combos()
    cycle_216_8bit_rgb_colors &method(:show_bg_color_for_each_fg_color)
  end
end

Class.new.extend(TerminalColorsDemo).show_all_rgb_color_combos
