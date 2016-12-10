require "io/console"

module Pecorb
  module Console
    CSI   = "\e["
    UP    = "#{CSI}A"
    DOWN  = "#{CSI}B"
    RIGHT = "#{CSI}C"
    LEFT  = "#{CSI}D"

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

    def print(val)          $stderr.print val                 end
    def puts(val)           $stderr.puts val                  end
    def output(val)         $stdout.puts val                  end

    def up(n=1)             $stderr.print "#{CSI}#{n}A"       end
    def down(n=1)           $stderr.print "#{CSI}#{n}B"       end
    def right(n=1)          $stderr.print "#{CSI}#{n}C"       end
    def left(n=1)           $stderr.print "#{CSI}#{n}D"       end

    def backspace(n=1)      $stderr.print "\b"*n              end
    def carriage_return()   $stderr.print "\r"                end
    def clear_to_eol()      $stderr.print "#{CSI}K"           end
    def clear_screen()      $stderr.print "#{CSI}H#{CSI}J"    end

    def black()             $stderr.print "#{CSI}#{CSI}30m"   end
    def red()               $stderr.print "#{CSI}#{CSI}31m"   end
    def green()             $stderr.print "#{CSI}#{CSI}32m"   end
    def yellow()            $stderr.print "#{CSI}#{CSI}33m"   end
    def blue()              $stderr.print "#{CSI}#{CSI}34m"   end
    def magenta()           $stderr.print "#{CSI}#{CSI}35m"   end
    def cyan()              $stderr.print "#{CSI}#{CSI}36m"   end
    def white()             $stderr.print "#{CSI}#{CSI}37m"   end
    def reset_color()       $stderr.print "#{CSI}#{CSI}0m"    end

    def save_pos
      $stderr.print "#{CSI}s"
      if block_given?
        yield
        load_pos
      end
    end
    def load_pos() $stderr.print "#{CSI}u" end
  end
end
