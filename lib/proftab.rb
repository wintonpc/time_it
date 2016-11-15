require 'time'

class ProfTab
  Record = Struct.new(:name, :start, :end)

  class << self
    def run(ip, op, &matcher)
      times = Hash.new { |h, k| h[k] = Record.new(k) }
      ip.each_line do |line|
        $stderr.puts line
        attrs = matcher.call(line)
        next unless attrs
        if attrs[:when] == :start
          times[attrs[:name]].start = attrs[:time]
        elsif attrs[:when] == :end
          times[attrs[:name]].end = attrs[:time]
        else
          $stderr.puts "Ignoring unexpected 'when': #{attrs[:when]}"
        end
      end

      tab = times.values.map do |r|
        duration = (r.end - r.start) * 1000
        [r.name, duration]
      end.to_h

      write_tab(op, tab)
    end

    def compare(old_path, new_path)
      old = read_tab(old_path)
      new = read_tab(new_path)
      results = new.keys.map do |name|
        a = old[name] || 0.0
        b = new[name]
        diff = b - a
        pct = a == 0 ? 100 : (diff / a) * 100
        [diff, "#{name.ljust(47, '.')}\t#{diff.round.to_s.rjust(7)}\t#{pct.round.to_s.rjust(5)}%"]
      end

      results.sort_by! { |(diff, _str)| diff }
      results.reverse.map(&:last).each { |x| puts x }
    end

    def read_tab(path)
      File.open(path) do |f|
        f.each_line.map do |line|
          name, duration = line.split("\t")
          [name, duration.to_f]
        end.to_h
      end
    end

    def write_tab(op, tab)
      tab.each_pair do |name, duration|
        op.puts "#{name}\t#{duration}"
      end
    end

    def merge(paths, op)
      tabs = paths.map(&method(:read_tab))
      sum = tabs.inject do |a, b|
        a.merge(b) do |_k, a, b|
          a + b
        end
      end
      mean = sum.each_pair.map do |k, v|
        [k, v / tabs.size]
      end.to_h
      write_tab(op, mean)
    end
  end
end
