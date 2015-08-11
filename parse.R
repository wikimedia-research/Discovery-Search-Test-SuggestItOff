library(rgeolocate)
library(uaparser)

#Process, read in and clean
system("python3 sanitise.py -in_file CirrusSearchUserTesting.log -out_file prototype.tsv")
data <- read.delim("prototype.tsv", as.is = TRUE, header = TRUE)
if(length(unique(data$test_group)) > 2){
  data <- data[data$test_group %in% c("a","b"),]
}

#Generate country data and sanitise
data$country <- rgeolocate::maxmind(data$ip, "/usr/local/share/GeoIP/GeoIP2-Country.mmdb", "country_code")$country_code
data$results <- as.logical(data$results)
ua_data <- parse_agents(data$user_agent)

#Extract browser versions, spider status
data$browser <- paste(ua_data$browser, ua_data$browser_major)
data$class <- ifelse(ua_data$device == "Spider", "Spider", "Non-Spider")

save(data, file = "ab_data.RData")
