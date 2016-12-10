require "io/console"
require_relative "../pecorb"

module Pecorb
  module Console
    CSI   = "\e["
    UP    = "#{CSI}A"
    DOWN  = "#{CSI}B"
    RIGHT = "#{CSI}C"
    LEFT  = "#{CSI}D"

    def read_char
      input_stream.echo = false
      input_stream.raw!
      input = input_stream.getc.chr
      if input == "\e" then
        input << input_stream.read_nonblock(3) rescue nil
        input << input_stream.read_nonblock(2) rescue nil
      end
    ensure
      input_stream.echo = true
      input_stream.cooked!
      return input
    end

    def puts(val="")        output_stream.puts val                  end
    def print(val="")       output_stream.print val                 end

    def up(n=1)             output_stream.print "#{CSI}#{n}A"       end
    def down(n=1)           output_stream.print "#{CSI}#{n}B"       end
    def right(n=1)          output_stream.print "#{CSI}#{n}C"       end
    def left(n=1)           output_stream.print "#{CSI}#{n}D"       end

    def backspace(n=1)      output_stream.print "\b"*n              end
    def carriage_return()   output_stream.print "\r"                end
    def clear_to_eol()      output_stream.print "#{CSI}K"           end
    def clear_to_eos()      output_stream.print "#{CSI}J"           end
    def clear_screen()      output_stream.print "#{CSI}H#{CSI}J"    end

    def black()             output_stream.print "#{CSI}#{CSI}30m"   end
    def red()               output_stream.print "#{CSI}#{CSI}31m"   end
    def green()             output_stream.print "#{CSI}#{CSI}32m"   end
    def yellow()            output_stream.print "#{CSI}#{CSI}33m"   end
    def blue()              output_stream.print "#{CSI}#{CSI}34m"   end
    def magenta()           output_stream.print "#{CSI}#{CSI}35m"   end
    def cyan()              output_stream.print "#{CSI}#{CSI}36m"   end
    def white()             output_stream.print "#{CSI}#{CSI}37m"   end
    def reset_color()       output_stream.print "#{CSI}#{CSI}0m"    end

    def save_pos
      output_stream.print "#{CSI}s"
      if block_given?
        yield
        load_pos
      end
    end
    def load_pos() output_stream.print "#{CSI}u" end

    private

    def input_stream
      Pecorb.config.input_stream
    end

    def output_stream
      Pecorb.config.output_stream
    end
  end
end
