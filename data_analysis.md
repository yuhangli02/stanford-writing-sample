Data Analysis for Profit from Policing : Allocation of Civil Asset
Forfeiture Funds
================
Yuhang Li
7/10/2023

``` r
#load required packages 
library(tidyverse)
library(knitr)
library(scales)
library(huxtable)
```

``` r
#load cleaned data sets 
national_rev <- read.csv("forfeit_cleaned/national_rev_cleaned.csv")
national_exp <- read.csv("forfeit_cleaned/national_exp_cleaned.csv")
IL_cleaned <- read_csv("forfeit_cleaned/IL_cleaned.csv", show_col_types = FALSE)  
```

``` r
#check data sets 
head(national_rev)
```

       ┌─────────────────────────────────────────────────────────────────
       │ state   revenue_   year   unit_typ   prop_typ   rev   procd_ty  
       │               id          e          e                pe        
       ├─────────────────────────────────────────────────────────────────
       │ AR           951   2018   OTHER                                 
       │ AR           952   2018   OTHER                                 
       │ AR           953   2018   OTHER                                 
       │ AR           954   2018   OTHER                                 
       │ AR           955   2018   OTHER                                 
       │ AR           956   2018   OTHER                                 
       └─────────────────────────────────────────────────────────────────

Column names: state, revenue_id, year, unit_type, prop_type, rev,
procd_type, conviction, case_id

7/9 columns shown.

``` r
head(national_exp)
```

             ┌────────────────────────────────────────────────────┐
             │ expense_id   year   exp_type       exp_amt   state │
             ├────────────────────────────────────────────────────┤
             │        121   2017   court costs      10941   FL    │
             │        122   2017   outside           1572   FL    │
             │                     services                       │
             │        123   2017   court costs       2450   FL    │
             │        124   2017   outside            610   FL    │
             │                     services                       │
             │        125   2018   outside            668   FL    │
             │                     services                       │
             │        126   2017   travel and         500   FL    │
             │                     training                       │
             └────────────────────────────────────────────────────┘

Column names: expense_id, year, exp_type, exp_amt, state

``` r
glimpse(IL_cleaned)
```

    ## Rows: 98,153
    ## Columns: 12
    ## $ id             <dbl> 9472, 9473, 9474, 9475, 9476, 9477, 9478, 9479, 9480, 9…
    ## $ agency         <chr> "CHICAGO POLICE DEPARTMENT", "OLYMPIA FIELDS POLICE DEP…
    ## $ revenue        <dbl> 7613272, 196, 3667, 6700, 2157, 2167, 4629, 20076, 100,…
    ## $ nbr_forfeit    <dbl> 5414, 1, 3, 1, 1, 1, 2, 6, 1, 1, 2, 1, 10, 4, 1, 5, 1, …
    ## $ state_share    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
    ## $ agency_share   <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
    ## $ prop_type      <chr> "currency", "currency", "currency", "vehicles", "curren…
    ## $ procd_type     <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
    ## $ year           <dbl> 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2…
    ## $ exp_amt        <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
    ## $ exp_type       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
    ## $ exp_proportion <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…

# Part 1: National level data

## Plot number of civil asset forfeiture cases per year

``` r
#plot number of civil asset forfeiture cases over years using line graph 
forfeit_nb_years <- national_rev %>% 
  ggplot(mapping = aes(x = year)) +
  geom_freqpoly(color = "#144a74") +
  labs(title = "Number of civil asset forfeiture cases over time",
       x = "Year",
       y = "Number of civil asset forfeiture cases") + 
  theme_classic()   
forfeit_nb_years 
```

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](data_analysis_files/figure-gfm/cases%20per%20year-1.png)<!-- -->

## Analyze the trend of average revenue from civil asset forfeiture funds from 1986 to 2019

