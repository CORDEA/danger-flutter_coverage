# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerFlutterCoverage do
    it "is a plugin" do
      # noinspection RubyArgCount
      expect(Danger::DangerFlutterCoverage.new(nil)).to be_a Danger::Plugin
    end
  end

  describe "#print" do
    before do
      @dangerfile = testing_dangerfile
      @flutter_coverage = @dangerfile.flutter_coverage

      @flutter_coverage.coverage_path = "./spec/fixtures/lcov.info"
    end

    it "coverage report should not be printed" do
      @flutter_coverage.coverage_path = ""
      @flutter_coverage.print
      expect(@dangerfile.status_report[:errors].first).to eq("The coverage file could not be found.")
    end

    context "with modified files" do
      before do
        allow(@flutter_coverage.git).to receive(:modified_files).and_return %w[lib/a.dart lib/b.dart lib/c.dart]
        allow(@flutter_coverage.git).to receive(:deleted_files).and_return []
        allow(@flutter_coverage.git).to receive(:renamed_files).and_return []
      end

      it "coverage report should be printed" do
        @flutter_coverage.print
        expected = "### Coverage report\n\n| Name | Coverage |\n|:---|---:|
| lib/a.dart | 25.0% |\n| lib/b.dart | 0.0% |\n| lib/c.dart | 72.7% |\n"
        expect(@dangerfile.status_report[:markdowns].first.message).to eq(expected)
      end
    end

    context "with modified & deleted files" do
      before do
        allow(@flutter_coverage.git).to receive(:modified_files).and_return %w[lib/a.dart lib/b.dart lib/c.dart]
        allow(@flutter_coverage.git).to receive(:deleted_files).and_return %w[lib/b.dart]
        allow(@flutter_coverage.git).to receive(:renamed_files).and_return []
      end

      it "coverage report should be printed without deleted files" do
        @flutter_coverage.print
        expected = "### Coverage report\n\n| Name | Coverage |\n|:---|---:|
| lib/a.dart | 25.0% |\n| lib/c.dart | 72.7% |\n"
        expect(@dangerfile.status_report[:markdowns].first.message).to eq(expected)
      end
    end

    context "with modified & renamed files" do
      before do
        allow(@flutter_coverage.git).to receive(:modified_files).and_return %w[lib/a.dart lib/b.dart lib/c.dart]
        allow(@flutter_coverage.git).to receive(:deleted_files).and_return []
        allow(@flutter_coverage.git).to receive(:renamed_files).and_return %w[lib/c.dart]
      end

      it "coverage report should be printed without renamed files" do
        @flutter_coverage.print
        expected = "### Coverage report\n\n| Name | Coverage |\n|:---|---:|
| lib/a.dart | 25.0% |\n| lib/b.dart | 0.0% |\n"
        expect(@dangerfile.status_report[:markdowns].first.message).to eq(expected)
      end
    end

    context "with deleted & renamed files" do
      before do
        allow(@flutter_coverage.git).to receive(:modified_files).and_return []
        allow(@flutter_coverage.git).to receive(:deleted_files).and_return %w[lib/a.dart]
        allow(@flutter_coverage.git).to receive(:renamed_files).and_return %w[lib/c.dart]
      end

      it "coverage report should not be printed" do
        @flutter_coverage.print
        expected = "### Coverage report\n\nNo changes.\n"
        expect(@dangerfile.status_report[:markdowns].first.message).to eq(expected)
      end
    end
  end
end
