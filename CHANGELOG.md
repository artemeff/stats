# Changelog

## v0.1.1-dev (2016-07-28)

- Enhancements
    - Assigns current timestamp value for Series in notify.
      When we buffer values - it may have a long interval to
      sync with backends and have wrong timestamps.
    - Batch writing in Influx backend.

## v0.1.0 (2016-07-27)

- Initial Release
