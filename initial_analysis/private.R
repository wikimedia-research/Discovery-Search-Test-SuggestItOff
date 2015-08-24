# Data Import
load("initial_analysis/ab_test_initial_data.RData") # from Oliver
data$zero_results <- factor(data$results, c(FALSE, TRUE), c("Zero results", "Some results"))
data$results <- factor(data$results, c(TRUE, FALSE), c("Some results", "Zero results"))
data$test_group <- factor(data$test_group)
data$project <- factor(data$project)
data$source <- factor(data$source)
data$country <- factor(data$country)
data$browser <- factor(data$browser)
data$class <- factor(data$class)
data <- dplyr::filter(data, ip != "85.13.134.246") # abusive IP
save(data, file = "initial_analysis/ab_test_initial_data_exclude-abuser.RData")
