# Dependabot Core

Dependabot Core is a library containing the logic to keep a project's
dependencies up to date. It is used by [Dependabot](https://dependabot.com).

## Setup

To run Dependabot Core, you'll need both Ruby and Node installed. The main
library is written in Ruby, and JavaScript is required for dealing with
package.json and yarn.lock files.

Before running Dependabot Core, install dependencies for the core library and
the helpers:

1. `bundle install`
2. `cd helpers/javascript && yarn install && cd -`
3. `cd helpers/php && composer install && cd -`
4. `cd helpers/elixir && mix deps.get && cd -`

## Internals

Dependabot Core has helper classes for seven concerns:

| Service                    | Description                                                                                   |
|----------------------------|-----------------------------------------------------------------------------------------------|
| `Dependabot::FileFetchers`       | Fetches the relevant dependency files for a project (e.g., the `Gemfile` and `Gemfile.lock`). |
| `Dependabot::FileParsers`        | Parses a dependency file and extracts a list of dependencies for a project.                   |
| `Dependabot::UpdateCheckers`     | Checks whether a given dependency is up-to-date.                                              |
| `Dependabot::FileUpdaters`       | Updates a dependency file to use the latest version of a given dependency.                    |
| `Dependabot::MetadataFinders`    | Looks up metadata about a dependency, such as its GitHub URL.                                 |
| `Dependabot::PullRequestCreator` | Creates a Pull Request to the original repo with the updated dependency file.                 |
| `Dependabot::PullRequestUpdater` | Updates an existing Pull Request with new dependency files (e.g., to resolve conflicts).      |

## Contributing

We'd love to see the following improvements to Dependabot Core:

- Support for [Pipenv](https://github.com/kennethreitz/pipenv) in Python.
- Support for [npm5](https://www.npmjs.com/package/npm5) in JavaScript.
- Support for additional languages (Elixir, anyone?)
