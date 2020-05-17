# Standardizing BLS CES NAICS to IPUMS ACS NAICS codes

This repository attempts to join BLS CES data to 2014-18 IPUMS ACS data for the purposes of estimating PUMA level and higher job losses, and other estimates using ACS data to do so. 

Data are organized in the `data` directory and programs in the `scripts` directory. Extracts from IPUMS should be sure to include the `INDNAICS` variable, and both the DDI file `usa_xxxxx.xml` and the data file should be placed in the `data/ipums` folder.

## Standardizing CES and IPUMS ACS NAICS codes

We went through a manual process to standardize the codes. You can find our decisions and notes on the decisions in this Excel document: https://github.com/UI-Research/ipums-acs-naics-standardization/blob/master/data/manual-files/2017-industry-code-list-ces-crosswalk-manual.xlsx. You can find the machine readable CSV used for analysis here: https://github.com/UI-Research/ipums-acs-naics-standardization/blob/master/data/processed-data/2017-ind-ces-crosswalk.csv.

Be careful when using this dataset. It can be thought of as an instruction manual, where each row is a unique `ces_code`, `ind` combination. Values are meant to be operated on at the `ces_code` level, summarized up to the `IND` level. The variables produced are as follows:

- `IND`: 4-digit ACS Industry classification.
- `naics`: NAICS classification per ACS provided crosswalk.
- `ces_code`: The 8-digit CES series code from BLS.
- `led_code`: The 2-digit NAICS code.
- `formula_type`: 
	- `single` denotes no formula, just one `ces_code` for the `IND`
	- `formula` denotes a formula for using multiple `ces_code` to summarize at the `IND` level, with the formula provided by `operator`
- `operator`: `+` or `-` values denote addition or subtraction necessary to summarize at the `IND` level. E.g., `32311100` `+` and `32311200` `+` for `IND = 1070` means that to summarize to `IND = 1070`, you should add `ces_code` `32311100` to `32311200`.
- `series_id`: The `series_id` column from the CES data corresponding to `ces_code` that should be pulled for seasonally adjusted total employment.
- `recency`: The number of months this particular `series_id` lags behind the most recent CES data release. `1` means that, for example, when April data are released, that `series_id` is just releasing new March data, so it is 1 month behind.
- `parent`: The parent `ces_code` for rows where `recency = 1` that provide industry categories that contain the `ces_code` in question, but are more broad, and have `recency = 0`. This column is for helping adjust `ces_code` with `recency = 1` to the current month using imputation from the broader category.
- `parent_series_id`: The `series_id` column from the CES data corresponding to `parent` that should be pulled for seasonally adjusted total employment.

# Running a test using CES national job loss

Next, we pull CES national figures from February and April by detailed category to derive job losses by category. We then use February counts of employment from CES national figures and apply the crosswalk to calculate mix for industries in IPUMS that represent combinations of CES categories, which is our bigget issue to solve for. We also create any necessary residual categories as specified in the crosswalk as part of this process. For example, if an IPUMS industry represents the combination of two industries, job loss for the IPUMS industry is:

`(emp_ces_industry1 * job_loss_ces_industry1 + emp_ces_industry2 * job_loss_ces_industry2) / (emp_ces_industry1 + emp_ces_industry2)`

If job loss represents one industry but subtracting out another, an example might look like:

`(emp_ces_industry1 * job_loss_ces_industry1 - emp_ces_industry2 * job_loss_ces_industry2) / (emp_ces_industry1 - emp_ces_industry2)`

Residual categories are calculated based on the rules specified in the standardization sheet. Note that `N/A` categories are treated as not having any changes in jobs. This primarily includes the farm-based labor sector, which is not included in non-farm CES employment data.