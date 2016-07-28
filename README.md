# Stats

Wrapper for stats libraries for easy migrating between them or use all of them at the same time :)
(currently supports only [InfuxDB](https://github.com/mneudert/instream), but you can implement
your own backend).

## Installation

Add `stats` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:stats, "~> 0.1"}]
end
```

Ensure `stats` is started before your application:

```elixir
def application do
  [applications: [:stats]]
end
```

## Configuration

### InfluxDB backend

InfluxDB support provided by [Instream](https://github.com/mneudert/instream) library. All you need
is add Instream to `mix.exs`:

```elixir
def deps do
  [{:stats, "~> 0.1"},
   {:instream, "~> 0.12.0"}]
end
```

Add it to the OTP applications (for OTP releases):

```elixir
def application do
  [applications: [:stats, :instream]]
end
```

And provide configuration for stats and instream:

```elixir
config :stats,
  backends: [Stats.Backend.Influx],
  notify_interval: 500

# for configuration see https://github.com/mneudert/instream#usage
config :stats, Stats.Backend.Influx,
  host: "localhost",
  pool: [max_overflow: 10, size: 5],
  port: 8086,
  scheme: "http",
  writer: Instream.Writer.Line
```

## Usage

For writing stats series to your db just:

```elixir
Stats.notify(%Stats.Series{values: %{cpu: 0.1, mem: 1042}})
```

### %Stats.Series{}

Struct for dealing with different backends, contains:

* `values` — map with your measurements;
* `timestamp` — timestamp, if `nil` it uses current time with nanoseconds precision;
* `options` — map with additional options for each backend, only part that have different behavior
  depends on backend, like database  or table names. For InfluxDB it may have `:tags` field.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
