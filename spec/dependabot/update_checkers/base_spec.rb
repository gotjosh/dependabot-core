# frozen_string_literal: true
require "spec_helper"
require "dependabot/dependency"
require "dependabot/update_checkers/base"

RSpec.describe Dependabot::UpdateCheckers::Base do
  let(:updater_instance) do
    described_class.new(
      dependency: dependency,
      dependency_files: [],
      github_access_token: "token"
    )
  end
  let(:dependency) do
    Dependabot::Dependency.new(
      name: "business",
      version: "1.5.0",
      requirements: [{ file: "Gemfile", requirement: ">= 0", groups: [] }],
      package_manager: "bundler"
    )
  end
  let(:latest_version) { Gem::Version.new("1.0.0") }
  let(:updated_requirements) do
    [{ file: "Gemfile", requirement: updated_requirement, groups: [] }]
  end
  let(:updated_requirement) { ">= 1.0.0" }
  let(:latest_resolvable_version) { latest_version }
  before do
    allow(updater_instance).
      to receive(:latest_version).
      and_return(latest_version)

    allow(updater_instance).
      to receive(:latest_resolvable_version).
      and_return(latest_resolvable_version)

    allow(updater_instance).
      to receive(:updated_requirements).
      and_return(updated_requirements)
  end

  describe "#needs_update?" do
    subject(:needs_update) { updater_instance.needs_update? }

    context "when the dependency is outdated" do
      let(:latest_version) { Gem::Version.new("1.6.0") }

      it { is_expected.to be_truthy }

      context "but cannot resolve to the new version" do
        let(:latest_resolvable_version) { Gem::Version.new("1.5.0") }
        it { is_expected.to be_falsey }
      end
    end

    context "when the dependency is up-to-date" do
      let(:latest_version) { Gem::Version.new("1.5.0") }
      it { is_expected.to be_falsey }

      it "doesn't attempt to resolve the dependency" do
        expect(updater_instance).to_not receive(:latest_resolvable_version)
        needs_update
      end
    end

    context "when the dependency couldn't be found" do
      let(:latest_version) { nil }
      it { is_expected.to be_falsey }
    end

    context "when updating a requirement file" do
      let(:dependency) do
        Dependabot::Dependency.new(
          name: "business",
          requirements: requirements,
          package_manager: "bundler"
        )
      end
      let(:requirements) do
        [{ file: "Gemfile", requirement: "~> 1", groups: [] }]
      end

      context "that already permits the latest version" do
        let(:updated_requirements) { requirements }
        it { is_expected.to be_falsey }
      end

      context "that doesn't yet permit the latest version" do
        let(:updated_requirements) do
          [{ file: "Gemfile", requirement: ">= 1, < 3", groups: [] }]
        end
        it { is_expected.to be_truthy }
      end

      context "that we don't know how to fix" do
        let(:updated_requirements) do
          [{ file: "Gemfile", requirement: :unfixable, groups: [] }]
        end
        it { is_expected.to be_falsey }
      end
    end
  end

  describe "#updated_dependency" do
    subject(:updated_dependency) { updater_instance.updated_dependency }
    let(:latest_version) { Gem::Version.new("1.9.0") }

    its(:version) { is_expected.to eq("1.9.0") }
    its(:previous_version) { is_expected.to eq("1.5.0") }
    its(:package_manager) { is_expected.to eq(dependency.package_manager) }
    its(:name) { is_expected.to eq(dependency.name) }
  end
end
