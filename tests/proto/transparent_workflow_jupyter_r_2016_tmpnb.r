
# install.packages(c('dplyr','httr','jsonlite','tidyr','ggplot2','foreign',
#                   'reshape','haven','packrat'),
#                   lib='/usr/local/lib/R/site-library',dependencies=TRUE)

library(dplyr)

library(httr)
library(jsonlite)

library(tidyr)


library(ggplot2)

library(foreign)

# below aren't necessary, they're alternative 'Paths to Rome'
# library(reshape)
# library(haven)
# library(packrat)

install.packages('packrat')

# put key inside quotes
YOUR_KEY_GOES_HERE = ""

# library(dplyr)

url_base = "http://api.census.gov/data/2015/pdb/tract?"

request = "County_name,State_name,Tot_Population_CEN_2010,LAND_AREA,Females_CEN_2010&for=tract:*&in=state:06+county:037"

# put key inside quotes
# YOUR_KEY_GOES_HERE = ""

# pasted output has quotes
paste0(url_base,'get=',request,'&key=',YOUR_KEY_GOES_HERE)

# paste output, THEN, noquotes
paste0(url_base,'get=',request,'&key=',YOUR_KEY_GOES_HERE) %>% noquote()



# add measure name (from Table of Contents), drop off '+county:037" in 'for=tract:*&in=state:06+county:037'

request_more = "County_name,State_name,Tot_Population_CEN_2010,LAND_AREA,Females_CEN_2010&for=tract:*&in=state:06"

paste0(url_base,'get=',request_more,'&key=',YOUR_KEY_GOES_HERE)

# paste output, THEN, noquotes
paste0(url_base,'get=',request_more,'&key=',YOUR_KEY_GOES_HERE) %>% noquote()


url_base = ""

request = ""

?paste0

# library(httr)
# library(jsonlite)

# url_fin = paste0(url_base,'get=',request,'&key=',YOUR_KEY_GOES_HERE)  # pasted output has quotes
# url_fin

url_fin_more = paste0(url_base,'get=',request_more,'&key=',YOUR_KEY_GOES_HERE)  # pasted output has quotes
url_fin = url_fin_more

# ?GET
req_url_fin = httr::GET(url_fin)

# ?content
# extract (json) content from a request

json_req = httr::content(req_url_fin, as = "text")

# agrees with 'point and click' return
# json_req %>% cat()

# human readable, "prettify" like a shopping list
# prettify(json_req,indent=1)

json_req = '[["County_name","State_name","Tot_Population_CEN_2010","LAND_AREA","Females_CEN_2010","state","county","tract"],
["Alameda County","California","2937","2.657","1476","06","001","400100"]]'

# ?fromJSON
# https://cran.r-project.org/web/packages/jsonlite/vignettes/json-apis.html

# NEEDS quotes around final url
# url_fin = url_fin_more

print(url_fin)

data_pdb_raw = json_req %>%
# url_fin %>% 
# noquote() %>%
fromJSON()

dim(data_pdb_raw)

# json 'null' is correctly encoded as r matrix 'NA'

summary(data_pdb_raw)
# r matrix shows 1 NA, which agrees with single null in json source

sum(is.na(data_pdb_raw))
which(is.na(data_pdb_raw), arr.ind = TRUE)


head(data_pdb_raw)

data_pdb_raw[unique(which(is.na(data_pdb_raw), arr.ind = TRUE)[,1]),]


dim(data_pdb_raw)

# NA in row 1475
data_pdb_raw[1475,]
# data_pdb_raw = data_pdb_raw[-1475,]


data_pdb_raw[unique(which(is.na(data_pdb_raw), arr.ind = TRUE)[,1]),]


data_pdb_raw = data_pdb_raw[-unique(which(is.na(data_pdb_raw), arr.ind = TRUE)[,1]),]


sum(is.na(data_pdb_raw))

dim(data_pdb_raw)

# <8b> is a jupyter idiom for '...' shortening output
data_pdb_raw


