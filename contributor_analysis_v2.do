cd V:\FHSS-JoePriceResearch\papers\current\contributors
set seed 200

use ark1910 pid attached using V:\FHSS-JoePriceResearch\papers\current\tree_growth\US\US_stats\state_stats_20jan2022, clear

merge 1:1 ark1910 using V:\FHSS-JoePriceResearch\data\census_refined\fs\1910\ark1910_pr_race_or_color.dta, nogen keep(1 3) 
gen black = regexm(pr_race_or_color,"Black")==1 | pr_race_or_color=="Mulatto" | pr_race_or_color=="Negro"
drop pr_race_or_color


*draw a random sample
gen random = runiform()
gsort black random
by black: gen order = _n
keep if order<=100000

rename ark1910 ark

*** I was unable to run this section because I could not find the file ark_pids_march3. This may bias the results.
/*
merge 1:1 ark using ark_pids_march3, nogen keep(1 3)
replace pid = pid2 if pid2~="" & pid==""
replace attached = 1 if pid2~=""
drop pid2
*/

save "V:\FHSS-JoePriceResearch\papers\current\contributors\data\tmp.dta", replace
import delimited "V:\FHSS-JoePriceResearch\papers\current\contributors\Complete\blackwhiteComplete.csv", clear
rename (v2 v5) (pid attach_date)
gen date = date(attach_date, "YMD")
format date %td
drop if missing(pid)
duplicates drop pid, force
save "V:\FHSS-JoePriceResearch\papers\current\contributors\Complete\blackwhiteComplete.dta", replace

use "V:\FHSS-JoePriceResearch\papers\current\contributors\data\tmp.dta", clear
merge m:1 pid using "V:\FHSS-JoePriceResearch\papers\current\contributors\Complete\blackwhiteComplete.dta", nogen keep(1 3)

gen percentage = 1/_N
sort date
gen cumulative = sum(percentage)
gen percentage_2 = 2*percentage
bysort black (date): gen cumulative_race = sum(percentage_2)
gen count = !missing(pid)
sum count if black
sum count if black==0
replace cumulative_race = 100*cumulative_race

format date %tdCCYY

twoway (line cumulative_race date if black==0) (line cumulative_race date if black), title("Cumulative Linking of 1910 Census to Family Tree") ytitle("Percentage of Population Linked") xtitle("Year") legend(order(1 "White" 2 "Black")) name(Cumulative_Linked_Sample, replace) saving("V:\FHSS-JoePriceResearch\papers\current\contributors\cumulative_linking", replace)

/*
tab black attached
drop if pid==""
keep pid
export delimited check_pids.csv, replace
*/

**merge in the contributor info.
**V:\FHSS-JoePriceResearch\papers\current\contributors\Complete\blackwhiteComplete.csv

**create a figure that shows the cumulative coverage of the family tree for this data using the first date variable.

