# frozen_string_literal: true

module Noraneko
  class Runner
    def run(paths)
      target_files = find_target_files(paths)
      registry = analyze_ruby_files(target_files)
      Project.new(registry).all_unuseds
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

    def analyze_ruby_files(target_files)
      Noraneko::Registry.new.tap do |registry|
        target_files.each do |file|
          file.gsub!('//', '/')
          processor =
            Noraneko::Processor.init_with(registry: registry, filepath: file)
          source = File.read(file)
          ast = Parser::CurrentRuby.parse(source)
          processor.process(ast)
        end
      end
    end
  end
end
