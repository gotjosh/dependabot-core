import sys
import json

from lib import parser, updater

if __name__ == "__main__":
  args = json.loads(sys.stdin.read())

  if args["function"] == "parse":
    print parser.parse(args["args"][0])
  elif args["function"] == "update":
    print updater.update(*args["args"])
