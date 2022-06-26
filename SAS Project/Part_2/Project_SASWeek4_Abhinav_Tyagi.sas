*Question 1: Import dataset in the SAS environment and check top 10 record of import dataset (2 Mark);

PROC IMPORT 
datafile='/home/u48688022/ProjectWeek4/Life+Insurance+Dataset.csv'
out=WORK.Insurance replace; delimiter=",";
GETNAMES=yes;
GUESSINGROWS=1000;
RUN;

PROC PRINT 
data= WORK.Insurance  (obs=10);
RUN;

*Question 2: Check variable type of the import dataset (2 Mark);

proc contents data = work.insurance;
run;

*Question 3: Checks if any variables have missing values, if yes then do treatment? (3 Mark);

proc means data=work.insurance NMISS N; 
run;
%put ---------->>>>>>NO MISSING VARIABLE;
*Question 4: Check summary and percentile distribution of all numerical variables for churners and non-churners? (5 Marks);

PROC SUMMARY 
PRINT n nmiss min p1 p5 p10 p25 p50 p75 p90 p95 p99 max
data=WORK.insurance;
class churn;
VAR age Cust_Tenure Overall_cust_satisfation_score Cust_Income Agent_Tenure Complaint 
	YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt;
RUN;

*Question 5: Check for outlier, if yes then do treatment? (3 Mark);
proc univariate data=WORK.Insurance plot;
var Age Cust_Tenure Overall_Cust_Satisfation_Score CC_Satisfation_Score Cust_Income Agent_Tenure
Complaint YTD_contact_cnt Due_date_day_cnt Existing_Policy_Count Miss_due_date_cnt;
run;
/*Outliers */
data WORK.Insurance;
set Work.Insurance;
if cust_income>35331 then cust_income=35331;
if YTD_contact_cnt>30 then YTD_contact_cnt=30;
if due_date_day_cnt>34 then due_date_day_cnt=34;
if miss_due_date_cnt>10 then miss_due_date_cnt=10;
run;
/*Checking distribution after flooring and caping*/
proc univariate data=WORK.Insurance plot;
var Age Cust_Tenure Overall_Cust_Satisfation_Score CC_Satisfation_Score Cust_Income Agent_Tenure
Complaint YTD_contact_cnt Due_date_day_cnt Existing_Policy_Count Miss_due_date_cnt;
run;
*Question 6: Check the proportion of all categorical variables and extract percentage 
contribution of each class in respective variables? (5 Marks);

PROC FREQ
data=WORK.insurance;
tables age Cust_Tenure Overall_cust_satisfation_score Cust_Income Agent_Tenure Complaint YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt 
/ NOCUM NOFREQ ;
RUN;

*Question 7: Customer service management want you to create a macro where they will 
just put mobile number and they will get all the important information like Age, Education, Gender, Income and CustID (6 Marks);

%macro Finder(num = );
	proc print data =work.insurance noobs;
	where Mobile_num = &num;
	var CustID Age EducationField Gender Cust_Income ;
	run;
%mend;
%Finder(num= 9926913118);

*Question 8: Check correlation of all numerical variables before building model, because we cannot add correlated variables in model? (4 Marks);

proc corr data=WORK.insurance ;
var churn age Cust_Tenure Overall_cust_satisfation_score 
	 Cust_Income Agent_Tenure Complaint YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt;
run;

*Question 9: Create train and test (70:30) dataset from the existing data set. Put seed 1234? (4 Marks);

proc freq data=WORK.insurance;
table churn/nocum;
run;
proc surveyselect data=WORK.insurance method=srs rep=1
sampsize=600 seed=1234 out=test;
run;
proc contents data=test varnum;
run;
proc freq data=test;
table churn/nocum;
run;
proc sql;
create table train as select t1.* from WORK.insurance as t1
where Mobile_num not in (select Mobile_num from test);
quit;
proc freq data=train;
table churn/nocum;
run;

*Question 10: Develop linear regression model first on the target variable to extract VIF information to check multicollinearity? (6 Marks);

PROC REG data = Work.Insurance;
model churn = YTD_contact_cnt Miss_due_date_cnt;  
run;

*Question 11:Create clean logistic model on the target variables? (4 Marks);

proc logistic data=train;
model churn = age Cust_Tenure Overall_cust_satisfation_score 
	 Cust_Income Agent_Tenure Complaint YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt;
run;
proc logistic data=train outmodel=outmod;
model churn = age Cust_Tenure Overall_cust_satisfation_score 
	 Cust_Income Agent_Tenure Complaint YTD_contact_cnt Due_date_day_cnt Existing_policy_count Miss_due_date_cnt;/selection=stepwise;
output out=outreg p=predicted;
run;

*Question 12: Create a macro and take a KS approach to take a cut off on the calculated scores? (4 Marks);

*Question 13:Predict test dataset using created model? (2 Marks);

