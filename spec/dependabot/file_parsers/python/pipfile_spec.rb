# frozen_string_literal: true
require "spec_helper"
require "dependabot/dependency_file"
require "dependabot/file_parsers/python/pipfile"
require_relative "../shared_examples_for_file_parsers"

RSpec.describe Dependabot::FileParsers::Python::Pipfile do
  it_behaves_like "a dependency file parser"

  let(:files) { [pipfile, lockfile] }
  let(:pipfile) do
    Dependabot::DependencyFile.new(
      name: "Pipfile",
      content: pipfile_body
    )
  end
  let(:lockfile) do
    Dependabot::DependencyFile.new(name: "Pipfile.lock", content: lockfile_body)
  end

  let(:pipfile_body) { fixture("python", "pipfiles", "version_not_specified") }
  let(:lockfile_body) do
    fixture("python", "lockfiles", "version_not_specified")
  end
  let(:parser) { described_class.new(dependency_files: files) }

  describe "parse" do
    subject(:dependencies) { parser.parse }

    its(:length) { is_expected.to eq(2) }

    context "with a version specified" do
      describe "the first dependency" do
        subject { dependencies.first }

        it { is_expected.to be_a(Dependabot::Dependency) }
        its(:name) { is_expected.to eq("requests") }
        its(:version) { is_expected.to eq("2.18.0") }
      end
    end
  end
end
