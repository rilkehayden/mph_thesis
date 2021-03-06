# Oil and Gas Disposal Well Analysis for Kansas
# Katherine Wolf
# November 2018

#### check working directory ####

getwd() # this directory should be the one with your data files in it!
# if not, use "setwd()" to set the working directory



#### load libraries ####

library(plyr)
library(dplyr)
library(data.table)
library(ggplot2)
library(psych)



#### create necessary functions ####

# functions
`%notin%`  <-  function(x,y) !(x %in% y) # define "not-in" function



# #### raw data import ####
# 
# # well data import
# ks_wells_2018_11_01 <- read.csv(file = "ks_wells_2018_11_01.txt", stringsAsFactors = FALSE) # import raw data
# save(ks_wells_2018_11_01, file = "ks_wells_2018_11_01.rdata") # save as an rdata file
# 
# # UIC data import
# ks_uic_2018_09_04 <- read.csv(file = "KS_UIC_archive_2018_09_04.txt") # import raw data
# save(ks_uic_2018_09_04, file = "ks_uic_2018_09_04.rdata") # save as an rdata file



#### load necessary files ####

load(file = "ks_wells_2018_11_01.rdata") # load well data
load(file = "ks_uic_2018_09_04.rdata") # load UIC data



#### make protected file to avoid issues ####

ks_clean <- ks_wells_2018_11_01 # make well data file for cleaning



#### data analysis in UIC data ####

# isolate individual well IDs present in UIC data
kids <- unique(ks_uic_2018_09_04$KGS_ID)

# make table of KS wells in UIC data
ks_wells_in_uic_data_only  <-  subset(ks_clean, KID %in% kids)
save(ks_wells_in_uic_data_only, 
     file = "ks_wells_in_uic_data_only.rdata")

# make table of statuses in UIC data
uic_statuses <- table(ks_wells_in_uic_data_only$STATUS)
write.csv(uic_statuses, file = "uic_statuses.csv")



#### formatting changes in main well data ####

# convert dates to dates
ks_clean$permit_as_date  <-  
  as.Date(ks_clean$PERMIT, "%d-%b-%Y") # permit date
ks_clean$spud_as_date  <-  
  as.Date(ks_clean$SPUD, "%d-%b-%Y") # spud date
ks_clean$completion_as_date  <-  
  as.Date(ks_clean$COMPLETION, "%d-%b-%Y") # completion date
ks_clean$plugging_as_date  <-  
  as.Date(ks_clean$PLUGGING, "%d-%b-%Y") # plugging date
ks_clean$modified_as_date  <-  
  as.Date(ks_clean$MODIFIED, "%d-%b-%Y") # modified date
ks_clean$API_NUMBER  <-  
  as.character(ks_clean$API_NUMBER) # make API into a character



#### add analysis categories ####

# categorizing the well as SWD ('swd'), INJ ('inj'), or Class I ('ci')
ks_clean$well_type <- NA

# categorizing the well as plugged and abandoned ('pa') or not ('not_pa')
ks_clean$activity <- NA

# classifying as having or not having an api ('yes' or 'no')
ks_clean$has_api <- NA

# whether the well was classified via either
# (1) a STATUS of "SWD" or "SWD-P&A" ('status');
# (2) a status2 of "Converted to SWD Well" ('status2'); or
# (3) manual comment review ('comments')
ks_clean$assignment <- NA

save(ks_clean, 
     file = "ks_clean.rdata") # save results of all these conversions



##### counting duplicates #####

# count unique APIs
number_of_unique_APIs <- length(unique(ks_clean$API_NUMBER))
save(number_of_unique_APIs, file = "number_of_unique_APIs.rdata")

# raw well count
raw_well_count <- nrow(ks_clean)
save(raw_well_count, file = "raw_well_count.rdata")

# overall counts by API
ks_by_API_count <- table(ks_clean$API_NUMBER)
save(ks_by_API_count, file = "ks_by_API_count.rdata")

# view rows with duplicated APIs
index <- duplicated(ks_clean$API_NUMBER) | duplicated(ks_clean$API_NUMBER,
                                                      fromLast = TRUE)
ks_API_dups <- ks_clean[index,]
save(ks_API_dups, file = "ks_API_dups.rdata")

# view counts of duplicates per API
ks_API_dup_counts <- table(ks_API_dups$API_NUMBER)
save(ks_API_dup_counts, file = "ks_dup_API_count.rdata")

