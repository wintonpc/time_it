class TimeIt
  class << self
    Rec = Struct.new(:name, :parent, :start, :stop, :children)

    def time_it(name)
      begin_rec(name)
      GC.disable
      start = Time.now
      yield
    ensure
      stop = Time.now
      end_rec(start, stop)
      GC.enable unless @rec
    end

    private

    def begin_rec(name)
      parent = @rec
      @rec = Rec.new(name, parent, -1, -1, [])
      parent.children << @rec if parent
    end

    def end_rec(start, stop)
      @rec.start = start
      @rec.stop  = stop
      rec = @rec
      @rec = @rec.parent
      if @rec.nil?
        report(rec)
      end
    end

    def report(rec)
      q = visit_time_it(rec) { |ti, depth| [first_part(ti, depth), duration(ti).to_s] }
      max_name_width = q.map(&:first).map(&:size).max
      max_time_width = q.map(&:last).map(&:size).max
      print_time_it(rec, max_name_width, max_time_width)
    end

    def visit_time_it(ti, depth=0, &visit)
      [
          visit.call(ti, depth),
          *insert_mysteries(ti.children).flat_map { |c| visit_time_it(c, depth+1, &visit) }
      ]
    end

    def insert_mysteries(tis)
      return [] if tis.none?
      with_mysteries = tis.drop(1).inject([tis.first]) do |acc, ti|
        if duration2(acc.last.stop, ti.start) >= $time_it_threshold_ms
          acc << Rec.new('???', ti.parent, acc.last.stop, ti.start, [])
        end
        acc << ti
      end
      with_mysteries.reject { |ti| duration(ti) < $time_it_threshold_ms }
    end

    def print_time_it(ti, max_name_width, max_time_width)
      total_width = max_name_width + max_time_width + 7
      write('-' * total_width)
      visit_time_it(ti) do |ti, depth|
        write(cjust("#{first_part(ti, depth)} ", " #{duration(ti)} ms", total_width, '.'))
      end
      write('-' * total_width)
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
      ((stop - start) * 1000).round
    end

    def first_part(ti, depth)
      "#{'  ' * depth}#{ti.name}"
    end
  end
end

def time_it(name, &block)
  TimeIt.time_it(name, &block)
end

$time_it_threshold_ms = 10
$time_it_writer = proc { |s| puts s }
