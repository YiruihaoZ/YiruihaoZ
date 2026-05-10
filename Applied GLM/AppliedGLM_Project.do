************************************************************************
*********************** 1. Data loading and management *****************
************************************************************************

************ Load the data *************
cd "D:\AU 25\Appl GLM\Project2"

use "anemia.dta", clear

*codebook, compact



*********** Abnormal values to missing (based on prior experience) *******************
replace v456 = . if v456 == 999
replace v445 = . if v445 == 9999
replace hw71 = . if hw71 >5000

*histogram hw71, freq 
* Okay now

************ Rename variables to understandable format ********************************

rename v001 cluster_number
rename v002 household_number
rename v013 age_5_year
rename v024 region
rename v025 residence_type
rename v106 highest_education
rename v190 wealth_index
rename v212 mother_age_at_first_birth
rename v445 body_mass_index
rename v456 mother_hemoglobin_level
rename b4 gender_child
rename m18 child_size_birth
rename hw1 child_age
rename hw71 waz 



************************************************************************
*********************** 1. EDA *****************************************
************************************************************************

**************** Boxplots to understand relationship between response and continuous predictors **************************

* Note: 5 continuous predictors

*********** Response: Anemia ***************

cd "D:\AU 25\Appl GLM\Project2\Boxplots_anemia"  

graph box mother_age_at_first_birth, over(anemia) ytitle("Mother's age at first birth") ysize(7) xsize(4)
graph export "mother_age_at_first_birth.png", as(png) replace

graph box mother_hemoglobin_level, over(anemia) ytitle("Mother's hemoglobin level") ysize(7) xsize(4)
graph export "mother_hemoglobin_level.png", as(png) replace

graph box child_age, over(anemia) ytitle("Child age") ysize(7) xsize(4)
graph export "child_age.png", as(png) replace

graph box body_mass_index, over(anemia) ytitle("Child BMI") ysize(7) xsize(4)
graph export "child_body_mass_index.png", as(png) replace

graph box waz, over(anemia) ytitle("Child WAZ") ysize(7) xsize(4)
graph export "child_waz.png", as(png) replace




*************** Break *************************

*********** Response: Stunting ***************

cd "D:\AU 25\Appl GLM\Project2\Boxplots_stunting"  

graph box mother_age_at_first_birth, over(stunting) ytitle("Mother's age at first birth") ysize(7) xsize(4)
graph export "mother_age_at_first_birth.png", as(png) replace

graph box mother_hemoglobin_level, over(stunting) ytitle("Mother's hemoglobin level") ysize(7) xsize(4)
graph export "mother_hemoglobin_level.png", as(png) replace

graph box child_age, over(stunting) ytitle("Child age") ysize(7) xsize(4)
graph export "child_age.png", as(png) replace

graph box body_mass_index, over(stunting) ytitle("Child BMI") ysize(7) xsize(4)
graph export "child_body_mass_index.png", as(png) replace

graph box waz, over(stunting) ytitle("Child WAZ") ysize(7) xsize(4)
graph export "child_waz.png", as(png) replace





***************** T-tests and Chi-square tests to understand the strength *********************
* Independent sample t test with equal variance assumption

*********** Response: Anemia ***************
*** T-tests
ttest mother_age_at_first_birth, by(anemia)
ttest body_mass_index, by(anemia)
ttest mother_hemoglobin_level, by(anemia)
ttest child_age, by(anemia)
ttest waz, by(anemia)

*** Chi-square tests

tab region anemia, chi2
tab age_5_year anemia, chi2
tab motherane anemia, chi2
tab gender_child anemia, chi2     /*Omit*/
tab child_size_birth anemia, chi2 /*Omit*/
tab residence_type anemia, chi2
tab SES anemia, chi2
tab highest_education anemia, chi2
tab food_access anemia, chi2

* Use p-value cut off as 0.25 suggested by Hosmer and Lemeshaw
* Omit Variables: Child's gender and Child's size at birth


*********** Response: Stunting ***************
*** T-tests
ttest mother_age_at_first_birth, by(stunting)
ttest body_mass_index, by(stunting)
ttest mother_hemoglobin_level, by(stunting)
ttest child_age, by(stunting)
ttest waz, by(stunting)

*** Chi-square tests

tab region stunting, chi2
tab age_5_year stunting, chi2 /*Omit*/
tab motherane stunting, chi2
tab gender_child stunting, chi2     
tab child_size_birth stunting, chi2
tab residence_type stunting, chi2
tab SES stunting, chi2
tab highest_education stunting, chi2
tab food_access stunting, chi2

* Omit Variables: Mother's age in 5 year groups


********************************************************************************
**************************** 3. Primary Model **********************************
********************************************************************************

*********** Response: Anemia ***************
logit anemia i.region ///
i.age_5_year c.mother_age_at_first_birth c.mother_hemoglobin_level i.motherane  ///
c.child_age waz c.body_mass_index ///
i.residence_type i.SES i.highest_education i.food_access



