#!/usr/bin/env Rscript



#*****************
# OPTION PARSING *
#*****************

suppressPackageStartupMessages(library("optparse"))

option_list <- list (
  
  make_option( c("--input", "-i"), default = 'stdin',
               help = "Input matrix. 'stdin' for reading from standard input [default=%default]." ),
  
  make_option( c("--output", "-o"), default = 'distance.matrix.tsv',
               help = "Output file name. 'stdout' for standard output [default=%default]." ),
  
  make_option( c("--header"), default = TRUE,
               help = "Whether the input matrix has a header [default=%default]." ),
  
  make_option( c("--log10", "-l"), default = FALSE,
               help = "Apply log10 to the matrix as pre-processing step [default = %default]." ),
  
  make_option( c("--pseudocount", "-p"), type = 'numeric', default = 0.001,
               help = "The pseudocount to add when applying the log [default = %default]." ),
  
  make_option( c("--method", "-m"), default = 'binary',
               help = "The method you want to apply. It can be one of the methods of dist.binary (ade4 package) or one of the methods implemented in the function 'dist' [default=%default]." )
)


parser <- OptionParser(
  usage = "%prog [options]", 
  option_list=option_list,
  description = "\nProvided an input matrix, it computes the corresponding distance matrix with the specified method."
)

arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options




#***************
# READ OPTIONS *
#***************


if ( ! is.null(opt$input) ) {
  
  if ( opt$input == 'stdin' ) {
    
    input.matrix <- read.table ( file = 'stdin', header = opt$header, quote = NULL )
    
  } else {
    
    input.matrix <- read.table ( file = opt$input, header = opt$header, quote = NULL )
    
  }
  
} else {
  
  print('Missing input matrix!')
  quit(save = 'no')
  
}


output = ifelse(opt$output == "stdout", "", opt$output)


#*******************
# DEFINE FUNCTIONS *
#*******************



dist.binary.ade4 <- function (m, method = NULL) {
  
  METHODS <- c( "JACCARD S3", 
                "SOCKAL & MICHENER S4", 
                "SOCKAL & SNEATH S5", 
                "ROGERS & TANIMOTO S6", 
                "CZEKANOWSKI S7", 
                "GOWER & LEGENDRE S9", 
                "OCHIAI S12", 
                "SOKAL & SNEATH S13", 
                "Phi of PEARSON S14", 
                "GOWER & LEGENDRE S2" )
  

  
  if ( is.null (method) ) {
    
    cat("1 = JACCARD index (1901) S3 coefficient of GOWER & LEGENDRE\n")
    cat("s1 = a/(a+b+c) --> d = sqrt(1 - s)\n")
    cat("2 = SOCKAL & MICHENER index (1958) S4 coefficient of GOWER & LEGENDRE \n")
    cat("s2 = (a+d)/(a+b+c+d) --> d = sqrt(1 - s)\n")
    cat("3 = SOCKAL & SNEATH(1963) S5 coefficient of GOWER & LEGENDRE\n")
    cat("s3 = a/(a+2(b+c)) --> d = sqrt(1 - s)\n")
    cat("4 = ROGERS & TANIMOTO (1960) S6 coefficient of GOWER & LEGENDRE\n")
    cat("s4 = (a+d)/(a+2(b+c)+d) --> d = sqrt(1 - s)\n")
    cat("5 = CZEKANOWSKI (1913) or SORENSEN (1948) S7 coefficient of GOWER & LEGENDRE\n")
    cat("s5 = 2*a/(2*a+b+c) --> d = sqrt(1 - s)\n")
    cat("6 = S9 index of GOWER & LEGENDRE (1986)\n")
    cat("s6 = (a-(b+c)+d)/(a+b+c+d) --> d = sqrt(1 - s)\n")
    cat("7 = OCHIAI (1957) S12 coefficient of GOWER & LEGENDRE\n")
    cat("s7 = a/sqrt((a+b)(a+c)) --> d = sqrt(1 - s)\n")
    cat("8 = SOKAL & SNEATH (1963) S13 coefficient of GOWER & LEGENDRE\n")
    cat("s8 = ad/sqrt((a+b)(a+c)(d+b)(d+c)) --> d = sqrt(1 - s)\n")
    cat("9 = Phi of PEARSON = S14 coefficient of GOWER & LEGENDRE\n")
    cat("s9 = ad-bc)/sqrt((a+b)(a+c)(b+d)(d+c)) --> d = sqrt(1 - s)\n")
    cat("10 = S2 coefficient of GOWER & LEGENDRE\n")
    cat("s10 =  a/(a+b+c+d) --> d = sqrt(1 - s) and unit self-similarity\n")
    cat("Select an integer (1-10): ")
    method <- as.integer(readLines(n = 1))
  
  }
  
  
  
  a <- (m %*% t(m))[ 1,2 ]
  
  b <- (m %*% (1 - t(m)))[ 1,2 ]
  
  c <- ((1 - m) %*% t(m))[ 1,2 ]
  
  d <- ncol(m) - a - b - c
  
  if ( method == 1 ) {
    
    s <- a/(a + b + c)

  }
  
  else if ( method == 2 ) {
    
    s <- (a + d)/(a + b + c + d)
    
  }
  
  else if ( method == 3 ) {
    
    s <- a/(a + 2 * (b + c))
  
  }
  
  else if ( method == 4 ) {
    
    s <- (a + d)/(a + 2 * (b + c) + d)
    
  }

  else if ( method == 5 ) {
    
    s <- 2*a/(2 * a + b + c)
  
  }
  
  else if ( method == 6 ) {
    
    s <- (a - (b + c) + d)/(a + b + c + d)
    
  }
  
  else if ( method == 7 ) {
    
    s <- a/sqrt((a+b)*(a+c))
  
  }
  
  else if ( method == 8 ) {
    
    s <- a * d/sqrt((a + b) * (a + c) * (d + b) * (d + c))
  
  }
  
  else if ( method == 9 ) {
    
    s <- ( a * d - b * c ) / sqrt( (a + b) * (a + c) * (b + d) * (d + c) )
  
  }
  
  else if ( method == 10 ) {
    
    s <- a / ( a + b + c + d )
    diag(s) <- 1
  
  }
  
  else stop( "Non convenient method" )
  
  distance <- sqrt( 1 - s )
  
  return(distance)
  
}





