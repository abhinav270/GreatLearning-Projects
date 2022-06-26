/*
1. Write a query to calculate what % of the customers have
 made a claim in the current exposure period[i.e. in the given dataset]? 
(2) Hint: There are customers who have claimed more than once and 
they should be regarded only once in the % calculation.
*/
Select (Count(ClaimNb)*100.0/(SELECT count(IDpol) from Auto_insurance_risk)) as Percentage_Claim 
FROM Auto_insurance_risk
where ClaimNb >= 1;

/*
2.1. Create a new column as 'claim_flag' in
	the table 'auto_insurance_risk' as integer datatype.
	Set the value to 1 when ClaimNb is 
greater than 0 and set the value to 0 otherwise.
*/

ALTER TABLE Auto_insurance_risk ADD claim_flag INTEGER;

UPDATE Auto_insurance_risk
SET claim_flag = 1
WHERE ClaimNb > 1;

UPDATE Auto_insurance_risk
SET claim_flag = 0
WHERE ClaimNb < 1;

/*
3.1. What is the average exposure period for those who have claimed? (1)
3.2. What do you infer from the result? 
(1) Hint: Use claim_flag variable to group the data.
*/

SELECT claim_flag,avg(Exposure) from Auto_insurance_risk as Average_Exposure
group by claim_flag;


/*
4.1. If we create an exposure bucket where buckets are like below, 
		what is the % of total claims by these buckets? 
4.2. What do you infer from the summary? 
(1) Hint: Buckets are => E1 = 0 to 0.25, E2 = 0.26 to 0.5, E3 = 0.51 to 0.75, E4 > 0.75,
 You need to consider ClaimNb field to get the total claim count.
*/

ALTER TABLE Auto_insurance_risk
ADD exposure_bucket TEXT;

update Auto_insurance_risk
set exposure_bucket = case 
when  Exposure >0 AND Exposure<= 0.25 then 'E1'
when  Exposure >=0.26 AND Exposure<=0.50 then 'E2'
when  Exposure >=0.51 AND Exposure<= 0.75 then 'E3'
when  Exposure >=0.75 then 'E4'
end;

select exposure_bucket,(count(ClaimNb)*100.0/(Select count(*)
from Auto_insurance_risk))as Percentage_Of_Claims  from Auto_insurance_risk 
group by exposure_bucket;

/*
5. Which area has the higest number of average claims? 
	Show the data in percentage w.r.t. the number of policies in corresponding Area.
	(2) Hint: Use ClaimNb field for this question.
*/

SELECT Area	, avg(claimNB) from Auto_insurance_risk 
group by area;
select area , count(claimNb)*100.0/sum(count(claimNb))over() as percentage 
from Auto_insurance_risk 
group by Area
having ClaimNb = 1;

/*
6. If we use these exposure bucket along with Area 
i.e. group Area and Exposure Buckets together and look at the claim rate, 
an interesting pattern could be seen in the data. What is that? 
(3) Note: 2 Marks for SQL and 1 for inference.
*/

SELECT Area,exposure_bucket,(Count(ClaimNb)* 100 / (Select Count(*) From Auto_insurance_risk))
as Claim_Rate
FROM Auto_insurance_risk
group by Area
order by Claim_Rate DESC;

/* inference exposure buxket e4 and area d have max number of ClaimNb
/*
7. If we look at average Vehicle Age for those who claimed vs those who didn't claim,
	what do you see in the summary? (1.5+1 = 2.5) 
7.2. Now if we calculate the average Vehicle Age for those who claimed and group them by Area, 
	what do you see in the summary?
	Any particular pattern you see in the data? (1.5+1=2.5)
*/

select claim_flag, avg(VehAge) from Auto_insurance_risk
group by claim_flag;

select claim_flag,Area,avg(VehAge) from Auto_insurance_risk
group by Area
having claim_flag=1;

/*
8. If we calculate the average vehicle age by exposure bucket(as mentioned above),
 we see an interesting trend between those who claimed vs those who didn't. 
What is that?(3)   E4 having the high average veh age 
*/

select claim_flag,exposure_bucket, avg(VehAge) from Auto_insurance_risk
group by claim_flag,exposure_bucket;

/*
9.1. Create a Claim_Ct flag on the ClaimNb field as below,
 and take average of the BonusMalus by Claim_Ct. (2)
 9.2. What is the inference from the summary? (1)
 Note: Claim_Ct = '1 Claim' where ClaimNb = 1,
		Claim_Ct = 'MT 1 Claims' where ClaimNb > 1,
		Claim_Ct = 'No Claims' where ClaimNb = 0.
*/

ALTER TABLE Auto_insurance_risk
ADD Claim_Ct TEXT;

update Auto_insurance_risk
set Claim_Ct = case 
when ClaimNb =1 then  '1 Claim'
when ClaimNb >1 then 'MT 1 Claims'
when ClaimNb =0 then 'No Claim'
end;

select Claim_Ct, avg(bonusmalus) from Auto_insurance_risk
group by Claim_Ct;


/*
10. Using the same Claim_Ct logic created above, 
if we aggregate the Density column (take average) by Claim_Ct, 
what inference can we make from the summary data?(4) 
Note: 2.5 Marks for SQL and 1.5 for inference.
*/

select Claim_Ct, avg(Density) from Auto_insurance_risk
group by Claim_Ct;

/* 11. Which Vehicle Brand & Vehicle Gas combination have the 
highest number of Average Claims (use ClaimNb field for aggregation)? (2)*/

SELECT VehBrand, VehGas, max(maximum) as highest_number_of_claims 
from (select VehBrand,VehGas, avg(claimNb)as maximum from Auto_insurance_risk) 
group by VehBrand,VehGas;

/*
12. List the Top 5 Regions & Exposure[use the buckets created above] 
Combination from Claim Rate's perspective. 
Use claim_flag to calculate the claim rate. (3)
*/

select Region,exposure_bucket,claimNb as maximum_Claim 
from Auto_insurance_risk
where claim_flag = 1
order by claimNb DESC
limit 5;

/*
13.1. Are there any cases of illegal driving 
i.e. underaged folks driving and committing accidents? 
13.2. Create a bucket on DrivAge and then take average of BonusMalus by this Age Group Category. 
WHat do you infer from the summary? (2.5+1.5 = 4) 
Note: DrivAge=18 then 1-Beginner, 
DrivAge<=30 then 2-Junior,
 DrivAge<=45 then 3-Middle Age, 
 DrivAge<=60 then 4-Mid-Senior,
 DrivAge>60 then 5-Senior
*/

select DrivAge , ClaimNb from Auto_insurance_risk
where DrivAge <18 and claim_flag =1;
-- no sign of underaged folks driving and commiting accidents

 ALTER TABLE Auto_insurance_risk
 add DrivAge_Bucket TEXT;

UPDATE Auto_insurance_risk 
 set DrivAge_Bucket = case 
 when DrivAge =18 then '1-Beginner'
 when DrivAge <=30 then '2-Junior'
 when DrivAge <=45 then '3- Middle Age'
 when DrivAge <=60 then '4-Mid-Senior'
 when DrivAge >60 then '5-SEnior'
 end;

SELECT DrivAge_Bucket ,avg(BonusMalus) FROM Auto_insurance_risk
GROUP by DrivAge_Bucket
ORDER by avg(BonusMalus) DESC;
 