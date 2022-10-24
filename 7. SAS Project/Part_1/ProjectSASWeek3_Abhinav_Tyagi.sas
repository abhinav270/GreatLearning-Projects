*1. Import all the 4 files in SAS data environment 8;

*First file Agent_Score ;
PROC IMPORT 
datafile='/home/u48688022/ProjectWeek3/Agent_Score.csv' 
out=finance.Agent_Score replace; 
delimiter=",";
GETNAMES=yes;
GUESSINGROWS=1000;
run;
*Second File Online.csv;
PROC IMPORT 
datafile='/home/u48688022/ProjectWeek3/Online.csv' 
out=finance.Online replace; 
delimiter=",";
GETNAMES=yes;
GUESSINGROWS=1000;
run;
*Third file Roll_Agent.csv;
PROC IMPORT 
datafile='/home/u48688022/ProjectWeek3/Roll_Agent.csv' 
out=finance.Roll_Agent replace; 
delimiter=",";
GETNAMES=yes;
GUESSINGROWS=1000;
run;
*Fourth File Third_Party.csv;
PROC IMPORT 
datafile='/home/u48688022/ProjectWeek3/Roll_Agent.csv' 
out=finance.Third_Party replace; 
delimiter=",";
GETNAMES=yes;
GUESSINGROWS=1000;
run;

*2. Create one dataset from all the 4 dataset? 8;


data finance.insurance;
set finance.Online finance.Roll_Agent finance.Third_Party;
run;
Proc Print data=finance.insurance (obs=100);
run;



*3.Remove all unwanted ID variables? 2;
data finance.insurance (drop = hhid custmid);
set finance.insurance;
run;

*4. Calculate annual premium for all customers?  4;

data finance.Annual_Premium;
set finance.insurance;
Annual_Premium = 12 * Premium  ;
run;
******************* using proc SQL ****************************;
proc sql ;
select sum(annual_premium) as Annual_Premium from finance.annual_Premium;
quit;
**************************using sum *************************************;
proc print data = finance.Annual_Premium;
sum annual_premium ;
run;
*5. Calculate age and tenure as of 31 July 2020 for all customers?  4;

proc print data= finance.insurance(obs=1000);
run;

data finance.insurance ;
set finance.insurance;
customer_age = intck('year',dob,'31jul2020'D);
customer_tenure= intck('year',policy_date,'31jul2020'D);
run;

*6. Create a product name by using both level of product information. And product name should be representable
 i.e. no code should be present in final product name?  4;
 
data finance.insurance;
set finance.insurance;
product_name= compbl(cat(substr(product_lvl2,6,length(product_lvl2)),' ',product_lvl1));
run;
data finance.insurance;
lenght product_name $25;
set finance.insurance;
run;

*7. After doing clean up in your data, you have to calculate the distribution of customers across product and 
policy status and interpret the result  5;

proc sql;
select count(policy_num) as no_of_customers,Final_product,policy_status
from finance.insurance
group by policy_status,Final_product;
quit;

proc sql;
select count(policy_num) as no_of_customers,Final_product
from finance.insurance
group by Final_product;
quit;

proc sql;
select count(policy_num) as no_of_customers,policy_status
from finance.insurance
group by policy_status;
quit;

*Ans- Most Custmers have Policy Status - Payment Due Most Customer buy policy of Term Kishan;

*8. Calculate Average annual premium for different payment mode and interpret the result?  5;

proc sql;
select payment_mode, avg(premium)
from finance.insurance
group by payment_mode;
quit;

*Ans- Monthly payment mode customers have heighest annual premium where as Annual payment mode have least annual premium;


*9. Calculate Average persistency score, no fraud score and tenure of customers across product and policy status, and interpret the result?  5;

proc sql;
select avg(Presistency_Score) as Avg_Presistency_score,
       avg(NoFraud_Score) as Avg_NoFraud_Score ,
       avg(Customer_tenure) as Avg_Tenure
from finance.insurance
group by product, policy_status;
quit;

* Ans- Average Presistency score, Average No Fraud Score and Average Tenure across product and policy status is 0.8, 0.82, 17 months respectively;

*10. Calculate Average age of customer across acquisition channel and policy status, and interpret the result?   5;

proc sql;
select acq_chnl,policy_status,avg(Customer_age) as average_customer_age
from finance.insurance
group by acq_chnl, policy_status;
quit;

*we can interpret that average age of customer across acquisition channel and policy status is 38 years.;








