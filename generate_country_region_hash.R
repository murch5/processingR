#Compiling country and region data from UN M49
setwd("/home/murch/projects/processingR")


source("clean_DF.R")
source("/home/murch/projects/phenotypeR/merge_df_by_key.R")

country_data <- read.csv("UNSD — Methodology.csv", stringsAsFactors = FALSE)
country_code <- read.csv("regional_classifiers_recode.csv", stringsAsFactors = FALSE)

country_data <- cleanDataFrame(country_data)

country_data_subset <- country_data[,c("Country_or_Area","Region_Name", "Sub_region_Name","Intermediate_Region_Name","ISO_alpha3_Code")]

country_merge <- merge_df_by_key(country_code,"country", country_data_subset, "Country_or_Area")

country_code_normal <- country_code[which(country_code[,"country"]!="region" & country_code[,"country"]!="inter" ),]

country_merge_normal <- merge_df_by_key(country_code_normal,"country", country_data_subset, "Country_or_Area")

country_data_inter <- unique(country_data_subset[,c("Intermediate_Region_Name","Sub_region_Name","Region_Name")])
country_code_interonly <- country_code[which(country_code[,"country"]=="inter"),]
country_merge_interonly <- merge_df_by_key(country_code_interonly,"region", country_data_inter, "Intermediate_Region_Name")
colnames(country_merge_interonly)[3] = "Intermediate_Region_Name"

country_data_region <- unique(country_data_subset[,c("Sub_region_Name","Region_Name")])
country_code_regiononly <- country_code[which(country_code[,"country"]=="region"),]
country_merge_regiononly <- merge_df_by_key(country_code_regiononly,"region", country_data_region, "Sub_region_Name")
colnames(country_merge_regiononly)[3] = "Sub_region_Name"

country <- dplyr::bind_rows(country_merge_normal,country_merge_regiononly, country_merge_interonly)

country$region <- NULL

con<-file("/home/murch/projects/phenotypeR/in/region_classifier_df.csv",encoding="UTF-8")
write.csv(country,file=con,row.names = FALSE)