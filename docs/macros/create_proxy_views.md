{% docs create_proxy_views %}

Some teams struggle with allowing their Data Analyst to build on top of large tables that are hard to reproduce in their development environment.

The `create_proxy_as_view` macro is a way to automatically create views of production tables in a development environment. This is of particular help in Redshift where no such thing as 0-copy-clone exists.

## Usage

You can use the macro by running the `run-operation` in the cloud command line.
An example application for the `tpch` data looks like:

```sh
dbt run-operation create_proxy_views --args '{model_name: 'dim_customers', production_schema: 'analytics'}'
```

{% enddocs %}
