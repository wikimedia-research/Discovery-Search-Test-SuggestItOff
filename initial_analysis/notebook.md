# Suggestion Confidence A/B Test Initial Analysis
Mikhail Popov  
August 11, 2015  

## Packages Used In Analysis


```r
# Utility function for transferring 2x2 tables over:
transfer <- function(x) {
  paste0(c(
    sprintf("x <- matrix(c(%s), nrow = 2, byrow = FALSE)",
            paste0(as.numeric(x), collapse = ", ")),
    sprintf("colnames(x) <- c('%s')", paste0(colnames(x), collapse = "', '")),
    sprintf("rownames(x) <- c('%s')", paste0(rownames(x), collapse = "', '"))
  ), collapse = "; ")
}

# install.packages('ggthemes', dependencies = TRUE) # for theme_fivethirtyeight
# install.packages('import') # for importing specific functions from packages
# install.packages(
#   'printr',
#   type = 'source',
#   repos = c('http://yihui.name/xran', 'http://cran.rstudio.com')
# )
# install.packages('mosaic') # for odds.ratio
c("magrittr", "tidyr", "knitr", "ggplot2", "ggthemes", "printr") %>%
  sapply(library, character.only = TRUE) %>% invisible
import::from(dplyr, select, arrange, rename, mutate, summarise, keep_where = filter)
```


```r
load("ab_test_initial_data_exclude-abuser.RData")
# load("initial_analysis/ab_test_initial_data_exclude-abuser.RData")
```

## Data Cleanup

Oliver has taken care of parsing the log files from JSON-y format to a tabular one. He has also mapped IP addresses to country codes and parsed the user agents and tagged known automata. He also noticed that a specific IP address from Germany is an abusive spider responsible for 2.1 million of the observations. We are excluding this "user" from analysis.

## Summary Statistics


```r
with(data, {
  table(test_group, results) %>% prop.table(margin = 1)
}) %>% kable
```

      Some results   Zero results
---  -------------  -------------
a        0.7399656      0.2600344
b        0.7409764      0.2590236

## Significance Testing


```r
mosaicplot(results ~ test_group, data = data, shade = TRUE,
           main = "Association of test group and results",
           xlab = "Got results", ylab = "Test group")
```

![](notebook_files/figure-html/association_mosaic-1.png) 

```r
# We can see from this mosaic plot that there might be an association.
```


```r
par(mfrow = c(1, 2))
with(keep_where(data, class != "Spider"), {
  x <- table(test_group, results)
  # chisq.test(x)
  # mosaic::oddsRatio(x, verbose = TRUE)
  mosaicplot(t(x), color = c("cornflowerblue", "orange"), border = "white",
           main = "Actual users", cex.axis = 1,
           sub = "p = 0.004, OR = 1.006 (95%: 1.002, 1.01)",
           xlab = "Got zero results", ylab = "Test group")
})
with(keep_where(data, class == "Spider"), {
  x <- table(test_group, results)
  # chisq.test(x)
  # mosaic::oddsRatio(x, verbose = TRUE)
  mosaicplot(t(x), color = c("cornflowerblue", "orange"), border = "white",
           main = "Spiders", cex.axis = 1,
           sub = "p = 0.007, OR = 1.005 (95%: 1.001, 1.009)",
           xlab = "Got zero results", ylab = "Test group")
})
```

![](notebook_files/figure-html/association_mosaic_by_class-1.png) 


```r
with(keep_where(data, country == "US" & class != "Spider"), {
  table(test_group, results)
}) %>% transfer
```

**Hypothesis**: Group (A/B) and Results (Y/N) are independent.

```r
group_results_odds_ratio <- with(data, {
  table(test_group, results)
}) %>% mosaic::oddsRatio(conf.level = 0.95)
attr(group_results_odds_ratio, "upper.OR")
attr(group_results_odds_ratio, "lower.OR")
group_results_odds_ratio
```

Using this initial set of data, we can reject the hypothesis (p = 0.0073). The odds of getting results for those in group B was 1.005 times the odds for those in group A -- 95% CI: (1.0014, 1.0091).

**Bottom line**: Group B is associated with better results, BUT only ever so slightly.

When we look at the standardized residuals (also shown in the mosaic plot above), we see that slightly more users form Group B would have gotten results than if the variables were truly independent.


      Some results   Zero results
---  -------------  -------------
a        -2.684949       2.684949
b         2.684949      -2.684949


```r
# install.packages('Exact') # for exact.test
# install.packages('Barnard') # for barnardw.test
```
