with source as (

    select * from {{ source('tpch', 'partsupp') }}

),

renamed as (

    select
        -- generate_surrogate_key caluclates different to legacy surrogate_key
        -- https://docs.getdbt.com/guides/migration/versions/upgrading-to-dbt-utils-v1.0#changes-to-surrogate_key
        {{ dbt_utils.generate_surrogate_key(
            ['ps_partkey', 
            'ps_suppkey']) }} 
                as part_supplier_key,
        ps_partkey as part_key,
        ps_suppkey as supplier_key,
        ps_availqty as available_quantity,
        ps_supplycost as cost,
        ps_comment as comment

    from source

)

select * from renamed