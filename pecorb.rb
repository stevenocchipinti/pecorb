#!/usr/bin/env ruby
require 'io/console'

KILL_LINE_CHAR = "\x1B[K"
CURSOR_UP_CHAR = "\x1B[A"
CSI = "\e["

@input = ""
@cursor = 0
@selected = 0
@items = []
@displayed_items = []


def read_char
  $stdin.echo = false
  $stdin.raw!
  input = $stdin.getc.chr
  if input == "\e" then
    input << $stdin.read_nonblock(3) rescue nil
    input << $stdin.read_nonblock(2) rescue nil
  end
ensure
  $stdin.echo = true
  $stdin.cooked!
  return input
end

def debug(str)
  $stderr.print "#{CSI}s"
  $stderr.print "#{CSI}10B\r"
  $stderr.print "#{str}#{CSI}K"
  $stderr.print "#{CSI}u"
end

def replace_input(str)
  $stderr.print "#{CSI}s"
  $stderr.print "\b"*@cursor
  $stderr.print "#{@input}#{CSI}K"
  $stderr.print "#{CSI}u"
end

def replace_items
  return unless block_given?
  $stderr.print "#{CSI}s"
  $stderr.print "#{CSI}\r"
  $stderr.print "#{CSI}B#{CSI}K" * @displayed_items.size
  $stderr.print "#{CSI}A" * (@displayed_items.size - 1) if @displayed_items.size > 0
  new_items = yield
  @displayed_items = new_items
  @selected = limit_max @selected, @displayed_items.size - 1
  print_items new_items
  $stderr.print "#{CSI}u"
end

def limit_max(n, max)
  [[max, n].min, 0].max
end

def print_items(items)
  items.each_with_index do |item, i|
    $stderr.puts "#{@selected == i ? "‣" : " "} #{item}"
  end
end

def filter_items(items, filter)
  regex = Regexp.new(filter.chars.join(".*"), "i")
  items.select {|i| regex.match i }
end

def from_end_to_start
  # Move up x times and right y times
  $stderr.print "#{CSI}#{@displayed_items.size+1}A#{CSI}#{@prompt.length}C"
end

def from_start_to_end
  # Move down x times and then to the start of the line
  $stderr.print "#{CSI}#{@displayed_items.size+1}B\r"
end

def prompt(items, prompt="Select an item: ")
  @displayed_items = @items = items
  @prompt = prompt

  $stderr.puts prompt
  print_items(items)
  from_end_to_start

  while c = read_char
    case c
    when /[\r]/
      break
    when /[]/
      @input = ""
      break
    when "" # Backspace key
      next if @input.empty? || @cursor <= 0
      @input.slice!(@cursor-1)
      replace_input(@input)
      replace_items { filter_items(@items, @input) }
      $stderr.print "\b"
      @cursor -= 1
    when "#{CSI}D" # Left arrow key
      next unless @cursor > 0
      $stderr.print c
      @cursor -= 1
    when "#{CSI}C" # Right arrow key
      next unless @cursor < @input.length
      $stderr.print c
      @cursor += 1
    when "#{CSI}A" # Up arrow key
      @selected -= 1 if @selected > 0
      replace_items { filter_items(@items, @input) }
    when "#{CSI}B" # Down arrow key
      @selected += 1 if @selected < @displayed_items.size - 1
      replace_items { filter_items(@items, @input) }
    else
      @input.insert(@cursor, c)
      replace_input(@input)
      replace_items { filter_items(@items, @input) }
      $stderr.print c
      @cursor += 1
    end
  end

  from_start_to_end
  $stdout.puts @displayed_items[@selected]
end

input = ARGF.readlines.map(&:strip).reject(&:empty?)

# After reading from $stdin (file, pipe, etc.), switch $stdin to be the users
# terminal to present the prompt
$stdin.reopen(File.open("/dev/tty", "r"))

prompt input unless input.empty?
