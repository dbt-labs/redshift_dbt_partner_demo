{% docs create_proxy_views %}

Some teams struggle with allowing their Data Analyst to build on top of large tables that are hard to reproduce in their development environment.


The `create_proxy_as_view` macro is a way to automatically create views of production tables in a development environment. This is of particular help in Redshift where no such thing as 0-copy-clone exists.

## Prerequiste

In order to leverage this macro we need the ability to slice and dice the `json` output when we run `dbt ls --output json`. For this reason we use [jq](https://stedolan.github.io/jq/):

> jq is like `sed` for JSON data - you can use it to slice and filter and map and transform structured data with the same ease that `sed`, `awk`, `grep` and friends let you play with text.

You can install easily via `brew`:

```sh 
brew install jq
```

## Usage

The macro leverages the output from `dbt ls` as `json` to identify all upstream model for a model that we would like to develop on. 

Let's assume we are developing over `dim_customers` which is build on top of a large session table and we run

```sh
dbt ls --select +dim_customers --exclude dim_customers --resource-type model --output json
```

This outputs the a list of json objects containing the upstream dependencies for the dim_customers. Using `jq` we can map this into

```json
[
    {
        "config": {
            "enabled": true,
            "alias": null,
            "schema": null,
            "database": null,
            "tags": [],
            "meta": {},
            "materialized": "table",
            "persist_docs": {},
            "quoting": {},
            "column_types": {},
            "full_refresh": null,
            "unique_key": null,
            "on_schema_change": "ignore",
            "grants": {},
            "bind": false,
            "post-hook": [],
            "pre-hook": []
        },
        "alias": "stg_tpch_customers"
    },
    {
        "config": {
            "enabled": true,
            "alias": null,
            "schema": null,
            "database": null,
            "tags": [],
            "meta": {},
            "materialized": "table",
            "persist_docs": {},
            "quoting": {},
            "column_types": {},
            "full_refresh": null,
            "unique_key": null,
            "on_schema_change": "ignore",
            "grants": {},
            "bind": false,
            "post-hook": [],
            "pre-hook": []
        },
        "alias": "stg_tpch_nations"
    },
    {
        "config": {
            "enabled": true,
            "alias": null,
            "schema": null,
            "database": null,
            "tags": [],
            "meta": {},
            "materialized": "table",
            "persist_docs": {},
            "quoting": {},
            "column_types": {},
            "full_refresh": null,
            "unique_key": null,
            "on_schema_change": "ignore",
            "grants": {},
            "bind": false,
            "post-hook": [],
            "pre-hook": []
        },
        "alias": "stg_tpch_regions"
    }
]
```

This json object is passed to our macro using `dbt run-operation`. For feasibility purposes one case wrap the entire statement into a function that you can place in your `bashrc` or `zshrc`:

```sh
create_deps_as_views() {
    dependencies=$(dbt ls --select +$1 --exclude $1 --resource-type model --output json --output-keys config,alias | jq -s -c '. | map(.)') && \
    dbt run-operation create_proxy_views \
    --args '{models: '$dependencies'}'
}
```

## Running the macro

```sh
create_deps_as_views dim_customers 
13:25:00  Running with dbt=1.2.0
13:25:02  Creating proxy view "dev"."dbt_sdurry"."stg_tpch_customers" pointing to "dev"."production"."stg_tpch_customers"
# TODO: We have permission issues atm :-D 
13:25:02  Encountered an error while running operation: Database Error
  permission denied for schema production
```

{% enddocs %}
