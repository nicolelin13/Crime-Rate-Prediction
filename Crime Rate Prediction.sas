TITLE "Crimate Rates Dataset";
*insert data;
*create dummy variables for variable Region
*create new variablePop_Density;
*create logrithom transformed variables based on Land, Total_Pop, PCIncome, Pers_Income, and Pop_Density;
*create all the possible variables before head, so that there is only one split of the models;

DATA crimerates;
INFILE "Crimerates_data.txt" firstobs=2 delimiter='09'x;
INPUT ID County$ State$ Land Total_Pop Pop18_34 Pop65plus Docs Beds Crimes HSgrads Bgrads Poverty Unemp PCIncome Pers_Income Region;
dRegion1=(Region=1);
dRegion2=(Region=2);
dRegion3=(Region=3);
LogLand=log(Land);
Pop_Density=Total_Pop/Land;
LogTotal_Pop=log(Total_Pop);
*SqrtTotal_Pop=sqrt(Total_Pop);
LogPCIncome=log(PCIncome);
*SqrtPCIncome=sqrt(PCIncome);
LogPers_Income=log(Pers_Income);
*SqrtPers_Income=sqrt(Pers_Income);
LogPop_Density=log(Pop_Density);
*SqrtPop_Density=sqrt(Pop_Density);
Pop18_34_Unemp=Pop18_34*Unemp;
Pop65plus_Unemp=Pop65plus*Unemp;
Poverty_Unemp=Poverty*Unemp;
Pop18_34_PCIncome=Pop18_34*PCIncome;
Pop65plus_PCIncome=Pop65plus*PCIncome;
Pop18_34_LogPCIncome=Pop18_34*LogPCIncome;
Pop65plus_LogPCIncome=Pop65plus*LogPCIncome;

LABEL Land='Land Area(sq. mi.)' 
Total_Pop='Est. Pop.' 
Pop18_34='Pop. Age 18-34 (%)' 
Pop65plus='% of Pop. Age 65+ (%)' 
Docs='Drs per 1000 Pop.' 
Beds='Beds and Cribs per 1000 Pop.' 
Crimes='Serious Crimes per 1000 Pop.' 
HSgrads='High School Attainment (%)'
Bgrads='Bachelor Attainment (%)'
Poverty='Poverty Rate (%)'
Unemp='Unemployment Rate (%)'
PCIncome='Per Capita Income ($)'
Pers_Income='Total Personal Income (Mil $)'
Region='Geographic Region'
dRegion1='North East'
dRegion2='North Central'
dRegion3='South'
logLand='Log of Land'
Pop_Density ='Population Density'
logTotal_Pop='Log of Total_Pop'
SqrtTotal_Pop='Sqrt of Total_Pop'
logPCIncome='Log of Per Capita Income ($)'
SqrtPCIncome='Sqrt of Per Capita Income ($)'
logPers_Income='Log of Total Personal Income (Mil $)'
SqrtPers_Income='Sqrt of Total Personal Income (Mil $)'
logPop_Density='Log of Pop_Density'
SqrtPop_Density='Sqrt of Pop_Density'
Pop18_34_Unemp='Pop18_34(%) * Unemp(%)'
Pop65plus_Unemp='Pop65plus(%) * Unemp(%)'
Poverty_Unemp='Poverty(%) * Unemp(%)'
Pop18_34_PCIncome='Pop18_34(%) * PCIncome($)'
Pop65plus_PCIncome='Pop65plus(%) * PCIncome($)'
Pop18_34_LogPCIncome='Pop18_34(%) * LogPCIncome($)'
Pop65plus_LogPCIncome='Pop65plus(%) * LogPCIncome($)';

RUN;

PROC PRINT;
RUN;

*EXPLORATION-visualization of dependent variable Crimes;
*first--to check whether the dependent variable Crimes is normal distributed--if not, consider transformation;

PROC UNIVARIATE;
VAR Crimes;
HISTOGRAM /NORMAL;
PROBPLOT /NORMAL(mu=est sigma=est);
RUN;

*try transformations&interaction terms;

DATA crimerates1;
SET crimerates;
LogCrimes=log(Crimes);
SqrtCrimes=sqrt(Crimes);
SquareCrimes=Crimes**2;
CubicCrimes=Crimes**3;
InverseCrimes=1/Crimes;
RUN;

PROC PRINT DATA=crimerates1;
RUN;

*EXPLORATION-visualization;
*check whether the transformations are normal distributed--LogCrimes, SqrtCrimes, SquareCrimes, CubicCrimes, InverseCrimes;
*check the distribution of new variables and compare with the orignal variable;
*data=crimerates1 is the dataset with all the transformed and new created data;

PROC UNIVARIATE DATA=crimerates1;
VAR LogCrimes
SqrtCrimes
SquareCrimes
/*LogCrimes & SqrtCrimes are enough for transformation*/
CubicCrimes
/*LogCrimes & SqrtCrimes are enough for transformation*/
InverseCrimes
/*LogCrimes & SqrtCrimes are enough for transformation*/
Pop_Density
LogLand
Total_Pop
LogTotal_Pop
PCIncome
LogPCIncome
Pers_Income
LogPers_Income
Pop_Density
LogPop_Density;
HISTOGRAM /NORMAL;
PROBPLOT /NORMAL(mu=est sigma=est);
RUN;

*explore the pearson correlaton coefficient values of all variables;

PROC CORR DATA=crimerates1;
VAR Land Total_Pop LogTotal_Pop Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp 
PCIncome LogPCIncome Pers_Income LogPers_Income dRegion1 dRegion2 dRegion3 Pop_Density LogPop_Density 
Pop18_34_Unemp Pop65plus_Unemp Poverty_Unemp Pop18_34_PCIncome Pop65plus_PCIncome Pop18_34_LogPCIncome Pop65plus_LogPCIncome
Crimes LogCrimes SqrtCrimes;
RUN;

PROC MEANS MEAN;
VAR Pop18_34 Pop65plus Poverty Unemp PCIncome LogPCIncome;
RUN;

*center interaction terms;
*data=crimerates2;

DATA crimerates2;
SET crimerates1;
Pop18_34_c=Pop18_34-28.5684091;
Pop65plus_c=Pop65plus-12.1697727;
Unemp_c=Unemp-6.5965909;
Poverty_c=Poverty-8.7206818;
PCIncome_c=PCIncome-18561.48;
LogPCIncome_c=LogPCIncome-9.8069546;
Pop18_34_Unemp_c=Pop18_34_c*Unemp_c;
Pop65plus_Unemp_c=Pop65plus_c*Unemp_c;
Poverty_Unemp_c=Poverty_c*Unemp_c;
Pop18_34_PCIncome_c=Pop18_34_c*PCIncome_c;
Pop65plus_PCIncome_c=Pop65plus_c*PCIncome_c;
Pop18_34_LogPCIncome_c=Pop18_34_c*LogPCIncome_c;
Pop65plus_LogPCIncome_c=Pop65plus_c*LogPCIncome_c;