# count unique KIDs
unique_KID_count <- length(unique(ks_clean$KID))
save(unique_KID_count, file = "unique_KID_count.rdata")

# counts by well status for rows without APIs
ks_wells_no_API <- 
  ks_clean[which(ks_clean$API_NUMBER == ""),] # isolate rows for wells sans APIs
save(ks_wells_no_API, 
     file = "ks_wells_no_API.rdata") # save the above
ks_wells_no_API_by_status <- 
  table(ks_wells_no_API$STATUS) # table of counts of wells sans API by status
save(ks_wells_no_API_by_status, 
     file = "ks_wells_no_API_by_status.rdata") # save table of counts



##### checking ambiguous wells for inclusion or exclusion #####

# get counts by well status1 (main status)
ks_well_counts_by_status1 <- 
  table(ks_clean$STATUS) # get counts
ks_well_counts_by_status1 <- 
  as.data.frame(ks_well_counts_by_status1) # convert to dataframe
save(ks_well_counts_by_status1, 
     file = "ks_well_counts_by_status1.rdata")
write.csv(ks_well_counts_by_status1, 
          file = "ks_well_counts_by_status1.csv") # write for excel file

# get counts by well status2
ks_well_counts_by_status2 <- 
  table(ks_clean$STATUS2)
ks_well_counts_by_status2 <- 
  as.data.frame(ks_well_counts_by_status2) # convert to dataframe
save(ks_well_counts_by_status2, 
     file = "ks_well_counts_by_status2.rdata")
write.csv(ks_well_counts_by_status2, 
          file = "ks_well_counts_by_status2.csv")

# make vectors of status1s and status2s
ks_all_status1s <- 
  sort(unique(ks_clean$STATUS)) # vector of all STATUS values
ks_all_status2s <- 
  sort(unique(ks_clean$STATUS2)) # vector of all STATUS2 values
save(ks_all_status1s, 
     file = "ks_all_status1s.rdata")
save(ks_all_status2s, # save status1s to file
     file = "ks_all_status2s.rdata") # save status2s to file
write.csv(ks_all_status1s, 
          file = "ks_all_status1s.csv") # csv of status1s for excel
write.csv(ks_all_status2s, 
          file = "ks_all_status2s.csv") # csv of status2s for excel

# make vectors of status1s for further investigation or not
ks_status1_check_further <- 
  c("INTENT",
    "OTHER()",
    "OTHER(NULL)",
    "OTHER(OTHER)",
    "OTHER(TA)",
    "OTHER(TEMP ABD)",
    "OTHER-P&A()",
    "OTHER-P&A(TA)")

ks_potential_disposal_include_status1s <- 
  sort(c("OTHER()",
         "OTHER(1O&1SWD)",
         "OTHER(CBM/SWD)",
         "OTHER(CLASS ONE (OLD))",
         "OTHER(CLASS1)",
         "OTHER(NHDW)",
         "OTHER(NULL)",
         "OTHER(OIL,SWD)",
         "OTHER(OTHER)",
         "OTHER(SWD-P&A)",
         "OTHER(TA)",
         "OTHER(TEMP ABD)",
         "OTHER-P&A()",
         "OTHER-P&A(CLASS ONE (OLD))",
         "OTHER-P&A(OIL-SWD)",
         "OTHER-P&A(TA)",
         "SWD",
         "SWD-P&A"))

ks_definitely_include_status1s <- 
  sort(c("OTHER(1O&1SWD)",
         "OTHER(CBM/SWD)",
         "OTHER(CLASS ONE (OLD))",
         "OTHER(CLASS1)",
         "OTHER(NHDW)",
         "OTHER(OIL,SWD)",
         "OTHER(SWD-P&A)",
         "OTHER-P&A(CLASS ONE (OLD))",
         "OTHER-P&A(OIL-SWD)",
         "SWD",
         "SWD-P&A"))

