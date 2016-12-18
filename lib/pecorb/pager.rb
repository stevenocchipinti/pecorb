require_relative "../core_extensions/comparable"

module Pecorb
  class Pager
    def initialize(items, viewport_size)
      @configured_items = @items = items
      @viewport_size = viewport_size
      @cursor = 0
      reset_viewport
    end

    def selected_item
      @items.fetch(@cursor)
    end

    def items_in_viewport
      @items.slice(@viewport.min, @viewport_size)
    end

    def filter!(filter_text)
      self.items = fuzzy_filter(filter_text)
    end

    def items=(new_items)
      @items = new_items
      @cursor = @cursor.clamp(0, @items.size-1)
      reset_viewport
    end

    def down
      move_cursor_by(1)
    end

    def up
      move_cursor_by(-1)
    end


    private

    def move_cursor_by(number)
      new_cursor = @cursor + number

      if new_cursor >= @items.size
        @cursor = 0
        reset_viewport
      elsif new_cursor > @viewport.max
        shift_viewport_by(1)
      end

      if new_cursor < 0
        @cursor = @items.size - 1
        reset_viewport
      elsif new_cursor < @viewport.min
        shift_viewport_by(-1)
      end

      @cursor = new_cursor % @items.size
    end

    def shift_viewport_by(number)
      @viewport = (@viewport.min + number)..(@viewport.max + number)
    end

    def reset_viewport
      @viewport = 0..(@viewport_size - 1)
      unless @viewport.cover?(@cursor)
        @viewport = (@cursor - @viewport_size + 1)..@cursor
      end
    end

    def fuzzy_filter(filter_text)
      return @configured_items unless filter_text
      regex = Regexp.new(filter_text.chars.join(".*"), "i")
      @configured_items.select {|i| regex.match i }
    end
  end
end