#********
# BEGIN *
#********

non.binary.methods <- c( "euclidean", "maximum", "manhattan", "canberra", "minkowski")

if ( opt$header == FALSE ) {
  
  rownames(input.matrix) <- input.matrix$V1
  input.matrix$V1 <- NULL
  
}

input.matrix <- as.matrix(input.matrix)

if ( !is.numeric(input.matrix) ) {
  
  print ("input.matrix must contain numeric values")
  quit (save = 'no')
  
}



if ( !( opt$method %in% non.binary.methods ) ) {
  
  if ( any( input.matrix < 0 ) ) {
    
    print ("non negative values expected in input.matrix")
    quit (save = 'no')
    
  }
  
  input.matrix <- as.matrix( 1 * (input.matrix > 0) )
  
}


if ( opt$log10 ) {
  
  input.matrix <- log10 ( input.matrix + opt$pseudocount )
  
}




# distance.matrix <- matrix( data = NA, nrow = nrow(input.matrix), ncol = nrow(input.matrix) )
distance.matrix <- vector()


# colnames(distance.matrix) <- rownames(input.matrix)
# rownames(distance.matrix) <- rownames(input.matrix)

for ( i in 1:nrow(input.matrix) ) {
  
  current.vector <- rep("NA", nrow(input.matrix))
  for ( j in i:nrow(input.matrix) ) {
    
    sub.input.matrix <- input.matrix[ c(i,j), ]
    
    if ( opt$method %in% non.binary.methods | opt$method == 'binary' ) {

      val <- as.numeric(dist( sub.input.matrix, method = opt$method ))
      current.vector[j] <- val
      # distance.matrix[ i,j ] <- as.numeric(dist( sub.input.matrix, method = opt$method ))

    } else {

      opt$method <- as.numeric(opt$method)
      val <- as.numeric(dist( sub.input.matrix, method = opt$method ))
      current.vector[j] <- val
      # distance.matrix[ i,j ] <- dist.binary.ade4( sub.input.matrix, method = opt$method )

     }

  }
  
  distance.matrix <- cbind(distance.matrix, current.vector)

}


print("changing colnames")

colnames(distance.matrix) <- rownames(input.matrix)

print("changing rownames")
rownames(distance.matrix) <- rownames(input.matrix)
# distance.matrix <- t(distance.matrix)

print("saving matrix")
write.table( distance.matrix, output, quote = FALSE, sep = "\t" )



#*******
# EXIT *
#*******


quit( save = "no" )


