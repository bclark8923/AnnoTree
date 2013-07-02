#!/usr/bin/python

from os import system
from sys import argv

DEBUG = False
if len(argv) > 1:
    if argv[1] == "DEBUG": DEBUG = True



config = open("config/install.config").read(-1)
components = open("config/components.config").read(-1)

username = "annotree"
password = "ann0tr33s"

for line in config.split("\n"):
  parts = line.split("=")
  if len(parts) == 2:
    key = parts[0]
    value = parts[1]
    if key == "username": username = value
    if key == "password": password = value


if DEBUG: system('echo "Creating Database" | cowsay')
line = components.split("\n")[0]
command = "mysql -u " + username + " --password=" + password + " < " + line
system(command)

if DEBUG: system('echo "Creating Database Tables" | cowsay')
for line in components.split("\n")[1:]:
  if len(line) < 1 or line[0] == "#":
    continue
  command = "mysql -u " + username + " --password=" + password + " annotree < " + line
  system(command)
  if DEBUG:
    print 'Running: ' + command  
