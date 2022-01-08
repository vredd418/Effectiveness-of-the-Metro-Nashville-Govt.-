library(httr)
library(tidyverse)
library(RSocrata)
library(lubridate)
library(rgdal)
library(ggplot2)
library(tidycensus)

df = read.socrata("https://data.nashville.gov/resource/7qhx-rexh.json")
df <- df %>% subset(., select = c("status", "case_request", "case_subrequest", "additional_subrequest", "date_time_opened",
                        "date_time_closed", "mapped_location.latitude", "mapped_location.longitude"))
df <- df %>% filter(year(date_time_opened) == 2019) %>% 
  filter(year(date_time_closed) == 2019) %>% 
  filter_at(vars(mapped_location.latitude, mapped_location.longitude), all_vars(!is.na(.)))

tract <- readOGR(dsn = "C:/Users/vredd/Documents/data_science_projects/Midcourse project/Effectiveness-of-the-Metro-Nashville-Govt.-/data",
                layer = "tl_2019_47_tract")

census <- get_acs(geography = "census",
                  variables = ,
                  year = 2019)

vars <- load_variables(2019, "acs5", cache = TRUE)
