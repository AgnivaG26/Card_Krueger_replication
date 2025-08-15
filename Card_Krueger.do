cd "D:\Card_Krueger_replication"
codebook
type codebook

infile using "njmin.dct", using("public.dat") clear

* Chain labels
label define CHAIN 1 "Burger King" 2 "KFC" 3 "Roy Rogers" 4 "Wendys"
label values CHAIN CHAIN

* State labels
label define STATE 0 "Pennsylvania" 1 "New Jersey"
label values STATE STATE

* Meal codes
label define MEALS 0 "None" 1 "Free meals" 2 "Reduced price" 3 "Both"
label values MEALS MEALS
label values MEALS2 MEALS

* Interview status (FIXED - no line break needed)
label define STATUS2 0 "Refused" 1 "Completed" 2 "Closed for renovation" 3 "Closed permanently" 4 "Highway construction" 5 "Mall fire"
label values STATUS2 STATUS2

* Yes/no labels for dummies
label define YESNO 0 "No" 1 "Yes"
foreach var in CO_OWNED SOUTHJ CENTRALJ NORTHJ PA1 PA2 SHORE BONUS SPECIAL2 {
    label values `var' YESNO
}

* Step 1: Convert to string with leading zeros
tostring DATE2, gen(DATE2_str) format(%06.0f)

* Step 2: Extract month, day, year
gen str2 mm = substr(DATE2_str, 1, 2)
gen str2 dd = substr(DATE2_str, 3, 2)
gen str2 yy = substr(DATE2_str, 5, 2)

* Step 3: Expand year to 4 digits
gen str4 yyyy = cond(real(yy) < 30, "20" + yy, "19" + yy)

* Step 4: Build full date string
gen str10 DATE2_fmt = mm + "/" + dd + "/" + yyyy

* Step 5: Convert to Stata internal date
gen date2 = date(DATE2_fmt, "MDY")
format date2 %td
label variable date2 "Second interview date"

drop DATE2 DATE2_str DATE2_fmt mm dd yy yyyy
ren date2 DATE2
save njmin_labeled.dta, replace

* Summary statistics
summarize

* Clear everything for a fresh start
clear all
set more off
use njmin_labeled.dta
* Calculate counts for ALL stores
qui count 
local all_stores = r(N)

qui count if STATUS2 == 1
local all_interviewed = r(N)

qui count if STATUS2 == 2
local all_renovations = r(N)

qui count if STATUS2 == 3
local all_closed = r(N)

qui count if STATUS2 == 4
local all_temp_closed = r(N)

qui count if STATUS2 == 5
local all_fire_closed = r(N)

qui count if STATUS2 == 0
local all_refused = r(N)

* Calculate for PA
qui count if STATE == 0
local pa_stores = r(N)

qui count if STATE == 0 & STATUS2 == 1
local pa_interviewed = r(N)

qui count if STATE == 0 & STATUS2 == 2
local pa_renovations = r(N)

qui count if STATE == 0 & STATUS2 == 3
local pa_closed = r(N)

qui count if STATE == 0 & STATUS2 == 4
local pa_temp_closed = r(N)

qui count if STATE == 0 & STATUS2 == 5
local pa_fire_closed = r(N)

qui count if STATE == 0 & STATUS2 == 0
local pa_refused = r(N)

* Calculate for NJ
qui count if STATE == 1
local nj_stores = r(N)

qui count if STATE == 1 & STATUS2 == 1
local nj_interviewed = r(N)

qui count if STATE == 1 & STATUS2 == 2
local nj_renovations = r(N)

qui count if STATE == 1 & STATUS2 == 3
local nj_closed = r(N)

qui count if STATE == 1 & STATUS2 == 4
local nj_temp_closed = r(N)

qui count if STATE == 1 & STATUS2 == 5
local nj_fire_closed = r(N)

qui count if STATE == 1 & STATUS2 == 0
local nj_refused = r(N)

* Create the output table
clear
set obs 7

gen Category = ""
gen All = .
gen PA = . 
gen NJ = .

replace Category = "Num_stores" in 1
replace All = `all_stores' in 1
replace PA = `pa_stores' in 1
replace NJ = `nj_stores' in 1

replace Category = "Num_Interviewed" in 2
replace All = `all_interviewed' in 2
replace PA = `pa_interviewed' in 2
replace NJ = `nj_interviewed' in 2

replace Category = "Num_Renovations" in 3
replace All = `all_renovations' in 3
replace PA = `pa_renovations' in 3
replace NJ = `nj_renovations' in 3

replace Category = "Num_Closed" in 4
replace All = `all_closed' in 4
replace PA = `pa_closed' in 4
replace NJ = `nj_closed' in 4

replace Category = "Num_temp_closed" in 5
replace All = `all_temp_closed' in 5
replace PA = `pa_temp_closed' in 5
replace NJ = `nj_temp_closed' in 5

replace Category = "Num_Close_due_to_fire" in 6
replace All = `all_fire_closed' in 6
replace PA = `pa_fire_closed' in 6
replace NJ = `nj_fire_closed' in 6

replace Category = "Refused_Second_Interview" in 7
replace All = `all_refused' in 7
replace PA = `pa_refused' in 7
replace NJ = `nj_refused' in 7

* Display the final table
list, clean noobs

* Create LaTeX table output
tempname myfile
file open `myfile' using "table1.tex", write replace

* LaTeX header
file write `myfile' "\documentclass{article}" _n
file write `myfile' "\usepackage{booktabs}" _n
file write `myfile' "\begin{document}" _n _n
file write `myfile' "\begin{table}[htbp]" _n
file write `myfile' "\centering" _n
file write `myfile' "\caption{Store Status Summary}" _n
file write `myfile' "\label{tab:summary}" _n
file write `myfile' "\begin{tabular}{lccc}" _n
file write `myfile' "\toprule" _n
file write `myfile' "Category & All & PA & NJ \\" _n
file write `myfile' "\midrule" _n

* Write table content
file write `myfile' "Number of Stores & `all_stores' & `pa_stores' & `nj_stores' \\" _n
file write `myfile' "Interviewed & `all_interviewed' & `pa_interviewed' & `nj_interviewed' \\" _n
file write `myfile' "Renovations & `all_renovations' & `pa_renovations' & `nj_renovations' \\" _n
file write `myfile' "Closed & `all_closed' & `pa_closed' & `nj_closed' \\" _n
file write `myfile' "Temporarily Closed & `all_temp_closed' & `pa_temp_closed' & `nj_temp_closed' \\" _n
file write `myfile' "Closed Due to Fire & `all_fire_closed' & `pa_fire_closed' & `nj_fire_closed' \\" _n
file write `myfile' "Refused Interview & `all_refused' & `pa_refused' & `nj_refused' \\" _n

* Close table
file write `myfile' "\bottomrule" _n
file write `myfile' "\end{tabular}" _n
file write `myfile' "\end{table}" _n
file write `myfile' "\end{document}" _n

file close `myfile'
di "LaTeX table successfully created: table1.tex"






* Load the dataset
use njmin_labeled.dta, clear

* 1. Create all variables explicitly 
* Store counts
gen burger = (CHAIN == 1)
gen kfc = (CHAIN == 2)
gen roy = (CHAIN == 3)
gen wendy = (CHAIN == 4)
gen co_owned = (CO_OWNED == 1)

* Wave 1 variables
gen fte1 = EMPFT + NMGRS + 0.5*EMPPT
gen pct_full1 = (EMPFT + NMGRS)/(EMPFT + EMPPT + NMGRS) if !missing(EMPFT, EMPPT, NMGRS)
gen wage1 = WAGE_ST
gen wage_425_pct = PCTAFF  // Percentage at $4.25
gen meal1 = PENTREE + PFRY + PSODA
gen hrs1 = HRSOPEN

* Wave 2 variables
gen fte2 = EMPFT2 + NMGRS2 + 0.5*EMPPT2
gen pct_full2 = (EMPFT2 + NMGRS2)/(EMPFT2 + EMPPT2 + NMGRS2) if !missing(EMPFT2, EMPPT2, NMGRS2)
gen wage2 = WAGE_ST2
gen meal2 = PENTREE2 + PFRY2 + PSODA2
gen hrs2 = HRSOPEN2
preserve
* 2. Collapse with explicit mean/sum operations
collapse (sum) burger kfc roy wendy co_owned ///
         (mean) fte1 pct_full1 wage1 wage_425_pct ///
		        meal1 hrs1 ///
		 (mean) fte2 pct_full2 wage2 meal2 hrs2, by(STATE)
		 
* 3. Format and label for Table 2
* Round all values
foreach var of varlist burger-co_owned {
    replace `var' = round(`var', 1)  // Whole numbers for counts
}
foreach var of varlist fte* hrs* {
    replace `var' = round(`var', 0.01)
}
replace pct_full1 = round(pct_full1, 0.01)
replace pct_full2 = round(pct_full2, 0.01)
replace wage_425_pct = round(wage_425_pct, 0.01)

foreach var of varlist wage* meal* {
    replace `var' = round(`var', 0.01)
}

* 4. Export/display the table



* Open a new file for writing
file open mytable using "table2.tex", write replace

* Write complete LaTeX document header
file write mytable "\documentclass{article}" _n
file write mytable "\usepackage{booktabs} % For professional tables" _n
file write mytable "\usepackage{textcomp} % For currency symbols" _n
file write mytable "\begin{document}" _n _n
file write mytable "\setcounter{table}{1}" _n
file write mytable "\begin{table}[htbp]" _n
file write mytable "\centering" _n
file write mytable "\caption{Means of Key Variables}" _n
file write mytable "\label{tab:means}" _n _n

* Begin tabular environment
file write mytable "\begin{tabular}{lcc}" _n
file write mytable "\toprule" _n
file write mytable " & PA & NJ \\" _n
file write mytable "\midrule" _n

* 1. Write STATE row
file write mytable "STATE & " %4.2f (STATE[1]) " & " %4.2f (STATE[2]) " \\" _n
file write mytable "\midrule" _n

* 2. Distribution of Store Types
file write mytable "\multicolumn{3}{l}{\textbf{1. Distribution of Store Types}} \\" _n
file write mytable "a. Burger King & " %5.2f (burger[1]) " & " %5.2f (burger[2]) " \\" _n
file write mytable "b. KFC & " %5.2f (kfc[1]) " & " %5.2f (kfc[2]) " \\" _n
file write mytable "c. Roy Rogers & " %5.2f (roy[1]) " & " %5.2f (roy[2]) " \\" _n
file write mytable "d. Wendys & " %5.2f (wendy[1]) " & " %5.2f (wendy[2]) " \\" _n
file write mytable "e. CompanyOwned & " %5.2f (co_owned[1]) " & " %5.2f (co_owned[2]) " \\" _n
file write mytable "\midrule" _n

* 3. Means in Wave 1
file write mytable "\multicolumn{3}{l}{\textbf{2. Means in Wave 1:}} \\" _n
file write mytable "f. FTE Employment & " %5.2f (fte1[1]) " & " %5.2f (fte1[2]) " \\" _n
file write mytable "g. Percentage full-time employees & " %4.2f (pct_full1[1]) " & " %4.2f (pct_full1[2]) " \\" _n
file write mytable "h. Starting Wage & " %4.2f (wage1[1]) " & " %4.2f (wage1[2]) " \\" _n
file write mytable `"i. Wage = \textdollar 4.25 (percentage) & "' %5.2f (wage_425_pct[1]) `" & "' %5.2f (wage_425_pct[2]) " \\" _n
file write mytable "j. Price of full meal & " %4.2f (meal1[1]) " & " %4.2f (meal1[2]) " \\" _n
file write mytable "k. Hours open on week days & " %5.2f (hrs1[1]) " & " %5.2f (hrs1[2]) " \\" _n
file write mytable "\midrule" _n

* 4. Means in Wave 2
file write mytable "\multicolumn{3}{l}{\textbf{3. Means in Wave 2:}} \\" _n
file write mytable "l. FTE Employment & " %5.2f (fte2[1]) " & " %5.2f (fte2[2]) " \\" _n
file write mytable "m. Percentage full-time employees & " %4.2f (pct_full2[1]) " & " %4.2f (pct_full2[2]) " \\" _n
file write mytable "n. Starting Wage & " %4.2f (wage2[1]) " & " %4.2f (wage2[2]) " \\" _n
file write mytable "o. Price of full meal & " %4.2f (meal2[1]) " & " %4.2f (meal2[2]) " \\" _n
file write mytable "p. Hours open on week days & " %5.2f (hrs2[1]) " & " %5.2f (hrs2[2]) " \\" _n

* Write footer
file write mytable "\bottomrule" _n
file write mytable "\end{tabular}" _n
file write mytable "\end{table}" _n
file write mytable "\end{document}" _n

* Close the file
file close mytable

* Display confirmation
display "Table successfully written to table2_formatted.tex"

restore

preserve

* First, let's check the raw data
tab STATE
summarize WAGE_ST if STATE == 0, detail
summarize WAGE_ST if STATE == 1, detail

* Let's check the wage distribution by state
tab WAGE_ST STATE, row

*Let's create state labels
label define state_labels 0 "Pennsylvania" 1 "New Jersey"
label values STATE state_labels

* Now creating the proper chart for overall sample distribution
summarize WAGE_ST
local range = r(max) - r(min)
local binwidth = `range' / 14
local start = r(min)

gen bin_num = floor((WAGE_ST - `start') / `binwidth')
replace bin_num = 13 if bin_num >= 14
gen bin_center = `start' + (bin_num + 0.5) * `binwidth'

