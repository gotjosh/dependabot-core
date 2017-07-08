# Parse the Pipfile and Pipfile.lock to get a list of dependency versions.
import json

from pipfile.api import PipfileParser

def parse(directory):
  pipfile_dict = PipfileParser(directory + "/Pipfile").parse()
  lockfile_dict = json.loads(open(directory + "/Pipfile.lock", "r").read())

  packages = []

  for key in pipfile_dict["default"].iterkeys():
    packages.append({ "name": key, "version": lockfile_dict["default"][key]["version"].replace('=', '') })

  for key in pipfile_dict["develop"].iterkeys():
    packages.append({ "name": key, "version": lockfile_dict["develop"][key]["version"].replace('=', '') })

  return json.dumps({ "result": packages })
