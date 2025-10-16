{% macro normalise_club(name) %}
lower(
  regexp_replace(
    regexp_replace(
      regexp_replace(
        regexp_replace(
          {{ name }}, '\s*\(.*\)$', ''           -- strip trailing "(...)"
        ),
        '\b(u1[0-9]|u2[0-9]|u\d\d|u18|u19|u20|u21|u22|u23|res(erve)?s?|b|ii|academy|acad(\.)?)\b', ''
      ),
      '[\.\-\'/]', ' '                           -- punct → spaces
    ),
    '\s+', ' '                                   -- collapse spaces
  )
)
{% endmacro %}