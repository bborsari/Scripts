#!/usr/bin/env Rscript



#*****************
# OPTION PARSING *
#*****************

suppressPackageStartupMessages(library("optparse"))

option_list <- list (
  
  make_option( c("--input", "-i"), default = 'stdin',
               help = "Distance matrix. 'stdin' for reading from standard input [default = %default]." ),
  
  make_option( c("--output", "-o"), default = 'tSNE.pdf',
               help = "Output file name [default = %default]." ),
  
  make_option( c("--save", "-S"), default = TRUE,
               help = "Whether to save or not the tSNE object [default = %default]." ),
  
  make_option( c("--robject", "-r"), default = 'tSNE.object.Rdata',
               help = "The name of the file where to save the tSNE object [default = %default]."),
  
  make_option( c("--title", "-t"), default = 'Metric tSNE',
               help = "The title of the plot [default = %default]."),
  
  make_option( c("--header_metadata", "-H"), default = TRUE,
               help = "Whether the metadata file has header [default = %default]." ),
  
  make_option( c("--header_labels"), default = TRUE,
               help = "Whether the labels file has header [default = %default]." ),
  
  make_option( c("--metadata", "-d"), default = NULL,
               help = "Metadata file by which to define color and shape. Can be 'stdin' [default = %default]." ),
  
  make_option( c("--retrieve_coordinates_labels"), default = TRUE,
               help = "Whether to retrieve coordinates of the labels from the fit object [default = %default]."),
  
  make_option( c("--labels", "-l"), default = NULL,
               help = "Labels' file. Can be 'stdin'. If --retrieve_coordinates = TRUE, the rownames of the file must be a subset of the rownames of the distance matrix, and column 1 must contain the labels. If FALSE, rownames are not required and the file must contain x (column 1) and y (column 2) coordinates of the labels (column 3)[default = %default]."),
  
  make_option( c("--colour", "-c"), type = "numeric", default = NULL,
               help = "The column number in the metadata file you want to colour the data by [default = %default]." ),
  
  make_option( c("--shape", "-s"), type = "numeric", default = NULL,
               help = "The column name in the metadata file you want to shape the data by [default = %default]." ),
  
  make_option( c("--colour_legend_title"), default = NULL,
               help = "The title for the legend of the colour factors." ),
  
  make_option( c("--shape_legend_title"), default = NULL,
               help = "The title for the legend of the shape factors." ),
  
  make_option( c("--perplexity", "-p"), type = "numeric", default = 30,
               help = "The perplexity value [default = %default].")
  
)


parser <- OptionParser(
  usage = "%prog [options] file", 
  option_list=option_list,
  description = "\nProvided a distance matrix, it returns a tSNE representation of the data."
)

arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options





#***************
# READ OPTIONS *
#***************


if ( ! is.null(opt$input) ) {
  
  if ( opt$input == 'stdin' ) {
    
    distance.matrix <- read.table( file = 'stdin', header = TRUE, quote = NULL)
    
  } else {
    
    distance.matrix <- read.table( file = opt$input, header = TRUE, quote = NULL)
    
  }
  
} else {
  
  print('Missing input matrix!')
  quit(save = 'no')
  
}



if ( ! is.null(opt$metadata) ) {
  
  if ( opt$metadata == 'stdin' ) {
    
    metadata <- read.table( file = 'stdin', header = opt$header_metadata, quote = NULL )
    
  } else {
    
    metadata <- read.table( file = opt$metadata, header = opt$header_metadata, quote = NULL)
    
  }
  
  if (! opt$header_metadata) {
    
    rownames(metadata) <- metadata$V1
    metadata$V1 <- NULL
    
  }
  
  roworder <- rownames(distance.matrix)
  metadata <- metadata[ roworder, ]
  
}



if ( ! is.null(opt$labels) ) {
  
  if ( opt$labels == 'stdin' ) {
    
    labels <- read.table( file = 'stdin', header = opt$header_labels, quote = NULL )
    
  } else {
    
    labels <- read.table( file = opt$labels, header = opt$header_labels, quote = NULL )
    
  }
  
  if ( opt$retrieve_coordinates_labels & !opt$header_labels ) {
    
    rownames(labels) <- labels$V1
    labels$V1 <- NULL
    
  }
  
}



#************
# LIBRARIES *
#************

suppressPackageStartupMessages(library("ggplot2"))
suppressPackageStartupMessages(library("ggrepel"))
suppressPackageStartupMessages(library("Rtsne"))


#*******************
# DEFINE FUNCTIONS *
#*******************

add_modify_aes <- function( mapping, ... ) {
  
  ggplot2:::rename_aes( modifyList( mapping, ... ) )  
  
}

ggplotColours <- function(n = 6, h = c(0, 360) + 15){
  if ((diff(h) %% 360) < 1) h[2] <- h[2] - 360/n
  hcl(h = (seq(h[1], h[2], length = n)), c = 100, l = 65)
}


#********
# BEGIN *
#********

set.seed(1)

distance.object <- as.dist(distance.matrix)