ks_potential_disposal_exclude_status1s <- 
  sort(c("INTENT",
         "INJ",
         "INJ-P&A",
         "OTHER(INJ or EOR)",
         "OTHER-P&A(INJ OR )",
         "OTHER-P&A(INJ or EOR)",
         "CBM",
         "CBM-P&A",
         "D&A",
         "EOR",
         "EOR-P&A",
         "GAS",
         "GAS-P&A",
         "LOC",
         "O&G",
         "O&G-P&A",
         "OIL",
         "OIL-P&A",
         "OTHER-P&A(2 OIL)",
         "OTHER-P&A(CATH)",
         "OTHER-P&A(COREHOLE)",
         "OTHER-P&A(GAS-INJ)",
         "OTHER-P&A(GAS-STG)",
         "OTHER-P&A(GSW)",
         "OTHER-P&A(LH)",
         "OTHER-P&A(OBS)",
         "OTHER-P&A(OIL&GAS-INJ)",
         "OTHER-P&A(SHUT-IN)",
         "OTHER-P&A(STRAT)",
         "OTHER-P&A(WATER)",
         "OTHER(2OIL)",
         "OTHER(ABD LOC)",
         "OTHER(CATH)",
         "OTHER(COREHOLE)",
         "OTHER(GAS-INJ)",
         "OTHER(GAS-STG)",
         "OTHER(GAS INJ)",
         "OTHER(GAS SHUT-IN)",
         "OTHER(GSW)",
         "OTHER(HELIUM)",
         "OTHER(LH)",
         "OTHER(Monitor)",
         "OTHER(MONITOR)",
         "OTHER(OBS)",
         "OTHER(OBSERVATION)",
         "OTHER(OIL&GAS-INJ)",
         "OTHER(Oil)",
         "OTHER(OIL/GAS)",
         "OTHER(SHUT-IN)",
         "OTHER(STRAT)",
         "OTHER(WATER)"))

# check lengths of vectors
length(ks_potential_disposal_include_status1s) # count included statii
length(ks_potential_disposal_exclude_status1s) # count excluded statii
length(ks_all_status1s) # above two numbers should sum to this number



#### selecting rows based on status2 ####
# make vector of status2s to include regardless of status1
ks_potential_disposal_include_status2s <- 
  sort(c("Converted to SWD Well")) 

# vector of status2s that don't guarantee inclusion
ks_potential_disposal_exclude_status2s <- 
  setdiff(ks_all_status2s,
          ks_potential_disposal_include_status2s)
ks_potential_disposal_exclude_status2s



#### investigating rows based on comments ####
ks_potential_disposal_comments <-   # make vector of just comments
  ks_clean$COMMENTS

# below identifies rows with comments containing the strings 
# "swd", "disp", "salt", "class", or "waste"
positions_of_possible_comments_to_include <-
  grep("swd|disp|salt|class|waste", 
       ks_potential_disposal_comments, 
       ignore.case = TRUE)

comments_to_review <-   # makes vector of identified comments
  ks_clean$COMMENTS[positions_of_possible_comments_to_include]

# makes .csv file of identified comments
write.csv(comments_to_review,   # makes .csv file of identified comments
          file = "comments_to_review.csv")

# makes dataframe of entire rows matching comments
rows_requiring_comment_investigation <-
  ks_clean[which(ks_clean$COMMENTS %in% comments_to_review),]

# make dataframe of most relevant columns of entire rows matching comments
rows_requiring_comment_investigation_simple <- 
  rows_requiring_comment_investigation[
    ,c("KID",
       "API_NUMBER",
       "has_api",
       "activity",
       "well_type",
       "assignment",
       "STATUS",
       "STATUS2",
       "COMMENTS"
       )
    ]

# make .csv files of rows matching comments and simple rows matching comments
write.csv(rows_requiring_comment_investigation,
          file = "rows_requiring_comment_investigation.csv")
write.csv(rows_requiring_comment_investigation_simple, 
          file = "rows_requiring_comment_investigation_simple.csv")

#### manual review of the above to determine assignments must happen here ####
#### DO NOT RUN PAST HERE ####




# import manual assignments
raw_manual_well_assignments <- 
  read.csv(file = "rows_requiring_comment_investigation_simple_2018_11_14.csv")

#### rules for manual well assignments

manual_without_drops <- 
  raw_manual_well_assignments %>%
  filter(well_type != "drop")

View(manual_without_drops)


# final well group
# pull the KIDs of the wells selected from at least one of the groups
kids_comments_for_the_final_list <- 
  ks_clean$KID[which(ks_clean$KID %in% manual_without_drops$KID)]
kids_status1s <- 
  ks_clean$KID[which(ks_clean$STATUS %in% ks_definitely_include_status1s)]
