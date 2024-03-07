
with source_data as (

    select 1 as id
    union all
    select null as id

)

select *
from (
    select *
    from source_data
) as x
where id = 1
