#!/usr/bin/env ruby

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
    ColorCubeCoordinates.each do |x, y, z|
      yield(x, y, z)
    end
  end

  def calculate_color_number(r, g, b)
    16 + (36 * r) + (6 * g) + b
  end

  def show_bg_color_with_fg_color(fg_x, fg_y, fg_z, bg_x, bg_y, bg_z)
    fg_color = calculate_color_number(fg_x, fg_y, fg_z)
    bg_color = calculate_color_number(bg_x, bg_y, bg_z)

    # Display the fg and bg color
    color_code_text = %Q(  #{fg_color.to_s.rjust(3, " ")}  #{bg_color.to_s.rjust(3, " ")}  )
    ansi_output = "\e[48;5;#{bg_color};38;5;#{fg_color}m#{color_code_text}\e[0m "
    print ansi_output

    # Output a newline every 6th change to stay within the same color cube slice
    print "\n" if (bg_color + 1) % 6 == 4
  end

  def show_bg_color_for_each_fg_color(fg_x, fg_y, fg_z)
    color_closure = Proc.new do |bg_x, bg_y, bg_z|
      show_bg_color_with_fg_color(fg_x, fg_y, fg_z, bg_x, bg_y, bg_z)
    end

    cycle_216_8bit_rgb_colors &color_closure
  end

  def show_all_rgb_color_combos()
    color_closure = Proc.new do |fg_x, fg_y, fg_z|
      show_bg_color_for_each_fg_color(fg_x, fg_y, fg_z)
    end

    cycle_216_8bit_rgb_colors &color_closure
  end
end

Class.new.extend(TerminalColorsDemo).show_all_rgb_color_combos
