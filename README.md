# Country-and-Region-Metadata

## Purpose of project

* Produce intermediate files that can be used as input to metadata utilized by all sectors
* Avoid duplication work of cleaning raw data

## Output files
The output files from this project are used as input for the downstream process.
The data is in long format, so for each region, we map all the ISO3Code values that belong to that region.
![image](https://github.com/user-attachments/assets/68087586-b0e1-4ca6-9d41-bd1c13066f32)

In this way, the data can be easily reshaped into wide format using `ISO3Code ~ Region_Code`. Then every row represents an ISO3Code, and every region is a column
```
# for example
dt_rec_w <- data.table::dcast(dt_rec, ISO3Code ~ Region_Code, value.var = "Region")
```
