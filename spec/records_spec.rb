require 'rspec'
require 'records'
require 'time_it'

$time_it_pretty = false

S = Struct.new(:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l)

class Record
  def initialize(*args)
    @fields = args
  end

  def a; @fields[0]; end
  def b; @fields[1]; end
  def c; @fields[2]; end
  def d; @fields[3]; end
  def e; @fields[4]; end
  def f; @fields[5]; end
  def g; @fields[6]; end
  def h; @fields[7]; end
  def i; @fields[8]; end
  def j; @fields[9]; end
  def k; @fields[10]; end
  def l; @fields[11]; end
end

class Record2 < Array
  def initialize(*args)
    self.replace(args)
  end

  def a; self[0]; end
  def b; self[1]; end
  def c; self[2]; end
  def d; self[3]; end
  def e; self[4]; end
  def f; self[5]; end
  def g; self[6]; end
  def h; self[7]; end
  def i; self[8]; end
  def j; self[9]; end
  def k; self[10]; end
  def l; self[11]; end
end

class RubyObject
  attr_accessor :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l

  def initialize(a, b, c, d, e, f, g, h, i, j, k, l)
    @a, @b, @c, @d, @e, @f, @g, @h, @i, @j, @k, @l = a, b, c, d, e, f, g, h, i, j, k, l
  end
end

describe 'records' do
  let!(:n) { 250000 }

  it 'Hash' do
    xs = time_it(:build_hash) do
      n.times.map do |i|
        {
            a: 1,
            b: 'to be or not to be',
            c: 0.12345678,
            d: 2,
            e: 'that is the question',
            f: 3.14159265,
            g: 3,
            h: 'hello world',
            i: 2.71828182,
            j: 4,
            k: 'goodbye, cruel world',
            l: 1.01010101,
        }
      end
    end

    time_it(:copy_hash) do
      xs.map do |x|
        {
            a: x[:a],
            b: x[:b],
            c: x[:c],
            d: x[:d],
            e: x[:e],
            f: x[:f],
            g: x[:g],
            h: x[:h],
            i: x[:i],
            j: x[:j],
            k: x[:k],
            l: x[:l],
        }
      end
    end
  end

  it 'Struct' do
    xs = time_it(:build_struct) do
      n.times.map do |i|
        S.new(1, 'to be or not to be', 0.12345678, 2, 'that is the question', 3.14159265, 3, 'hello world', 2.71828182, 4, 'goodbye, cruel world', 1.01010101)
      end
    end

    time_it(:copy_struct) do
      xs.map do |x|
        S.new(x.a, x.b, x.c, x.d, x.e, x.f, x.g, x.h, x.i, x.j, x.k, x.l)
      end
    end
  end

  it 'RubyObject' do
    xs = time_it(:build_ruby_object) do
      n.times.map do |i|
        RubyObject.new(1, 'to be or not to be', 0.12345678, 2, 'that is the question', 3.14159265, 3, 'hello world', 2.71828182, 4, 'goodbye, cruel world', 1.01010101)
      end
    end

    time_it(:copy_ruby_object) do
      xs.map do |x|
        RubyObject.new(x.a, x.b, x.c, x.d, x.e, x.f, x.g, x.h, x.i, x.j, x.k, x.l)
      end
    end
  end

  it 'Record' do
    xs = time_it(:build_record) do
      n.times.map do |i|
        Record.new(1, 'to be or not to be', 0.12345678, 2, 'that is the question', 3.14159265, 3, 'hello world', 2.71828182, 4, 'goodbye, cruel world', 1.01010101)
      end
    end

    time_it(:copy_record) do
      xs.map do |x|
        Record.new(x.a, x.b, x.c, x.d, x.e, x.f, x.g, x.h, x.i, x.j, x.k, x.l)
      end
    end
  end

  it 'Record2' do
    xs = time_it(:build_record2) do
      n.times.map do |i|
        Record.new(1, 'to be or not to be', 0.12345678, 2, 'that is the question', 3.14159265, 3, 'hello world', 2.71828182, 4, 'goodbye, cruel world', 1.01010101)
      end
    end

    time_it(:copy_record2) do
      xs.map do |x|
        Record.new(x.a, x.b, x.c, x.d, x.e, x.f, x.g, x.h, x.i, x.j, x.k, x.l)
      end
    end
  end

  it 'Closure' do
    xs = time_it(:build_closure) do
      n.times.map do |i|
        ->(z){ z.call(1, 'to be or not to be', 0.12345678, 2, 'that is the question', 3.14159265, 3, 'hello world', 2.71828182, 4, 'goodbye, cruel world', 1.01010101) }
      end
    end

    time_it(:copy_closure) do
      xs.map do |x|
        x.call(->(a, b, c, d, e, f, g, h, i, j, k, l) do
          ->(z){ z.call(a, b, c, d, e, f, g, h, i, j, k, l) }
        end)
      end
    end
  end

  it 'Array' do
    xs = time_it(:build_array) do
      n.times.map do |i|
        [1, 'to be or not to be', 0.12345678, 2, 'that is the question', 3.14159265, 3, 'hello world', 2.71828182, 4, 'goodbye, cruel world', 1.01010101]
      end
    end

    time_it(:copy_array) do
      xs.map do |x|
        [x[0], x[1], x[2], x[3], x[4], x[5], x[6], x[7], x[8], x[9], x[10], x[11]]
      end
    end
  end
end
