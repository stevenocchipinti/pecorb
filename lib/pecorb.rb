require_relative "pecorb/list"
require_relative "pecorb/version"

module Pecorb
  extend self

  def list(*args)
    List.new(*args).prompt
  end

  DefaultConfig = Struct.new(:input_stream, :output_stream) do
    def initialize
      self.input_stream = $stdin
      self.output_stream = $stdout
    end
  end

  def self.configure
    @config = DefaultConfig.new
    yield(@config) if block_given?
    @config
  end

  def self.config
    @config || configure
  end
end
