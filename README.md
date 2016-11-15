# time_it
time_it is a self-contained ruby file intended to be dropped into an existing project. The purpose is to find time-consuming sections of code.

Simply include `time_it` and wrap the interesting code in a `time_it` block.

```ruby
time_it('a') do
  sleep(0.2)
  time_it('b') do
    sleep(0.1)
  end
  time_it('c') do
    sleep(0.4)
  end
  sleep(0.2)
end
```

As you can see, blocks can be nested. When the outermost block complete, a report is written to STDOUT.

```
a ...... 900 ms
  ??? .. 200 ms
  b .... 100 ms
  c .... 400 ms
  ??? .. 200 ms
```

This indicates that block `a` took 900ms to execute. 100ms of that time was spent in `b`, and 400ms in `c`.
The rest of the time was spent doing stuff before `b` and after `c`.

In this particular example `c` is taking the most time. If this were real code, I'd probably nest some more blocks
inside `c` to reveal more detail.



# prof{tab,merge,comp}

A suite of tools for comparing performance between different builds of an application that log in the following form:

```
14:24:40.289 [main] INFO  log - PROFILE Started applyRules
14:24:52.525 [main] INFO  log - PROFILE Finished applyRules
```

If your logs do not match this format, you can easily tweak `proftab.rb` to accomodate your own format. As long as you can
transform a line into the following hash structure, you're good to go.

```ruby
{
  time: ..., # a Time timestamp
  when: ..., # either :start or :end
  name: ...  # a String describing the work done. "applyRules" in the example above
}
```

## Collect timings with proftab.rb

Writes to a simple tab-separated file.

```
$ your_program | ruby proftab.rb > a1.tab
$ your_program | ruby proftab.rb > a2.tab
$ your_program | ruby proftab.rb > a3.tab
```

## Average the timings with profmerge.rb

```
$ ruby profmerge.rb a?.tab > a.tab
```

## Compare timings with profcomp.rb

Repeat the above steps with a different build to obtain `b.tab`.

```
$ ruby profcomp.rb a.tab b.tab
```

resulting in

```
applyRules.....................................	   1617   47%
foo............................................	   xxxx   yy%
bar............................................	   zzzz   ww%
```

which indicates that in the `b` build, `applyRules` took 1617ms longer, which was a 47% increase.
