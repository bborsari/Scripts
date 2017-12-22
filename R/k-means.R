#!/usr/bin/env Rscript



#*****************
# OPTION PARSING *
#*****************

suppressPackageStartupMessages(library("optparse"))

option_list <- list (
  
  make_option( c("--input", "-i"), default = 'stdin',
               help = "Input matrix. 'stdin' for reading from standard input [default = %default]." ),
  
  make_option( c("--output", "-o"), default = 'out.kmeans.tsv',
               help = "Output file name. 'stdout' for standard output [default = %default]." ),
  
  make_option( c("--header"), default = TRUE,
               help = "Whether the input matrix has a header [default = %default]." ),
  
  make_option( c("--log10", "-l"), default = FALSE,
               help = "Apply log10 to the matrix as pre-processing step [default = %default]." ),
  
  make_option( c("--pseudocount", "-p"), type = 'numeric', default = 0.001,
               help = "The pseudocount to add when applying the log [default = %default]." ),
  
  make_option( c("--clusters", "-c"), type = 'numeric', default = 4,
               help = "The number of clusters [default = %default]." ),
  
  make_option( c("--iterations"), type = 'numeric', default = 50,
               help = "The number of iterarions [default = %default]." )

)


parser <- OptionParser(
  usage = "%prog [options] file", 
  option_list=option_list,
  description = "\nProvided an input matrix, it attaches an additional column with the clusters."
)

arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options





#***************
# READ OPTIONS *
#***************


if ( ! is.null(opt$input) ) {
  
  if ( opt$input == 'stdin' ) {
    
    input.matrix <- read.table( file = 'stdin', header = opt$header, quote = NULL )
    
  } else {
    
    input.matrix <- read.table( file = opt$input, header = opt$header, quote = NULL )
    
  }
  
} else {
  
  print('Missing input matrix!')
  quit(save = 'no')
  
}


output = ifelse(opt$output == "stdout", "", opt$output)

#********
# BEGIN *
#********


if ( opt$header == FALSE ) {
  
  rownames(input.matrix) <- input.matrix$V1
  input.matrix$V1 <- NULL
  
}


input.matrix <- as.matrix(input.matrix)

if ( !is.numeric(input.matrix) ) {
  
  print ("input.matrix must contain numeric values")
  quit (save = 'no')
  
}

if ( opt$log10 ) {

  input.matrix <- log10 ( input.matrix + opt$pseudocount )

}


set.seed(1)

Klist <- replicate ( opt$iterations, kmeans( input.matrix, opt$clusters), simplify = FALSE )



K <-
  Klist [[ which.max (sapply(1:length(Klist),
                             function(i) { Klist[[i]]$betweenss / Klist[[i]]$totss } ) ) ]]$cluster

input.matrix <- as.data.frame(input.matrix)
input.matrix$Kmeans <- K

write.table( input.matrix, output, quote = FALSE, col.names = TRUE, row.names = TRUE, sep='\t' )




#*******
# EXIT *
#*******


quit( save = "no" )