class(data_pdb_raw)
dim(data_pdb_raw)

str(data_pdb_raw)

colnames(data_pdb_raw)
rownames(data_pdb_raw)


# first row of matrix - humans understand as the intended variable names
data_pdb_raw[1,]

# column names (header) of matrix - computer understands as empty
colnames(data_pdb_raw)

# make the assignment: column names of matrix = first row of matrix
colnames(data_pdb_raw) = data_pdb_raw[1,]

# assignment reflected but first row still present (redundant)
data_pdb_raw %>% head()

# data_pdb_mat: a new object distinguishing it from _raw source
# throw away first row

data_pdb_mat = data_pdb_raw[-1,] 

data_pdb_mat


# set options

str(data_pdb_mat)

# NOTE: default of [R]: automaticaly converting 'character' to 'factor' 
# this is an artifact leftover from oldtime convenience

data_pdb_mat %>% as.data.frame() %>% str()

# turn that default option OFF
options(stringsAsFactors = FALSE)

data_pdb_mat %>% as.data.frame() %>% str()

# store as data frame
data_pdb_df = data_pdb_mat %>% as.data.frame()



data_pdb_df %>%
str()

# want numeric numbers for
# Tot_Population_CEN_2010
# LAND_AREA
# Females_CEN_2010

# more data
data_pdb_df = data_pdb_df %>% 
mutate(Tot_Population_CEN_2010=as.numeric(Tot_Population_CEN_2010),
       LAND_AREA=as.numeric(LAND_AREA)       
      ) 

data_pdb_df %>%
str()

data_pdb_df %>%
summary()



data_pdb_df = data_pdb_df %>% 
mutate(      
      ) 

# check structure

data_pdb_df %>% 
filter(Tot_Population_CEN_2010 < 0)

data_pdb_df %>% 
filter(Tot_Population_CEN_2010 < 0) %>%
nrow()

data_pdb_df %>% 
filter(Tot_Population_CEN_2010 > 0) %>% nrow()

# apply filter where Total Population Count >=0

data_pdb_df %>% 
filter((Tot_Population_CEN_2010 > 0) || (Tot_Population_CEN_2010 == 0)) %>% 
nrow()

# number of rows in census returned dataset (raw)
# no filter
data_pdb_df %>% nrow()

data_pdb_df %>% 
filter() %>% 
nrow()

# is.na(data_pdb_df)
# summary(data_pdb_df)

data_pdb_df %>%
group_by(County_name) %>%
summarise(Tot_Pop_County = sum(Tot_Population_CEN_2010))

summary(data_pdb_df)


# library(tidyr)

data_pdb_df %>% 
head()

# [State,County,Tract] are the three variables, when viewed together, define the entity id
# County_name, State_name, Tot_Population_CEN_2010, are the three variables that are measurements of the entitiy

# ?tidyr::unite() to glue together variables into single entity id

# primary key := create a single entity id, by uniting the three entity variables
data_pdb_df_pk = data_pdb_df %>% 
unite("state_county_tract",state,county,tract)

data_pdb_df_pk %>% head()

# note: unite() default behavior drops original entity variables, and glues in underscore "_"


?tidyr::separate

data_pdb_df_pk %>% 

# Alternative way of creating entity id by gluing entity variables
# using mutate(paste0())

data_pdb_df %>% 
mutate(state_county_tract_v2 = paste0(state,county,tract)) %>% 
head()


# Except for our entity id "state_county_tract"
# gather all columns (several measures) into two seperate columns [variable name,variable value]

data_pdb_df_pk %>%
gather(var_name,var_val,-state_county_tract) %>%
head()


data_pdb_df_pk %>%
gather(var_name,var_val,-state_county_tract) %>%
tail()


data_pdb_df_coord = data_pdb_df_pk %>%
gather(var_name,var_val,-state_county_tract)

# library(reshape)

# Many ways to Rome: alternative method
# ?reshape2::melt() to coordinate format

