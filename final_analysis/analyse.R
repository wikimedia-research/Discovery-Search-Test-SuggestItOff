library(broom)

main <- function(){
  
  # Load data and turn it into a matrix
  load(file = "final_results.RData")
  results_matrix <- as.matrix(as.data.frame(results, stringsAsFactors = FALSE)[,2:3])
  rownames(results_matrix) <- ifelse(results$V2 == "suggest-confidence-a", "Group A", "Group B")
  colnames(results_matrix) <- c("No Results", "Some Results")
  
  # Check for group association
  png(filename = "final_association.png", width = 861, height = 542)
  par(mar = c(2.5, 2.5, 2.5, 0), bg = "#F0F0F0",
      col.lab = "#3C3C3C", col.axis = "#3C3C3C", col.main = "#3C3C3C")
  mosaicplot(t(results_matrix), color = c("#F8766D", "#00BFC4"), border = "white",
             main = "Final association of test group and results",
             xlab = "Results?", ylab = "Test group", margin = NULL)
  dev.off()
  
  # Calculate ChiSq
  write.table(tidy(chisq.test(results_matrix)), row.names = FALSE, sep = "\t",
              quote = TRUE, file = "final_chisq.tsv")
  
  # Calculate a simple percentage difference
  results$proportion <- results$results/(results$no_results + results$results)
  # 0.08% difference.
}
