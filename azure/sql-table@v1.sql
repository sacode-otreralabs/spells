---
author: ${author}
script: azure/sql-table@v1
description: Create SQL table.
fileType: template
tags: [ddl, azure-sql]
context:
  datasetId: ${datasetId}
  namespace: ${namespace}
  schemaName: ${schemaName}
  tableName: ${tableName}
  columns: ${columns}
  additionalColumns: ${additionalColumns}
adfDataTypes:
  - int: Int32
  - varchar: String
  - nvarchar: String
dwColumns: 
  - dwDomain: { name: 'dwDomain', type: 'nvarchar', precision: 100, isNullable: false, expression: '${namespace}' }
  - dwSessionId: { name: 'dwSessionId', type: 'nvarchar', precision: 100, isNullable: false, expression: '@{pipeline().TriggerId}' }
  - dwCreateDate: { name: 'dwCreateDate', type: 'datetime', default: 'CURRENT_TIMESTAMP' }
  - dwUpdateDate: { name: 'dwUpdateDate', type: 'datetime', default: 'CURRENT_TIMESTAMP', expression: '@{utcNow()}' }
  - dwAuthor: { name: 'dwAuthor', type: 'nvarchar', precision: 100, default: "'🔀 Ingestron.io'" }

output: |
  {
    "datasetId": context.datasetId,
    "namespace": context.namespace,
    "schemaName": context.schemaName,
    "tableName": context.tableName,
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
    },
    "additionalColumns": $append(context.additionalColumns.
      {
        "name": $,
        "value": $lookup($$.dwColumns, $).expression
      }, [])
  }
---
{%- import "./azure/helpers/index.njk" as utils -%}
-- Template:  {{script}}
-- Author:    {{author}}
-- Generated: {{ 'now' | time('YYYY-MMM-DD') }}
-- {{ description | replace("\n","\n-- ") }}

IF SCHEMA_ID('{{context.schemaName}}') IS NULL EXEC('CREATE SCHEMA [{{context.schemaName}}]')

IF OBJECT_ID('[{{context.schemaName}}].[{{context.tableName}}]', 'U') IS NOT NULL 
  DROP TABLE [{{context.schemaName}}].[{{context.tableName}}]

CREATE TABLE [{{context.schemaName}}].[{{context.tableName}}] (
  {%- for key in context.columns | d([]) %}
  [{{key.name}}] {{ key.type }}
  {{- utils.dbColumn(key.name, key.type, key.precision, key.scale, key.isNullable or key.unique, key.default) -}}, 
  {{- ' -- PK' if key.unique| d(false) -}}
  {%- endfor %}
  {{- utils.additionalColumns(context.additionalColumns, context) | safe -}}
)
