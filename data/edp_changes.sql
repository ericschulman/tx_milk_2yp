/*Count the number of distinct CTAs and groups*/
SELECT COUNT (DISTINCT group_edps.dim_cta_key) as CTAs, 
COUNT (DISTINCT group_edps.dim_group_key) as Groups, 
COUNT (DISTINCT group_edps.dim_date_key) as Dates 
  FROM group_edps;

/*Number of CTA GROUP Combos*/
SELECT COUNT(*)
FROM
(SELECT DISTINCT group_edps.dim_cta_key, group_edps.dim_group_key
FROM group_edps
GROUP BY group_edps.dim_cta_key, group_edps.dim_group_key);

/*For each transaction put all the prices 491 prices by CTA and week (0) if undefined in the same week*/


/*For each transaction put all the volumes from the week before of 25*33 CTA groups*/

/*For each of the 25 CTAs 1 if it is in that CTA*/

/*For each of the 31 CTA*/