LABEL Pop18_34_c='Centered Pop18_34'
Pop65plus_c='Centered Pop65plus'
Unemp_c='Centered Unemp'
Poverty_c='Centered Poverty'
PCIncome_c='Centered PCIncome'
LogPCIncome_c='Centered LogPCIncome'
Pop18_34_Unemp_c='Centered Pop18_34(%) * Unemp(%)'
Pop65plus_Unemp_c='Centered Pop65plus(%) * Unemp(%)'
Poverty_Unemp_c='Centered Poverty(%) * Unemp(%)'
Pop18_34_PCIncome_c='Centered Pop18_34(%) * PCIncome($)'
Pop65plus_PCIncome_c='Centered Pop65plus(%) * PCIncome($)'
Pop18_34_LogPCIncome_c='Centered Pop18_34(%) * LogPCIncome($)'
Pop65plus_LogPCIncome_c='Centered Pop65plus(%) * LogPCIncome($)';

RUN;

PROC PRINT DATA=crimerates2;
RUN;

*EXPLORATION-visualization;
*check whether the transformations are normal distributed--LogCrimes, SqrtCrimes, SquareCrimes, CubicCrimes, InverseCrimes;
*check the distribution of new variables and compare with the orignal variable;
*data=crimerates1 is the dataset with all the transformed and new created data;

PROC UNIVARIATE DATA=crimerates2;
VAR LogCrimes
SqrtCrimes
SquareCrimes
CubicCrimes
InverseCrimes
LogLand
Pop_Density
Total_Pop
LogTotal_Pop
SqrtTotal_Pop
PCIncome
LogPCIncome
SqrtPCIncome
Pers_Income
LogPers_Income
SqrtPers_Income
Pop_Density
LogPop_Density
SqrtPop_Density;
HISTOGRAM /NORMAL;
PROBPLOT /NORMAL(mu=est sigma=est);
RUN;

* -----[ Validation dataset split ]-----;
*split the datase for validation;
*creating training and testing set;

TITLE "Validation and Predition Power for Crimes";

PROC SURVEYSELECT DATA=crimerates2 OUT=xv_all seed=123
SAMPRATE=0.75 OUTALL;
RUN;

TITLE "Validation - Train Set";

PROC PRINT DATA=xv_all;
RUN;

DATA xv_all;
SET xv_all;
IF selected THEN new_y=Crimes;
IF selected THEN new_logy=LogCrimes;
IF selected THEN new_sqrty=SqrtCrimes;
RUN;

PROC PRINT DATA=xv_all;
RUN;

*-----[ Model Selection ]-----;
*model election based on the Crimerates_Train dataset;

* Model 1.1 Selection Methods;
* Model 1.1 - the model with the all original X wihh Pop_Density;
* Find the best regression model to predict crimes rate;
* Use all model selection methods to identify best method for this data;

/*Model 2--with original Y, original X*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 1.1 for Crimes";
MODEL new_y = Land Total_Pop Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome Pers_Income dRegion1 dRegion2 dRegion3 Pop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 1.1 Selection - Forward";
MODEL new_y = Land Total_Pop Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome Pers_Income dRegion1 dRegion2 dRegion3 Pop_Density
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 1.1 Selection - Backward";
MODEL new_y = Land Total_Pop Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome Pers_Income dRegion1 dRegion2 dRegion3 Pop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 1.1 Selection - Stepwise";
MODEL new_y = Land Total_Pop Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome Pers_Income dRegion1 dRegion2 dRegion3 Pop_Density
/selection=stepwise sle=0.05 sls=0.05;
RUN;

* -----[ Model 1.2 Selection Methods ]-----;
* Model 1.2 - the mode with the oriinal X wih Pop_Density and without Pers_Income and Total_Pop;
* Find the best regression model to predict crimes rate;
* Use all model selection methods to identify best method for this data;

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 1.2 for Crimes - Initial - without Pers_Income";
MODEL new_y = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 1.2 Selection - Forward";
MODEL new_y = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 1.2 Selection - Backward";
MODEL new_y = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 1.2 Selection - Stepwise";
MODEL new_y = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 1.2--based on forward and backward selection--Model 1.2.1;

PROC REG DATA=xv_all;
*model 1.2.1;
TITLE "Model 1.2.1(Forward and Backward)";
MODEL new_y = Land Pop18_34 Beds Poverty dRegion1 dRegion2 dRegion3 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 dRegion3 Pop_Density);
RUN;

*delete the obs#6 in the Model1.2.1;

DATA xv_all_no6;
SET xv_all;
IF _N_=6 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6;
*model 1.2.1-without #6;
TITLE "Model 1.2.1(Forward and Backward)";
MODEL new_y = Land Pop18_34 Beds Poverty dRegion1 dRegion2 dRegion3 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 dRegion3 Pop_Density);
RUN;

*delete the obs#168 in the Model1.2.1;

DATA xv_all_no6_168;
SET xv_all_no6;
IF _N_=168 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_168;
*model 1.2.1-without #6&168;
TITLE "Model 1.2.1(Forward and Backward)";
MODEL new_y  = Land Pop18_34 Beds Poverty dRegion1 dRegion2 dRegion3 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 dRegion3 Pop_Density);
RUN;

*MODEL 1.2.2, selected by stepwise;

PROC REG DATA=xv_all;
*model 1.2.2;
TITLE "Model 1.2.2(STEOWISE)";
MODEL new_y = Pop18_34 Beds Poverty dRegion1 dRegion2 Pop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Pop18_34 Beds Poverty dRegion1 dRegion2 Pop_Density);
RUN;

DATA xv_all_no6_215;
SET xv_all;
IF _N_=6 THEN DELETE;
IF _N_=215 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_215;
*model 1.2.2;
TITLE "Model 1.2.2(STEOWISE) without #6,215";
MODEL new_y = Pop18_34 Beds Poverty dRegion1 dRegion2 Pop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Pop18_34 Beds Poverty dRegion1 dRegion2 Pop_Density);
RUN;

*For the model 1 category, two model left, compare the prediction performance to decide the final one;

proc reg data=xv_all;
* MODEL1.2.1;
model new_y=Land Pop18_34 Beds Poverty dRegion1 dRegion2 dRegion3 Pop_Density;
*out=outm1 defines dataset containing Model1 predicted values for test set;
output out=outm1(where=(new_y=.)) p=yhat;
* MODEL1.2.2;
model new_y=Pop18_34 Beds Poverty dRegion1 dRegion2 Pop_Density;
*out=outm2 defines dataset containing Model2 predicted values for test set;
output out=outm2(where=(new_y=.)) p=yhat;
run;

proc print data=outm1;
run;
proc print data=outm2;
run;


/* summarize the results of the cross-validations for model.2.1*/
title "Difference between Observed and Predicted in Test Set";
data outm1_sum;
set outm1;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm1_sum;
var d absd;
output out=outm1_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm1_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm1;
var CRIMES yhat;
run;



