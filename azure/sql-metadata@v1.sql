---
author: 🔀ingestron.io 
script: azure/sql-metadata@v1
description: |
  Retrieve Azure SQL object metadata by schema and object name.
  -- @schema {nvarchar} schema name.
  -- @objectName {nvarchar} object (table/view) name.
  returns {nvarchar} metadata object in JSON format.
---
SELECT 
  physicalName = name,
  type = TYPE_NAME(system_type_id),
  logicalName = name,
  name = name,
  physicalType = TYPE_NAME(system_type_id),
  precision = IIF(precision = 0, max_length, precision),
  scale = IIF(scale = 0, max_length, scale)
FROM sys.columns
WHERE object_id = OBJECT_ID('[{{schema}}].[{{objectName}}]')
FOR JSON PATH, ROOT ('structure')
