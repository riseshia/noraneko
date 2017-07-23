# frozen_string_literal: true

module Noraneko
  class CLI
    # @param args [Array<String>] command line arguments
    # @return [Integer] UNIX exit code
    def run(_args = ARGV)
      execute_runner('.')
    rescue StandardError, SyntaxError => e
      $stderr.puts e.message
      $stderr.puts e.backtrace
      return 2
    end

    private

    def execute_runner(path)
      runner = Runner.new
      unused_methods = runner.run(path)
      unused_methods.empty? ? 0 : 1
    end

    def print_result(methods)
      methods.each do |method|
        p method
      end
    end
  end
end
