# frozen_string_literal: true

module Danger
  class DangerFlutterCoverage < Plugin
    attr_accessor :coverage_path

    def print
      raise "The coverage file could not be found." unless File.exist?(coverage_path)

      parse_lcov(File.readlines(coverage_path, chomp: true))
    end

    private

    def parse_lcov(lines) end

    class Coverage
      attr_reader :name, :line_coverages

      def initialize(name, line_coverages, lines, instrumented_lines)
        @name = name
        @line_coverages = line_coverages
        @number_of_lines = lines
        @number_of_instrumented_lines = instrumented_lines
      end

      def calculate
        @number_of_instrumented_lines / @number_of_lines
      end
    end

    class LineCoverage
      attr_reader :line_number

      def initialize(line_number, execution_count)
        @line_number = line_number
        @execution_count = execution_count
      end

      def instrumented?
        @execution_count.positive?
      end
    end
  end
end
