{% macro normalise_club(col) -%}
-- Returns a lowercased, trimmed, de-noised key for club names.
-- Works on DuckDB.
-- Example: "1. FC Köln" -> "1 fc koln"
lower(
  trim(
    regexp_replace(
      -- replace any non-letter/number with a single space
      regexp_replace(coalesce({{ col }}, ''), '[^0-9A-Za-z]+', ' ', 'g'),
      '\s+', ' ', 'g'
    )
  )
)
{%- endmacro %}