*********** Response: Stunting ***************
logit stunting i.region ///
c.mother_age_at_first_birth c.mother_hemoglobin_level i.motherane  ///
i.gender_child c.child_age waz c.child_size_birth c.body_mass_index ///
i.residence_type i.SES i.highest_education i.food_access




*************************** Draw (absolute) correlation heatmap for the predictors

corr region ///
age_5_year mother_age_at_first_birth mother_hemoglobin_level motherane  ///
  gender_child child_age waz child_size_birth body_mass_index ///
  residence_type SES highest_education food_access
  
  
  
matrix C = r(C)
mata:
C = st_matrix("C")
C = abs(C)
st_matrix("C", C)
end
*ssc install heatplot


matrix rownames C = region age_5_year mother_age_at_first_birth mother_hemoglobin_level motherane ///
                    gender_child child_age waz child_size_birth body_mass_index ///
                    residence_type SES highest_education food_access
matrix colnames C = region age_5_year mother_age_at_first_birth mother_hemoglobin_level motherane ///
                    gender_child child_age waz child_size_birth body_mass_index ///
                    residence_type SES highest_education food_access


heatplot C, xlabel(, angle(vertical))

*** Several predictors has high correlations, which is reflected in the coefficients of the primary model. Some are not significant despie being significant in the univariate analysis.

*** Hence a variable selection method may be useful. We are using Lasso here.



********************************************************************************
************************* 4. Lasso Variable selection **************************
********************************************************************************




*** Response: Anemia

lasso logit anemia i.region ///
i.age_5_year c.mother_age_at_first_birth c.mother_hemoglobin_level i.motherane  ///
c.child_age c.waz c.body_mass_index ///
i.residence_type i.SES i.highest_education i.food_access, selection(cv)


****** See how lasso penalty actually works/removes variables
coefpath
* Left side, more penalization (this is not standard lambda)

cvplot /*Shows optimal lambda value*/

estimates store minCV

lassocoef, display(coef)

* Omits motherane, body_mass_index, residence_type, food_access ---- 4 in total!!

*********** selected model by minimum CV
*logit anemia i.region ///
*i.age_5_year c.mother_age_at_first_birth c.mother_hemoglobin_level  ///
*c.child_age c.waz ///
*i.SES i.highest_education



lassoknots, display(nonzero bic cvmd)

*help(lassoknots)

lassoselect ID=19
estimates store minBIC

cvplot

lassocoef, display(coef)

*********** selected model by minimum BIC
* logit anemia ///
* c.mother_age_at_first_birth  ///
* c.child_age c.waz ///
* i.SES i.highest_education

lassocoef minCV minBIC /*Which variables are included in which method*/
* Can chose any of the two models, with justification


************* Say select the model using BIC

logit anemia ///
c.mother_age_at_first_birth  ///
c.child_age c.waz ///
i.SES i.highest_education

estimates store M1


********* Try one random slope due to cluster_number
melogit anemia ///
    c.mother_age_at_first_birth  ///
    c.child_age c.waz ///
    i.SES i.highest_education ///
    || cluster_number:
estimates store M2

****  Mixed effect models are not nested hence LR test is not possibele.

estimates table M1 M2, stats(ll bic)

**** Model without random slope has smaller bic, hence better model. No need to add the random slope



********************************************************************************
*************************Stepwise Backward Model Selection **************************
********************************************************************************



*Anemia
*Full Model
logit anemia i.region c.mother_age_at_first_birth c.mother_hemoglobin_level i.age_5_year i.motherane c.child_age c.body_mass_index c.waz i.residence_type i.SES i.highest_education i.food_access

*Step1: Remove motherane
logit anemia i.region c.mother_age_at_first_birth c.mother_hemoglobin_level i.age_5_year c.child_age c.body_mass_index c.waz i.residence_type i.SES i.highest_education i.food_access

*Step2: Remove food_access
logit anemia i.region c.mother_age_at_first_birth c.mother_hemoglobin_level i.age_5_year c.child_age c.body_mass_index c.waz i.residence_type i.SES i.highest_education 

*Step3: Remove body_mass_index
logit anemia i.region c.mother_age_at_first_birth c.mother_hemoglobin_level i.age_5_year c.child_age c.waz i.residence_type i.SES  i.highest_education

*Step4: Remove residence_type
logit anemia i.region c.mother_age_at_first_birth c.mother_hemoglobin_level i.age_5_year c.child_age c.waz i.SES i.highest_education 

testparm i.age_5_year
testparm i.SES
testparm i.region
testparm i.highest_education

*Step5 Remove age_5_year
logit anemia i.region c.mother_age_at_first_birth c.mother_hemoglobin_level c.child_age c.waz i.SES i.highest_education 
testparm i.SES
testparm i.region
testparm i.highest_education

*Step6 remove  highest_education
logit anemia i.region c.mother_age_at_first_birth c.mother_hemoglobin_level c.child_age c.waz i.SES
testparm i.SES
testparm i.region





*stunting
*Full Model
logit stunting i.region c.mother_age_at_first_birth c.mother_hemoglobin_level i.age_5_year i.motherane c.child_age c.body_mass_index c.waz i.residence_type i.SES i.highest_education i.food_access

