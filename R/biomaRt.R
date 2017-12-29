#!/usr/bin/env Rscript

.libPaths("/nfs/users2/rg/bborsari/software/R-3.4.1/library")


#*****************
# OPTION PARSING *
#*****************

suppressPackageStartupMessages(library("optparse"))

option_list <- list (
  
  make_option( c ("-m", "--useMart"), default = "ENSEMBL_MART_ENSEMBL",
               help = "The BioMart database. Choose among 'ENSEMBL_MART_ENSEMBL', 'ENSEMBL_MART_MOUSE', 'ENSEMBL_MART_SNP', 'ENSEMBL_MART_FUNCGEN' [default = %default]." ),
  
  make_option( c ("-d", "--useDataset"), default = "hsapiens_gene_ensembl",
               help = "The BioMart dataset [default = %default]." ),
  
  make_option( c ("--host"), default = "aug2017.archive.ensembl.org",
               help = "The host to be used for useMart [default = %default]." ),
  
  make_option( c ("-f", "--filters"), default = "",
               help = "The filters to apply. E.g.: \"c(\"ensembl_gene_id\")\". If more than one filter is present, it must be provided in form of a vector" ),
  
  make_option( c ("-a", "--attributes"),
               help = "The required attributes. E.g.: \"c(\"ensembl_gene_id\")\". If more than one filter is present, it must be provided in form of a vector" ),
  
  make_option( c ("-n", "--column_number"), type = "numeric",
               default = 1, help = "The number of the column with the ids [default = %default]." ),
  
  make_option( c("-i", "--input.matrix"), default = 'stdin',
               help = "The input matrix [default = %default]." ),
  
  make_option( c( "--header" ), default = FALSE,
               help = "Whether the input matrix has header [default = %default]." ),
  
  make_option( c( "-o", "--output"), default = "BM.out.tsv",
               help = "Output file name. 'stdout' for standard output [default = %default].")
  
)


parser <- OptionParser(
  usage = "%prog [options] file", 
  option_list=option_list,
  description = "\nProvided a list of identifiers, it applies the desired filters and retrieves the desired attributes through biomaRt package."
)

arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options




#***************
# READ OPTIONS *
#***************

# read input matrix
if ( ! is.null(opt$input) ) {
  
  
  if (opt$input.matrix == 'stdin') {
    
    input.matrix <- read.table( file = 'stdin', 
                                header = opt$header, 
                                quote = NULL, 
                                sep="\t",
                                stringsAsFactors = FALSE)
    
  } else {
    
    input.matrix <- read.table( file = opt$input.matrix, 
                                header = opt$header, 
                                quote = NULL, 
                                sep="\t",
                                stringsAsFactors = FALSE)
    
  }
  
} else {
  
  print('Missing input matrix!')
  quit(save = 'no')
  
}


# read values

my.values <- input.matrix[, opt$column_number]


# read filters and attributes

my.filters <- eval( parse( text = opt$filters ) )
my.attributes <- eval( parse( text = opt$attributes ) )
  


# output
output = ifelse(opt$output == "stdout", "", opt$output)



#************
# LIBRARIES *
#************

suppressPackageStartupMessages(library("biomaRt"))


#********
# BEGIN *
#********

my.mart <- useDataset( opt$useDataset, 
                       useMart(opt$useMart, host = opt$host) )

my.list <- getBM( filters = my.filters, 
                  attributes = my.attributes,
                  values = my.values,
                  mart = my.mart )


#*********
# OUTPUT *
#*********

write.table(my.list, file=output, quote=FALSE, sep="\t", row.names = F, col.names = F)


#*******
# EXIT *
#*******

quit(save="no")