kids_status2s <- 
  ks_clean$KID[which(ks_clean$STATUS2 %in% 
                       ks_potential_disposal_include_status2s)]

length(kids_comments_for_the_final_list)
length(kids_status1s)
length(kids_status2s)

kid_list <- c(kids_comments_for_the_final_list, kids_status1s, kids_status2s)
kids_for_final_list <- unlist(kid_list)
length(kids_for_final_list)
kids_for_final_list <- unique(kids_for_final_list)
length(kids_for_final_list)

ks_final_wells <- ks_clean[which(ks_clean$KID %in% kids_for_final_list),]
View(ks_final_wells)





#### category assignments ####

#### assign has api ####
ks_final_wells$has_api  <-  ifelse(ks_final_wells$API_NUMBER == "", "no", "yes")
View(ks_final_wells)

#### swd versus not ####
View(table(ks_final_wells$STATUS))

ks_definitely_include_status1s <- sort(c("OTHER(1O&1SWD)","OTHER(CBM/SWD)","OTHER(CLASS ONE (OLD))","OTHER(CLASS1)","OTHER(NHDW)","OTHER(OIL,SWD)","OTHER(SWD-P&A)","OTHER-P&A(CLASS ONE (OLD))","OTHER-P&A(OIL-SWD)","SWD","SWD-P&A"))

swd_statii <- sort(c("OTHER(1O&1SWD)","OTHER(CBM/SWD)","OTHER(OIL,SWD)","OTHER(SWD-P&A)","OTHER-P&A(OIL-SWD)","SWD","SWD-P&A"))
class1_statii <- sort(c("OTHER(CLASS ONE (OLD))","OTHER(CLASS1)","OTHER(NHDW)","OTHER-P&A(CLASS ONE (OLD))"))
swd_statii2 <- sort(c("Converted to SWD Well"))

ks_final_wells <- within(ks_final_wells, swd_inj_ci[STATUS %in% class1_statii] <-  'class1')
ks_final_wells <- within(ks_final_wells, swd_inj_ci[STATUS %in% swd_statii | STATUS2 %in% swd_statii2]  <-  'swd')

#### pa versus not ####
pa_statii <- sort(c("OTHER(SWD-P&A)","OTHER-P&A(CLASS ONE (OLD))","OTHER-P&A(OIL-SWD)","SWD-P&A"))
ks_final_wells <- within(ks_final_wells, activity[STATUS %in% pa_statii] <-  'pa')

#### deal with comments ####
ks_final_wells <- merge(ks_final_wells, core_manual, by = "KID", all.x = TRUE, all.y = TRUE)
ks_final_wells <- within(ks_final_wells, swd_inj_ci[man_swd_inj_ci == 'swd'] <- 'swd')
ks_final_wells <- within(ks_final_wells, swd_inj_ci[man_swd_inj_ci == 'class1'] <- 'class1')
ks_final_wells <- within(ks_final_wells, swd_inj_ci[man_swd_inj_ci == 'swd_class1'] <- 'swd_class1')
ks_final_wells <- within(ks_final_wells, activity[man_activity == 'pa'] <- 'pa')
ks_final_wells <- within(ks_final_wells, activity[man_activity == 'never_completed'] <- 'never_completed')
ks_final_wells <- within(ks_final_wells, other[STATUS %in% c("SWD","SWD-P&A")] <- 'no')

# assign not-others to "yes"
ks_final_wells$other[is.na(ks_final_wells$other)]  <-  "yes"
ks_final_wells$activity[is.na(ks_final_wells$activity)]  <-  "not_pa"
ks_final_wells$manual[is.na(ks_final_wells$man_swd_inj_ci)] <- "no"
ks_final_wells$manual[is.na(ks_final_wells$manual)] <- "yes"

View(ks_final_wells)

View(table(ks_final_wells$swd_inj_ci,ks_final_wells$has_api))

save(ks_final_wells, file = "ks_final_wells.rdata")


#### deleting those with duplicate APIs
# make dataset without wells without apis
ks_only_apis <- ks_final_wells
ks_only_apis <- ks_final_wells[!(is.na(ks_final_wells$API_NUMBER) | ks_final_wells$API_NUMBER==""),]
View(ks_only_apis)

# find duplicate APIs
ks_final_index  <-  duplicated(ks_only_apis$API_NUMBER) | duplicated(ks_only_apis$API_NUMBER, fromLast = TRUE)
ks_API_dups <- ks_only_apis[ks_final_index, ]
# View(ks_API_dups)

