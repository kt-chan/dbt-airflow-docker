SELECT eid, name
FROM from {{ source('sample_data', 'employee') }}