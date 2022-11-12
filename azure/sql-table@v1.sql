---
author: ${author}
script: azure/sql-table@v1
description: Create SQL table.
fileType: template
tags: [ddl, azure-sql]
context:
  namespace: ${namespace}
  schema: ${schema}
  objectName: ${objectName}
  columns: ${columns}
  additionalColumns: ${additionalColumns}
adfDataTypes:
  - int: Int32
  - varchar: String
  - nvarchar: String
output: |
  {
    "relativePath": "${context.namespace}/tables",
    "fileName": "${context.schema}.${context.objectName}.sql",
    "datasetId": "${context.objectName}",
    "translator": {
      "type": "TabularTranslator",
      "mappings": $append(context.columns.
      {
        "source": {
            "path": "['" & name & "']"
        },
        "sink": {
            "name": name,
            "type": $lookup($$.adfDataTypes,type)
        }
      }, context.additionalColumns.
      {
        "source": {
            "path": "$['" & $ & "']"
        },
        "sink": {
            "name": $
        }
      }),
      "collectionReference": "$['data']",
      "mapComplexValuesToString": true
    }
  }
---
{%- import "./azure/helpers/index.njk" as utils -%}
-- Template:  {{script}}
-- Author:    {{author}}
-- Generated: {{ 'now' | time('YYYY-MMM-DD') }}
-- {{ description | replace("\n","\n-- ") }}

IF SCHEMA_ID('{{context.schema}}') IS NULL EXEC('CREATE SCHEMA [{{context.schema}}]')

IF OBJECT_ID('[{{context.schema}}].[{{context.objectName}}]', 'U') IS NOT NULL 
  DROP TABLE [{{context.schema}}].[{{context.objectName}}]

CREATE TABLE [{{context.schema}}].[{{context.objectName}}] (
  {%- for key in context.columns | d([]) %}
  [{{key.name}}] {{ key.type }}
  {{- utils.dbColumn(key.name, key.type, key.precision, key.scale, key.isNullable or key.unique, key.default) -}}, 
  {{- ' -- PK' if key.unique| d(false) -}}
  {%- endfor %}
  {{- utils.additionalColumns(context.additionalColumns, context) | safe -}}
)
