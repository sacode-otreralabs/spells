---
author: 🔀ingestron.io
script: sample/template@v1
description: |
  Create SQL table by meta definitions.
  returns {output} object info.
fileType: template
tags: [demo]
context: 
  namespace: ${namespace}
  schema: ${schema}
  objectName: ${objectName}
  columns: ${columns}
  pk: ${pk}
output: |
  {
    "relativePath": "${context.namespace}/tables",
    "fileName": "${context.schema}.${context.objectName}.sql"
  }
---
-- Author:  {{author}}
-- Template:  {{script}}
-- Generated: {{ 'now' | time('YYYY-MM-DD') }}
-- {{ description | replace("\n","\n-- ") }}

CREATE TABLE [{{context.schema}}].[{{context.objectName}}] (
  {%- for key in context.columns | d([]) %}
  [{{key.name}}] {{ key.physicalType }}
  {{- utils.dbColumn(key.name, key.physicalType, key.precision, key.scale) -}}, 
  {{- ' -- PK' if key.name in context.pk | d([]) -}}
  {%- endfor %}
  dwSessionId varchar(50) NOT NULL,
  dwDomain varchar(100) NOT NULL,
  dwCreateDate datetime NOT NULL,
  dwUpdateDate datetime NOT NULL        
);
GO