``` r
#plot a bar graph of average revenue over years 
avg_rev_year <- national_rev %>% 
  group_by(year) %>% 
  summarize(avg_rev = mean(rev, na.rm = TRUE)) %>% 
  ggplot(mapping = aes(x = year, y = avg_rev)) +
  geom_bar(stat = "identity", fill = "#144a74") +
  labs(title = "Average revenue from civil asset forfeiture (1986 - 2019)",
       x = "Year",
       y = "Average revenue in U.S. dollars") +
  theme_classic()
avg_rev_year 
```

![](data_analysis_files/figure-gfm/average%20revenue%20per%20year-1.png)<!-- -->

## Analyze the proportion of total expenditure for each expenditure type

``` r
#write a function to find proportion of total expenditure for each expenditure type 
exp_prop <- function(dataset) {
  exp_prop_calc <- dataset %>% 
    #filter by positive expenditure values 
    filter(exp_type != "NA" & exp_amt > 0) %>%
    group_by(exp_type) %>% 
    summarize(total_exp = sum(exp_amt)) %>% 
    #calculate proportion of total expenditure 
    mutate(exp_pct = total_exp / sum(total_exp))
  return(exp_prop_calc)
}

#find proportion of national expenditure 
national_exp_type <- exp_prop(national_exp)

#plot proportion of total expenditure by type of expenditure
exp_type_bar <- national_exp_type %>% 
  ggplot(aes(x = reorder(exp_type, exp_pct), y = exp_pct, fill = exp_type)) +
  geom_bar(stat = "identity") +
  coord_flip() + 
  scale_fill_brewer(palette = "Set3") +
  labs(title = "Proportion of forfeiture expenditure by expenditure type",
       x = "Proportion of total expenditure",
       y = "Expenditure Type",
       fill = "Expenditure Type") +
  theme_classic()
exp_type_bar
```

![](data_analysis_files/figure-gfm/proportion%20of%20total%20exp-1.png)<!-- -->

## Find the percentage of civil asset forfeitures involving individuals convicted with crime, grouped by property type

``` r
#find proportion of cases with positive convicted outcome by property type 
percent_convicted <- national_rev %>%
  group_by(prop_type) %>% 
  summarize(percent_con = mean(conviction, na.rm = TRUE)) %>% 
  filter(prop_type != "NA") %>% 
  arrange(desc(percent_con))

#format as table 
percent_convicted %>% 
  #convert to percentage 
  mutate(percent_con = percent(percent_con, accuracy = 0.01)) %>% 
  kable(caption = "Percentage of civil asset forfeitures with convicted outcomes",
        col.names = c("Property type",
                      "Percent convicted after seizure")
  )      
```

| Property type | Percent convicted after seizure |
|:--------------|:--------------------------------|
| other         | 17.84%                          |
| real property | 17.07%                          |
| currency      | 5.19%                           |
| vehicles      | 4.95%                           |

Percentage of civil asset forfeitures with convicted outcomes

## Find the top 10 and bottom 10 states that had the most and least civil asset forfeitures cases

``` r
#find number of cases per state 
cases_per_state <- national_rev %>% 
  group_by(state) %>% 
  summarize(count = n()) %>% 
  filter(count > 60) %>% 
  arrange(desc(count)) 

#find top 10 states with most cases
top_10 <- cases_per_state %>% 
  head(10)

#find bottom 10 states with least cases
bottom_10 <- cases_per_state %>% 
  tail(10)

#combine the two groups
combined_states <- rbind(top_10, bottom_10)

#differentiate the two groups
combined_states$group <- if_else(combined_states$state %in%
                                   top_10$state,
                                 "Top 10",
                                 "Bottom 10")

#plot bargraph 
forfeit_rank_states <- combined_states %>% 
  ggplot(mapping = aes(x = reorder(state, count), y = count, fill = group)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_manual(values = c("Top 10" = "#599e94",
                               "Bottom 10" = "#d2980d")) +
  labs(title = "Civil asset forfeiture cases 1986 - 2019",
       subtitle = "States that had most and least number of cases",
       x = "Number of civil asset forfeiture cases",
       y = "State",
       fill = "Group") + 
  theme_classic()

#print bargraph 
forfeit_rank_states       
```