# remove duplicate APIs, keeping those last modified
ks_bye_dup_API <- subset(ks_only_apis, ave(modified_as_date, API_NUMBER, FUN = max) == modified_as_date)
View(ks_bye_dup_API)


#### dealing with API duplication based on 4-digit activity code

# delete extraneous four digits
ks_bye_dup_API$API_NUMBER_SIMPLE  <-  substr(ks_bye_dup_API$API_NUMBER, 0, 12)
View(ks_bye_dup_API)

# find duplicate APIs without extraneous four digits
ks_simple_API_index  <-  duplicated(ks_bye_dup_API$API_NUMBER_SIMPLE) | duplicated(ks_bye_dup_API$API_NUMBER_SIMPLE, fromLast = TRUE)
ks_simple_API_dups <- ks_bye_dup_API[ks_simple_API_index, ]
View(ks_simple_API_dups)

# remove duplicate APIs, keeping those last modified
ks_bye_dup_API_simple <- subset(ks_bye_dup_API, ave(modified_as_date, API_NUMBER_SIMPLE, FUN = max) == modified_as_date)

View(ks_bye_dup_API_simple)

# re-find duplicates
ks_simple_API_index_2 <- duplicated(ks_bye_dup_API_simple$API_NUMBER_SIMPLE) | duplicated(ks_bye_dup_API_simple$API_NUMBER_SIMPLE, fromLast = TRUE)
ks_simple_API_dups_2 <- ks_bye_dup_API_simple[ks_simple_API_index_2, ]
View(ks_simple_API_dups_2)

ks_bye_dup_API_simple <- ks_bye_dup_API_simple[order(ks_bye_dup_API_simple$API_NUMBER_SIMPLE,ks_bye_dup_API_simple$other),]
View(ks_bye_dup_API_simple)

true_no_dup_API <- ks_bye_dup_API_simple[!duplicated(ks_bye_dup_API_simple$API_NUMBER_SIMPLE),]
View(true_no_dup_API)

# drop never-completeds
no_never_complete <- subset(true_no_dup_API, !(activity == "never_completed"))
View(no_never_complete)

# remove classIs
ks_no_dup_api_or_ci <- subset(no_never_complete, !(swd_inj_ci == "class1"))
View(ks_no_dup_api_or_ci)


# find duplicated latitudes and longitudes
ks_lat_long_dup_index <- duplicated(ks_no_dup_api_or_ci[c("LATITUDE","LONGITUDE")]) | duplicated(ks_no_dup_api_or_ci[c("LATITUDE","LONGITUDE")], fromLast = TRUE)
ks_lat_long_dup <- ks_no_dup_api_or_ci[ks_lat_long_dup_index, ]
View(ks_lat_long_dup)


View(ks_no_dup_API_or_cI)



# calling it the final thesis data
ks_final_thesis_data <- ks_no_dup_api_or_ci
save(ks_final_thesis_data, file = "ks_final_thesis_data.rdata")
View(ks_final_thesis_data)


table(ks_final_thesis_data$swd_inj_ci,ks_final_thesis_data$activity)
table(ks_final_thesis_data$other,ks_final_thesis_data$swd_inj_ci)
 
ks_set_for_mapping <- ks_final_thesis_data[,c("KID","API_NUMBER_SIMPLE","LATITUDE","LONGITUDE","swd_inj_ci")]
# View(ks_set_for_mapping)
write.csv2(ks_set_for_mapping, file = "ks_set_for_mapping.csv")



# import mapping results back
ks_join_results <- read.csv(file = "well_join_2018_10_30.txt",stringsAsFactors = FALSE)
# View(ks_join_results)
save(ks_join_results, file = "ks_join_results.rdata")
#
# # load needed files if starting from here
load(file = "ks_final_thesis_data.rdata")
load(file = "ks_join_results.rdata")
 

ks_join_to_edit <- ks_join_results
ks_join_to_edit$API_NUMBER <- NULL
ks_join_to_edit$LATITUDE <- NULL
ks_join_to_edit$LONGITUDE <- NULL
ks_join_to_edit$swd_inj_ci <- NULL
ks_join_to_edit$Join_Count <- NULL
ks_join_to_edit$OBJECTID_1 <- NULL
ks_join_to_edit$TARGET_FID <- NULL
 