* Calculating percentages relative to TOTAL SAMPLE (not within each state)
egen total_sample = count(WAGE_ST) 
bysort STATE bin_num: gen bin_count = _N
gen pct_of_total = (bin_count / total_sample) * 100

* Keeping unique combinations
bysort STATE bin_num: keep if _n == 1

* Checking our calculations
list STATE bin_center pct_of_total if bin_center > 4.9 & bin_center < 5.1, clean

* Positioning bars side by side
gen x_left = bin_center - `binwidth'/4 if STATE == 0
gen x_right = bin_center + `binwidth'/4 if STATE == 1

twoway ///
    (bar pct_of_total x_left if STATE == 0, barwidth(`=`binwidth'/2.2') color("black")) ///
    (bar pct_of_total x_right if STATE == 1, barwidth(`=`binwidth'/2.2') color("gs10")), ///
    legend(order(1 "Pennsylvania" 2 "New Jersey") pos(1) ring(0) cols(1) region(color(white))) ///
    title("Distribution of Starting Wages, February 1992") ///
    xtitle("Starting wage ($/hour)") ytitle("Percent of stores") ///
    ylabel(0(5)30) xlabel(4(0.5)6) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(feb1992_overall, replace)
graph export "Feb_1992.jpg", as(jpg) quality(95) width(800) height(600) replace