![](data_analysis_files/figure-gfm/most%20and%20least%20cases-1.png)<!-- -->

# Part 2 : Illinois Data

## Summary statistics

``` r
#select column names for which summary statistics will be calculated 
selected_cols <- c("revenue", "exp_amt", "agency_share") 

#create for loop to calculate summary statistics 
summary_stats <- list()
for (col in selected_cols) {
  column_summary <- summary(IL_cleaned[[col]], na.rm = TRUE)
  summary_stats[[col]] <- column_summary    
}

#format the three sets of summary statistics into a table 
summary_table <- hux(Variable = c("revenue", "expenditure", "agency share"),
                     Min = c(0, 0, 0),
                     Q1 = c(278, 0, 64.2),
                     Median = c(714, 0, 175),
                     Q3 = c(2094, 0, 538.4),
                     Max = c(17396274, 3189760, 86450)) %>% 
  set_all_padding(4) %>%
  set_outer_padding(0) %>%
  set_number_format(0) %>%
  set_bold(row = 1, col = everywhere) %>%
  set_bottom_border(row = 1, col = everywhere) %>%
  set_width(0.4) %>%
  set_caption("Summary statistics for revenue, expenditure, and agency share")

#print table 
summary_table
```

         Summary statistics for revenue, expenditure, and agency share          
               Variable     Min    Q1   Median     Q3        Max  
             ─────────────────────────────────────────────────────
               revenue        0   278      714   2094   17396274  
               expenditur     0     0        0      0    3189760  
               e                                                  
               agency         0    64      175    538      86450  
               share                                              

Column names: Variable, Min, Q1, Median, Q3, Max

## Trend of IL average revenue per year from 2000 to 2019

``` r
#find average revenue per year
IL_avg <- IL_cleaned %>% 
  #remove outlier 
  filter(year != "2009") %>% 
  group_by(year) %>% 
  summarize(avg_rev = mean(revenue, na.rm = TRUE))

#plot a line graph of average revenue over the years in data 
IL_avg_rev <- IL_avg %>% 
  ggplot(mapping = aes(x = year, y = avg_rev)) +
  geom_freqpoly(stat = "identity", color = "#144a74") +
  labs(title = "Average revenue from IL civil asset forfeiture (2000 - 2019)",
       x = "Year",
       y = "Average revenue in U.S. dollars") +
  theme_classic()

IL_avg_rev
```

![](data_analysis_files/figure-gfm/average%20revenue%20IL-1.png)<!-- -->

## Boxplot of average revenue by property type

``` r
#plot a boxplot of forfeiture revenue by property type 
IL_rev_property <- IL_cleaned %>% 
  filter(prop_type != "NA" & revenue < 5000) %>% 
  ggplot(mapping = aes(x = prop_type, y = revenue)) +
  geom_boxplot() +
  labs(title = "Revenue by type of property",
       x = "Property type",
       y = "Revenue") +
  coord_flip() +
  theme_classic()
IL_rev_property   
```

![](data_analysis_files/figure-gfm/boxplot%20rev-1.png)<!-- -->

Since distribution of variables are highly skewed, analysis of
expenditure is better done by calculating the proportion of total
expenditure of each type of expense and visualizing the results in a pie
chart.

## Pie chart to analyze proportion of total expenditure by expenditure type

\`

``` r
#use previously created function to compute proportion of total expenditure
IL_exp_type <- exp_prop(IL_cleaned)

#create a pie chart to show the proportion of total expenditure occupied by each 
#expenditure type 
IL_exp_type_pie <- IL_exp_type %>% 
  ggplot(aes(x = "", y = exp_pct, fill = exp_type)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y") +
  scale_fill_brewer(palette = "Set2") +
  theme_classic() +
  labs(title = "Proportion of total expenditure by type",
       x = NULL,
       y = NULL,
       fill = "Type of Expenditure")
IL_exp_type_pie
```

![](data_analysis_files/figure-gfm/exp%20by%20type%20IL-1.png)<!-- -->
