# frozen_string_literal: true

module Noraneko
  class Runner
    def run(path)
      target_files = find_target_files(path)
      project = scan_files(target_files)
      project.unused_methods
    end

    private

    def find_target_files(path)
      Dir["#{path}/**/*.rb"].reject do |file|
        file.end_with?('_spec.rb') || file.end_with?('_test.rb')
      end
    end

    def scan_files(target_files)
      descriptions = target_files.map do |file|
        source = File.read(file)
        Analyzer.new.execute(source)
      end
      Project.new(descriptions)
    end
  end
end
