set client_min_messages to ERROR;

\i load_topology.sql

-- Endpoint / node mismatch
SELECT topology.ST_AddEdgeNewFaces('city_data', 7, 6,
 'LINESTRING(36 38,57 33)');
SELECT topology.ST_AddEdgeNewFaces('city_data', 5, 7,
 'LINESTRING(36 38,57 33)');

-- Crosses a node
SELECT topology.ST_AddEdgeNewFaces('city_data', 5, 6,
 'LINESTRING(36 38, 41 40, 57 33)');

-- Non-existent node 
SELECT topology.ST_AddEdgeNewFaces('city_data', 5, 60000,
 'LINESTRING(36 38,57 33)');
SELECT topology.ST_AddEdgeNewFaces('city_data', 60000, 6,
 'LINESTRING(36 38,57 33)');

-- Non-simple curve
SELECT topology.ST_AddEdgeNewFaces('city_data', 5, 5,
 'LINESTRING(36 38, 40 50, 36 38)');

-- Coincident edge
SELECT topology.ST_AddEdgeNewFaces('city_data', 18, 19,
 'LINESTRING(35 22,47 22)');

-- Crosses an edge
SELECT topology.ST_AddEdgeNewFaces('city_data', 5, 6,
 'LINESTRING(36 38, 40 50, 57 33)');

-- Touches an existing edge
SELECT 'O', topology.ST_AddEdgeNewFaces('city_data', 5, 6,
 'LINESTRING(36 38,45 32,57 33)');

-- Shares a portion of an existing edge
SELECT 'O', topology.ST_AddEdgeNewFaces('city_data', 5, 6,
 'LINESTRING(36 38,38 35,57 33)');

---------------------------------------------------------------------
-- Define some features
---------------------------------------------------------------------

CREATE TABLE city_data.fp(id varchar);
SELECT 'L' || topology.AddTopoGeometryColumn('city_data',
  'city_data', 'fp', 'g', 'POLYGON');

-- Feature composed by face 3 and face 4
INSERT INTO city_data.fp VALUES ('F3,F4',
  topology.CreateTopoGeom('city_data', 3, 1, '{{3,3},{4,3}}')); 

CREATE TABLE city_data.fc(id varchar);
SELECT 'L' || topology.AddTopoGeometryColumn('city_data',
  'city_data', 'fc', 'g', 'COLLECTION');

-- Feature composed by face 5 and node 4 
INSERT INTO city_data.fc VALUES ('F5,N4',
  topology.CreateTopoGeom('city_data', 4, 2, '{{5,3},{4,1}}')); 


---------------------------------------------------------------------
-- Now add some edges splitting faces...
---------------------------------------------------------------------

--
-- start node has:
--    outward edge on the left face
--    inward edge on the right face
-- end node has:
--    inward edge on the left face
--    inward edge on the right face
--
SELECT 1 as id, topology.st_addedgenewfaces('city_data', 14, 18,
  'LINESTRING(21 14, 35 22)') as edge_id INTO newedge;
SELECT 'T1', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (19, 7, 17, 10, 
  ( SELECT edge_id FROM newedge WHERE id = 1 ) )
  ORDER BY edge_id;

--
-- start node has:
--    inward edge on the left face
--    outward edge on the right face
-- end node has:
--    inward edge on the left face
--    outward edge on the right face
--
INSERT INTO newedge SELECT 2, topology.st_addedgenewfaces('city_data',
  12, 18, 'LINESTRING(47 14, 35 22)');
SELECT 'T2', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (17, 8, 15, 11, 
  ( SELECT edge_id FROM newedge WHERE id = 2 ) )
  ORDER BY edge_id;

--
-- start node has:
--    inward edge on the left face
--    inward edge on the right face
-- end node has:
--    outward edge on the left face
--    outward edge on the right face
--
INSERT INTO newedge SELECT 3, topology.st_addedgenewfaces('city_data',
  12, 10, 'LINESTRING(47 14, 35 6)');
