SELECT 
	geometry_id,
	class,
	subclass,
	JSON_EXTRACT_SCALAR(names, '$.local') as name,
	CAST(JSON_EXTRACT_SCALAR(metadata, '$.surface_area_sq_m') AS double) as area,
	wkt
FROM daylight_earth
WHERE release = 'v1.55'
  --AND subclass IN ('building','residential')
  AND ST_CONTAINS(
    ST_GEOMETRYFROMTEXT('POLYGON((
      35.00206618130 -15.84904136541,
      35.00206618130 -15.74158804580,
      35.06271976592 -15.74158804580,
      35.06271976592 -15.84904136541,
      35.00206618130 -15.84904136541
    ))'),
    ST_GEOMETRYFROMTEXT(wkt)
  )
