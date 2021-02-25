clear all

** Set major file path

global MASTER "C:\Users\te48local\Dropbox\Coal Bonding"

** Standard Header Stuff
capture log close
log using "$MASTER\Code\Log\kentucky_data_compilation`c(current_date)'.log", replace text
set more off

************************************************************************************
************************************************************************************
/*
DO FILE NAME: kentucky_data_compilation.do
DO FILE AUTHORS:  Tom Eisenberg
SOURCE:  None

PURPOSE: Reads in and manipulates the Kentucky coal bonding data

DATE CREATED: 02/02/2021

NOTES: 

CHANGES:

*/

*Files this do file uses
************************************************************************************
******* .xlsx files
local kydata "$MASTER\Data\Bond Spreadsheets\Kentucky\Bonds_and_bond_activities_12032020.xlsx"


* Files this do file produces
************************************************************************************
******* .dta files
local kydstata "$MASTER\Data\Bond Spreadsheets\Kentucky\kentucky_raw_stata.dta"

** Import original Excel file - takes a while so better off using stata file to start

*import excel using "`kydata'", firstrow 

*save "$MASTER\Data\Bond Spreadsheets\Kentucky\kentucky_raw_stata.dta", replace

** Import stata file of kentucky bond data

use "$MASTER\Data\Bond Spreadsheets\Kentucky\kentucky_raw_stata.dta", clear


/*
** Restrict to TWO permits first for a test case

*keep if ORIGINAL_PERMIT_NUMBER=="0070019" | ORIGINAL_PERMIT_NUMBER=="8260558" | ORIGINAL_PERMIT_NUMBER=="9000022"
*keep if ORIGINAL_PERMIT_NUMBER=="0070001" | ORIGINAL_PERMIT_NUMBER=="0070008" | ORIGINAL_PERMIT_NUMBER=="9020013" | ORIGINAL_PERMIT_NUMBER=="9170012"
*/

* Drop extraneous rows
drop if BOND_ACTIVITY_CODE==""


* Convert to dates, extrtact relevant years and months
gen bond_issue_date = date(BOND_ISSUE_DATE, "MDY")
gen bond_issue_year = year(bond_issue_date)
gen bond_issue_month = month(bond_issue_date)
format bond_issue_date %td

gen bond_activity_date = dofc(BOND_ACTIVITY_DATE)
gen bond_activity_year = year(bond_activity_date)
gen bond_activity_month = month(bond_activity_date)


* Count how many years a bond is active
bysort PERMBOND_ID: egen min_year = min(bond_issue_year)
bysort PERMBOND_ID: egen max_year = max(bond_activity_year)

gen num_years = max_year - min_year


* Get the unique bond totals for each activity line

* Mark which instance of a year a bond shows up
sort ORIGINAL_PERMIT_NUMBER PERMBOND_ID bond_issue_year  bond_activity_year bond_activity_month

by ORIGINAL_PERMIT_NUMBER PERMBOND_ID bond_issue_year : gen bond_instance = _n



* Replace missing bond amounts with 0 (?)
replace BOND_AMOUNT_THIS_ACTIVITY = 0 if BOND_AMOUNT_THIS_ACTIVITY==.



**** Get bond totals for first instances based on status

* Add reductions for first instances
gen running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="RD" & bond_instance==1

* Add part release grading for first instances
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="RG" & bond_instance==1

* Ignore release denials for first instances
replace running_bond_total = ORIGINAL_BOND_AMOUNT if BOND_ACTIVITY_CODE=="CD" & bond_instance==1

* Ignore release denials for first instances
replace running_bond_total = ORIGINAL_BOND_AMOUNT if BOND_ACTIVITY_CODE=="PD" & bond_instance==1

* BS: should go to 0 and new total is reflected in new bond (if there is one)
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY  if BOND_ACTIVITY_CODE=="BS" & bond_instance==1

* Ignore OS for first instances
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="OS" & bond_instance==1

* SF: should go to 0 and new total is reflected in new bond (if there is one)
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY  if BOND_ACTIVITY_CODE=="SF" & bond_instance==1

* RV: should go to 0 and new total is reflected in new bond (if there is one)
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY  if BOND_ACTIVITY_CODE=="RV" & bond_instance==1

* SU: should go to 0 and new total is reflected in new bond
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY  if BOND_ACTIVITY_CODE=="SU" & bond_instance==1

* Add PAs for first instances
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="PA" & bond_instance==1

