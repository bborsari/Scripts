#!/usr/bin/env Rscript


#*****************
# OPTION PARSING *
#*****************

suppressPackageStartupMessages(library("optparse"))

option_list <- list(
  
  make_option( c ( "-n", "--number_colors" ), type='numeric', default=6,
               help = "The number of colours you want to get [default = %default]."),
  
  make_option( c( "--output", "-o" ), default = 'stdout',
               help = "Output file name; 'stdout' for standard output [default = %default]." )
  
)


parser <- OptionParser(
  usage = "%prog [options]", 
  option_list=option_list,
  description = "\nIt returns the desired number of ggplot colours."
)

arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options


#***************
# READ OPTIONS *
#***************

output = ifelse(opt$output == "stdout", "", opt$output)


#*******************
# DEFINE FUNCTIONS *
#*******************


ggplotDefaultColours <- function(n, h=c(0, 360) +15) { 
  if ((diff(h)%%360) < 1) h[2] <- h[2] - 360/n
  hcl(h = (seq(h[1], h[2], length = n)), c = 100, l = 65)
}



#********
# BEGIN *
#********



l <- data.frame(((ggplotDefaultColours(n=opt$number_colors))))
colnames(l) <- 'colors'

write.table(l, file=output, quote=FALSE, sep="\t", row.names = F, col.names = F)


#*******
# EXIT *
#*******

quit(save="no")

