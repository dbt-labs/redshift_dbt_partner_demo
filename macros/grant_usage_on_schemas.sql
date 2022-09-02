{% macro grant_usage_on_schemas(schemas, grantee) %}
  {% for schema in schemas %}
    grant usage on schema {{ schema }} to {{ grantee }};
    {{ log("Granting Usage to " ~ grantee ~ " on " ~ schema) }}
  {% endfor %}
{% endmacro %}