* Add UCs for first instances
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="UC" & bond_instance==1

* Add AMs for first instances - looks like it can alter amounts
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="AM" & bond_instance==1

* Add OPs for first instances - looks like it can alter amounts
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="OP" & bond_instance==1

* RC goes to 0
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="RC" & bond_instance==1

* Add riders
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="RI" & bond_instance==1

* Add complete overlaps
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="OL" & bond_instance==1

* Add forfeitures
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="FF" & bond_instance==1

* Add DRs
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="DR" & bond_instance==1

* Add AOs
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="AO" & bond_instance==1

* Add VFs
replace running_bond_total = ORIGINAL_BOND_AMOUNT + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="VF" & bond_instance==1

* Ignore DF for first instances - FF is the actual action
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="DF" & bond_instance==1

* Ignore OF for first instances - FF is the actual action
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="OF" & bond_instance==1

* Ignore NF for first instances - FF is the actual action
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="NF" & bond_instance==1

* Ignore LU for first instances
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="LU" & bond_instance==1

* Ignore FE for first instances - FF is the actual action
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="FE" & bond_instance==1

* Ignore HP
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="HP" & bond_instance==1

* Ignore LS
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="LS" & bond_instance==1

* Ignore DL
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="DL" & bond_instance==1

* Ignore UD
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="UD" & bond_instance==1

* Ignore FL--seems to happen when a DF doesn't fully go through
replace running_bond_total = ORIGINAL_BOND_AMOUNT  if BOND_ACTIVITY_CODE=="UD" & bond_instance==1


* Max number of bond instances is 15

forvalues i = 2/15 {
	

by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="RD" & bond_instance==`i'

* Add part release grading for first instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="RG" & bond_instance==`i'


* RV: should go to 0 and new total is reflected in new bond
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY  if BOND_ACTIVITY_CODE=="RV" & bond_instance==`i'

* Ignore release denials for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="CD" & bond_instance==`i'


* Ignore OS for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1]  if BOND_ACTIVITY_CODE=="OS" & bond_instance==`i'

* BS: should go to 0 and new total is reflected in new bond
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY  if BOND_ACTIVITY_CODE=="BS" & bond_instance==`i'

* SF: should go to 0 and new total is reflected in new bond
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY  if BOND_ACTIVITY_CODE=="SF" & bond_instance==`i'

* SU: should go to 0 and new total is reflected in new bond
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY  if BOND_ACTIVITY_CODE=="SU" & bond_instance==`i'

* Add riders
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY  if BOND_ACTIVITY_CODE=="RI" & bond_instance==`i'

* Add PAs for first instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="PA" & bond_instance==`i'

* RC goes to 0
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="RC" & bond_instance==`i'

* FF goes to 0
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="FF" & bond_instance==`i'

* Ignore release denials for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="PD" & bond_instance==`i'

* Ignore DF for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="DF" & bond_instance==`i'

* Ignore OF for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="OF" & bond_instance==`i'

* Ignore LU for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="LU" & bond_instance==`i'

* Ignore OS for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="OS" & bond_instance==`i'

* Ignore NF for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="NF" & bond_instance==`i'

* Ignore NF for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="NF" & bond_instance==`i'

* Ignore HP for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="HP" & bond_instance==`i'

* Ignore LS for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="LS" & bond_instance==`i'

* Ignore LS for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="FE" & bond_instance==`i'
	
* Ignore DL for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="DL" & bond_instance==`i'	

* Ignore UD for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="UD" & bond_instance==`i'	


* Ignore FL for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] if BOND_ACTIVITY_CODE=="FL" & bond_instance==`i'	

* Add AMs for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="AM" & bond_instance==`i'

* Add OPs for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="OP" & bond_instance==`i'

* Add UCss for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="UC" & bond_instance==`i'

* Add OLs for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="OL" & bond_instance==`i'

* Add DRs for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="DR" & bond_instance==`i'

* Add AOs for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="AO" & bond_instance==`i'

* Add VFs for all instances
by ORIGINAL_PERMIT_NUMBER PERMBOND_ID: replace running_bond_total = running_bond_total[_n-1] + BOND_AMOUNT_THIS_ACTIVITY if BOND_ACTIVITY_CODE=="VF" & bond_instance==`i'

}

save "$MASTER\Data\Bond Spreadsheets\Kentucky\kentucky_running_totals.dta", replace
