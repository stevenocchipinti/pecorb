require_relative "console"
require_relative "../core_extensions/comparable"
require_relative "pager"

module Pecorb
  class List
    include Console

    def initialize(items, opts={})
      raise "Items must be enumerable!" unless items.is_a? Enumerable
      @prompt = opts.fetch(:prompt, "Select an item: ")
      @pager = Pager.new items, IO.console.winsize.first - 2
      @cursor = 0
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
          @pager.up
          update_ui
        when Console::DOWN, "\n" # CTRL-J enters a linefeed char in bash
          @pager.down
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
      puts @pager.selected_item
      reset_color
      @pager.selected_item
    end

    private

    def init_ui
      # WARNING: Can't use save_pos here because it causes problems when
      # introducing newlines, see issue #1
      puts
      print_items
      carriage_return; (@pager.items_in_viewport.size + 1).times { up }
      print @prompt
    end

    def update_ui
      save_pos do
        update_filter_text
        clear_items
        @pager.filter! @filter_text
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
      @pager.items_in_viewport.size.times { down; clear_to_eol }
      @pager.items_in_viewport.size.times { up }
    end

    def print_items
      @pager.items_in_viewport.each_with_index do |item, i|
        if item == @pager.selected_item
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