ks_wells_and_block_groups <- merge(x = ks_final_thesis_data, y = ks_join_to_edit, by = "KID", all.x = TRUE)
View(ks_wells_and_block_groups)

# currently active classification
ks_wells_and_block_groups$current_active <- NA

# use status
ks_wells_and_block_groups  <-  within(ks_wells_and_block_groups, current_active[STATUS == "INJ-P&A" | STATUS == "OTHER-P&A(CLASS ONE (OLD))" | STATUS == " OTHER-P&A(INJ OR )" | STATUS == " OTHER-P&A(INJ or EOR)" | STATUS == "OTHER-P&A(OIL-SWD)" | STATUS == " OTHER-P&A(TA)" | STATUS == "SWD-P&A"]  <-  'plugged_abandoned')

# use presence of plugged date
ks_wells_and_block_groups  <-  within(ks_wells_and_block_groups, current_active[!is.na(plugging_as_date)]  <-  'plugged_abandoned')

# make rest active
ks_wells_and_block_groups$current_active[is.na(ks_wells_and_block_groups$current_active)]  <-  "presumed_active"
View(ks_wells_and_block_groups)

ks_wells_and_block_groups$swd <- 1

ks_well_counts <- aggregate (ks_wells_and_block_groups$swd~GEOID_Data,ks_wells_and_block_groups,sum)
View(ks_well_counts)

# rename GEOID_Data to GEOID in well data
ks_well_counts$GEOID <- ks_well_counts$GEOID_Data
save(ks_well_counts, file = "ks_well_counts.rdata")
load(file = "ks_well_counts.rdata")
 
# load ACS variables
load(file = "ACS_constructed_variables.rdata")
View(ACS_constructed_variables[,201:291])

# # limit ks block groups to ks
# ks_acs <- ACS_constructed_variables[which(ACS_constructed_variables$STATEFP=='20'),]
# save(ks_acs, file = "ks_acs.rdata")
load(file = "ks_acs.rdata")

# merge well counts and acs!  hey-o!
KS_FINAL_DATASET <- merge(ks_well_counts, ks_acs, by = "GEOID", all = TRUE)
View(KS_FINAL_DATASET)
save(KS_FINAL_DATASET, file = "KS_FINAL_DATASET.rdata")
write.csv(KS_FINAL_DATASET, file = "KS_FINAL_DATASET.csv")


#### Analyses! ####

# load files if starting from here
load(file = "KS_FINAL_DATASET.rdata")
ks_analysis_dataset <- KS_FINAL_DATASET
View(ks_analysis_dataset)

#### swd well block groups only ####

# make variable for sum of swd wells per block group
ks_analysis_dataset$any_swd_sum <- ks_analysis_dataset[,c("ks_wells_and_block_groups$swd")]
str(ks_analysis_dataset$any_swd_sum)
ks_analysis_dataset <- within(ks_analysis_dataset,any_swd_sum[is.na(ks_analysis_dataset$any_swd_sum)] <- 0)
ks_analysis_dataset[,c("ks_wells_and_block_groups$swd")] <- NULL
View(ks_analysis_dataset)

sum(ks_analysis_dataset$any_swd_sum)


# make new binary variable for have versus not have swd
ks_analysis_dataset$any_swd_binary <- NA
ks_analysis_dataset <- within(ks_analysis_dataset, any_swd_binary[any_swd_sum == 0] <- 'no')
ks_analysis_dataset <- within(ks_analysis_dataset, any_swd_binary[any_swd_sum > 0] <- 'yes')
table(ks_analysis_dataset$any_swd_binary)

names(ks_analysis_dataset)

# drop 12 without people
ks_analysis_dataset <- ks_analysis_dataset %>%
  filter(population_density_B01001_ALAND > 0)

#### correlation matrix of ACS variables ####
names(ks_analysis_dataset) # get variable names

# make dataframe for the correlation dataset
correlation_matrix_data  <-  ks_analysis_dataset[,c("median_household_income_B19013","median_household_value_B25077","percent_white_B03002","population_density_B01001_ALAND","percent_high_school_plus_B15003","median_age_B01002","any_swd_sum","any_swd_binary","GEOID_simple")]

# create the correlation matrix
correlation_matrix  <-  round(cor(correlation_matrix_data[,1:6], use = "pairwise.complete.obs"),2) # rounds to 2 decimal places

