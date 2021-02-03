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



