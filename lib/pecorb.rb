require_relative "pecorb/version"
require_relative "pecorb/console"

module Pecorb
  extend self
  extend Console

  @input = ""
  @cursor = 0
  @selected = 0
  @items = []
  @displayed_items = []


  def prompt(items, prompt="Select an item: ")
    @displayed_items = @items = items
    @prompt = prompt

    print_menu

    while c = read_char
      case c
      when '', "\r"
        break
      when ''
        carriage_return
        clear_to_eos
        exit 0
      when ''
        clear_screen
        print_menu
      when '' # Backspace key
        next if @input.empty? || @cursor <= 0
        @input.slice!(@cursor-1)
        replace_input(@input)
        replace_items { filter_items(@items, @input) }
        backspace
        @cursor -= 1
      when Console::LEFT
        next unless @cursor > 0
        print c
        @cursor -= 1
      when Console::RIGHT
        next unless @cursor < @input.length
        print c
        @cursor += 1
      when Console::UP, ''
        @selected = (@selected - 1) % @displayed_items.size
        replace_items { filter_items(@items, @input) }
      when Console::DOWN, "\n" # CTRL-J enters a linefeed char in bash
        @selected = (@selected + 1) % @displayed_items.size
        replace_items { filter_items(@items, @input) }
      else
        @input.insert(@cursor, c)
        replace_input(@input)
        replace_items { filter_items(@items, @input) }
        print c
        @cursor += 1
      end
    end

    move_cursor_from_start_to_end
    output @displayed_items[@selected]
    @displayed_items[@selected]
  end

  private

  def print_menu
    puts @prompt
    print_items(@displayed_items)
    move_cursor_from_end_to_start
    print @input
  end

  def move_cursor_from_end_to_start
    up(@displayed_items.size + 1)
    right(@prompt.size)
  end

  def move_cursor_from_start_to_end
    down(@displayed_items.size + 1)
    carriage_return
  end

  def replace_input(str)
    save_pos do
      backspace(@cursor)
      print @input
      clear_to_eol
    end
  end

  def replace_items
    return unless block_given?
    list_size = @displayed_items.size
    save_pos do
      down
      carriage_return
      clear_to_eol
      if list_size > 0
        (list_size - 1).times { down; clear_to_eol}
        (list_size - 1).times { up }
      end
      @displayed_items = yield
      @selected = limit_max @selected, list_size - 1
      print_items @displayed_items
    end
  end

  def limit_max(n, max)
    [[max, n].min, 0].max
  end

  def print_items(items)
    items.each_with_index do |item, i|
      if @selected == i
        cyan
        print "‣ "
      else
        print "  "
      end
      puts item
      reset_color
    end
  end

  def filter_items(items, filter)
    regex = Regexp.new(filter.chars.join(".*"), "i")
    items.select {|i| regex.match i }
  end
end
