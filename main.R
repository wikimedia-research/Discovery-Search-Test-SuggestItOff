library(rgeolocate)
library(uaparser)
library(data.table)

#Process, read in and clean
system("python3 sanitise.py -in_file CirrusSearchUserTesting.log -out_file prototype.tsv")
data <- read.delim("prototype.tsv", as.is = TRUE, header = TRUE)
if(length(unique(data$test_group)) > 2){
  data <- data[data$test_group %in% c("a","b"),]
}

#Generate country data and aggregate
data$country <- rgeolocate::maxmind(data$ip, "/usr/local/share/GeoIP/GeoIP2-Country.mmdb", "country_code")$country_code
data$results <- as.logical(data$results)
data <- as.data.table(data)
data <- data[,j= .N, by = c("test_group", "ip", "project", "user_agent", "results", "source", "country")]

ua_data <- parse_agents(data$user_agent)

"test_group" "ip"         "project"    "user_agent" "results"   
[6] "source"     "country"  
