fraction_explained_variance <- function(dataframe, variable, group){
  SS_total <- sum((dataframe[,variable] - mean(dataframe[,variable]))^2)
  SS_between<-0
  for (i in unique(dataframe[,group])){
    y<-dataframe[which(dataframe[,group]==i),variable]
    len <- length(y)
    SS_i <- len*((mean(y) - mean(dataframe[,variable]))^2)
    SS_between <- SS_between + SS_i
  }
  print(SS_total)
  print(SS_between/SS_total)
}

