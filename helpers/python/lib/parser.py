# TODO: Python code goes here, not just hard coded output.
#       We need to parse the Pipfile and Pipfile.lock to get a list of
#       dependencies and their versions.
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
