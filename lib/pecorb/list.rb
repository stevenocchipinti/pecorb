require_relative "console"

module Pecorb
  class List
    include Console

    def initialize(items, opts={})
      raise "Items must be enumerable!" unless items.is_a? Enumerable
      @prompt = opts.fetch(:prompt, "Select an item: ")

      @displayed_items = @configured_items = items
      @cursor = @selected = 0
      @filter_text = ""
    end

    def prompt
      print @prompt
      update_ui
      while c = read_char
        case c
        when "", "\r"
          break
        when ""
          carriage_return
          clear_to_eos
          exit 0
        when ""
          clear_screen
          print @prompt
          @cursor.times { right }
          update_ui
        when "" # Backspace key
          next if @filter_text.empty? || @cursor <= 0
          @filter_text.slice!(@cursor - 1)
          update_ui
          backspace
          @cursor -= 1
        when Console::LEFT
          next unless @cursor > 0
          print c
          @cursor -= 1
        when Console::RIGHT
          next unless @cursor < @filter_text.length
          print c
          @cursor += 1
        when Console::UP, ""
          @selected = (@selected - 1) % @displayed_items.size
          update_ui
        when Console::DOWN, "\n" # CTRL-J enters a linefeed char in bash
          @selected = (@selected + 1) % @displayed_items.size
          update_ui
        else
          @filter_text.insert(@cursor, c)
          update_ui
          print c
          @cursor += 1
        end
      end

      backspace(@cursor)
      clear_to_eos
      cyan
      puts @displayed_items[@selected]
      reset_color
      @displayed_items[@selected]
    end

    private

    def update_ui
      save_pos do
        update_filter_text
        clear_items
        update_items
        print_items
      end
    end

    def update_filter_text
      backspace(@cursor)
      print @filter_text
      clear_to_eol
    end

    def clear_items
      carriage_return; down; clear_to_eol
      @displayed_items.size.times { down; clear_to_eol }
      @displayed_items.size.times { up }
    end

    def update_items
      @displayed_items = fuzzy_filter(@configured_items, @filter_text)
      @selected = limit_max @selected, @displayed_items.size - 1
    end

    def print_items
      @displayed_items.each_with_index do |item, i|
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

    def limit_max(n, max)
      [[max, n].min, 0].max
    end

    def fuzzy_filter(items, filter)
      regex = Regexp.new(filter.chars.join(".*"), "i")
      items.select {|i| regex.match i }
    end
  end
end
