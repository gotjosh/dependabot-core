# frozen_string_literal: true
module Bundler
  class Source
    class Git
      class GitProxy
        private

        # Bundler allows ssh authentication when talking to GitHub but there's
        # no way for Dependabot to do so (it doesn't have any ssh keys).
        # Instead, we convert all `git@github.com:` URLs to use HTTPS.
        def configured_uri_for(uri)
          uri = uri.gsub("git@github.com:", "https://github.com/")
          if /https?:/ =~ uri
            remote = URI(uri)
            config_auth =
              Bundler.settings[remote.to_s] || Bundler.settings[remote.host]
            remote.userinfo ||= config_auth
            remote.to_s
          else
            uri
          end
        end
      end
    end
  end
end
