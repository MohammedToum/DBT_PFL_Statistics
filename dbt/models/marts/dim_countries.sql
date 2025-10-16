{{ config(materialized='table') }}

-- Grain: one row per stg_countries.country_sk
select
    country_sk,
    country_name,
    country_iso2
from {{ ref('stg_countries') }}