*First, we create binning for November 1992 data (matching February approach)
summarize WAGE_ST2
local range = r(max) - r(min)
local binwidth = `range' / 14
local start = r(min)

gen bin_num2 = floor((WAGE_ST2 - `start') / `binwidth')
replace bin_num2 = 13 if bin_num2 >= 14
gen bin_center2 = `start' + (bin_num2 + 0.5) * `binwidth'

* Calculating percentages relative to TOTAL SAMPLE
egen total_sample2 = count(WAGE_ST2) 
bysort STATE bin_num2: gen bin_count2 = _N
gen pct_of_total2 = (bin_count2 / total_sample2) * 100

* Keeping unique combinations
bysort STATE bin_num2: keep if _n == 1
* Positioning bars side by side
gen x_left2 = bin_center2 - `binwidth'/4 if STATE == 0
gen x_right2 = bin_center2 + `binwidth'/4 if STATE == 1

twoway ///
    (bar pct_of_total2 x_left2 if STATE == 0, barwidth(`=`binwidth'/2.2') color("black")) ///
    (bar pct_of_total2 x_right2 if STATE == 1, barwidth(`=`binwidth'/2.2') color("gs10")), ///
    legend(order(1 "Pennsylvania" 2 "New Jersey") pos(1) ring(0) cols(1) region(color(white))) ///
    title("Distribution of New Wages, November 1992") ///
    xtitle("Wage in second wave ($/hour)") ytitle("Percent of stores") ///
    ylabel(0(5)30) xlabel(4(0.5)6) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(nov1992_overall, replace)
