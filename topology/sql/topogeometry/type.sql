-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- 
-- PostGIS - Spatial Types for PostgreSQL
-- http://postgis.refractions.net
--
-- Copyright (C) 2011 Sandro Santilli <strk@keybit.net>
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

-- {
--  Override geometrytype() for topogeometry objects
--
--  Note: For performance reasons, this function always assumes
--        TopoGeometry are of the MULTI type. This may not always
--        be the case if you convert the TopoGeometry to an actual
--        Geometry.
--
-- }{
CREATE OR REPLACE FUNCTION topology.GeometryType(tg topology.TopoGeometry)
	RETURNS text
AS
$$
	SELECT CASE
		WHEN type($1) = 1 THEN 'MULTIPOINT'
		WHEN type($1) = 2 THEN 'MULTILINESTRING'
		WHEN type($1) = 3 THEN 'MULTIPOLYGON'
		WHEN type($1) = 4 THEN 'GEOMETRYCOLLECTION'
		ELSE 'UNEXPECTED'
		END;
$$
LANGUAGE 'SQL' STABLE STRICT;
-- }

-- {
--  Override st_geometrytype() for topogeometry objects
--
--  Note: For performance reasons, this function always assumes
--        TopoGeometry are of the MULTI type. This may not always
--        be the case if you convert the TopoGeometry to an actual
--        Geometry.
--
-- }{
CREATE OR REPLACE FUNCTION topology.ST_GeometryType(tg topology.TopoGeometry)
	RETURNS text
AS
$$
	SELECT CASE
		WHEN type($1) = 1 THEN 'ST_MultiPoint'
		WHEN type($1) = 2 THEN 'ST_MultiLinestring'
		WHEN type($1) = 3 THEN 'ST_MultiPolygon'
		WHEN type($1) = 4 THEN 'ST_GeometryCollection'
		ELSE 'ST_Unexpected'
		END;
$$
LANGUAGE 'SQL' STABLE STRICT;
-- }
