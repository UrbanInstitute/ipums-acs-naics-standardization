# Standardizing BLS CES NAICS to IPUMS ACS NAICS codes

This repository attempts to join BLS CES data to 2014-18 IPUMS ACS data for the purposes of estimating PUMA level and higher job losses, and other estimates using ACS data to do so. 

Data are organized in the `data` directory and programs in the `scripts` directory. Extracts from IPUMS should be sure to include the `INDNAICS` variable, and both the DDI file `usa_xxxxx.xml` and the data file should be placed in the `data/ipums` folder.

## Standardizing CES and IPUMS ACS NAICS codes

We went through a manual process to standardize the codes. You can find our decisions and notes on the decisions in this Excel document: [add link here]. You can find the machine readable CSV used for analysis here: [add link here].

# Running a test using CES national job loss

Next, we pull CES national figures from February and April by detailed category to derive job losses by category. We then use February counts of employment from CES national figures and apply the crosswalk to calculate mix for industries in IPUMS that represent combinations of CES categories, which is our bigget issue to solve for. We also create any necessary residual categories as specified in the crosswalk as part of this process. For example, if an IPUMS industry represents the combination of two industries, job loss for the IPUMS industry is:

`(emp_ces_industry1 * job_loss_ces_industry1 + emp_ces_industry2 * job_loss_ces_industry2) / (emp_ces_industry1 + emp_ces_industry2)`

If job loss represents one industry but subtracting out another, an example might look like:

`(emp_ces_industry1 * job_loss_ces_industry1 - emp_ces_industry2 * job_loss_ces_industry2) / (emp_ces_industry1 - emp_ces_industry2)`

Residual categories are calculated based on the rules specified in the standardization sheet. Note that `N/A` categories are treated as not having any changes in jobs. This primarily includes the farm-based labor sector, which is not included in non-farm CES employment data.