# view and write to file
View(correlation_matrix)
write.csv(correlation_matrix, file = "correlation_matrix.csv")

# count observations going into the correlation matrix
counts_pairwise_correlations  <-  count.pairwise(correlation_matrix_data[,1:6], y = NULL,diagonal=TRUE)

# view and write to file
View(counts_pairwise_correlations)
write.csv(counts_pairwise_correlations, file = "counts_pairwise_correlations.csv")


#### checking normality ####

par(mfrow=c(2,2))

# income
density_hh_income <- density(ks_analysis_dataset$median_household_income_B19013, na.rm = TRUE)
plot(density_hh_income, main = "Median Household Income Density Plot")

density_household_value <- density(ks_analysis_dataset$median_household_value_B25077, na.rm = TRUE)
plot(density_household_value, main = "Median Household Value Density Plot")

density_percent_white <- density(ks_analysis_dataset$percent_white_B03002, na.rm = TRUE)
plot(density_percent_white, main = "Percent White Density Plot")

density_pop_density <- density(ks_analysis_dataset$population_density_B01001_ALAND, na.rm = TRUE)
plot(density_pop_density, main = "Population Density Density Plot")

density_percent_high_school <- density(ks_analysis_dataset$percent_high_school_plus_B15003, na.rm = TRUE)
plot(density_percent_high_school, main = "Percent Completed High School Density Plot")

density_median_age <- density(ks_analysis_dataset$median_age_B01002, na.rm = TRUE)
plot(density_median_age, main = "Median Age Density Plot")

density_swd <- density(ks_analysis_dataset$any_swd_sum, na.rm = TRUE)
plot(density_swd, main = "Number of Disposal Wells per Block Group Density Plot")






#### analysis by presence and absence of swd ####
# number of block groups with and without swd wells
table(ks_analysis_dataset$any_swd_binary)



## median household income
# median
aggregate(median_household_income_B19013~any_swd_binary, data=ks_analysis_dataset, FUN=median)
median(ks_analysis_dataset$median_household_income_B19013, na.rm = TRUE)

# interquartile range
aggregate(median_household_income_B19013~any_swd_binary, data=ks_analysis_dataset, FUN=quantile)
quantile(ks_analysis_dataset$median_household_income_B19013, na.rm = TRUE)

# missings
table(is.na(ks_analysis_dataset$median_household_income_B19013))
aggregate(median_household_income_B19013~any_swd_binary, data=ks_analysis_dataset, FUN=length)

# t test
t.test(ks_analysis_dataset$median_household_income_B19013[ks_analysis_dataset$any_swd_binary=="yes"], ks_analysis_dataset$median_household_income_B19013[ks_analysis_dataset$any_swd_binary=="no"])


## median household value
# median
aggregate(median_household_value_B25077~any_swd_binary, data=ks_analysis_dataset, FUN=median)
median(ks_analysis_dataset$median_household_value_B25077, na.rm = TRUE)

# interquartile range
aggregate(median_household_value_B25077~any_swd_binary, data=ks_analysis_dataset, FUN=quantile)
quantile(ks_analysis_dataset$median_household_value_B25077, na.rm = TRUE)

# missings
table(is.na(ks_analysis_dataset$median_household_value_B25077))
aggregate(median_household_value_B25077~any_swd_binary, data=ks_analysis_dataset, FUN=length)

# t test
t.test(ks_analysis_dataset$median_household_value_B25077[ks_analysis_dataset$any_swd_binary=="yes"], ks_analysis_dataset$median_household_value_B25077[ks_analysis_dataset$any_swd_binary=="no"])


## percent white
# median
aggregate(percent_white_B03002~any_swd_binary, data=ks_analysis_dataset, FUN=median)
median(ks_analysis_dataset$percent_white_B03002, na.rm = TRUE)

# interquartile range
aggregate(percent_white_B03002~any_swd_binary, data=ks_analysis_dataset, FUN=quantile)
quantile(ks_analysis_dataset$percent_white_B03002, na.rm = TRUE)

# missings
table(is.na(ks_analysis_dataset$percent_white_B03002))
aggregate(percent_white_B03002~any_swd_binary, data=ks_analysis_dataset, FUN=length)

