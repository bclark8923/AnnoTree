#!/usr/bin/python

import os
from sys import argv
from itertools import chain
def main():
  log_level = 'Error'
  if(len(argv)) > 1:
      log_level = argv[1]


  components = open('../config/components.config').read(-1)
  components_list = components.split('\n')
  f_names = []

  if log_level == "DEBUG": print components_list

  paths = ('../tables', '../procedures', '../util')
  for dirname, dirnames, filenames in chain.from_iterable(os.walk(path) for path in paths):
    for filename in filenames:
      full_name = os.path.join(dirname, filename).replace('../', '')
      if not full_name[-1] == '~':
        if log_level == "DEBUG": full_name
        if not full_name in components_list:
          print log_level + ": " + full_name

if __name__ == "__main__":
    main()

    
