# frozen_string_literal: true
require "dependabot/file_fetchers/base"

module Dependabot
  module FileFetchers
    module Python
      class Pipfile < Dependabot::FileFetchers::Base
        def self.required_files
          %w(Pipfile Pipfile.lock)
        end
      end
    end
  end
end