/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm2_sum;
set outm2;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm2_sum;
var d absd;
output out=outm2_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm2_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm2;
var CRIMES yhat;
run;


/*Model 2--with original Y, transformed X*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 2 for Crimes - Initial";
MODEL new_y = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 2 Selection - Forward";
MODEL new_y = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 2 Selection - Backward";
MODEL new_y = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 2 Selection - Stepwise";
MODEL new_y = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 2.1--based on forward and stepwise selection--Model 2.1;

PROC REG DATA=xv_all;
*model 2.1;
TITLE "Model 2.1(Forward and Stepwise)";
MODEL new_y = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

*delete the obs#6 in the Model1.2.1;

PROC REG DATA=xv_all_no6;
*model 2.1-without #6;
TITLE "Model 2.1(Forward and Stepwise) without #6";
MODEL new_y = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

*delete the obs#214 in the Model2.1;

DATA xv_all_no6_214;
SET xv_all_no6;
IF _N_=214 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_214;
*model 2.1-without #6&214;
TITLE "Model 2.1(Forward and Stepwise) without #6,214";
MODEL new_y  = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

*MODEL 2.2, selected by backward;

PROC REG DATA=xv_all;
*model 2.2;
TITLE "Model 2.2(BACKWARD)";
MODEL new_y = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no6;
*model 2.2;
TITLE "Model 2.2(BACKWARD) without #6";
MODEL new_y = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no6_214;
*model 2.2;
TITLE "Model 2.2(BACKWARD) without #6,214";
MODEL new_y = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

*For the model 2 category, two model left, compare the prediction performance to decide the final one;

proc reg data=xv_all_no6_214;
* MODEL 2.1;
model new_y=Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density;
*out=outm3 defines dataset containing Model1 predicted values for test set;
output out=outm3(where=(new_y=.)) p=yhat;
* MODEL 2.2;
model new_y=Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density;
*out=outm4 defines dataset containing Model2 predicted values for test set;
output out=outm4(where=(new_y=.)) p=yhat;
run;

proc print data=outm3;
run;
proc print data=outm4;
run;

/* summarize the results of the cross-validations for model.2.1*/
title "Difference between Observed and Predicted in Test Set";
data outm3_sum;
set outm3;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm3_sum;
var d absd;
output out=outm3_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm3_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm3;
var CRIMES yhat;
run;



/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm4_sum;
set outm4;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm4_sum;
var d absd;
output out=outm4_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm4_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm4;
var CRIMES yhat;
run;


/*MODEL 3*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 3 for Crimes";
MODEL new_y = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 3 Selection - Forward";
MODEL new_y = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 3 Selection - Backward";
MODEL new_y = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 3 Selection - Stepwise";
MODEL new_y = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 3--based on forward and backward selection--Model 3.1;

PROC REG DATA=xv_all;
*model 3.1;
TITLE "Model 3.1(Forward and Backward)";
MODEL new_y = Land Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c);
RUN;

*delete the obs#6 in the Model3.1;

PROC REG DATA=xv_all_no6;
*model 3.1-without #6;
TITLE "Model 3.1(Forward and Backward) without #6";
MODEL new_y = Land Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c);
RUN;

PROC REG DATA=xv_all_no6_214;
*model 3.1-without #6,214;
TITLE "Model 3.1(Forward and Backward) without #6,214";
MODEL new_y = Land Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c);
RUN;

*MODEL 3.2, selected by stepwise;

PROC REG DATA=xv_all;
*model 3.2;
TITLE "Model 3.2(STEOWISE)";
MODEL new_y = Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c);
RUN;

PROC REG DATA=xv_all_no6_214;
*model 3.2;
TITLE "Model 3.2(STEOWISE) without #6,215";
MODEL new_y = Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c);
RUN;

*For the model 3 category, two model left, compare the prediction performance to decide the final one;

proc reg data=xv_all;
* MODEL 3;
model new_y=Land Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c;
*out=outm1 defines dataset containing Model1 predicted values for test set;
output out=outm5(where=(new_y=.)) p=yhat;
* MODEL1.2.2;
model new_y=Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c;
*out=outm2 defines dataset containing Model2 predicted values for test set;
output out=outm6(where=(new_y=.)) p=yhat;
run;

proc print data=outm5;
run;
proc print data=outm6;
run;


/* summarize the results of the cross-validations for model3*/
title "Difference between Observed and Predicted in Test Set";
data outm5_sum;
set outm5;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm5_sum;
var d absd;
output out=outm5_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm5_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm5;
var CRIMES yhat;
run;



/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm6_sum;
set outm6;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm6_sum;
var d absd;
output out=outm6_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm6_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm6;
var CRIMES yhat;
run;



/*MODEL 4*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 4 for Crimes";
MODEL new_y = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 4 Selection - Forward";
MODEL new_y = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 4 Selection - Backward";
MODEL new_y = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 4 Selection - Stepwise";
MODEL new_y = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 4--based on all selection;

PROC REG DATA=xv_all;
*model 4;
TITLE "Model 4(Forward and Backward and Stepwise)";
MODEL new_y = Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;

PROC REG DATA=xv_all_no6;
*model 4;
TITLE "Model 4(Forward and Backward and Stepwise) without #6";
MODEL new_y = Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;

PROC REG DATA=xv_all_no6_214;
*model 4;
TITLE "Model 4(Forward and Backward and Stepwise) without #6,214";
MODEL new_y = Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;

DATA xv_all_no6_214_13;
SET xv_all_no6_214;
IF _N_=13 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_214_13;
*model 4;
TITLE "Model 4(Forward and Backward and Stepwise) without #6,214";
MODEL new_y = Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;

*For the model 4 category;

proc reg data=xv_all;
* MODEL 4;
model new_y=Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c;
*out=outm7 defines dataset containing Model1 predicted values for test set;
output out=outm7(where=(new_y=.)) p=yhat;
RUN;

proc reg data=xv_all_no6;
* MODEL 4;
model new_y=Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c;
*out=outm2 defines dataset containing Model2 predicted values for test set;
output out=outm8(where=(new_y=.)) p=yhat;
run;

proc reg data=xv_all_no6_214;
* MODEL 4;
model new_y=Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c;
*out=outm2 defines dataset containing Model2 predicted values for test set;
output out=outm9(where=(new_y=.)) p=yhat;
run;

proc reg data=xv_all_no6_214_13;
* MODEL 4;
model new_y=Land Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c;
*out=outm2 defines dataset containing Model2 predicted values for test set;
output out=outm10(where=(new_y=.)) p=yhat;
run;

proc print data=outm7;
run;
proc print data=outm8;
run;
proc print data=outm9;
run;
proc print data=outm10;
run;


/* summarize the results of the cross-validations for model3*/
title "Difference between Observed and Predicted in Test Set";
data outm7_sum;
set outm7;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm7_sum;
var d absd;
output out=outm7_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm7_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm7;
var CRIMES yhat;
run;

