use Mix.Config

config :stats,
  backends: [],
  notify_interval: 1000

config :stats, Stats.Backend.Influx,
  host: "localhost",
  pool: [max_overflow: 10, size: 5],
  port: 8086,
  scheme: "http",
  writer: Instream.Writer.Line

config :logger,
  level: :warn
