#require "debug"

#if defined?(DEBUGGER__)
#  puts "ruby/debugger loaded."

#[Dir.pwd]. each do |path|
#  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
#end

 cur_path = Dir.pwd
 $LOAD_PATH.unshift(cur_path) unless $LOAD_PATH.include?(cur_path)

require "term_colors"
include TerminalColorsDemo
