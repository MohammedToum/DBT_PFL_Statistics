{{ config(enabled=false) }}


CREATE OR REPLACE VIEW staging.unmapped_clubs AS
SELECT DISTINCT
  UPPER(TRIM(club_involved_name)) AS key_norm
from {{ ref("premier-league") }} t
LEFT JOIN {{ ref('clubs_map') }} m
  ON UPPER(TRIM(t.club_involved_name)) = UPPER(TRIM(m.raw_key))
WHERE m.raw_key IS NULL
ORDER BY 1;
