{% macro create_database(database_name) %}
  
  {% set sql %}
    create database {{database_name}};
  {% endset %}

  {% do run_query(sql) %}

{% endmacro %}