require_relative "pecorb/version"
require "io/console"

module Pecorb
  extend self

  KILL_LINE_CHAR = "\x1B[K"
  CURSOR_UP_CHAR = "\x1B[A"
  CSI = "\e["
  SELECTED_COLOR = "#{CSI}\e[36m"
  RESET_COLOR = "#{CSI}\e[0m"

  @input = ""
  @cursor = 0
  @selected = 0
  @items = []
  @displayed_items = []


  def prompt(items, prompt="Select an item: ")
    @displayed_items = @items = items
    @prompt = prompt

    $stderr.puts prompt
    print_items(items)
    move_cursor_from_end_to_start

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

    move_cursor_from_start_to_end
    $stdout.puts @displayed_items[@selected]
    @displayed_items[@selected]
  end

  private

  def move_cursor_from_end_to_start
    # Move up x times and right y times
    $stderr.print "#{CSI}#{@displayed_items.size+1}A#{CSI}#{@prompt.length}C"
  end

  def move_cursor_from_start_to_end
    # Move down x times and then to the start of the line
    $stderr.print "#{CSI}#{@displayed_items.size+1}B\r"
  end

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

  def replace_input(str)
    $stderr.print "#{CSI}s"
    $stderr.print "\b"*@cursor
    $stderr.print "#{@input}#{CSI}K"
    $stderr.print "#{CSI}u"
  end

  def replace_items
    return unless block_given?
    list_size = @displayed_items.size
    $stderr.print "#{CSI}s"
    $stderr.print "#{CSI}\r"
    $stderr.print "#{CSI}B#{CSI}K"
    if list_size > 0
      $stderr.print "#{CSI}B#{CSI}K" * (list_size - 1)
      $stderr.print "#{CSI}A" * (list_size - 1)
    end
    new_items = yield
    @displayed_items = new_items
    @selected = limit_max @selected, list_size - 1
    print_items new_items
    $stderr.print "#{CSI}u"
  end

  def limit_max(n, max)
    [[max, n].min, 0].max
  end

  def print_items(items)
    items.each_with_index do |item, i|
      $stderr.puts "#{@selected == i ? "#{SELECTED_COLOR}‣" : " "} #{item}#{RESET_COLOR}"
    end
  end

  def filter_items(items, filter)
    regex = Regexp.new(filter.chars.join(".*"), "i")
    items.select {|i| regex.match i }
  end
end
