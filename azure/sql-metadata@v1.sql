---
author: 🔀ingestron.io
script: azure/sql-metadata@v1
description: Retrieve table/view metadata from SQL database.
fileType: template
tags: [metadata, azure-sql]
context:
  namespace: ${namespace}
  schema: ${schema}
  objectName: ${objectName}
output: |
  {
    "relativePath": "meta/${context.namespace}/tables",
    "fileName": "${context.schema}.${context.objectName}.meta.sql"
  }
---
-- Template:  {{script}}
-- Author:    {{author}}
-- Generated: {{ 'now' | time('YYYY-MM-DD') }}
-- {{ description | replace("\n","\n-- ") }}

DECLARE @schema nvarchar(max) = '{{context.schema}}'
DECLARE @objectName nvarchar(max) = '{{context.objectName}}'

DECLARE @json nvarchar(max) = (
SELECT
  [objectId] = o.object_id,
  [objectName] = o.name,
  [id] = c.column_id,
  [name] = c.name,
  [physicalName] = c.name,
  [logicalName] = c.name,
  [type] = TYPE_NAME(c.system_type_id),
  [physicalType] = TYPE_NAME(c.system_type_id),
  [precision] = IIF(c.precision = 0, c.max_length, c.precision),
  [scale] = IIF(c.scale = 0, c.max_length, c.scale),
  [isNullable] = c.is_nullable,
  [definition] = dc.definition
FROM sys.columns c
  INNER JOIN sys.objects o ON o.object_id = c.object_id
  INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
  LEFT OUTER JOIN sys.default_constraints dc ON c.default_object_id = dc.object_id
WHERE o.object_id = OBJECT_ID(CONCAT_WS('.', QUOTENAME(@schema,'['), QUOTENAME(@objectName,'[')))
FOR JSON PATH, ROOT ('structure')
)

SELECT @json as value
