require_relative '../lib/proftab.rb'

pattern = /(?<time>\d{2}:\d{2}:\d{2}.\d{3}) .* (MONGORW|PROFILE) (?<when>Started|Finished) (?<name>.*)/
ProfTab.run($stdin, $stdout) do |line|
  m = pattern.match(line)
  if m
    {
      time: Time.parse(m[:time]),
      when: m[:when] == 'Started' ? :start : :end,
      name: m[:name]
    }
  else
    nil
  end
end
