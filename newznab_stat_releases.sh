#!/bin/bash

MYSQL="mysql -t -f --reconnect -s -w -u newznab -pxxx newznab"

SQL_BASE=
while read line; do
	SQL_BASE+="$line "
done << EOF
FROM (
	SELECT cat2.ID,
	       cat1.title AS cat1,
		   cat2.title AS cat2
	FROM category cat1
	JOIN category cat2
	ON cat2.parentID = cat1.ID
	WHERE cat1.status = 1
	   AND cat2.status = 1) AS cat
JOIN (
	SELECT categoryID,count(*) AS count
	FROM releases
	GROUP BY categoryID) AS count
ON cat.ID = count.categoryID
EOF

$MYSQL << EOF
SELECT CONCAT(cat1,' -> ',cat2) AS category,count
${SQL_BASE}; 

SELECT 'Total Count',SUM(count)
${SQL_BASE}; 

SELECT
	table_schema "DB Name",
	TRUNCATE(SUM( data_length + index_length ) /1024 /1024,0) "DB Size in MB"
FROM information_schema.TABLES
WHERE table_schema = 'newznab'
	OR table_schema = 'spotweb'
GROUP BY table_schema;
EOF

date