graph export "Nov_1992.jpg", as(jpg) quality(95) width(800) height(600) replace

restore


* Load the dataset
use njmin_labeled.dta, clear

* 1. Calculate FTE employment measures
gen fte_emp1 = EMPFT + NMGRS + 0.5 * EMPPT
gen fte_emp2 = EMPFT2 + NMGRS2 + 0.5 * EMPPT2

* 2. Create wage categories for New Jersey only 
gen wage_cat = .
replace wage_cat = 1 if STATE == 1 & WAGE_ST == 4.25    // EXACTLY $4.25 stores (changed from < 4.26)
replace wage_cat = 2 if STATE == 1 & WAGE_ST >= 4.26 & WAGE_ST <= 4.99  // $4.26-$4.99 (added <= to match R's between())
replace wage_cat = 3 if STATE == 1 & WAGE_ST >= 5.00   // $5.00+

* 2.5. CALCULATE ALL LOCAL MACROS FIRST (before any collapse operations)
sum fte_emp1 if STATE == 0
local pa_emp1 = r(mean)
sum fte_emp1 if STATE == 1
local nj_emp1 = r(mean)

sum fte_emp2 if STATE == 0
local pa_emp2 = r(mean)
sum fte_emp2 if STATE == 1
local nj_emp2 = r(mean)


