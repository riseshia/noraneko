# frozen_string_literal: true

module Noraneko
  class CLI
    # @param args [Array<String>] command line arguments
    # @return [Integer] UNIX exit code
    def run(_args = ARGV)
      execute_runner('.')
      return 0
    rescue StandardError, SyntaxError => e
      $stderr.puts e.message
      $stderr.puts e.backtrace
      return 2
    end

    private

    def execute_runner(path)
      runner = Runner.new
      runner.run(path)
    end
  end
end
