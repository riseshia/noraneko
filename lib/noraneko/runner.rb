# frozen_string_literal: true

module Noraneko
  class Runner
    def run(paths)
      normalized = normalize_paths(paths)
      registry = analyze_ruby_files(normalized)
      view_registry = analyze_view_files(normalized)
      Project.new(registry, view_registry).all_unuseds
    end

    private

    def normalize_paths(paths)
      paths.map do |path|
        if path.end_with?('/')
          path[0..-2]
        else
          path
        end
      end
    end

    def find_ruby_files(paths)
      paths.map { |path| find_ruby_files_in_path(path) }.flatten
    end

    def find_ruby_files_in_path(path)
      Dir["#{path}/**/*.rb"].reject do |file|
        file.match?(/\/(spec|test|db)\//)
      end
    end

    def find_view_files(paths)
      paths.map { |path| Dir["#{path}/**/app/views/**/*.*"] }.flatten
    end

    def analyze_ruby_files(paths)
      target_files = find_ruby_files(paths)
      Noraneko::Registry.new.tap do |registry|
        target_files.each do |file|
          processor =
            Noraneko::Processor.init_with(registry: registry, filepath: file)
          source = File.read(file)
          ast = Parser::CurrentRuby.parse(source)
          processor.process(ast)
        end
      end
    end

    def analyze_view_files(paths)
      target_files = find_view_files(paths)
      Noraneko::Registry.new.tap do |registry|
        target_files.each do |file|
          processor =
            Noraneko::ViewProcessor.new(registry: registry, filepath: file)
          source = File.read(file)
          processor.process(source)
        end
      end
    end
  end
end
