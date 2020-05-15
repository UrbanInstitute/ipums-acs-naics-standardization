# Standardizing BLS CES NAICS to IPUMS ACS NAICS codes

This repository attempts to join BLS CES data to 2014-18 IPUMS ACS data for the purposes of estimating PUMA level and higher job losses, and other estimates using ACS data to do so. This relies on 2017 NAICS definitions, and thus has two parts:

- Standardizing IPUMS ACS 2017 and previous years to 2018 IPUMS ACS INDNAICS definitions, which use 2017 NAICS definitions, while previous years use previous definitions
- Standardizing and summarizing NAICS code definitions between the ACS and CES

Data are organized in the `data` directory and programs in the `scripts` directory. Extracts from IPUMS should be sure to include the `INDNAICS` variable, and both the DDI file `usa_xxxxx.xml` and the data file should be placed in the `data/ipums` folder.

## Standardizing IPUMS NAICS codes



## Standardizing CES and IPUMS ACS NAICS codes

