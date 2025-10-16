{{ config(materialized='view') }}

with transfers as (
  -- take the normalized club names from stg_transfers
  select upper(trim(from_club)) as club_name from {{ ref('stg_transfers') }}
  union
  select upper(trim(to_club))   as club_name from {{ ref('stg_transfers') }}
),
mapped as (
  select upper(trim(cleaned_full_name)) as club_name
  from {{ ref('clubs_map') }}
  where cleaned_full_name is not null and trim(cleaned_full_name) <> ''
)
select t.club_name as key_norm
from transfers t
left join mapped m using (club_name)
where m.club_name is null
order by 1