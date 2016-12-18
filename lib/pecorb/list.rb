require_relative "console"
require_relative "../core_extensions/comparable"

# TODO: Separate pager and user input responsibilities

module Pecorb
  class List
    include Console

    def initialize(items, opts={})
      raise "Items must be enumerable!" unless items.is_a? Enumerable
      @prompt = opts.fetch(:prompt, "Select an item: ")
      @cursor = @row_cursor = @selected = 0
      @display_limit = IO.console.winsize.first - 2
      @page = 0
      @matching_items = @configured_items = items
      @displayed_items = @configured_items.slice(0, @display_limit)
      @filter_text = ""
    end

    def prompt
      init_ui
      while c = read_char
        case c
        when "", "\r"
          break
        when "", ""
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
          new_selection = @selected - 1
          @page -= 1 if new_selection - 1 < 0
          @selected = new_selection % @displayed_items.size
          update_ui
        when Console::DOWN, "\n" # CTRL-J enters a linefeed char in bash
          new_selection = @selected + 1
          @page += 1 if new_selection + 1 > @display_limit
          @selected = new_selection % @displayed_items.size
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

    def init_ui
      # WARNING: Can't use save_pos here because it causes problems when
      # introducing newlines, see issue #1
      puts
      print_items
      carriage_return; (@displayed_items.size + 1).times { up }
      print @prompt
    end

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
      regex = Regexp.new(@filter_text.chars.join(".*"), "i")
      @matching_items = @configured_items.select {|i| regex.match i }
      start_index = @page * @display_limit
      @displayed_items = @matching_items.slice(start_index, @display_limit)
      @selected = @selected.clamp(0, @displayed_items.size - 1)
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
  end
end
