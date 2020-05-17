# Program to one time download any large data, in this case CES

# Download data -----------------------------------------------------------

url = "https://download.bls.gov/pub/time.series/ce/ce.data.0.AllCESSeries"

# BLS CES Data
download.file(
  url = url,
  destfile = "data/ces/ces_all.txt"
)
