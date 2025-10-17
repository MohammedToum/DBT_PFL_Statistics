{% macro normalise_country(col) -%}
-- Lowercase + collapse whitespace. Country names don’t need heavy normalisation.
lower(
  trim(
    regexp_replace(coalesce({{ col }}, ''), '\s+', ' ', 'g')
  )
)
{%- endmacro %}
