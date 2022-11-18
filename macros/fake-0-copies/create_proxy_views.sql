{% macro create_proxy_views(model_name, production_schema) %}

{% set upstream_nodes = breadth_first_search(model_name) %}
{% set models = [] %}
{% for node_name in upstream_nodes -%}
    {% do models.append(
        {
            'config': graph.nodes[node_name]['config'],
            'alias': graph.nodes[node_name]['alias']
        }
    ) %}
{%- endfor %}

{% if production_schema is defined %}
    {% set prod_schema = production_schema %}
{% else %}
    {{ exceptions.raise_compiler_error("Argument production_schema is undefined. Please reference the production_schema") }}
{%- endif -%}

{% if prod_schema == target.schema %}
    {% do log("This macro shouldn't be run on the production target. Exiting without actions.", info=True) %}
{% else %}
    {% for model in models %}
        {{ model | tojson }}
        {% set relation_identifier = model["alias"] %}
        {% set relation_sub_schema = model["config"]["schema"] %}
        {% set relation_schema = target.schema + "_" + relation_sub_schema if relation_sub_schema else target.schema %}
        {% set relation_prod_schema = prod_schema + "_" + relation_sub_schema if relation_sub_schema else prod_schema %}

        {# checks if the relation already exists and drops it #}
        {% set existing_relation = adapter.get_relation(
            database=target.dbname,
            schema=relation_schema,
            identifier=relation_identifier) %}
        {% if existing_relation %}
            {% do log("Dropping " ~ existing_relation, info=True) %}
            {% do adapter.drop_relation(existing_relation) %}
        {% endif %}

        {# creates the schema and proxy view #}
        {% set proxy_view = api.Relation.create(
            database=target.dbname,
            schema=relation_schema,
            identifier=relation_identifier) %}
        {% set prod_relation = adapter.get_relation(
            database=target.dbname,
            schema=relation_prod_schema,
            identifier=relation_identifier) %}
        {% if prod_relation %}
            {% do adapter.create_schema(proxy_view) %}
            {% set sql %}
                create view {{ proxy_view }} as select * from {{ prod_relation }};
                -- with no schema binding;
            {% endset %}
            {% do log("Creating proxy view " ~ proxy_view ~ " pointing to " ~ prod_relation, info=True) %}
            {% do run_query(sql) %}
        {% else %}
            {% do log("There's no equivalent model to " ~ proxy_view ~ " found in production.", info=True) %}
            {% do log("Maybe it's ephemeral or haven't been run yet. You could try to create with a `dbt run`", info=True) %}
        {% endif %}
    {% endfor %}

    {% do log("The proxy views were created", info=True) %}
{% endif %}

{% endmacro %}
