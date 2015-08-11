library(data.table)
library(ggplot2)
library(ggthemes)
options(scipen = 500)
library(scales)

load("ab_data.RData")
data <- as.data.table(data)

# Check for no substantial variation in browsers
browser_variation <- function(dataset){
  browser_data <- dataset[, j = list(events = .N), by = c("test_group", "browser")]
  browser_a <- browser_data[test_group == "a"]
  browser_a <- browser_a[order(browser_a$events, decreasing = TRUE)]
  top_10 <- rbind(browser_a[1:10], browser_data[test_group == "b" & browser %in% browser_a$browser[1:10]])
  return(top_10)
}

initial_variation <- browser_variation(data)
ggsave(filename = "pre_cleanup_browser_variation.png",
       plot = ggplot(initial_variation, aes(x = reorder(browser, events), y = events, fill = factor(test_group))) +
         geom_bar(stat="identity", position = "dodge") +
         theme_fivethirtyeight() + scale_x_discrete() + scale_y_continuous() +
         labs(title = "Top browsers for each test group") + coord_flip())

sanitised_variation <- browser_variation(data[data$ip != "85.13.134.246"])
ggsave(filename = "post_cleanup_browser_variation.png",
       plot = ggplot(sanitised_variation, aes(x = reorder(browser, events), y = events, fill = factor(test_group))) +
         geom_bar(stat="identity", position = "dodge") +
         theme_fivethirtyeight() + scale_x_discrete() + scale_y_continuous() +
         labs(title = "Top browsers for each test group, after cleanup") + coord_flip())

# Check for geographic variation
geographic_variation <- function(dataset){
  geo_data <- dataset[, j = list(events = .N), by = c("test_group", "country")]
  geo_a <- geo_data[test_group == "a"]
  geo_a <- geo_a[order(geo_a$events, decreasing = TRUE)]
  top_10 <- rbind(geo_a[1:10], geo_data[test_group == "b" & country %in% geo_a$country[1:10]])
  return(top_10)
}

sanitised_geo_variation <- geographic_variation(data[ip != "85.13.134.246"])
ggsave(filename = "post_cleanup_geo_variation.png",
       plot = ggplot(sanitised_geo_variation, aes(x = reorder(country, events), y = events, fill = factor(test_group))) +
         geom_bar(stat="identity", position = "dodge") +
         theme_fivethirtyeight() + scale_x_discrete() + scale_y_continuous() +
         labs(title = "Top countries for each test group, after cleanup") + coord_flip())

# Check source
source_data <- data[,j=as.data.frame(table(source), stringsAsFactors = FALSE), by = c("test_group")]
setnames(source_data, 3, "events")
ggsave(filename = "source_variation.png",
       plot = ggplot(source_data, aes(x = reorder(source, events), y = events, fill = factor(test_group))) +
         geom_bar(stat="identity", position = "dodge") +
         theme_fivethirtyeight() + scale_x_discrete() + scale_y_continuous() +
         labs(title = "Source of A/B test events") + coord_flip())