# t test
t.test(ks_analysis_dataset$percent_white_B03002[ks_analysis_dataset$any_swd_binary=="yes"], ks_analysis_dataset$percent_white_B03002[ks_analysis_dataset$any_swd_binary=="no"])


## population density
# median
aggregate(population_density_B01001_ALAND~any_swd_binary, data=ks_analysis_dataset, FUN=median)
median(ks_analysis_dataset$population_density_B01001_ALAND, na.rm = TRUE)

# interquartile range
aggregate(population_density_B01001_ALAND~any_swd_binary, data=ks_analysis_dataset, FUN=quantile)
quantile(ks_analysis_dataset$population_density_B01001_ALAND, na.rm = TRUE)

# missings
table(is.na(ks_analysis_dataset$population_density_B01001_ALAND))

# t test
t.test(ks_analysis_dataset$population_density_B01001_ALAND[ks_analysis_dataset$any_swd_binary=="yes"], ks_analysis_dataset$population_density_B01001_ALAND[ks_analysis_dataset$any_swd_binary=="no"])


## percent high school or more
# median
aggregate(percent_high_school_plus_B15003~any_swd_binary, data=ks_analysis_dataset, FUN=median)
median(ks_analysis_dataset$percent_high_school_plus_B15003, na.rm = TRUE)

# interquartile range
aggregate(percent_high_school_plus_B15003~any_swd_binary, data=ks_analysis_dataset, FUN=quantile)
quantile(ks_analysis_dataset$percent_high_school_plus_B15003, na.rm = TRUE)

# missings
table(is.na(ks_analysis_dataset$percent_high_school_plus_B15003))
aggregate(percent_high_school_plus_B15003~any_swd_binary, data=ks_analysis_dataset, FUN=length)

# t test
t.test(ks_analysis_dataset$percent_high_school_plus_B15003[ks_analysis_dataset$any_swd_binary=="yes"], ks_analysis_dataset$percent_high_school_plus_B15003[ks_analysis_dataset$any_swd_binary=="no"])


## median age
# median
aggregate(median_age_B01002~any_swd_binary, data=ks_analysis_dataset, FUN=median)
median(ks_analysis_dataset$median_age_B01002, na.rm = TRUE)

# interquartile range
aggregate(median_age_B01002~any_swd_binary, data=ks_analysis_dataset, FUN=quantile)
quantile(ks_analysis_dataset$median_age_B01002, na.rm = TRUE)

# missings
table(is.na(ks_analysis_dataset$median_age_B01002))
aggregate(median_age_B01002~any_swd_binary, data=ks_analysis_dataset, FUN=length)

# t test
t.test(ks_analysis_dataset$median_age_B01002[ks_analysis_dataset$any_swd_binary=="yes"], ks_analysis_dataset$median_age_B01002[ks_analysis_dataset$any_swd_binary=="no"])



#### Poisson
poisson_model <- glm(formula = any_swd_sum ~ median_household_value_B25077 + percent_white_B03002 + population_density_B01001_ALAND + percent_high_school_plus_B15003 + median_age_B01002, family = "poisson", data = ks_analysis_dataset)
summary(poisson_model)

poisson_model <- glm(formula = any_swd_sum ~ median_household_income_B19013 + median_household_value_B25077 + percent_white_B03002 + population_density_B01001_ALAND + percent_high_school_plus_B15003 + median_age_B01002, family = "poisson", data = ks_analysis_dataset)
summary(poisson_model)
confint(poisson_model)

ks_analysis_dataset <- within(ks_analysis_dataset, any_swd_binary[ks_analysis_dataset$any_swd_binary == "yes"]  <-  1)
ks_analysis_dataset <- within(ks_analysis_dataset, any_swd_binary[ks_analysis_dataset$any_swd_binary == "no"]  <-  0)
View(ks_analysis_dataset$any_swd_binary)
ks_analysis_dataset$any_swd_binary <- as.numeric(ks_analysis_dataset$any_swd_binary)
View(ks_analysis_dataset$any_swd_binary)

#### logistic model r
logistic_model <- glm(formula = any_swd_binary ~ median_household_income_B19013 + median_household_value_B25077 + percent_white_B03002 + population_density_B01001_ALAND + percent_high_school_plus_B15003 + median_age_B01002, family = "binomial", data = ks_analysis_dataset)
summary(logistic_model)
confint(logistic_model)




write.csv(ks_analysis_dataset, file = "ks_analysis_dataset.csv")