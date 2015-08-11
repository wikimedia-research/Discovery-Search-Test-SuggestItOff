library(rgeolocate)
library(uaparser)
library(data.table)

load("ab_data.RData")

# Check for no substantial variation in browsers
data <- as.data.table(data)
browser_data <- data[, j = list(events = .N), by = c("test_group", "browser")]
browser_a <- browser_data[test_group == "a"]
browser_a <- browser_a[order(browser_a$events, decreasing = TRUE)]


data <- data[,j= .N, by = c("test_group", "ip", "project", "user_agent", "results", "source", "country")]
