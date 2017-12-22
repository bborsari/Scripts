#!/usr/bin/env Rscript



#*****************
# OPTION PARSING *
#*****************

suppressPackageStartupMessages(library("optparse"))

option_list <- list(
  
  make_option( c ( "--input", "-i" ), default = 'stdin',
               help = "Input matrix. 'stdin' for reading from standard input; 1st column must contain counts, 2nd column must contain groups [default = %default]." ),
  
  make_option( c( "--output", "-o" ), default = 'piechart.pdf',
               help = "Output file name [default = %default]." ),
  
  make_option( c( "--header" ), default = TRUE,
               help = "Whether the input matrix has header [default = %default]."),
  
  make_option( c("--legend_title", "-t"), default = "class",
               help = "The title for the legend [default = %default]."),
  
  make_option( c("--palette", "-p"), default = NULL,
               help = "The palette you want to use; if not specified, it will use the default ggplot palette [default = %default].")

)


parser <- OptionParser(
  usage = "%prog [options] file", 
  option_list=option_list,
  description = "\nReturns a pie chart of the input file."
)

arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options



#************
# LIBRARIES *
#************

suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(dplyr))





#***************
# READ OPTIONS *
#***************



# read input matrix

if ( ! is.null(opt$input) ) {
  
  if (opt$input == 'stdin') {
    
    input.matrix <- read.table( file = 'stdin', header = opt$header, quote = NULL, sep="\t", col.names = c("value", "group"))
    
  } else {
  
    input.matrix <- read.table( file = opt$input, header = opt$header, quote = NULL, sep="\t", col.names = c("value", "group"))
  
  }
  
} else {
  
  print('Missing input matrix!')
  quit(save = 'no')
  
}  


# read palette

if ( !is.null(opt$palette) ) {
  
  palette <- as.character( read.table( file = opt$palette, comment.char='%' )$V1 )
  
}


#********
# BEGIN *
#********


input.matrix <- input.matrix %>%
  mutate(group = factor(group, levels = rev(input.matrix$group)),
         cumulative = cumsum(value),
         midpoint = cumulative - value / 2,
         label = paste0(round(value / sum(value) * 100, 1), "%"))



p <- ggplot(input.matrix, aes(x = 1, weight = value, fill = group)) +
  geom_bar(width = 1, position = "stack") +
  coord_polar(theta = "y") +
  geom_text(aes(x = 1.3, y = midpoint, label = label)) +
  theme_void() +
  labs(fill = opt$legend_title)


if ( ! is.null(opt$palette)) {
  
  p <- p + scale_fill_manual(values=palette)
  
}


pdf( file = opt$output, paper="a4r", width = 32, height = 14 )
print(p)
dev.off()


#*******
# EXIT *
#*******

quit( save = "no" )