sum fte_emp1 if STATE == 1 & WAGE_ST == 4.25  // Changed from wage_cat == 1
local nj425_emp1 = r(mean)
sum fte_emp1 if STATE == 1 & WAGE_ST >= 4.26 & WAGE_ST <= 4.99  // Changed from wage_cat == 2
local nj426499_emp1 = r(mean)
sum fte_emp1 if STATE == 1 & WAGE_ST >= 5.00  // Changed from wage_cat == 3
local nj500_emp1 = r(mean)

sum fte_emp2 if STATE == 1 & WAGE_ST == 4.25  // Changed from wage_cat == 1
local nj425_emp2 = r(mean)
sum fte_emp2 if STATE == 1 & WAGE_ST >= 4.26 & WAGE_ST <= 4.99  // Changed from wage_cat == 2
local nj426499_emp2 = r(mean)
sum fte_emp2 if STATE == 1 & WAGE_ST >= 5.00  // Changed from wage_cat == 3
local nj500_emp2 = r(mean)

* Calculate all differences
local pa_nj_diff1 = `pa_emp1' - `nj_emp1'
local pa_nj_diff2 = `pa_emp2' - `nj_emp2'
local nj425_500_diff1 = `nj425_emp1' - `nj500_emp1'
local nj426499_500_diff1 = `nj426499_emp1' - `nj500_emp1'
local nj425_500_diff2 = `nj425_emp2' - `nj500_emp2'
local nj426499_500_diff2 = `nj426499_emp2' - `nj500_emp2'
local pa_change = `pa_emp2' - `pa_emp1'
local nj_change = `nj_emp2' - `nj_emp1'
local nj425_change = `nj425_emp2' - `nj425_emp1'
local nj426499_change = `nj426499_emp2' - `nj426499_emp1'
local nj500_change = `nj500_emp2' - `nj500_emp1'
local diff_nj_pa_calc = `nj_change' - `pa_change'
local low_high_diff_calc = `nj425_change' - `nj500_change'
local mid_high_diff_calc = `nj426499_change' - `nj500_change'

* 5. Create final table display 
display "PA Employment Wave 1: " `pa_emp1'
display "PA Employment Wave 2: " `pa_emp2' 
display "PA Change: " `pa_change'
display "NJ Employment Wave 1: " `nj_emp1'
display "NJ Employment Wave 2: " `nj_emp2'
display "NJ Change: " `nj_change'
display "NJ-PA Difference in Changes: " `diff_nj_pa_calc'
display "NJ $4.25 stores change: " `nj425_change'
display "NJ $5.00+ stores change: " `nj500_change'
display "Low-High difference: " `low_high_diff_calc'


file open mytable using "table3.tex", write replace

