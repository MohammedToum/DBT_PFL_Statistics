
  
  create view "plt"."analytics_staging"."stg_example__dbt_tmp" as (
    with source as (

    select *
    from "plt"."analytics"."example"

)

select
    *
from source
  );
