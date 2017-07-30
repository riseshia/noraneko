# frozen_string_literal: true

module Noraneko
  class Runner
    def run(paths)
      target_files = find_target_files(paths)
      project = scan_files(target_files)
      project.result
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
      registry = Noraneko::Registry.new

      target_files.each do |file|
        file.gsub!('//', '/')
        processor =
          Noraneko::Processor.init_with(registry: registry, filepath: file)
        source = File.read(file)
        ast = Parser::CurrentRuby.parse(source)
        processor.process(ast)
      end
      Project.new(registry)
    end
  end
end