# data_pdb_df_pk %>%
# reshape::melt("state_county_tract") %>%
# head()

# data_pdb_df_pk %>%
# reshape::melt("state_county_tract") %>%
# tail()

data_pdb_df_pk %>% head()

# library(ggplot2)

# convert 
## Relevel the cars by mpg
## this allows the plot to sort from most to least

# histogram of population count (each entity is a tract)
qplot(data=data_pdb_df_pk,Tot_Population_CEN_2010,geom="histogram")


# p = ggplot(data_pdb_df_pk, aes(x=reorder(state_county_tract,-Tot_Population_CEN_2010), y=Tot_Population_CEN_2010)) + 
#     geom_point(stat="identity")


ggplot(data_pdb_df_pk, aes(x=(LAND_AREA),y=(Tot_Population_CEN_2010))) + 
geom_point()


ggplot(data_pdb_df_pk, aes(x=log(LAND_AREA),y=log(Tot_Population_CEN_2010))) + 
geom_point()


str(data_pdb_df_pk)

data_pdb_df_pk %>%
mutate(Num_Males_2010 = Tot_Population_CEN_2010 - Females_CEN_2010) %>%
group_by(State_name,County_name) %>%
summarise(Num_M_2010_Cou=sum(Num_Males_2010),
         Num_F_2010_Cou=sum(Females_CEN_2010),
          Num_All_2010_Cou=sum(Tot_Population_CEN_2010)
         ) %>%
arrange(desc(Num_All_2010_Cou))

tab_sex_county = data_pdb_df_pk %>%
mutate(Num_Males_2010 = Tot_Population_CEN_2010 - Females_CEN_2010) %>%
group_by(State_name,County_name) %>%
summarise(Num_M_2010_Cou=sum(Num_Males_2010),
         Num_F_2010_Cou=sum(Females_CEN_2010),
          Num_All_2010_Cou=sum(Tot_Population_CEN_2010)
         ) %>%
arrange(desc(Num_All_2010_Cou))



names(data_pdb_df_pk)

data_pdb_df_pk %>%
head()

# intercept allowed to be estimated when land area is 0
lm(Tot_Population_CEN_2010 ~ LAND_AREA,data=data_pdb_df_pk) %>%
summary()

# force intercept to be 0
# 0 population when 0 land area
lm(Tot_Population_CEN_2010 ~ -1 + LAND_AREA, data=data_pdb_df_pk) %>%
summary()

# log-outcome and log-predictor, estimate the intercept
lm(log(Tot_Population_CEN_2010 + 0.01) ~ 1 + log(LAND_AREA + 0.01), data=data_pdb_df_pk) %>%
summary()



getwd()

# your_output_dir = 'Z:\\projects\\workshop_ccpr_stat\\workshop_data_workflow\\data_proc\\'

your_output_dir = '/home/jovyan/work/test/'

# ?write.csv

# write.csv(tab_sex_county,paste0(your_output_dir,'tab_sex_county.csv'))

# drop row number

write.csv(data_pdb_df_pk,paste0(your_output_dir,'data_pdb_df_pk.csv'),row.names=FALSE)

# list.files('/home/jovyan/work/test/')
list.files(your_output_dir)

# library(haven)

# ?write_dta
# write_dta(data_pdb_df_pk, paste0(your_output_dir,'data_pdb_df_pk_haven.dta'))
# ?read_dta

library(foreign)
# ?read.dta

write.dta(data_pdb_df_pk,paste0(your_output_dir,'data_pdb_df_pk_foreign.dta'))


list.files('/home/jovyan/work/test/')

# sessionInfo()

# library(devtools)
# devtools::install_version("tidyr", version = "0.3.1", repos = "http://cran.us.r-project.org")

library(packrat)

# ?packrat::bundle
packrat::bundle()

# ?packrat::unbundle
bundle_path = "/foo_path/foo.tar.gz"
packrat::unbundle(bundle=bundle_path)
