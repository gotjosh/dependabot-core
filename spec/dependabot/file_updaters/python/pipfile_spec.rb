# frozen_string_literal: true
require "spec_helper"
require "dependabot/dependency"
require "dependabot/dependency_file"
require "dependabot/file_updaters/python/pipfile"
require "dependabot/shared_helpers"
require_relative "../shared_examples_for_file_updaters"

RSpec.describe Dependabot::FileUpdaters::Python::Pipfile do
  it_behaves_like "a dependency file updater"

  let(:updater) do
    described_class.new(
      dependency_files: [pipfile, lockfile],
      dependency: dependency,
      github_access_token: "token"
    )
  end
  let(:pipfile) do
    Dependabot::DependencyFile.new(
      content: pipfile_body,
      name: "Pipfile"
    )
  end
  let(:pipfile_body) do
    fixture("python", "pipfiles", "version_not_specified")
  end
  let(:lockfile) do
    Dependabot::DependencyFile.new(
      content: lockfile_body,
      name: "Pipfile.lock"
    )
  end
  let(:lockfile_body) do
    fixture("python", "lockfiles", "version_not_specified")
  end
  let(:dependency) do
    Dependabot::Dependency.new(
      name: "requests",
      version: "2.18.1",
      package_manager: "pipfile"
    )
  end
  let(:tmp_path) { Dependabot::SharedHelpers::BUMP_TMP_DIR_PATH }

  before { Dir.mkdir(tmp_path) unless Dir.exist?(tmp_path) }

  describe "#updated_dependency_files" do
    subject(:updated_files) { updater.updated_dependency_files }

    it "doesn't store the files permanently" do
      expect { updated_files }.to_not(change { Dir.entries(tmp_path) })
    end

    it "returns DependencyFile objects" do
      updated_files.each { |f| expect(f).to be_a(Dependabot::DependencyFile) }
    end

    its(:length) { is_expected.to eq(2) }

    describe "the updated Pipfile" do
      subject(:updated_pipfile) do
        updated_files.find { |f| f.name == "Pipfile" }
      end

      its(:content) { is_expected.to eq(pipfile_body) }
    end

    describe "the updated Pipfile.lock" do
      let(:updated_lockfile) do
        updated_files.find { |f| f.name == "Pipfile.lock" }
      end

      let(:json_lockfile) { JSON.parse(updated_lockfile.content) }

      it "has an updated version of requests" do
        expect(json_lockfile["default"]["requests"]["version"]).
          to eq("==2.18.1")
      end

      it "has the correct (unupdated) Pipfile hash" do
        expect(json_lockfile["_meta"]["hash"]).
          to eq(JSON.parse(lockfile_body)["_meta"]["hash"])
      end
    end
  end
end