file write mytable "\documentclass{article}" _n
file write mytable "\usepackage{booktabs}" _n
file write mytable "\usepackage{multirow}" _n
file write mytable "\usepackage{array}" _n
file write mytable "\usepackage{adjustbox}" _n
file write mytable "\begin{document}" _n _n
file write mytable "\setcounter{table}{2}" _n
file write mytable "\begin{table}[htbp]" _n
file write mytable "\centering" _n
file write mytable "\caption{AVERAGE EMPLOYMENT PER STORE BEFORE AND AFTER THE RISE IN NEW JERSEY MINIMUM WAGE}" _n
file write mytable "\label{tab:employment}" _n
file write mytable "\begin{adjustbox}{width=\textwidth,center}" _n
file write mytable "\begin{tabular}{lcccccccc}" _n
file write mytable "\toprule" _n


file write mytable " & \multicolumn{3}{c}{Stores by State} & \multicolumn{3}{c}{Stores in New Jersey} & \multicolumn{2}{c}{Differences within NJ} \\\\" _n
file write mytable "\cmidrule(r){2-4} \cmidrule(lr){5-7} \cmidrule(l){8-9}" _n
file write mytable " & PA (i) & NJ (ii) & Diff (iii) & \\\$4.25 (iv) & \\\$4.26-4.99 (v) & \\\$5.00 (vi) & Low-High (vii) & Mid-High (viii) \\\\" _n
file write mytable "\midrule" _n


