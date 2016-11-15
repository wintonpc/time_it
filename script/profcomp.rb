require_relative '../lib/proftab.rb'

old_path, new_path = ARGV
ProfTab.compare(old_path, new_path)
