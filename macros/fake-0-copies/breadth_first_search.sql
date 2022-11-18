{% macro breadth_first_search(model_name) -%}
    
    {% set depends_on = {} %}
    {% for node_name, node_value in graph.nodes.items() -%}
        {% do depends_on.update({node_name: node_value['depends_on']['nodes']}) %}
    {%- endfor %}

    {% set start_node = 'model.' ~ project_name ~ '.' ~ model_name %}

    {% set queue = [start_node] %}
    {% set upstream_nodes = [] %}
    {% for _ in range(1, 10000) %}
        {% if queue|length == 0 %}
            {{ return(upstream_nodes) }}
        {% endif %}

        {% set node_name = queue.pop() %}
        {% for upstream_node_name in depends_on.get(node_name, []) %}
            {% if upstream_node_name.startswith('model.') and upstream_node_name not in upstream_nodes and upstream_node_name not in queue %}
                {% do upstream_nodes.append(upstream_node_name) %}
                {% do queue.append(upstream_node_name) %}
            {% endif %}
        {% endfor %}
    {% endfor %}
{%- endmacro %}