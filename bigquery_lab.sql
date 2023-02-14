-- This is the query from bigquery query lab, using public dataset on the platform: 
-- https://www.cloudskillsboost.google/course_sessions/2440590/labs/344081


-- with CTE (common table expression) as (), cet contains the results from ()
-- If the weather element is "PRCP" (precipitation), the precipitation amount is divided by 10 (to convert from tenths of millimeters to inches) and assigned to the "prcp" column. If the weather element is not "PRCP", the "prcp" column is set to NULL.

WITH bicycle_rentals AS (
  SELECT
    COUNT(starttime) as num_trips,
    EXTRACT(DATE from starttime) as trip_date
  FROM `bigquery-public-data.new_york_citibike.citibike_trips`
  GROUP BY trip_date
),
rainy_days AS
(
SELECT
  date,
  (MAX(prcp) > 5) AS rainy
FROM (
  SELECT
    wx.date AS date,
    IF (wx.element = 'PRCP', wx.value/10, NULL) AS prcp
  FROM
    `bigquery-public-data.ghcn_d.ghcnd_2015` AS wx
  WHERE
    wx.id = 'USW00094728'
)
GROUP BY
  date
)
SELECT
  ROUND(AVG(bk.num_trips)) AS num_trips,
  wx.rainy
FROM bicycle_rentals AS bk
JOIN rainy_days AS wx
ON wx.date = bk.trip_date
GROUP BY wx.rainy

-------------------------------------------------------------

SELECT
  wx.date,
  wx.value/10.0 AS prcp
FROM
  `bigquery-public-data.ghcn_d.ghcnd_2015` AS wx
WHERE
  id = 'USW00094728'
  AND qflag IS NULL
  AND element = 'PRCP'
ORDER BY
  wx.date



---------------------------------------------------------------

-- finding the most popular bike routes by start and end stations, and calculating the -- median trip duration and number of trips taken for each route. 

-- APPROX_QUANTILES(tripduration, 10) calculates the approximate quantiles of the --tripduration column in a dataset, where tripduration is likely a numerical variable -- that represents the duration of a trip. The 10 argument indicates that we want to --calculate 10 quantiles.

--[OFFSET (5)] selects the fifth (0-indexed) quantile from the list of 10 quantiles --that we just calculated. This quantile is the median of the tripduration column, --which means that half of the trips in the dataset have a duration shorter than the --typical_duration and half have a duration longer.

SELECT
  MIN(start_station_name) AS start_station_name,
  MIN(end_station_name) AS end_station_name,
  APPROX_QUANTILES(tripduration, 10)[OFFSET (5)] AS typical_duration,
  COUNT(tripduration) AS num_trips
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE
  start_station_id != end_station_id
GROUP BY
  start_station_id,
  end_station_id
ORDER BY
  num_trips DESC
LIMIT
  10
;

----------------------------------------------------------------------------------------

-- selects information about the distances traveled by Citibike riders in New York City.
WITH
  trip_distance AS (
SELECT
  bikeid,
  ST_Distance(ST_GeogPoint(s.longitude,
      s.latitude),
    ST_GeogPoint(e.longitude,
      e.latitude)) AS distance
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`,
  `bigquery-public-data.new_york_citibike.citibike_stations` as s,
  `bigquery-public-data.new_york_citibike.citibike_stations` as e
WHERE
  CAST(start_station_id as STRING) = s.station_id
  AND CAST(end_station_id as STRING) = e.station_id)
SELECT
  bikeid,
  SUM(distance)/1000 AS total_distance
FROM
  trip_distance
GROUP BY
  bikeid
ORDER BY
  total_distance DESC
LIMIT
  5
;

-- a different query method:

SELECT
  bikeid,
  ST_Distance(ST_GeogPoint(s.longitude, s.latitude),
              ST_GeogPoint(e.longitude, e.latitude)) AS distance
FROM
  (SELECT
     station_id,
     latitude,
     longitude
   FROM
     `bigquery-public-data.new_york_citibike.citibike_stations`) s,
  `bigquery-public-data.new_york_citibike.citibike_trips` t,
  (SELECT
     station_id,
     latitude,
     longitude
   FROM
     `bigquery-public-data.new_york_citibike.citibike_stations`) e
WHERE
  CAST(t.start_station_id AS STRING) = s.station_id
  AND CAST(t.end_station_id AS STRING) = e.station_id;
