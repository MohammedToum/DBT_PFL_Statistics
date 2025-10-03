with
source_data as (
    select
        club_name,
        player_name,
        age,
        position,
        club_involved_name,
        fee,
        transfer_movement,
        transfer_period,
        fee_cleaned,
        league,
        year,
        season,
        coalesce(nationality, null) as nationality
    from {{ ref("premier-league") }}
)

select *
from source_data;
