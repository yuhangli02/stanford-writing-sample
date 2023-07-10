#import required libraries
library(tidyverse)
library(knitr)

#load national and illinois state data 
national_revenue <- read_csv("forfeit_raw/National_Revenue/National_Revenue.csv")
national_expense <- read_csv("forfeit_raw/National_Expense/National Expense.csv")
illinois_revenue <- read_csv("forfeit_raw/State_Revenue/ILrevenue.csv")
illinois_expense <- read_csv("forfeit_raw/State_Expense/ILexpense.csv")

#clean national revenue data  
national_rev_cleaned <- national_revenue %>% 
    rename("state" = "STATE",
           "revenue_id" = "RevenueID",
           "year" = "YEAR",
           "unit_type" = "UNIT_TYPE",
           "prop_type" = "PROP_TYPE",
           "rev" = "REV",
           "procd_type" = "PROCD_TYPE",
           "conviction" = "CONV_TYPE",
           "case_id" = "CASE_NO") %>% 
    #create logical column for conviction outcome 
    mutate(conviction = if_else(conviction == "conviction", 1, 0)) %>% 
    #change all values of property type to lowercase 
    mutate(prop_type = tolower(prop_type))          

#clean national expense data
national_exp_cleaned <- national_expense %>% 
  rename("expense_id" = "ExpenseID",
         "year" = "Year",
         "exp_type" = "EXP_TYPE",
         "exp_amt" = "EXP_AMT",
         "state" = "State")

#join state level data for Illinois 
IL_joined <- illinois_revenue %>% 
  left_join(illinois_expense, by = "ID")

#clean joined data 
illinois_cleaned <- IL_joined %>%
  #select necessary variables
  select(ID, IL_Agency, IL_Total_Amt_Forfeited, IL_Total_Nbr_of_Forfeitures, IL_Share, IL_Agency_Share, PROP_TYPE, PROCD_TYPE, YEAR, EXP_AMT, EXP_TYPE) %>% 
  #rename variables
  rename("id" = "ID",
         "agency" = "IL_Agency",
         "total_amt_forfeited" = "IL_Total_Amt_Forfeited",
         "nbr_forfeit" = "IL_Total_Nbr_of_Forfeitures",
         "state_share" = "IL_Share",
         "agency_share" = "IL_Agency_Share",
         "prop_type" = "PROP_TYPE",
         "procd_type" = "PROCD_TYPE",
         "year" = "YEAR",
         "exp_amt" = "EXP_AMT",
         "exp_type" = "EXP_TYPE") 


#export cleaned data sets 
national_rev_cleaned %>% 
  write_csv("forfeit_cleaned/national_rev_cleaned.csv")
national_exp_cleaned %>% 
  write_csv("forfeit_cleaned/national_exp_cleaned.csv")
illinois_cleaned %>% 
  write_csv("forfeit_cleaned/IL_cleaned.csv")            