file write mytable "FTE EMP1 & " %5.2f (`pa_emp1') " & " %5.2f (`nj_emp1') " & " %5.2f (`pa_nj_diff1') " & " %5.2f (`nj425_emp1') " & " %5.2f (`nj426499_emp1') " & " %5.2f (`nj500_emp1') " & " %5.2f (`nj425_500_diff1') " & " %5.2f (`nj426499_500_diff1') " \\\\" _n
file write mytable "FTE EMP2 & " %5.2f (`pa_emp2') " & " %5.2f (`nj_emp2') " & " %5.2f (`pa_nj_diff2') " & " %5.2f (`nj425_emp2') " & " %5.2f (`nj426499_emp2') " & " %5.2f (`nj500_emp2') " & " %5.2f (`nj425_500_diff2') " & " %5.2f (`nj426499_500_diff2') " \\\\" _n
file write mytable "Change & " %5.2f (`pa_change') " & " %5.2f (`nj_change') " & " %5.2f (`diff_nj_pa_calc') " & " %5.2f (`nj425_change') " & " %5.2f (`nj426499_change') " & " %5.2f (`nj500_change') " & " %5.2f (`low_high_diff_calc') " & " %5.2f (`mid_high_diff_calc') " \\\\" _n

file write mytable "\bottomrule" _n
file write mytable "\end{tabular}" _n
file write mytable "\end{adjustbox}" _n
file write mytable "\end{table}" _n
file write mytable "\end{document}" _n

file close mytable
display "Table 3 LaTeX file created: table3.tex"
gen FTE_EMP1 = EMPFT + NMGRS + 0.5 * EMPPT
gen FTE_EMP2 = EMPFT2 + NMGRS2 + 0.5 * EMPPT2
gen delta_emp = FTE_EMP2 - FTE_EMP1
gen GAP = cond(STATE == 1 & WAGE_ST <= 5.05, (5.05 - WAGE_ST)/WAGE_ST, 0)
gen CHAIN1 = (CHAIN == 1)
gen CHAIN2 = (CHAIN == 2)
gen CHAIN3 = (CHAIN == 3)

* Check mean of non-zero GAP
summarize GAP if GAP > 0

* Regressions
* 1. Run your regressions
reg delta_emp STATE, robust
estimates store reg1
reg delta_emp STATE CHAIN1 CHAIN2 CHAIN3 CO_OWNED, robust
estimates store reg2
reg delta_emp GAP, robust
estimates store reg3
reg delta_emp GAP CHAIN1 CHAIN2 CHAIN3 CO_OWNED, robust
estimates store reg4
reg delta_emp GAP SOUTHJ CENTRALJ NORTHJ PA1 PA2, robust
estimates store reg5

* Generate the LaTeX table
tempname myfile
file open `myfile' using "regression_table.tex", write replace

* LaTeX header
file write `myfile' "\documentclass{article}" _n
file write `myfile' "\usepackage{booktabs}" _n
file write `myfile' "\begin{document}" _n _n
file write `myfile' "\setcounter{table}{3}" _n

* Table structure - CAPTION MOVED OUTSIDE TABULAR
file write `myfile' "\begin{table}[htbp]" _n
file write `myfile' "\centering" _n
file write `myfile' "\caption{Employment Effects of Minimum Wage Changes}" _n
file write `myfile' "\begin{tabular}{lccccc}" _n
file write `myfile' "\toprule" _n
file write `myfile' " & \multicolumn{5}{c}{Dependent variable:} \\" _n
file write `myfile' "\cmidrule(lr){2-6}" _n
file write `myfile' " & \multicolumn{5}{c}{delta\_emp} \\" _n
file write `myfile' " & (1) & (2) & (3) & (4) & (5) \\" _n
file write `myfile' "\midrule" _n

* Define variables in exact order from your image
local varlist STATE CHAIN1 CHAIN2 CHAIN3 CO_OWNED GAP SOUTHJ CENTRALJ NORTHJ PA1 PA2

* Write coefficients
foreach var in `varlist' {
    * Clean variable names
    if "`var'" == "CO_OWNED" local varname "Co-Owned"
    else if "`var'" == "SOUTHJ" local varname "South Jersey"
    else if "`var'" == "CENTRALJ" local varname "Central Jersey"
    else if "`var'" == "NORTHJ" local varname "North Jersey"
    else local varname "`var'"
    
    file write `myfile' "`varname' "
    
    * Coefficients
    forval i = 1/5 {
        estimates restore reg`i'
        capture matrix list e(b)
        if _rc == 0 {
            matrix b = e(b)
            capture local bval = b[1, "`var'"]
            if _rc == 0 {
                matrix V = e(V)
                local seval = sqrt(V["`var'","`var'"])
                local tval = `bval'/`seval'
                
                local stars = ""
                if abs(`tval') > invnormal(0.995) local stars "***"
                else if abs(`tval') > invnormal(0.975) local stars "**"
                else if abs(`tval') > invnormal(0.95) local stars "*"
                
                file write `myfile' "& `: disp %6.3f `bval''`stars' "
            }
            else {
                file write `myfile' "& "
            }
        }
        else {
            file write `myfile' "& "
        }
    }
    file write `myfile' "\\" _n
    
    * Standard errors
    file write `myfile' " "
    forval i = 1/5 {
        estimates restore reg`i'
        capture matrix list e(b)
        if _rc == 0 {
            matrix b = e(b)
            capture local bval = b[1, "`var'"]
            if _rc == 0 {
                matrix V = e(V)
                local seval = sqrt(V["`var'","`var'"])
                file write `myfile' "& (`: disp %6.3f `seval'') "
            }
            else {
                file write `myfile' "& "
            }
        }
        else {
            file write `myfile' "& "
        }
    }
    file write `myfile' "\\" _n
}

* Constant at bottom
file write `myfile' "Constant "
forval i = 1/5 {
    estimates restore reg`i'
    matrix b = e(b)
    local bval = b[1, "_cons"]
    local seval = sqrt(e(V)["_cons","_cons"])
    local tval = `bval'/`seval'
    
    local stars = ""
    if abs(`tval') > invnormal(0.995) local stars "***"
    else if abs(`tval') > invnormal(0.975) local stars "**"
    else if abs(`tval') > invnormal(0.95) local stars "*"
    
    file write `myfile' "& `: disp %6.3f `bval''`stars' "
}
file write `myfile' "\\" _n

file write `myfile' " "
forval i = 1/5 {
    estimates restore reg`i'
    local seval = sqrt(e(V)["_cons","_cons"])
    file write `myfile' "& (`: disp %6.3f `seval'') "
}
file write `myfile' "\\" _n

* Statistics
file write `myfile' "\midrule" _n
file write `myfile' "Observations "
forval i = 1/5 {
    estimates restore reg`i'
    file write `myfile' "& `: disp %9.0f e(N)' "
}
file write `myfile' "\\" _n

file write `myfile' "R\textsuperscript{2} "
forval i = 1/5 {
    estimates restore reg`i'
    file write `myfile' "& `: disp %5.3f e(r2)' "
}
file write `myfile' "\\" _n

* Close table
file write `myfile' "\bottomrule" _n
file write `myfile' "\end{tabular}" _n
file write `myfile' "\end{table}" _n
file write `myfile' "\end{document}" _n

file close `myfile'
di "LaTeX table successfully generated: regression_table.tex"