title "Difference between Observed and Predicted in Test Set";
data outm8_sum;
set outm8;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm8_sum;
var d absd;
output out=outm8_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm8_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm8;
var CRIMES yhat;
run;

title "Difference between Observed and Predicted in Test Set";
data outm9_sum;
set outm9;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm9_sum;
var d absd;
output out=outm9_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm9_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm9;
var CRIMES yhat;
run;

title "Difference between Observed and Predicted in Test Set";
data outm10_sum;
set outm10;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm10_sum;
var d absd;
output out=outm10_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm10_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm10;
var CRIMES yhat;
run;

/*MODEL 5*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 5 for LogCrimes";
MODEL new_logy = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 5 Selection - Forward";
MODEL new_logy = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 5 Selection - Backward";
MODEL new_logy = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 5 Selection - Stepwise";
MODEL new_logy = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 5--based on forward selection--Model 5.1;

PROC REG DATA=xv_all;
*model 5.1;
TITLE "Model 5.1(Forward)";
MODEL new_logy = Pop18_34 Docs Beds Bgrads Poverty PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34 Docs Beds Bgrads Poverty PCIncome dRegion1 dRegion2 dRegion3 Pop_Density);
RUN;


DATA xv_all_no371_407_427;
SET xv_all;
IF _N_=371 THEN DELETE;
IF _N_=407 THEN DELETE;
IF _N_=427 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no371_407_427;
*model 5.1;
TITLE "Model 5.1(Forward) without #371 407 427";
MODEL new_logy = Pop18_34 Docs Beds Bgrads Poverty PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34 Docs Beds Bgrads Poverty PCIncome dRegion1 dRegion2 dRegion3 Pop_Density);
RUN;

DATA xv_all_no371_407_427_349_404;
SET xv_all_no371_407_427;
IF _N_=349 THEN DELETE;
IF _N_=404 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no371_407_427_349_404;
*model 5.1;
TITLE "Model 5.1(Forward) without #371 407 427 349 404";
MODEL new_logy = Pop18_34 Docs Beds Bgrads Poverty PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34 Docs Beds Bgrads Poverty PCIncome dRegion1 dRegion2 dRegion3 Pop_Density);
RUN;

*MODEL 5--based on Backward and Stepwise selection--Model 5.2;

PROC REG DATA=xv_all;
*model 5.2;
TITLE "Model 5.2(Backward and Stepwise)";
MODEL new_logy = Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density);
RUN;

PROC REG DATA=xv_all_no371_407_427;
*model 5.2;
TITLE "Model 5.2(Backward and Stepwise) without #371 407 427";
MODEL new_logy = Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density);
RUN;


PROC REG DATA=xv_all_no371_407_427_349_404;
*model 5.2;
TITLE "Model 5.2(Backward and Stepwise) without #371 407 427 349 404";
MODEL new_logy = Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density);
RUN;

*For the model 5 category, one model left, but still try with the first two best models in this category;

proc reg data=xv_all_no371_407_427_349_404;
* MODEL5.1;
model new_logy=Pop18_34 Docs Beds Bgrads Poverty PCIncome dRegion1 dRegion2 dRegion3 Pop_Density;
*out=outm1 defines dataset containing Model1 predicted values for test set;
output out=outm11(where=(new_y=.)) p=yhat;
* MODEL5.2;
model new_logy=Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density;
*out=outm2 defines dataset containing Model2 predicted values for test set;
output out=outm12(where=(new_y=.)) p=yhat;
run;

proc print data=outm11;
run;
proc print data=outm12;
run;


/* summarize the results of the cross-validations for mode5.1*/
title "Difference between Observed and Predicted in Test Set";
data outm11_sum;
set outm11;
d=logCRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm11_sum;
var d absd;
output out=outm11_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm11_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm11;
var logCRIMES yhat;
run;



/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm12_sum;
set outm12;
d=logCRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm12_sum;
var d absd;
output out=outm12_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm12_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm2;
var logCRIMES yhat;
run;


/*MODEL 6--with LOG Y, transformed X*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 6 for Crimes - Initial";
MODEL new_logy = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 6 Selection - Forward";
MODEL new_logy = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 6 Selection - Backward";
MODEL new_logy = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 6 Selection - Stepwise";
MODEL new_logy = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 6.1--based on forward and stepwise selection--Model 6.1;

PROC REG DATA=xv_all;
*model 6.1;
TITLE "Model 6.1(Forward and Stepwise)";
MODEL new_logy = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no371_407_427;
*model 6.1;
TITLE "Model 6.1(Forward and Stepwise) without #371 407 427";
MODEL new_logy = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no371_407_427_6_349_404;
SET xv_all_no371_407_427;
IF _N_=6 THEN DELETE;
IF _N_=349 THEN DELETE;
IF _N_=404 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no371_407_427_6_349_404;
*model 6.1;
TITLE "Model 6.1(Forward and Stepwise) without #371 407 427 6 349 404";
MODEL new_logy = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

*MODEL 2.2, selected by backward;

PROC REG DATA=xv_all;
*model 6.2;
TITLE "Model 6.2(BACKWARD)";
MODEL new_logy = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_371_407_427;
SET xv_all;
IF _N_=6 THEN DELETE;
IF _N_=371 THEN DELETE;
IF _N_=407 THEN DELETE;
IF _N_=427 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_371_407_427;
*model 6.2;
TITLE "Model 6.2(BACKWARD) without 6 371 407 427";
MODEL new_logy = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_371_407_427_403;
SET xv_all_no6_371_407_427;
IF _N_=403 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_371_407_427_403;
*model 6.2;
TITLE "Model 6.2(BACKWARD) without 6 371 407 427 403";
MODEL new_logy = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_371_407_427_403_348;
SET xv_all_no6_371_407_427_403;
IF _N_=348 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_371_407_427_403_348;
*model 6.2;
TITLE "Model 6.2(BACKWARD) without 6 371 407 427 403 348";
MODEL new_logy = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

*For the model 6 category, two model left, compare the prediction performance to decide the final one;

proc reg data=xv_all_no371_407_427_6_349_404;
* MODEL 6.1;
model new_logy=Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density;
*out=outm3 defines dataset containing Model1 predicted values for test set;
output out=outm13(where=(new_logy=.)) p=logyhat;
RUN;

PROC REG DATA=xv_all_no6_371_407_427_403_348;
* MODEL 6.2;
model new_logy=Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density;
*out=outm4 defines dataset containing Model2 predicted values for test set;
output out=outm14(where=(new_logy=.)) p=logyhat;
run;

proc print data=outm13;
run;
proc print data=outm14;
run;

/* summarize the results of the cross-validations for model.2.1*/
title "Difference between Observed and Predicted in Test Set";
data outm13_sum;
set outm13;
d=logCRIMES-logyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm13_sum;
var d absd;
output out=outm13_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm13_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm13;
var logCRIMES logyhat;
run;

