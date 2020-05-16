# Script to take manual xlsx file crosswalk and output to clean
# machine readable CSV

# Import libraries --------------------------------------------------------

library(tidyverse)
library(readxl)

# Read data ---------------------------------------------------------------

manual <- read_excel("data/manual-files/2017-industry-code-list-ces-crosswalk-manual.xlsx",
                     sheet = "2017 Census Industry Code List",
                     skip = 2)

# Transform and write to CSV ----------------------------------------------

# Remove unnecessary columns and rows
manual_un <- manual %>%
  rename(IND = `2017 Census Code`,
         naics = `2017 NAICS Code`,
         ces_code = `BLS CES Industry_code`) %>%
  select(IND, naics, ces_code) %>%
  drop_na(IND) %>%
  mutate(ces_code = na_if(ces_code, "N/A")) %>%
  filter(str_length(IND) == 4) %>%
  write_csv("data/processed-data/2017-ind-ces-crosswalk.csv")
  
