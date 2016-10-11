// *********************************************************************************************************************************************************************
// *******************************************************************************************************************************************************************
// Date: 		04 August 2014
// Purpose:	Reduce periodental and permanent caries to reflect only non-edentulism
// do "/home/j/WORK/04_epi/02_models/01_code/06_custom/oral/02_03_edent_split_perio_permcaries.do"

// PREP STATA
	clear
	set more off
	set maxvar 3200
	if c(os) == "Unix" {
		global prefix "/home/j/"
		set odbcmgr unixodbc
		set mem 2g
	}
	else if c(os) == "Windows" {
		global prefix "J:"
		set mem 2g
	}

// Temp directory
	local tmp_dir "`1'"

// ME_id of edentulism
	local edent_id `2'

// ME_id of results
	local split_id `3'

// Location_id
	local loc `4'

** ** TEST **
** local tmp_dir "/ihme/gbd/WORK/04_epi/02_models/01_code/06_custom/oral"
** local edent_id 2337
** local split_id 2336
** local loc 11

// ****************************************************************************
// Log work
	capture log close
	log using "`tmp_dir'/`split_id'/00_logs/`loc'_draws.smcl", replace

// ****************************************************************************
// Load in necessary function
run "$prefix/WORK/10_gbd/00_library/functions/get_draws.ado"

// Perform split function
	foreach year in 1990 1995 2000 2005 2010 2015 {
		foreach sex in 1 2 {
			foreach met in 5 6 {
				** Make non-edentulism proportions
				get_draws, gbd_id_field(modelable_entity_id) gbd_id(`edent_id') measure_ids(`met') source("epi") location_ids(`loc') year_ids(`year') sex_ids(`sex') age_group_ids(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21) status(best) clear
				forval y = 0/999 {
					gen prop_`y' = (1-draw_`y')
				}
				drop draw*
				tempfile edent
				save `edent', replace
				** Read child cause to be split
				get_draws, gbd_id_field(modelable_entity_id) gbd_id(`split_id') measure_ids(`met') source("epi") location_ids(`loc') year_ids(`year') sex_ids(`sex') age_group_ids(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21) status(best) clear
				merge 1:1 age_group_id using `edent', keep(1 3) nogen
				forval z = 0/999 {
					replace prop_`z' = 1 if prop_`z' == .
					replace draw_`z' = draw_`z'*prop_`z'
				}
				drop prop* model_version_id
				outsheet using "`tmp_dir'/`split_id'/01_draws/`met'_`loc'_`year'_`sex'.csv", comma names replace
			}
		}
	}


// *********************************************************************************************************************************************************************
// *********************************************************************************************************************************************************************