/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm14_sum;
set outm14;
d=logCRIMES-logyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm14_sum;
var d absd;
output out=outm14_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm14_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm14;
var logCRIMES logyhat;
run;


/*MODEL 7*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 7 for Crimes";
MODEL new_logy = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 7 Selection - Forward";
MODEL new_logy = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 7 Selection - Backward";
MODEL new_logy = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 7 Selection - Stepwise";
MODEL new_logy = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 7--based on forward vselection--Model 7.1;

PROC REG DATA=xv_all;
*model 7.1;
TITLE "Model 7.1(Forward)";
MODEL new_logy = Land Pop18_34_c Docs Beds Bgrads Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34_c Docs Beds Bgrads Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c);
RUN;

PROC REG DATA=xv_all_no371_407_427;
*model 7.1;
TITLE "Model 7.1(Forward) without 371 407 427";
MODEL new_logy = Land Pop18_34_c Docs Beds Bgrads Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34_c Docs Beds Bgrads Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c);
RUN;

PROC REG DATA=xv_all_no371_407_427_349_404;
*model 7.1;
TITLE "Model 7.1(Forward) without 371 407 427 349 404";
MODEL new_logy = Land Pop18_34_c Docs Beds Bgrads Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34_c Docs Beds Bgrads Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c);
RUN;

*MODEL 7--based on backward and stepwise selection--Model 7.2 = M5.2;

*For the model 7 category, one model left, compare the prediction performance to decide the final one;

proc reg data=xv_all_no371_407_427_349_404;
* MODEL 7.1;
model new_logy=Land Pop18_34_c Docs Beds Bgrads Poverty_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Poverty_Unemp_c;
*out=outm1 defines dataset containing Model1 predicted values for test set;
output out=outm15(where=(new_logy=.)) p=logyhat;
run;

proc print data=outm15;
run;


/* summarize the results of the cross-validations for model3*/
title "Difference between Observed and Predicted in Test Set";
data outm15_sum;
set outm15;
d=logCRIMES-logyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm15_sum;
var d absd;
output out=outm15_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm15_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm15;
var logCRIMES logyhat;
run;


/*MODEL 8*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 8 for Crimes";
MODEL new_logy = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 8 Selection - Forward";
MODEL new_logy = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 8 Selection - Backward";
MODEL new_logy = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 8 Selection - Stepwise";
MODEL new_logy = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=stepwise sle=0.05 sls=0.05;
RUN;


/*MODLE 9*/


PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 9 for LogCrimes";
MODEL new_sqrty = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 9 Selection - Forward";
MODEL new_sqrty = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 9 Selection - Backward";
MODEL new_sqrty = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 9 Selection - Stepwise";
MODEL new_sqrty = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp PCIncome dRegion1 dRegion2 dRegion3 Pop_Density
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 9--based on all selections--Model 9;

PROC REG DATA=xv_all;
*model 9;
TITLE "Model 9(All)";
MODEL new_sqrty = Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density);
RUN;


DATA xv_all_no6;
SET xv_all;
IF _N_=6 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6;
*model 9;
TITLE "Model 9(All) without #6";
MODEL new_sqrty = Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density);
RUN;

DATA xv_all_no6_370;
SET xv_all_no6;
IF _N_=370 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_370;
*model 9;
TITLE "Model 9(All) without #6 370";
MODEL new_sqrty = Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density);
RUN;

*For the model 5 category, one model left, but still try with the first two best models in this category;

proc reg data=xv_all_no6_370;
* MODEL9;
model new_sqrty=Pop18_34 Beds Bgrads Poverty PCIncome dRegion1 dRegion2 Pop_Density;
*out=outm1 defines dataset containing Model1 predicted values for test set;
output out=outm16(where=(new_sqrty=.)) p=sqrtyhat;
run;

proc print data=outm16;
run;


/* summarize the results of the cross-validations for mode5.1*/
title "Difference between Observed and Predicted in Test Set";
data outm16_sum;
set outm16;
d=sqrtCRIMES-sqrtyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm16_sum;
var d absd;
output out=outm16_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm16_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm16;
var sqrtCRIMES sqrtyhat;
run;

