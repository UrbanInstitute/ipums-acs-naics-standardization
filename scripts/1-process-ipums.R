# File to read in and process IPUMS data for standardization

# Load required libraries -------------------------------------------------

library(ipumsr)
library(tidyverse)
library(testit)

# Read in data ------------------------------------------------------------

ddi <- read_ipums_ddi("data/ipums/usa_00041.xml")
ipums <- read_ipums_micro(ddi)

# Check NAICS codes are the same ------------------------------------------

ind_post2018 <- ipums %>%
  filter(MULTYEAR > 2017) %>%
  distinct(IND, INDNAICS) %>%
  rename(post = INDNAICS)
ind_pre2018 <- ipums %>%
  filter(MULTYEAR < 2018) %>%
  distinct(IND, INDNAICS) %>%
  rename(pre = INDNAICS)
ind_all <- ind_post2018 %>%
  full_join(ind_pre2018, by = "IND") %>%
  mutate(test = ifelse(pre == post, 1, 0))
assert(nrow(ind_all) == sum(ind_all$test))


