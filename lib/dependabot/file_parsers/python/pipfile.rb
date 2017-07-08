# frozen_string_literal: true
require "dependabot/dependency"
require "dependabot/file_parsers/base"
require "dependabot/file_fetchers/python/pipfile"
require "dependabot/shared_helpers"

module Dependabot
  module FileParsers
    module Python
      class Pipfile < Dependabot::FileParsers::Base
        def parse
          dependency_versions.map do |dep|
            Dependency.new(
              name: dep["name"],
              version: dep["version"],
              package_manager: "pipfile"
            )
          end
        end

        private

        def dependency_versions
          SharedHelpers.in_a_temporary_directory do |dir|
            File.write(File.join(dir, "Pipfile"), pipfile.content)
            File.write(File.join(dir, "Pipfile.lock"), lockfile.content)

            SharedHelpers.run_helper_subprocess(
              command: "python #{python_helper_path}",
              function: "parse",
              args: [dir]
            )
          end
        end

        def python_helper_path
          project_root = File.join(File.dirname(__FILE__), "../../../..")
          File.join(project_root, "helpers/python/run.py")
        end

        def required_files
          Dependabot::FileFetchers::Python::Pipfile.required_files
        end

        def pipfile
          @pipfile ||= get_original_file("Pipfile")
        end

        def lockfile
          @lockfile ||= get_original_file("Pipfile.lock")
        end
      end
    end
  end
end
