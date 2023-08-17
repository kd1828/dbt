{% macro generate_schema_name(custom_schema_name, node) %}
    {% set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        
        {{ default_schema }}
    -- if we are in PROD
        -- then we just want custom_schema_anme
    {% elif target.name in ['prod' ]%}

        {{ custom_schema_anme | trim }}

    {% else %}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{% endmacro %}