/*MODEL 10--with LOG Y, transformed X*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 10 for Crimes - Initial";
MODEL new_sqrty = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 10 Selection - Forward";
MODEL new_sqrty = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 10 Selection - Backward";
MODEL new_sqrty = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 10 Selection - Stepwise";
MODEL new_sqrty = Land Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 6.1--based on forward and stepwise selection--Model 6.1;

PROC REG DATA=xv_all;
*model 6.1;
TITLE "Model 10.1(Forward and Stepwise)";
MODEL new_sqrty = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no6;
*model 6.1;
TITLE "Model 10.1(Forward and Stepwise) without #6";
MODEL new_sqrty = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_406;
SET xv_all_no6;
IF _N_=406 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_406;
*model 6.1;
TITLE "Model 10.1(Forward and Stepwise) without #6 406";
MODEL new_sqrty = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_406_370;
SET xv_all_no6_406;
IF _N_=370 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_406_370;
*model 6.1;
TITLE "Model 10.1(Forward and Stepwise) without #6 406 370";
MODEL new_sqrty = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_406_370_214;
SET xv_all_no6_406_370;
IF _N_=214 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_406_370_214;
*model 10.1;
TITLE "Model 10.1(Forward and Stepwise) without #6 406 370 214";
MODEL new_sqrty = Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;


*MODEL 10.2, selected by backward;

PROC REG DATA=xv_all;
*model 10.2;
TITLE "Model 10.2(BACKWARD)";
MODEL new_sqrty = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no6;
*model 10.2;
TITLE "Model 10.2(BACKWARD) without #6";
MODEL new_sqrty = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_214;
SET xv_all_no6;
IF _N_=214 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_214;
*model 10.2;
TITLE "Model 10.2(BACKWARD) without #6 214";
MODEL new_sqrty = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_214_369;
SET xv_all_no6_214;
IF _N_=369 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_214_369;
*model 10.2;
TITLE "Model 10.2(BACKWARD) without #6 214 369";
MODEL new_sqrty = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_214_369_404;
SET xv_all_no6_214_369;
IF _N_=404 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_214_369_404;
*model 10.2;
TITLE "Model 10.2(BACKWARD) without #6 214 369 404";
MODEL new_sqrty = Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

*For the model 10 category, two model left, compare the prediction performance to decide the final one;
;

proc reg data=xv_all_no6_406_370_214;
* MODEL 10.1;
model new_sqrty=Land Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density;
*out=outm17 defines dataset containing Model1 predicted values for test set;
output out=outm17(where=(new_sqrty=.)) p=sqrtyhat;
RUN;

PROC REG DATA=xv_all_no6_214_369_404;
* MODEL 10.2;
model new_sqrty=Land Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density;
*out=outm4 defines dataset containing Model2 predicted values for test set;
output out=outm18(where=(new_sqrty=.)) p=sqrtyhat;
run;

proc print data=outm17;
run;
proc print data=outm18;
run;

/* summarize the results of the cross-validations for model.2.1*/
title "Difference between Observed and Predicted in Test Set";
data outm17_sum;
set outm17;
d=sqrtCRIMES-sqrtyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm17_sum;
var d absd;
output out=outm17_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm17_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm17;
var sqrtCRIMES sqrtyhat;
run;

/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm18_sum;
set outm18;
d=sqrtCRIMES-sqrtyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm18_sum;
var d absd;
output out=outm18_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm18_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm18;
var sqrtCRIMES sqrtyhat;
run;


/*MODEL 11*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 11 for Crimes";
MODEL new_sqrty = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 11 Selection - Forward";
MODEL new_sqrty = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 11 Selection - Backward";
MODEL new_sqrty = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 11 Selection - Stepwise";
MODEL new_sqrty = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c PCIncome_c dRegion1 dRegion2 dRegion3 Pop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_PCIncome_c Pop65plus_PCIncome_c
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 7--based on all vselection--Model 7;

PROC REG DATA=xv_all;
*model 11.1;
TITLE "Model 11.1(All)";
MODEL new_sqrty = Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c);
RUN;

DATA xv_all_no6_215_371_405_407;
SET xv_all;
IF _N_=6 THEN DELETE;
IF _N_=215 THEN DELETE;
IF _N_=371 THEN DELETE;
IF _N_=405 THEN DELETE;
IF _N_=407 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_215_371_405_407;
*model 11.1;
TITLE "Model 11.1(All) without #6 215 371 405 407";
MODEL new_sqrty = Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c);
RUN;

*For the model 11 category, two models left, compare the prediction performance to decide the final one;

proc reg data=xv_all;
* MODEL 11.1;
model new_sqrty=Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c;
*out=outm1 defines dataset containing Model1 predicted values for test set;
output out=outm19(where=(new_sqrty=.)) p=sqrtyhat;
run;

proc reg data=xv_all_no6_215_371_405_407;
* MODEL 11.2;
model new_sqrty=Pop18_34_c Beds Poverty_c PCIncome_c dRegion1 dRegion2 Pop_Density Poverty_Unemp_c;
*out=outm1 defines dataset containing Model1 predicted values for test set;
output out=outm20(where=(new_sqrty=.)) p=sqrtyhat;
run;

proc print data=outm19;
run;

proc print data=outm20;
run;


/* summarize the results of the cross-validations for model3*/
title "Difference between Observed and Predicted in Test Set";
data outm19_sum;
set outm19;
d=sqrtCRIMES-sqrtyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm19_sum;
var d absd;
output out=outm19_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm19_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm19;
var sqrtCRIMES sqrtyhat;
run;

/* summarize the results of the cross-validations for model3*/
title "Difference between Observed and Predicted in Test Set";
data outm20_sum;
set outm20;
d=sqrtCRIMES-sqrtyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm20_sum;
var d absd;
output out=outm20_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm20_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm20;
var sqrtCRIMES sqrtyhat;
run;


/*MODEL 12*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 12 for Crimes";
MODEL new_sqrty = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 12 Selection - Forward";
MODEL new_sqrty = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 12 Selection - Backward";
MODEL new_sqrty = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 12 Selection - Stepwise";
MODEL new_sqrty = Land Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 12--same with model 10;


/*MODEL 13--MODEL 2 with transformed Land LogLand*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 13 for Crimes - Initial";
MODEL new_y = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 13 Selection - Forward";
MODEL new_y = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 13 Selection - Backward";
MODEL new_y = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 13 Selection - Stepwise";
MODEL new_y = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 13--based on all selections--Model 13;

PROC REG DATA=xv_all;
*model 13;
TITLE "Model 13 (All)";
MODEL new_y = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

*delete the obs#6 in the Model1.2.1;

DATA xv_all_no6;
SET xv_all;
IF _N_=6 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6;
*model 13-without #6;
TITLE "Model 13 (All) without #6";
MODEL new_y = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

*delete the obs#214 in the Model13;

DATA xv_all_no6_214;
SET xv_all_no6;
IF _N_=214 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_214;
*model 13-without #6 214;
TITLE "Model 13(All) without #6 214";
MODEL new_y  = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

*For the model 13 category, one model left;

proc reg data=xv_all_no6_214;
* MODEL 13-without #6 214;
model new_y=LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density;
*out=outm21 defines dataset containing Model1 predicted values for test set;
output out=outm21(where=(new_y=.)) p=yhat;
RUN;

proc print data=outm21;
run;

/* summarize the results of the cross-validations for mode13*/
title "Difference between Observed and Predicted in Test Set";
data outm21_sum;
set outm21;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm21_sum;
var d absd;
output out=outm21_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm21_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm21;
var CRIMES yhat;
run;

