{% macro surrogate_key_v1(cols) -%}
  {{ dbt_utils.generate_surrogate_key( ["'v1'"] + cols ) }}
{%- endmacro %}