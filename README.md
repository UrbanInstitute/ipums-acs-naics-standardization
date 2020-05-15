# Standardizing BLS CES NAICS to IPUMS ACS NAICS codes

This repository attempts to join BLS CES data to 2014-18 IPUMS ACS data for the purposes of estimating PUMA level and higher job losses, and other estimates using ACS data to do so. 

Data are organized in the `data` directory and programs in the `scripts` directory. Extracts from IPUMS should be sure to include the `INDNAICS` variable, and both the DDI file `usa_xxxxx.xml` and the data file should be placed in the `data/ipums` folder.

## Standardizing CES and IPUMS ACS NAICS codes

