---
layout: post
title:  "Ruby 2.3 New Features Performance"
date:   2016-01-12
---

There are few new syntax/core library features on Ruby 2.3.
They all are nice-looking and useful, but let's look to them from a performance perspective:

### &. (safe navigation operator)

{% spoiler Benchmark code %}
{% highlight ruby %}
  require 'benchmark/ips'
  require 'active_support'
  require 'active_support/core_ext/object/try'

  Benchmark.ips do |x|
    x.config(:time => 10, :warmup => 5)

    struct = Struct.new(:sample, :param)
    object = struct.new("100")

    x.report(".try") { object.try(:param) }
    x.report("&&") { object.param && object.param }
    x.report("&.") { object&.param }

    x.compare!
  end
{% endhighlight %}
{% endspoiler %}

#### Results
{% highlight console %}
  Calculating -------------------------------------
                .try    91.744k i/100ms
                  &&   154.729k i/100ms
                  &.   155.004k i/100ms
  -------------------------------------------------
                .try      2.066M (± 5.5%) i/s -     20.642M
                  &&      9.794M (± 8.7%) i/s -     97.170M
                  &.      9.721M (± 8.9%) i/s -     96.412M

  Comparison:
                  &&:  9793515.5 i/s
                  &.:  9721014.8 i/s - 1.01x slower
                .try:  2066027.4 i/s - 4.74x slower
{% endhighlight %}

Performance of the new operator is the same as old && operator, but way better than .try operator.

### Hash#dig

{% spoiler Benchmark code %}
{% highlight ruby %}
  require 'benchmark/ips'

  Benchmark.ips do |x|
    x.config(:time => 10, :warmup => 5)

    hash = {a: {a: {a: {a: {a: 1}}}}}

    x.report("[]") { hash[:a][:a][:a][:a][:a] }
    x.report("&&") { hash[:a] && hash[:a][:a] && hash[:a][:a][:a] && hash[:a][:a][:a][:a] && hash[:a][:a][:a][:a][:a] }
    x.report(".dig") { hash.dig(:a, :a, :a, :a, :a) }

    x.compare!
  end
{% endhighlight %}
{% endspoiler %}

#### Results
{% highlight console %}
  Calculating -------------------------------------
                    []    96.013k i/100ms
                    &&    75.256k i/100ms
                  .dig    92.656k i/100ms
  -------------------------------------------------
                    []      4.364M (± 6.5%) i/s -     43.398M
                    &&      2.082M (± 2.7%) i/s -     20.846M
                  .dig      4.010M (± 2.7%) i/s -     40.120M

  Comparison:
                    []:  4363781.0 i/s
                  .dig:  4010299.9 i/s - 1.09x slower
                    &&:  2082485.1 i/s - 2.10x slower
{% endhighlight %}

The new .dig method is 2 times faster than "&&" chain.

## Array#dig

{% spoiler Benchmark code %}
{% highlight ruby %}
  require 'benchmark/ips'

  Benchmark.ips do |x|
    x.config(:time => 10, :warmup => 5)

    hash = {a: {a: {a: {a: {a: 1}}}}}

    x.report("[]") { hash[:a][:a][:a][:a][:a] }
    x.report("&&") { hash[:a] && hash[:a][:a] && hash[:a][:a][:a] && hash[:a][:a][:a][:a] && hash[:a][:a][:a][:a][:a] }
    x.report(".dig") { hash.dig(:a, :a, :a, :a, :a) }

    x.compare!
  end
{% endhighlight %}
{% endspoiler %}

#### Results
{% highlight console %}
  Calculating -------------------------------------
                    []   112.120k i/100ms
                    &&   100.524k i/100ms
                  .dig   106.302k i/100ms
  -------------------------------------------------
                    []      6.658M (± 3.0%) i/s -     66.487M
                    &&      4.012M (± 4.7%) i/s -     40.009M
                  .dig      5.161M (± 4.0%) i/s -     51.556M

  Comparison:
                    []:  6658225.5 i/s
                  .dig:  5160965.5 i/s - 1.29x slower
                    &&:  4011576.4 i/s - 1.66x slower
{% endhighlight %}

For arrays .dig is just a bit faster than &&.

## Conclusion
As you can see, these new features are not only nice-looking but also faster than classic ones.
