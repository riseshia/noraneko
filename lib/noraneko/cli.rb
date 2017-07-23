# frozen_string_literal: true

module Noraneko
  class CLI
    # @param args [Array<String>] command line arguments
    # @return [Integer] UNIX exit code
    def run(args = ARGV)
      paths = args.empty? ? ['.'] : args.first.split(',')
      execute_runner(paths)
    rescue StandardError, SyntaxError => e
      $stderr.puts e.message
      $stderr.puts e.backtrace
      return 2
    end

    private

    def execute_runner(paths)
      runner = Runner.new
      unused_methods = runner.run(paths)
      unused_methods.empty? ? 0 : 1
    end

    def print_result(methods)
      methods.each do |method|
        p method
      end
    end
  end
end
