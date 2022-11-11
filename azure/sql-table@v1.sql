---
author: 🔀ingestron.io
script: azure/sql-table@v1
description: Create SQL table.
fileType: template
tags: [ddl, azure-sql]
context:
  namespace: ${namespace}
  schema: ${schema}
  objectName: ${objectName}
  columns: ${columns}
output: |
  {
    "relativePath": "${context.namespace}/tables",
    "fileName": "${context.schema}.${context.objectName}.sql"
  }
---
{%- import "./azure/helpers/index.njk" as utils -%}
-- Template:  {{script}}
-- Author:    {{author}}
-- Generated: {{ 'now' | time('YYYY-MM-DD') }}
-- {{ description | replace("\n","\n-- ") }}

IF SCHEMA_ID('{{context.schema}}') IS NULL EXEC('CREATE SCHEMA [{{context.schema}}]')

IF OBJECT_ID('[{{context.schema}}].[{{context.objectName}}]', 'U') IS NOT NULL 
  DROP TABLE [{{context.schema}}].[{{context.objectName}}]

CREATE TABLE [{{context.schema}}].[{{context.objectName}}] (
  {%- for key in context.columns | d([]) %}
  [{{key.name}}] {{ key.type }}
  {{- utils.dbColumn(key.name, key.type, key.precision, key.scale) -}}, 
  {{- ' -- PK' if key.unique == true | d([]) -}}
  {%- endfor %}
  dwSessionId varchar(50) NOT NULL,
  dwDomain varchar(100) NOT NULL,
  dwCreateDate datetime NOT NULL,
  dwUpdateDate datetime NOT NULL        
)