/*MODLE 14*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 14 for Crimes";
MODEL new_y = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 14 Selection - Forward";
MODEL new_y = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 14 Selection - Backward";
MODEL new_y = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 14 Selection - Stepwise";
MODEL new_y = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 14--based on all selection;

PROC REG DATA=xv_all;
*model 4;
TITLE "Model 14(Forward and Stepwise)";
MODEL new_y = LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;

PROC REG DATA=xv_all_no6;
*model 14;
TITLE "Model 14(Forward and Stepwise) without #6";
MODEL new_y = LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;

PROC REG DATA=xv_all_no6_214;
*model 14;
TITLE "Model 14(Forward and Stepwise) without #6 214";
MODEL new_y = LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;


*For the model 4 category;

proc reg data=xv_all_no6_214;
* MODEL 14;
model new_y=LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c;
*out=outm7 defines dataset containing Model1 predicted values for test set;
output out=outm22(where=(new_y=.)) p=yhat;
RUN;

proc print data=outm22;
run;


/* summarize the results of the cross-validations for model3*/
title "Difference between Observed and Predicted in Test Set";
data outm22_sum;
set outm22;
d=CRIMES-yhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm22_sum;
var d absd;
output out=outm22_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm22_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm22;
var CRIMES yhat;
run;


/*MODEL 15*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 15 for Crimes - Initial";
MODEL new_logy = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 15 Selection - Forward";
MODEL new_logy = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 15 Selection - Backward";
MODEL new_logy = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 15 Selection - Stepwise";
MODEL new_logy = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 15--based on forward and stepwise selection--Model 15.1;

PROC REG DATA=xv_all;
*model 15.1;
TITLE "Model 15.1(Forward and Stepwise)";
MODEL new_logy = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_371_407_427;
SET xv_all;
IF _N_=6 THEN DELETE;
IF _N_=371 THEN DELETE;
IF _N_=407 THEN DELETE;
IF _N_=427 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_371_407_427;
*model 6.1;
TITLE "Model 15.1(Forward and Stepwise) without #6 371 407 427";
MODEL new_logy = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_371_407_427_348_403;
SET xv_all_no6_371_407_427;
IF _N_=348 THEN DELETE;
IF _N_=403 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_371_407_427_348_403;
*model 15.1;
TITLE "Model 15.1(Forward and Stepwise) without #6 371 407 427 348 403";
MODEL new_logy = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

*MODEL 15.2, selected by backward;

PROC REG DATA=xv_all;
*model 15.2;
TITLE "Model 15.2(BACKWARD)";
MODEL new_logy = LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no6_371_407_427;
*model 15.2;
TITLE "Model 15.2(BACKWARD) without #6 371 407 427";
MODEL new_logy = LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no6_371_407_427_348_403;
*model 15.2;
TITLE "Model 15.2(BACKWARD) without 6 371 407 427 348 403";
MODEL new_logy = LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_371_407_427348403214;
SET xv_all_no6_371_407_427_348_403;
IF _N_=214 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_371_407_427348403214;
*model 15.2;
TITLE "Model 15.2(BACKWARD) without 6 371 407 427 348 403 214";
MODEL new_logy = LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

*For the model 15 category, 5 models left, compare the prediction performance to decide the final one;

proc reg data=xv_all_no6_371_407_427;
* MODEL 15.1;
model new_logy=LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density;
*out=outm3 defines dataset containing Model1 predicted values for test set;
output out=outm23(where=(new_logy=.)) p=logyhat;
RUN;

PROC REG DATA=xv_all_no6_371_407_427_348_403;
* MODEL 15.1;
model new_logy=LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density;
*out=outm4 defines dataset containing Model2 predicted values for test set;
output out=outm24(where=(new_logy=.)) p=logyhat;
run;

proc reg data=xv_all_no6_371_407_427;
* MODEL 15.2;
model new_logy=LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density;
*out=outm3 defines dataset containing Model1 predicted values for test set;
output out=outm25(where=(new_logy=.)) p=logyhat;
RUN;

PROC REG DATA=xv_all_no6_371_407_427_348_403;
* MODEL 15.2;
model new_logy=LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density;
*out=outm4 defines dataset containing Model2 predicted values for test set;
output out=outm26(where=(new_logy=.)) p=logyhat;
run;

PROC REG DATA=xv_all_no6_371_407_427348403214;
* MODEL 15.2;
model new_logy=LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density;
*out=outm4 defines dataset containing Model2 predicted values for test set;
output out=outm27(where=(new_logy=.)) p=logyhat;
run;

proc print data=outm23;
run;

proc print data=outm24;
run;

proc print data=outm25;
run;

proc print data=outm26;
run;

proc print data=outm27;
run;

/* summarize the results of the cross-validations for model.2.1*/
title "Difference between Observed and Predicted in Test Set";
data outm23_sum;
set outm23;
d=logCRIMES-logyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm23_sum;
var d absd;
output out=outm23_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm23_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm23;
var logCRIMES logyhat;
run;

/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm24_sum;
set outm24;
d=logCRIMES-logyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm24_sum;
var d absd;
output out=outm24_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm24_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm24;
var logCRIMES logyhat;
run;

/* summarize the results of the cross-validations for model.2.1*/
title "Difference between Observed and Predicted in Test Set";
data outm25_sum;
set outm25;
d=logCRIMES-logyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm25_sum;
var d absd;
output out=outm25_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm25_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm25;
var logCRIMES logyhat;
run;

/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm26_sum;
set outm26;
d=logCRIMES-logyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm26_sum;
var d absd;
output out=outm26_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm26_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm26;
var logCRIMES logyhat;
run;

/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm27_sum;
set outm27;
d=logCRIMES-logyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm27_sum;
var d absd;
output out=outm27_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm27_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm27;
var logCRIMES logyhat;
run;

