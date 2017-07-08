import json
import re
import os

from pipfile.api import PipfileParser
from pipenv.project import Project
from pipenv.utils import convert_deps_to_pip

def update(directory, dependency_name, dependency_version):
  # TODO: Write some codes
  pipfile_dict = PipfileParser(directory + "/Pipfile").parse()

  dev = pipfile_dict["develop"].has_key(dependency_name)

  key = "develop" if dev else "default"

  old_requirement = pipfile_dict[key][dependency_name]
  old_version_string = re.sub('^[^\d]', '', old_requirement)

  precision = len(filter(None, old_version_string.split('.')))
  new_version_string = ".".join(dependency_version.split('.')[:precision])

  new_requirement = old_requirement.replace(old_version_string, new_version_string)

  project = Project()
  project._pipfile_location = directory + "/Pipfile"

  package_name_with_version = convert_deps_to_pip({ dependency_name: new_requirement }, False)[0]
  project.add_package_to_pipfile(package_name_with_version, dev)

  os.system("cd {0} && pipenv lock".format(directory))

  lockfile = open(directory + "/Pipfile.lock", "r").read()
  pipfile = open(directory + "/Pipfile", "r").read()
  return json.dumps({ "result": { "Pipfile": pipfile, "Pipfile.lock": lockfile } })