SELECT 'T3', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (11, 16, 14, 18, 
  ( SELECT edge_id FROM newedge WHERE id = 3 ) )
  ORDER BY edge_id;

--
-- start node has:
--    outward edge on the left face
--    outward edge on the right face
-- end node has:
--    outward edge on the left face
--    inward edge on the right face
--
INSERT INTO newedge SELECT 4, topology.st_addedgenewfaces('city_data',
  9, 13, 'LINESTRING(21 6, 35 14)');
SELECT 'T4', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (20, 10, 18, 13, 
  ( SELECT edge_id FROM newedge WHERE id = 4 ) )
  ORDER BY edge_id;

--
-- Same edge on start and end node, for left face, swapped direction
--
INSERT INTO newedge SELECT 5, topology.st_addedgenewfaces('city_data',
  14, 9, 'LINESTRING(21 14, 19 10, 21 6)');
SELECT 'T5', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (9, 12, 20,
  ( SELECT edge_id FROM newedge WHERE id = 5 ) )
  ORDER BY edge_id;

--
-- Same edge on start and end node, for left face, same direction
--
INSERT INTO newedge SELECT 6, topology.st_addedgenewfaces('city_data',
  8, 15, 'LINESTRING(9 6, 11 10, 9 14)');
SELECT 'T6', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (9, 12, 22,
  ( SELECT edge_id FROM newedge WHERE id = 6 ) )
  ORDER BY edge_id;

--
-- Same edge on start and end node, for right face, swapped direction
--
INSERT INTO newedge SELECT 7, topology.st_addedgenewfaces('city_data',
  17, 16, 'LINESTRING(21 22, 15 20, 9 22)');
SELECT 'T7', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (21, 6, 19,
  ( SELECT edge_id FROM newedge WHERE id = 7 ) )
  ORDER BY edge_id;

--
-- Same edge on start and end node, for right face, same direction
--
INSERT INTO newedge SELECT 8, topology.st_addedgenewfaces('city_data',
  15, 14, 'LINESTRING(9 14, 15 16, 21 14)');
SELECT 'T8', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (9, 21, 19,
  ( SELECT edge_id FROM newedge WHERE id = 8 ) )
  ORDER BY edge_id;

--
-- Closed edge, counterclockwise, in universe face, next right
--
INSERT INTO newedge SELECT 9, topology.st_addedgenewfaces('city_data',
  9, 9, 'LINESTRING(21 6, 18 0, 24 0, 21 6)');
SELECT 'T9', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (12, 13,
  ( SELECT edge_id FROM newedge WHERE id = 9 ) )
  ORDER BY edge_id;

--
-- Closed edge, clockwise, in universe face, next right
--
INSERT INTO newedge SELECT 10, topology.st_addedgenewfaces('city_data',
  10, 10, 'LINESTRING(35 6, 38 0, 32 0, 35 6)');
SELECT 'T10', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (13, 14,
  ( SELECT edge_id FROM newedge WHERE id = 10 ) )
  ORDER BY edge_id;

--
-- Closed edge, clockwise, in universe face, next left
--
INSERT INTO newedge SELECT 11, topology.st_addedgenewfaces('city_data',
  15, 15, 'LINESTRING(9 14, 3 11, 3 17, 9 14)');
SELECT 'T11', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (21, 22,
  ( SELECT edge_id FROM newedge WHERE id = 11 ) )
  ORDER BY edge_id;

--
-- Closed edge, clockwise, in universe face, against closed edge
--
INSERT INTO newedge SELECT 12, topology.st_addedgenewfaces('city_data',
  1, 1, 'LINESTRING(8 30, 5 27, 11 27, 8 30)');
SELECT 'T12', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (1, 
  ( SELECT edge_id FROM newedge WHERE id = 12 ) )
  ORDER BY edge_id;

