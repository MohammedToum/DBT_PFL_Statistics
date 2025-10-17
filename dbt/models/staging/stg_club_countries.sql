-- dbt/models/staging/stg_club_countries.sql
{{ config(materialized='view') }}

-- Compatibility shim: preserve the old model name expected by downstream
select
    club_key,
    club_involved_name as club_name,  -- in case old models expect `club_name`
    country
from {{ ref('stg_club_country_map') }}
