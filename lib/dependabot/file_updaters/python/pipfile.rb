# frozen_string_literal: true
require "dependabot/file_updaters/base"
require "dependabot/file_fetchers/python/pipfile"
require "dependabot/shared_helpers"

module Dependabot
  module FileUpdaters
    module Python
      class Pipfile < Dependabot::FileUpdaters::Base
        def updated_dependency_files
          [
            updated_file(
              file: pipfile,
              content: updated_dependency_files_content["Pipfile"]
            ),
            updated_file(
              file: lockfile,
              content: updated_dependency_files_content["Pipfile.lock"]
            )
          ]
        end

        private

        def required_files
          Dependabot::FileFetchers::Python::Pipfile.required_files
        end

        def pipfile
          @pipfile ||= get_original_file("Pipfile")
        end

        def lockfile
          @lockfile ||= get_original_file("Pipfile.lock")
        end

        def updated_dependency_files_content
          @updated_dependency_files_content ||=
            SharedHelpers.in_a_temporary_directory do |dir|
              File.write(File.join(dir, "Pipfile.lock"), lockfile.content)
              File.write(File.join(dir, "Pipfile"), pipfile.content)

              SharedHelpers.run_helper_subprocess(
                command: "python #{python_helper_path}",
                function: "update",
                args: [dir, dependency.name, dependency.version]
              )
            end
        end

        def python_helper_path
          project_root = File.join(File.dirname(__FILE__), "../../../..")
          File.join(project_root, "helpers/python/run.py")
        end
      end
    end
  end
end
