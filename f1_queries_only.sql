
-- Top 20 Drivers by Total Wins
SELECT
    CONCAT(dr.forename, ' ', dr.surname) AS name
    , COUNT(re.positionOrder) AS wins
FROM results re
INNER JOIN drivers dr ON dr.driverId = re.driverId
WHERE re.positionOrder = 1
GROUP BY re.driverId
ORDER BY wins DESC
LIMIT 20
;


-- Most wins by Driver and Constructor
SELECT
    CONCAT(dr.forename, ' ', dr.surname) AS driver_name
    , c.name AS constructor_name
    , COUNT(re.positionOrder) AS wins
FROM results re
INNER JOIN drivers dr ON re.driverId = dr.driverId
INNER JOIN constructors c ON re.constructorId = c.constructorId
WHERE re.positionOrder = 1
GROUP BY driver_name, constructor_name
ORDER BY wins desc
;


-- First F1 Race Win for Each Active Driver.
SELECT 
	driver_name 
	, CASE WHEN race IS NULL THEN "Seeking First Win" ELSE race END AS first_win
FROM (
	SELECT DISTINCT CONCAT(dr.forename, ' ', dr.surname) as driver_name 
	FROM results re
	LEFT JOIN races ra ON ra.raceId = re.raceId
	LEFT JOIN drivers dr ON dr.driverId = re.driverId
	WHERE ra.year = 2022) AS current_drivers
LEFT JOIN (
	SELECT 
		CONCAT(dr.forename, ' ', dr.surname) AS driver
		, MIN(concat(ra.year, ' ', ra.name)) AS race
		, MIN(concat(ra.year, ra.round)) AS round
	FROM results re
	LEFT JOIN races ra ON ra.raceId = re.raceId
	LEFT JOIN drivers dr ON dr.driverId = re.driverId
	where re.positionOrder = 1
	GROUP BY re.driverId) AS first_wins ON first_wins.driver = current_drivers.driver_name
ORDER BY CASE WHEN round IS NULL THEN 99999 ELSE round END ASC, driver_name ASC
;


-- Driver Stats for Lookup
SELECT 
    dr.driverId,
    CONCAT(dr.forename, ' ', dr.surname) AS driver,
    CASE WHEN driver_constructor.current_constructor IS NULL THEN "Non-active Driver" ELSE driver_constructor.current_constructor END AS current_constructor,
    GROUP_CONCAT(DISTINCT co.name SEPARATOR', ') as all_constructors,
    COUNT(re.raceId) AS total_career_races,
    COUNT(CASE WHEN re.positionOrder = 1 THEN 1 END) AS total_career_wins,
    COUNT(CASE WHEN re.positionOrder <= 3 THEN 1 END) AS total_career_podiums,
    COUNT(CASE WHEN re.positionOrder <= 10 THEN 1 END) AS total_career_top10s
FROM results re
INNER JOIN drivers dr ON dr.driverId = re.driverId
INNER JOIN constructors co ON co.constructorId = re.constructorId
LEFT JOIN (
	SELECT 
		dr1.driverId as id, 
		co1.name as current_constructor
	FROM results re1
	INNER JOIN drivers dr1 on dr1.driverId = re1.driverId
	INNER JOIN constructors co1 on co1.constructorId = re1.constructorId
	INNER JOIN races ra1 on ra1.raceId = re1.raceId
	WHERE ra1.year = 2022
	GROUP BY dr1.driverId
    ) as driver_constructor 
ON driver_constructor.id = dr.driverId
GROUP BY dr.driverId
ORDER BY 
	CASE WHEN current_constructor IS NULL 
    THEN 'zzzzz' ELSE driver END asc
;