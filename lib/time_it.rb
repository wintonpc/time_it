class TimeIt
  class << self
    Rec = Struct.new(:name, :parent, :start, :stop, :children, :multis)

    def time_it(name, multi: false)
      begin_rec(name)
      GC.disable
      start = Time.now
      yield
    ensure
      stop = Time.now
      end_rec(start, stop)
      GC.enable unless @rec
    end

    def time_all(name)
      name = "#{name}*"
      if !@rec
        raise 'time_all must be called within a time_it block'
      end
      start = Time.now
      yield
    ensure
      stop = Time.now
      @rec.multis[name] += duration2(start, stop)
    end

    private

    def multi
      @multi ||= Hash.new(0)
    end

    def begin_rec(name)
      parent = @rec
      @rec = new_rec(name, parent)
      parent.children << @rec if parent
    end

    def new_rec(name, parent, start=-1, stop=-1)
      Rec.new(name, parent, start, stop, [], Hash.new(0))
    end

    def end_rec(start, stop)
      @rec.start = start
      @rec.stop  = stop
      rec = @rec
      @rec = @rec.parent
      if @rec.nil?
        report(rec)
        @multi = nil
      end
    end

    def report(rec)
      q = visit_time_it(rec) { |name, duration, depth| [format_name(name, depth), format_duration(duration)] }
      max_name_width = q.map(&:first).map(&:size).max
      max_time_width = q.map(&:last).map(&:size).max
      print_time_it(rec, max_name_width, max_time_width)
    end

    def format_duration(duration)
      duration.round.to_s
    end

    def visit_time_it(ti, depth=0, &visit)
      [
          visit.call(ti.name, duration(ti), depth),
          *insert_mysteries(ti.children).flat_map { |c| visit_time_it(c, depth+1, &visit) },
          *ti.multis.map{|(name, duration)| visit.call(name, duration, depth+1)}
      ]
    end

    def insert_mysteries(tis)
      return [] if tis.none?
      tis.drop(1).inject([tis.first]) do |acc, ti|
        acc << new_rec('???', ti.parent, acc.last.stop, ti.start)
        acc << ti
      end
    end

    def print_time_it(ti, max_name_width, max_time_width)
      total_width = max_name_width + max_time_width + 7
      write('-' * total_width) if $time_it_pretty
      visit_time_it(ti) do |name, duration, depth|
        if duration >= $time_it_threshold_ms
          write(cjust("#{format_name(name, depth)} ", " #{format_duration(duration)} ms", total_width, '.'))
        end
      end
      write('-' * total_width) if $time_it_pretty
    end

    def write(s)
      $time_it_writer.call(s)
    end

    def cjust(left, right, width, char=' ')
      left + (char * (width - left.size - right.size)) + right
    end

    def duration(ti)
      duration2(ti.start, ti.stop)
    end

    def duration2(start, stop)
      (stop - start) * 1000
    end

    def format_name(name, depth)
      "#{'  ' * depth}#{name}"
    end
  end
end

def time_it(name, &block)
  TimeIt.time_it(name, &block)
end

def time_all(name, &block)
  TimeIt.time_all(name, &block)
end

$time_it_threshold_ms = 10
$time_it_writer = proc { |s| puts s }
$time_it_pretty = true