tsne.result <- Rtsne( distance.object, 
                      dims = 2,
                      theta = 0.5,
                      is_distance = TRUE,
                      pca = TRUE,
                      perplexity = opt$perplexity )

colnames(tsne.result$Y) <- c("x_axis", "y_axis")
fit <- as.data.frame(tsne.result$Y)
rownames(fit) <- rownames(distance.matrix)


if ( !is.null(opt$labels)) {
  
  if ( opt$retrieve_coordinates_labels ) {
    
    rownames.labels <- rownames(labels)
    labels <- data.frame( x_axis = fit[ rownames(labels),1 ],
                          y_axis = fit[ rownames(labels),2 ],
                          my.labels = labels[ ,1 ] )
    
    rownames(labels) <- rownames.labels
    
  }
  
  
}


mapping <- aes( x = fit$x_axis, y = fit$y_axis )
p <- ggplot( fit, aes( x = fit$x_axis, y = fit$y_axis ) )


if ( ! is.null(opt$colour) ) {
  
  palette <- structure(ggplotColours(length(levels(as.factor(metadata[ ,opt$colour ])))),
                       names = levels(as.factor(metadata[ ,opt$colour ])))
  
  fit$metadataColour <- as.factor(metadata[ ,opt$colour ])
  p <- ggplot( fit, add_modify_aes( mapping, aes( color = metadataColour ) ) )
  
  if ( opt$retrieve_coordinates_labels & ! is.null(opt$labels) ) {
    
    labels$metadataColour <- fit[rownames(labels), "metadataColour"]
    
  }
  
}


if ( ! is.null(opt$shape) ) {
  
  shapes <- structure(seq(1:length(levels(as.factor(metadata[ ,opt$shape ])))),
                      names = levels(as.factor(metadata[ ,opt$shape ])))
  
  fit$metadataShape <- as.factor(metadata[ ,opt$shape ])
  
  if ( ! is.null(opt$colour) ) {
    
    p <- ggplot( fit, add_modify_aes( mapping,
                                      aes( color = metadataColour, shape = metadataShape ) ) )
    
  } else {
    
    p <- ggplot( fit, add_modify_aes( mapping,
                                      aes( shape = metadataShape ) ) )
    
  }
  
  if ( opt$retrieve_coordinates_labels & ! is.null(opt$labels) ) {
    
    labels$metadataShape <- fit[rownames(labels), "metadataShape"]
    
  }
  
}

if ( ! is.null(opt$labels) ) {
  
  if (opt$retrieve_coordinates_labels) {
    
    p <- p + 
      geom_text_repel( data = labels,
                       aes( x = labels$x_axis, y = labels$y_axis, label = labels$my.labels ),
                       size = 3.5,
                       min.segment.length = unit( 0.1, "lines" ),
                       segment.size = 0.25,
                       segment.alpha = 0.3,
                       show.legend = FALSE ) +
      geom_point()
    
  } else {
    
    p <- ggplot( fit, aes( x = fit$x_axis, y = fit$y_axis ) ) +
      geom_text_repel( data = labels,
                       aes( x = labels[,1], y = labels[,2], label = labels[,3] ),
                       size = 3.5,
                       min.segment.length = unit( 0.1, "lines" ),
                       segment.size = 0.25,
                       segment.alpha = 0.3,
                       show.legend = FALSE )
    
    if ( ! is.null(opt$colour) ) {
      
      if ( ! is.null(opt$shape) ) {
        
        p <- p + 
          geom_point(aes( colour = metadataColour, shape = metadataShape )) +
          scale_colour_manual( values = palette ) +
          scale_shape_manual( values = shapes )
        
      } else {
        
        p <- p + 
          geom_point(aes( colour = metadataColour )) +
          scale_colour_manual( values = palette )
        
      }
      
    } else {
      
      if ( ! is.null(opt$shape) ) {
        
        p <- p + geom_point(aes( shape = metadataShape )) +
          scale_shape_manual( values = shapes )
        
      } else {
        
        p <- p + geom_point()
        
      }
      
    } 
    
  }
  
} else {
  
  p <- p + geom_point()
  
}

p <- p + 
  xlab( "z1" ) + 
  ylab( "z2" ) +
  theme_bw() + 
  theme( panel.border = element_blank(), 
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(), 
         axis.line = element_line(colour = "black"),
         plot.title = element_text(hjust = 0.5) )





if ( ! is.null(opt$title) ) {
  
  p <- p +
    labs( title = opt$title )
  
}

if ( ! is.null(opt$shape_legend_title) ) {
  
  p <- p +
    guides( shape = guide_legend( title = opt$shape_legend_title ) )
  
}

if ( ! is.null(opt$colour_legend_title) ) {
  
  p <- p +
    guides( colour = guide_legend( title = opt$colour_legend_title ) )
  
}


pdf( file = opt$output, paper="a4r", width = 32, height = 14 )
print(p)
dev.off()



#*******
# EXIT *
#*******

if ( opt$save ) {
  
  save( tsne.result, file = opt$robject )
  
} else {
  
  quit( save="no" )
  
}
