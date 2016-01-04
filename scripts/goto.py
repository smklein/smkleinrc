"""
Python script made/used by Sean Klein (smklein).

Used to quickly navigate between multiple repositories.
"""

import os
import sys

# Include the path to "local_goto.py".
# This must include "dir_info".
sys.path.append(os.getenv("HOME"))

# XXX Try swapping these to play with a sample goto. It is expected
# that "local_goto.py" will live in the HOME directory.
from local_goto import dir_info
#from sample_local_goto import dir_info

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

#Print header info.
def printHeader(line):
  print YELLOW + line + NC

#Colorize the comments (until the end of the line)
def colorized_comments(string):
  return string.replace("#", YELLOW + "#").replace("\n", "\n" + NC) + NC

#Print additional information corresponding to a single entry.
def printEntry(line, index, link_index, detail_level):
  directory = line["directory"] if "directory" in line else ""
  build = line["build"] if "build" in line else ""
  test = line["test"] if "test" in line else ""
  other = line["other"] if "other" in line else ""
  links = line["link"] if "link" in line else ""

  info_identifier = ""
  if build or test or links or other:
    info_identifier = RED + " *" + NC

  if (detail_level == 2):
    i = 0
    links = map(str.strip, filter(str.strip, links.splitlines()))
    for link in links:
      if not link.startswith("#"):
        # Real link, not just comment
        if i == link_index:
          print link
          sys.exit(2)
        else:
          i += 1
    print RED + "ERROR: " + NC + "Link index out of range."
    sys.exit(0)

  print "[" + str(index) + "] " + CYAN + directory + info_identifier + NC
  if (detail_level == 1):
    print GREEN + "HOW TO BUILD: " + NC + colorized_comments(build)
    print GREEN + "HOW TO TEST: " + NC + colorized_comments(test)
    print GREEN + "OTHER INFO: " + NC + colorized_comments(other)
    print GREEN + "EXTRA INFO: " + NC
    i = 0
    links = map(str.strip, filter(str.strip, links.splitlines()))
    for link in links:
      if link.startswith("#"):
        print colorized_comments(link)
      else:
        print "[" + str(i) + "] " + CYAN + link + NC
        i += 1

# Main Function. Takes a varying number of args:
#  No args: Prints basic info for all directories
#  One arg: cd into selected directory (using help of bash function)
#  Two args: Print additional info for selected directory, OR open link.
if __name__ == '__main__':
  selected_index = -1
  detail_level = 0
  link_index = 0

  if len(sys.argv) >= 2:
    try:
      selected_index = int(sys.argv[1])
    except:
      print RED + "ERROR: " + NC + "First argument must be an integer."
      sys.exit(0)
  if len(sys.argv) == 3:
    if sys.argv[2] == "info":
      detail_level = 1
    else:
        print RED + "ERROR: " + NC + "Try using one of [info|link #]"
        sys.exit(0)
  elif len(sys.argv) == 4:
    if sys.argv[2] == "link":
      detail_level = 2
      try:
        link_index = int(sys.argv[3])
      except:
        print RED + "ERROR: " + NC + "Link index not an integer."
        sys.exit(0)
    else:
        print RED + "ERROR: " + NC + "Try using one of [info|link #]"
        sys.exit(0)

  index = 0
  for line in dir_info:
    if isinstance(line, str):
      if (selected_index == -1):
        printHeader(line)
    else:
      if (selected_index == index and detail_level == 0):
        # This output is used by a bash function. This is also
        # the only way this script can exit with return code "0".
        print line["directory"]
        sys.exit(1)
      elif (selected_index == -1 or selected_index == index):
        printEntry(line, index, link_index, detail_level)
      index += 1