/*MODEL 16*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 16 for Crimes";
MODEL new_logy = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 16 Selection - Forward";
MODEL new_logy = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 16 Selection - Backward";
MODEL new_logy = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 16 Selection - Stepwise";
MODEL new_logy = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=stepwise sle=0.05 sls=0.05;
RUN;


/*MODEL 17*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 17 for Crimes - Initial";
MODEL new_sqrty = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 17 Selection - Forward";
MODEL new_sqrty = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 17 Selection - Backward";
MODEL new_sqrty = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 17 Selection - Stepwise";
MODEL new_sqrty = LogLand Pop18_34 Pop65plus Docs Beds HSgrads Bgrads Poverty Unemp LogPCIncome dRegion1 dRegion2 dRegion3 LogPop_Density/selection=stepwise sle=0.05 sls=0.05;
RUN;

*MODEL 17.1--based on forward and stepwise selection--Model 6.1;

PROC REG DATA=xv_all;
*model 6.1;
TITLE "Model 17.1(Forward and Stepwise)";
MODEL new_sqrty = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6;
SET xv_all;
IF _N_=6 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6;
*model 6.1;
TITLE "Model 17.1(Forward and Stepwise) without #6";
MODEL new_sqrty = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_214_370;
SET xv_all_no6;
IF _N_=214 THEN DELETE;
IF _N_=370 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_214_370;
*model 6.1;
TITLE "Model 17.1(Forward and Stepwise) without #6 214 370";
MODEL new_sqrty = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

DATA xv_all_no6_214_370_404;
SET xv_all_no6_214_370;
IF _N_=404 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_214_370_404;
*model 17.1;
TITLE "Model 17.1(Forward and Stepwise) without #6 406 370 404";
MODEL new_sqrty = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
plot student.*predicted.;
plot npp.*student.;
plot student.*(LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density);
RUN;

*MODEL 17.2, selected by backward;

PROC REG DATA=xv_all;
*model 17.2;
TITLE "Model 17.2(BACKWARD)";
MODEL new_sqrty = LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no6;
*model 17.2;
TITLE "Model 17.2(BACKWARD) without #6";
MODEL new_sqrty = LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no6_214_370;
*model 17.2;
TITLE "Model 17.2(BACKWARD) without #6 214 370";
MODEL new_sqrty = LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

PROC REG DATA=xv_all_no6_214_370_404;
*model 17.2;
TITLE "Model 17.2(BACKWARD) without #6 214 370 404";
MODEL new_sqrty = LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density);
RUN;

*For the model 17 category, two model left, compare the prediction performance to decide the final one;
;

proc reg data=xv_all_no6_214_370_404;
* MODEL 17.1;
model new_sqrty=LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density;
*out=outm17 defines dataset containing Model1 predicted values for test set;
output out=outm28(where=(new_sqrty=.)) p=sqrtyhat;
* MODEL 17.2;
model new_sqrty=LogLand Pop18_34 Beds Bgrads Poverty LogPCIncome dRegion1 dRegion2 LogPop_Density;
*out=outm4 defines dataset containing Model2 predicted values for test set;
output out=outm29(where=(new_sqrty=.)) p=sqrtyhat;
RUN;

proc print data=outm28;
run;

proc print data=outm29;
run;



/* summarize the results of the cross-validations for model7.1*/
title "Difference between Observed and Predicted in Test Set";
data outm28_sum;
set outm28;
d=sqrtCRIMES-sqrtyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm28_sum;
var d absd;
output out=outm28_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm28_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm28;
var sqrtCRIMES sqrtyhat;
run;

/* summarize the results of the cross-validations for model.2.2*/
title "Difference between Observed and Predicted in Test Set";
data outm29_sum;
set outm29;
d=sqrtCRIMES-sqrtyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm29_sum;
var d absd;
output out=outm29_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm29_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm29;
var sqrtCRIMES sqrtyhat;
run;


*-------------[Prediction of Model 17]-------------------*
*this is the prediciton of the final model of the analysis, which is Model 17.1(Forward and Stepwise) without #6 406 370 404;
*add datalines to training set without the outliers and influential points, which is DATA=xv_all_no6_214_370_404;

*new dataset including predicting datalines;
data new;
input LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density;
datalines;
9.12739 29.2 2.8764 8.8 0 0 5.4405
6.32257 31.6 5.2255 6.4 0 1 7.5249
;

*join datasets;
data pred;
set new xv_all_no6_214_370_404;

*compute prediction;
proc reg;
model new_sqrty = LogLand Pop18_34 Beds Poverty dRegion1 dRegion2 LogPop_Density
/p clm cli alpha=0.05;
run;



/*MODEL 18*/

PROC REG DATA=xv_all;
*full model;
TITLE "Full Model 18 for Crimes";
MODEL new_sqrty = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c/STB VIF;
RUN;

PROC REG DATA=xv_all;
*forward selection;
TITLE "Model 18 Selection - Forward";
MODEL new_sqrty = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=forward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*backward selection;
TITLE "Model 18 Selection - Backward";
MODEL new_sqrty = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=backward sle=0.05 sls=0.05;
RUN;

PROC REG DATA=xv_all;
*stepwise selection;
TITLE "Model 18 Selection - Stepwise";
MODEL new_sqrty = LogLand Pop18_34_c Pop65plus_c Docs Beds HSgrads Bgrads Poverty_c Unemp_c LogPCIncome_c dRegion1 dRegion2 dRegion3 LogPop_Density Pop18_34_Unemp_c Pop65plus_Unemp_c Poverty_Unemp_c Pop18_34_LogPCIncome_c Pop65plus_LogPCIncome_c
/selection=stepwise sle=0.05 sls=0.05;
RUN;

*model 18--selected by Forward and Stepwise;

PROC REG DATA=xv_all;
*model 18;
TITLE "Model 18(Forward and Stepwise)";
MODEL new_sqrty = LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;

PROC REG DATA=xv_all_no6;
*model 18;
TITLE "Model 18(Forward and Stepwise) without #6";
MODEL new_sqrty = LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;

DATA xv_all_no6_370_406;
SET xv_all_no6;
IF _N_=370 THEN DELETE;
IF _N_=406 THEN DELETE;
RUN;

PROC REG DATA=xv_all_no6_370_406;
*model 18;
TITLE "Model 18(Forward and Stepwise) without #6 370 406";
MODEL new_sqrty = LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c
/influence r stb vif;
PLOT student.*predicted.;
PLOT npp.*student.;
PLOT student.*(LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c);
RUN;

*For model 18 validation;

proc reg data=xv_all_no6_370_406;
* MODEL 18;
model new_sqrty=LogLand Pop18_34_c Beds Poverty_c dRegion1 dRegion2 LogPop_Density Poverty_Unemp_c;
*out=outm17 defines dataset containing Model1 predicted values for test set;
output out=outm30(where=(new_sqrty=.)) p=sqrtyhat;
RUN;

proc print data=outm30;
run;

/* summarize the results of the cross-validations for model.2.1*/
title "Difference between Observed and Predicted in Test Set";
data outm30_sum;
set outm30;
d=sqrtCRIMES-sqrtyhat; *d is the difference between observed and predicted values in test set;
absd=abs(d);
run;
/* computes predictive statistics: root mean square error (rmse) 
and mean absolute error (mae)*/
proc summary data=outm30_sum;
var d absd;
output out=outm30_stats std(d)=rmse mean(absd)=mae ;
run;
proc print data=outm30_stats;
title 'Validation  statistics for Model';
run;
*computes correlation of observed and predicted values in test set;
proc corr data=outm30;
var sqrtCRIMES sqrtyhat;
run;