--
-- Closed edge, counterclockwise, in universe face, against closed edge
--
INSERT INTO newedge SELECT 13, topology.st_addedgenewfaces('city_data',
  2, 2, 'LINESTRING(25 30, 28 27, 22 27, 25 30)');
SELECT 'T13', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (2, 
  ( SELECT edge_id FROM newedge WHERE id = 13 ) )
  ORDER BY edge_id;

--
-- Dangling edge, ending into closed edge endpoint
--
INSERT INTO city_data.node(geom, containing_face)
  VALUES ('POINT(9 33)', 1); -- N23
INSERT INTO newedge SELECT 14, topology.st_addedgenewfaces('city_data',
  23, 1, 'LINESTRING(9 33, 8 30)');
SELECT 'T14', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (1, 
  ( SELECT edge_id FROM newedge WHERE id = 14 ) )
  ORDER BY edge_id;
SELECT 'N' || node_id, containing_face
  FROM city_data.node WHERE node_id = 23;

--
-- Dangling edge, originating from closed edge endpoint
--
INSERT INTO city_data.node(geom, containing_face)
  VALUES ('POINT(12 28)', 0); -- N24
INSERT INTO newedge SELECT 15, topology.st_addedgenewfaces('city_data',
  1, 24,  'LINESTRING(8 30, 12 28)');
SELECT 'T15', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (38, 1,
  ( SELECT edge_id FROM newedge WHERE id = 15 ) )
  ORDER BY edge_id;
SELECT 'N' || node_id, containing_face
  FROM city_data.node WHERE node_id = 24;

--
-- Closed edge on isolated node
--
INSERT INTO newedge SELECT 16, topology.st_addedgenewfaces('city_data',
  4, 4, 'LINESTRING(20 37, 23 37, 20 34, 20 37)');
SELECT 'T16', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (2, 3,
  ( SELECT edge_id FROM newedge WHERE id = 16 ) )
  ORDER BY edge_id;
SELECT 'N' || node_id, containing_face FROM city_data.node WHERE node_id = 4;

--
-- Isolated edge
--
INSERT INTO city_data.node(geom, containing_face)
  VALUES ('POINT(35 28)', 0); -- N25
INSERT INTO city_data.node(geom, containing_face)
  VALUES ('POINT(39 28)', 0); -- N26
INSERT INTO newedge SELECT 17, topology.st_addedgenewfaces('city_data',
  25, 26,  'LINESTRING(35 28, 39 28)');
SELECT 'T17', 'E'||edge_id, next_left_edge, next_right_edge,
  left_face, right_face FROM
  city_data.edge WHERE edge_id IN (
  ( SELECT edge_id FROM newedge WHERE id = 17 ) )
  ORDER BY edge_id;
SELECT 'N' || node_id, containing_face
  FROM city_data.node WHERE node_id IN ( 25, 26 );

---------------------------------------------------------------------
-- Check new relations and faces status
---------------------------------------------------------------------

SELECT id, array_agg(comp) FROM (
SELECT f.id, r.element_type||':'||r.element_id as comp
  FROM city_data.fp f, city_data.relation r
  WHERE r.topogeo_id = id(f.g) AND r.layer_id = layer_id(f.g)
  ORDER BY f.id, element_type, element_id
) f GROUP BY id;

SELECT id, array_agg(comp) FROM (
SELECT f.id, r.element_type||':'||r.element_id as comp
  FROM city_data.fc f, city_data.relation r
  WHERE r.topogeo_id = id(f.g) AND r.layer_id = layer_id(f.g)
  ORDER BY f.id, element_type, element_id
) f GROUP BY id;

SELECT 'F'||face_id, st_astext(mbr) FROM city_data.face ORDER BY face_id;

---------------------------------------------------------------------
-- Cleanups
---------------------------------------------------------------------

DROP TABLE newedge;
SELECT topology.DropTopology('city_data');
