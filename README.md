# Search Analytics input plugin for Embulk

Embulk input plugin for Google Search Analytics.

## Overview
* **Plugin type**: input
* **Resume supported**: no
* **Cleanup supported**: no
* **Guess supported**: no

## Configuration

- **client_id**: authentication (string, required)
- **client_secret**: authentication (string, required)
- **refresh_token**: authentication (string, required)
- **site_url**: Site URL for target data
- **start_date**: Target report start date. Valid format is "YYYY-MM-DD" (string, required)
- **end_date**: Target report end date. Valid format is "YYYY-MM-DD" (string, required)
- **dimensions**: Target dimensions (array, required)
- **dimension_filter_groups**: Target dimension filter groups, see example. (array, default: nil)
- **search_type**: Target search type, (string, default: web)
- **row_limit**: Target row limit, (integer, default: 5000)

## Example

```yaml
in:
  type: search_analytics
  client_id: xxxxxxx.apps.googleusercontent.com
  client_secret: xxxxxxxxxx
  refresh_token: 1/xxxxxxxxxx
  site_url: https://sem-technology.info/
  start_date: 2017-12-01
  end_date: 2017-12-01
  dimensions:
    - query
    - device
  dimension_filter_groups:
    - group_type: and
      filters:
        - dimension: country
          operator: equals
          expression: jpn
```


## Build

```
$ rake
```
