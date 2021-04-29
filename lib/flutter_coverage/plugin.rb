# frozen_string_literal: true

module Danger
  class DangerFlutterCoverage < Plugin
    attr_accessor :coverage_path

    def print
      raise "The coverage file could not be found." unless File.exist?(coverage_path)

      cov = parse_lcov(File.readlines(coverage_path, chomp: true))
      markdown format_as_markdown(cov)
    end

    private

    def format_as_markdown(cov)
      target = git.modified_files - git.deleted_files - git.renamed_files
      lines = [
        '### Coverage report

| Name | Coverage |
|:---|---:|
'
      ]
      target.each do |t|
        i = cov.find_index { |c| c.name == t }
        if i
          c = cov[i]
          lines.push("| #{c.name} | #{format('%.1f', c.calculate)}% |\n")
        end
      end
      lines.join
    end

    def parse_lcov(lines)
      cov = []
      name = ""
      line_cov = []
      lf = lh = 0

      lines.each do |line|
        key, value = line.split(":")
        case key
        when "SF"
          name = value
        when "DA"
          n, c = value.split(",")
          line_cov.push(LineCoverage.new(n.to_i, c.to_i))
        when "LF"
          lf = value.to_f
        when "LH"
          lh = value.to_f
        when "end_of_record"
          cov.push(Coverage.new(name, line_cov, lf, lh))
          name = ""
          line_cov = []
          lf = lh = 0
        else
          warn "An unknown key was found."
        end
      end
      cov
    end

    class Coverage
      attr_reader :name, :line_coverages

      def initialize(name, line_coverages, lines, instrumented_lines)
        @name = name
        @line_coverages = line_coverages
        @number_of_lines = lines
        @number_of_instrumented_lines = instrumented_lines
      end

      def calculate
        (@number_of_instrumented_lines / @number_of_lines) * 100
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