*Step1: Remove mother_age_at_first_birth
logit stunting i.region c.mother_hemoglobin_level i.age_5_year i.motherane c.child_age c.body_mass_index c.waz i.residence_type i.SES i.highest_education i.food_access

*Step2: Remove body_mass_index
logit stunting i.region c.mother_hemoglobin_level i.age_5_year i.motherane c.child_age c.waz i.residence_type i.SES i.highest_education i.food_access

*Step3: Remove residence_type
logit stunting i.region c.mother_hemoglobin_level i.age_5_year i.motherane c.child_age c.waz i.SES i.highest_education i.food_access
testparm i.age_5_year
testparm i.SES
testparm i.region
testparm i.highest_education

*Step4: Remove SES
logit stunting i.region c.mother_hemoglobin_level i.age_5_year i.motherane c.child_age c.waz i.highest_education i.food_access
testparm i.age_5_year
testparm i.region
testparm i.highest_education
*Step5: Remove age_5_year
logit stunting i.region c.mother_hemoglobin_level i.motherane c.child_age c.waz i.highest_education i.food _access
testparm i.region
testparm i.highest_education

*Step6: Remove region
logit stunting c.mother_hemoglobin_level i.motherane c.child_age c.waz i.highest_education i.food _access
testparm i.highest_education

*Step7: Remove mother_hemoglobin_level
logit stunting i.motherane c.child_age c.waz i.highest_education i.food_access

*Step8: Remove motherane
logit stunting c.child_age c.waz i.highest_education i.food_access

*Step9: Remove child_age
logit stunting c.waz i.highest_education i.food_access

*Step10: Remove food_access
logit stunting c.waz i.highest_education 





********************************************************************************
************************* Model fitting & Assumption Check & Goodness-of-fit test**************************
********************************************************************************


***** To fit selected optimal multivariale logistic model for Anemia and Stunting

* Selected optimal multivariale logistic model for Anemia
logistic anemia ///
    i.region ///
	i.SES ///
    c.mother_age_at_first_birth ///
    c.mother_hemoglobin_level ///
    c.child_age ///
    c.waz, nolog

* Selected optimal multivariale logistic model for Anemia
logistic stunting ///
    c.waz ///
	i.highest_education, nolog

	
	
***** To check for the independence assumption
duplicates report caseid



***** To check for the linearity assumption for the continuous variable in each model

*** Anemia
quietly: logistic anemia ///
    i.region ///
	i.SES ///
    c.mother_age_at_first_birth ///
    c.mother_hemoglobin_level ///
    c.child_age ///
    c.waz, nolog

* Mother's age at first birth
logitcprplot mother_age_at_first_birth, lowess norline

* Mother's hemoglobin level (g/dL)
logitcprplot mother_hemoglobin_level, lowess norline

* Child's age
logitcprplot child_age, lowess norline

* weight adjusted Z-score that is a variable commonly used by WHO
logitcprplot waz, lowess norline


*** Stunting
quietly: logistic stunting ///
    c.waz ///
	i.highest_education, nolog
	
* weight adjusted Z-score that is a variable commonly used by WHO
logitcprplot waz, lowess norline


***** GOF test

*Anemia
quietly: logistic anemia ///
    i.region ///
	i.SES ///
    c.mother_age_at_first_birth ///
    c.mother_hemoglobin_level ///
    c.child_age ///
    c.waz, nolog

* Choosing a Threshold
*lsens

* GOF
estat gof, group(10)

* ROC
lroc



*Stunting
quietly: logistic stunting ///
    c.waz ///
	i.highest_education, nolog
	
* Choosing a Threshold
*lsens

* GOF
estat gof, group(10)

* ROC
lroc



****** To account for the lack of independence above, fit the mix-effect logistic regression

* Anemia model with random intercept for cluster
melogit anemia ///
    i.region ///
	i.SES ///
    c.mother_age_at_first_birth ///
    c.mother_hemoglobin_level ///
    c.child_age ///
    c.waz ///
    || cluster_number:, nolog

* Polytomous Wald Test on Mother's age at first birth
testparm c.mother_age_at_first_birth
	
	
	
* Stunting model with random intercept for cluster
melogit stunting ///
    c.waz ///
	i.highest_education ///
    || cluster_number:, nolog

* Polytomous Wald Test on Educaiton Level
testparm i.highest_education




*--------------------------------------------------------------------
* TABLE 1: Descriptive statistics by anemia status (No / Yes)
*--------------------------------------------------------------------

* Label groups for nicer output
label define anemia_lab 0 "No" 1 "Yes"
label values anemia anemia_lab

table (var) (anemia), ///
    stat(freq region residence_type highest_education wealth_index SES ///
         gender_child birth_size food_access) ///
    stat(percent region residence_type highest_education wealth_index SES ///
          gender_child birth_size food_access) ///
    stat(mean mother_age_at_first_birth mother_hemoglobin_level child_age BMI WAZ) ///
    stat(sd mother_age_at_first_birth mother_hemoglobin_level child_age BMI WAZ) ///
    nformat(%9.2f)
