# frozen_string_literal: true

module Noraneko
  class Runner
    def run(paths)
      target_files = find_target_files(paths)
      project = scan_files(target_files)
      project.unused_methods
    end

    private

    def find_target_files(paths)
      paths.map { |path| find_target_files_in_path(path) }.flatten
    end

    def find_target_files_in_path(path)
      Dir["#{path}/**/*.rb"].reject do |file|
        file.end_with?('_spec.rb', '_test.rb')
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
