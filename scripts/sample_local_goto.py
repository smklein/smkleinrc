"""
Python script made/used by Sean Klein (smklein).

Used to quickly navigate between multiple repositories.
"""

home = "~"
prefix_dir = home + "/path/prefix"

dir_info =\
["CATEGORY:",
 {"directory": prefix_dir + "/dirname",
  "build": """
      # Updates DEPS
      make deps
      # Actually builds sources. Defaults to "MODE=opt-linux".
      make sources please""",
  "test": """
      make this test pass please # Runs tests""",
  "link": """
      # Use as many links as you want!
      http://www.chromium.org/nativeclient/how-tos/build-tcb
      # Like this:
      https://google.com""",
  "other": """
      Put more info here!"""},
 {"directory": prefix_dir + "/asdfasdfasdf/"},
 {"directory": prefix_dir + "/asdfasdf"},
 {"directory": prefix_dir + "/asdf"},
 ]
