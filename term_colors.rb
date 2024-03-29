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

module TerminalColors

  class ColorPoint
    attr_reader :r, :g, :b, :num

    def initialize(r, g, b, num)
      @r = r; @g = g; @b = b; @num = num
    end

    def to_s
      sprintf "%i  %i  %i  %3i", @r, @g, @b, @num
    end
  end

  # Generate color cube with coordinates and ANSI color numbers.
  # x == Red
  # y == Green
  # z == Blue
  module AnsiColorCube
    @coords = (0..5).to_a.repeated_permutation(3).to_a

    # Use the ANSI algorithm to convert color cube coordinates into an ANSI color number
    # Turns out it's just (16..231) :shrug:
    @cube = @coords.map do |r, g, b|
      ansi_num = 16 + (36 * r) + (6 * g) + b
      ColorPoint.new(r, g, b, ansi_num)
    end

    class << self
      def bgr; @cube.dup; end
      def brg; @cube.sort_by { |c| [c.g, c.r, c.b] }; end
      def gbr; @cube.sort_by { |c| [c.r, c.b, c.g] }; end
      def grb; @cube.sort_by { |c| [c.b, c.r, c.g] }; end
      def rbg; @cube.sort_by { |c| [c.g, c.b, c.r] }; end
      def rgb; @cube.sort_by { |c| [c.b, c.g, c.r] }; end
    end
  end

  class TileSeparatorGen
    def initialize
      @tile_count = 0

      @next_full_tile_row_newline = "\n\n"
      @next_tile_layer_newline    = "\n"
      @tile_spacer                = "  "
    end

    def next_sep
      @tile_count += 1

      separator = case
      when @tile_count % 36 == 0; @next_full_tile_row_newline
      when @tile_count % 6 == 0;  @next_tile_layer_newline
      else ;                      @tile_spacer
      end

      #puts %Q(sep: #{separator.inspect}, count:#{@tile_count})

      separator
    end
  end

  class DummySeparatorGen
    def next_sep; ""; end
  end

  def format_color_number(color_num)
    color_num.to_s.rjust(3, " ")
  end

  def show_colors_and_text(fg, bg, sep)

    # Format the color numbers for display
    fg_formatted = format_color_number(fg.num)
    bg_formatted = format_color_number(bg.num)

    # Spaces chars here are significant to formatting
    color_code_text = %Q(  #{fg_formatted}  #{bg_formatted}  )

    # ANSI magic!
    # Color numbers in foreground color on top of background color
    ansi_output = "\e[48;5;#{bg.num};38;5;#{fg.num}m#{color_code_text}\e[0m#{sep}"

    # The money shot
    print ansi_output
  end

  class Demos

    extend TerminalColors

    class << self

      # Was using Array#repeated_permutation() until I read it doesn't guarantee ordering.
      def build_color_pairs(color_cube)

        # Create an array that repeats color_cube's elements one at a time, Array#size times each.
        slow_changer = color_cube.then do |cc|
          cc.inject([]) do |acc, a|
            acc.push(*([a] * cc.size))
          end
        end

        # Multiply color_cube by Array#size to repeat all elements in order, Array#size times.
        fast_changer = color_cube * color_cube.size

        slow_changer.zip(fast_changer)
      end

      def show_tiles(color_cube)
        gen = TileSeparatorGen.new

        build_color_pairs(color_cube).each do |fg, bg|
          show_colors_and_text(fg, bg, gen.next_sep)
        end
        nil
      end

      # Each layer across a line of tiles shows each progessive background value of Blue.
      # Each layer across a line of tiles shows a progressive background value of Green.
      # Each line of tiles shows a progressive background value of Red for 6 lines / 36 tiles.
      # Each set of 36 tiles shows a single progression of foreground color through B, G, and R.
      def bgr; show_tiles(AnsiColorCube.bgr); end

      # Each layer across a line of tiles shows each progessive foreground value of Blue.
      # Each layer across a line of tiles shows a progressive foreground value of Green.
      # Each line of tiles shows a progressive foreground value of Red for 6 lines / 36 tiles.
      # Each set of 36 tiles shows a single progression of background color through B, G, and R.
      def bgr_inv
        Class.new do
          include TerminalColors
          def show_tiles()
            gen = TileSeparatorGen.new
            AnsiColorCube.bgr.repeated_permutation(2).each do |bg, fg| # <== Reversed Args!
              show_colors_and_text(fg, bg, gen.next_sep)
            end
          end
        end.new.show_tiles
        nil
      end

      def rgb_list
        build_color_pairs(AnsiColorCube.rgb).each do |c1, c2|
           puts  "#{c1}   |   #{c2}"
        end
        nil
      end

      def rgb; show_tiles(AnsiColorCube.rgb); end

      def gbr; show_tiles(AnsiColorCube.gbr); end

    end
  end
end

#include TerminalColors
#Demos.bgr
#Demos.rgb
#Demos.rgb_list
