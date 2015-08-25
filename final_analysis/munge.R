library(data.table)

main <- function(){
  
  read_fun <- function(filepath){
    
    #Read in and sanitise
    data <- read.delim(gzfile(filepath), sep = "\t", header = FALSE, as.is = TRUE)
    data <- as.data.table(data[data$V2 %in% c("suggest-confidence-b", "suggest-confidence-a"),
                               c("V2","V3","V4","V7")])
    cat(".")
    
    #Exclude /that/ IP address and queries that didn't contain a full-text search
    data <- data[data$V7 != "85.13.134.246",] 
    data <- data[grepl(x = data$V3, pattern = "queryType: full_text,", fixed = TRUE),] 
    
    # Identify TRUE/FALSE values for the condition "returned results > 0"
    data$results_returned <- (data$V4 != "0")
    
    # And now we aggregate
    data <- data[, j = list(no_results = sum(results_returned == FALSE),
                            results    = sum(results_returned == TRUE)),
                 by = "V2"]
    return(data)
  }
  
  files <- list.files(path = "./data/", full.names = TRUE)
  results <- do.call("rbind", lapply(files, read_fun))
  results <- results[,j=list(no_results = sum(no_results), results = sum(results)), by = "V2"]
  save(results, file = "final_results.RData")
}

main()
q(save = "no")
