# Script to take manual xlsx file crosswalk and output to clean
# machine readable CSV

# Import libraries --------------------------------------------------------

library(tidyverse)
library(readxl)

# Read data ---------------------------------------------------------------

manual <- read_excel("data/manual-files/2017-industry-code-list-ces-crosswalk-manual.xlsx",
                     sheet = "2017 Census Industry Code List",
                     skip = 2)


# Transform to tidy format ------------------------------------------------

# Remove unnecessary columns and rows
manual_un <- manual %>%
  rename(IND = `2017 Census Code`,
         naics = `2017 NAICS Code`,
         ces_code = `BLS CES Industry_code`,
         led_code = `NAICS_2_Digit`) %>%
  select(IND, naics, ces_code, led_code) %>%
  drop_na(IND) %>%
  mutate(ces_code = na_if(ces_code, "N/A")) %>%
  filter(str_length(IND) == 4) 

# Convert forumulas to tidy data

# Single codes
manual_single <- manual_un %>%
  filter(str_length(ces_code) == 8 | is.na(ces_code)) %>%
  mutate(formula_type = "single")

# Formulas
manual_formula <- manual_un %>%
  filter(str_length(ces_code) != 8)

# Function to get formula rules using regular expressions, return tidy
# dataframe for each formula rule.
# INPUT: IND to select from manual_formula
# OUTPUT: Tibble of multiple rows, one for each ces_code
tidy_formulas <- function(ind_select){
  df_slice <- manual_formula %>%
    filter(IND == ind_select)
  formula <- df_slice %>% select(ces_code) %>% pull()
  ces_codes <- str_split(formula, "[+|-]")[[1]]
  operators <- c("+", str_extract_all(formula, "[-|+]")[[1]])
  tidy_convert <- tibble(ces_code = ces_codes,
                         operator = operators)
  ind_val <- df_slice %>% select(IND) %>% pull()
  naics_val <- df_slice %>% select(naics) %>% pull()
  led_val <- df_slice %>% select(led_code) %>% pull()
  tidy_convert %>%
    mutate(IND = ind_val,
           naics = naics_val,
           led_code = led_val,
           formula_type = "formula")
}

# Apply to each data slice and create a new dataframe
manual_reformat <- map(manual_formula$IND, tidy_formulas) %>%
  bind_rows()

# Bind rows together
manual_all <- manual_single %>%
  bind_rows(manual_reformat)

# Analyze CES recency, add variable ---------------------------------------

# read in data and filter to work with easily
ces <- read_tsv("data/ces/ces_all.txt") 

ces_filter <- ces %>%
  mutate(month = as.numeric(gsub("M", "", period))) %>%
  filter(year == max(year)) %>%
  mutate(series = substr(series_id,1,3),
         ces_code = substr(series_id,4,11),
         series_type = substr(series_id,12,13)) %>%
  filter(series == "CES",
         series_type == "01")

# Calculate recency relative to max month for each series
max_month <- max(ces_filter$month)

recency <- ces_filter %>%
  group_by(ces_code) %>%
  filter(month == max(month)) %>%
  ungroup() %>%
  mutate(recency = max_month - month) %>%
  select(series_id, ces_code, recency)

# Add parent with 0 recency as column to dataframe for recency == 1
need_parent <- recency %>%
  filter(recency == 1)
is_parent <- recency %>%
  filter(recency == 0)

# Function that replace the last non zero digit with 0s
# Input: 
#   - cstring, the string
#   - nz, non zero digits at the end of the string to replace
# Output: string with digits at the end replaced with 0s
replace_zeroes <- function(cstring, nz){
  end <- substr(cstring, length(cstring) - 1, length(cstring))
  while (end == "0"){
    cstring <- substr(cstring, 1, length(cstring) - 1)
    end <- substr(cstring, length(cstring) - 1, length(cstring))
  }
  rep_str <- substr(cstring, 1, str_length(cstring) - nz)
  str_pad(rep_str, 8, "right", pad = "0")
}

# Function to take ces_code and replace last digit that's not a 0 with
# a zero, look for recency, repeat until parent is found, return id
# Input: ces_code
# Output: ces_code with recency == 0
get_parent <- function(code_ces){
  found_parent <- FALSE
  num_zeroes <- 1
  while (found_parent == FALSE){
    test_ces <- replace_zeroes(code_ces, num_zeroes)
    test_filter <- is_parent %>%
      filter(ces_code == test_ces) %>%
      nrow()
    if (test_filter > 0){ found_parent = TRUE }
    num_zeroes <- num_zeroes + 1
  }
  test_ces
}

# Assign parents to existing datasets
get_parents <- need_parent %>%
  mutate(parent = ces_code %>%
           map_chr(get_parent))

# Bind data together
all_parents <- is_parent %>%
  bind_rows(get_parents)

# Add variables to tidy dataframe and write out
tidy_recency <- manual_all %>%
  left_join(all_parents, by = "ces_code") %>%
  mutate(parent_series_id = ifelse(is.na(parent), 
                  NA,
                  str_glue("CES{parent}01"))) %>%
  write_csv("data/processed-data/2017-ind-ces-crosswalk.csv")
  
