#!/usr/bin/ Rscript
partial_correlation <- function(expr_values, H3K4me3, time_point){
  mean <- apply(expr_values, 1, mean)
  sd <- apply(expr_values, 1, sd)
  cv <- CV(mean, sd)
  cv[is.nan(cv)] <- 0
  pcor_pearson <- pcor.test(as.numeric(log10(expr_values[,time_point]+1)), as.numeric(H3K4me3[,time_point]), mean)$estimate
  for (i in colnames(expr_values)[2:length(colnames(expr_values))]){
    pcor <- pcor.test(as.numeric(log10(expr_values[,i]+1)), as.numeric(H3K4me3[,i]), mean)$estimate
    pcor_pearson <- c(pcor_pearson, pcor)
    }
  pcor_spearman <- pcor.test(as.numeric(log10(expr_values[,time_point]+1)), as.numeric(H3K4me3[,time_point]), mean, method="spearman")$estimate
  for (i in colnames(expr_values)[2:length(colnames(expr_values))]){
    pcor <- pcor.test(as.numeric(log10(expr_values[,i]+1)), as.numeric(H3K4me3[,i]), mean, method="spearman")$estimate
    pcor_spearman <- c(pcor_spearman, pcor)
    }
  print(pcor_pearson)
  print(pcor_spearman)
}
