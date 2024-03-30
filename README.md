
## Print out all combinations of 8 bit ANSI terminal colors - Now with Ruby instead of bash!

This is based on the previous shell script version [here](https://github.com/blitterated/term-colors)

This will show all 46,656 (216 * 216) combinations of background and foreground colors in a 256 color capable shell.

On modern computers, this usually just means setting the following environment variable in your shell:

   ```sh
   export TERM=xterm-256color
   ```

[Wikipedia](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit) mentions that ANSI color values from 16 - 231 are used to represent colors in a 6 x 6 x 6 color cube.
This script will output those colors 6 per line to more accurately represent a "slice" through the color cube.

This also means that the script outputs 7,776 (46,656/6) lines to the terminal. To view these at human readable speed, you can pipe the script into `less` with a switch to prevent displaying ANSI escape sequences literally.

   ```sh
   ./term_colors.rb | less -R
   ```
