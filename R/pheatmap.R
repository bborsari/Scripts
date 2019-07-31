#!/usr/bin/env Rscript


#*****************
# OPTION PARSING *
#*****************

suppressPackageStartupMessages(library("optparse"))

option_list <- list(
  
  make_option( c ( "--input", "-i" ), default = 'stdin',
               help = "Input matrix. 'stdin' for reading from standard input [default = %default]." ),
  
  make_option( c ( "--log", "-l"), default = FALSE,
               help = "Whether to apply the log10 to the input matrix [default = %default]."),
  
  make_option( c( "--pseudocount"), type = "numeric", default = 0.001,
               help = "The pseudocount to use when applying the log10 [default = %default]."),
  
  make_option( c( "--output", "-o" ), default = 'pheatmap.pdf',
               help = "Output file name [default = %default]." ),
  
  make_option( c( "--row_tree_output"), default = 'row.tree.output.tsv',
               help = "Row-tree output file name [default = %default]." ),
  
  make_option( c( "--col_tree_output"), default = 'col.tree.output.tsv',
               help = "Column-tree output file name [default = %default]." ),
  
  make_option( c( "--header" ), default = TRUE,
               help = "Whether the input matrix has header [default = %default]."),
  
  make_option( c( "--header_metadata" ), default = TRUE,
               help = "Whether the metadata files have header [default = %default]." ),
  
  make_option( c( "--row_metadata" ), default = NULL,
               help = "Metadata file for the rows. Can be 'stdin' [default = %default]." ),
  
  make_option( c( "--col_metadata" ), default = NULL,
               help = "Metadata file for the columns. Can be 'stdin' [default = %default]."),
  
  make_option( c("--no_hc" ), default = TRUE,
               help = "Whether to plot the heatmap following the row order of row_metadata, without performing hierarchical clustering [default = %default]."),
  
  make_option( c( "--by_row_hc" ), default = TRUE,
               help = "Whether to plot the heatmap performing only hc by rows [default = %default]."),

  make_option( c( "--by_col_hc" ), default = FALSE,
               help = "Whether to plot the heatmap performing only hc by cols [default = %default]."),
   
  make_option( c( "--joint_hc" ), default = FALSE,
               help = "Whether to perform hc by columns and by rows in the same plot [default = %default]."),
    
  make_option( c( "--by_row_method" ), default = 'complete',
               help = "The clustering method applied to rows [default = %default]."),
  
  make_option( c( "--by_col_method" ), default = 'complete',
               help = "The clustering method applied to cols [default = %default]."),
  
  make_option( c( "--joint_method" ), default = 'complete',
               help = "The clustering method applied jointly to rows and cols [default = %default]."),
  
  make_option( c( "--by_row_distance" ), default = 'euclidean',
               help = "The distance measure used to cluster rows [default = %default]."),
  
  make_option( c( "--by_col_distance" ), default = 'euclidean',
               help = "The distance measure used to cluster columns [default = %default]."),
  
  make_option( c( "--cut_tree_row" ), default = FALSE,
               help = "Whether to retrieve the row hierarchical clusters [default = %default]." ),
  
  make_option( c( "--cut_tree_col" ), default = FALSE,
               help = "Whether to retrieve the column hierarchical clusters [default = %default]." ),
  
  make_option( c( "--by_row_k"), default = NULL, type = "numeric",
               help = "The number of clusters you want to cut the row tree by [default = %default]."),
  
  make_option( c( "--by_col_k"), default = NULL, type = "numeric",
               help = "The number of clusters you want to cut the col tree by [default = %default]."),
  
  make_option( c( "--title", "-t" ), default = NULL,
               help = "The title of the plot [default = %default]."),
  
  make_option( c( "--palette_file", "-p" ), default = NULL,
               help = "File with first column as matrix palette [default = %default]."),
  
  make_option( c( "--palette_breaks" ), default = NULL,
               help = "A vector that is one element longer than the palette file, used to map specific ranges of values to specific colours. (e.g. \"\\-1,\\-0.5,0,0.5,1\") [default = %default]."),
  
  make_option( c( "--show_rownames" ), default = TRUE,
               help = "Whether to draw rownames [default = %default]."),
  
  make_option( c( "--show_colnames" ), default = TRUE,
               help = "Whether to draw colnames [default = %default]."),
  
  make_option( c( "--row_labels"), default = NULL, type = "numeric",
               help = "Column number of row_metadata that contains the row labels. If 'NULL', use the rownames of the input matrix [default = %default]."),
  
  make_option( c( "--col_labels"), default = NULL, type = "numeric",
               help = "Column number of col_metadata that contains the col labels. If 'NULL', use the colnames of the input matrix [default = %default]."),
  
  make_option( c( "--show_legend" ), default = TRUE,
               help = "Whether to draw or not the legend [default = %default]." ),
  
  make_option( c( "--show_annotation_legend" ), default = TRUE,
               help = "Whether to draw or not the legend for the annotation tracks [default = %default]." ),
  
  make_option( c("--legend_breakpoints"), default = NULL,
               help = "Vector of breakpoints for the legend [default = %default]." ),
  
  make_option( c("--legend_labels"), default = NULL,
               help = "Vector of labels for the legend_breakpoints [default = %default]." ),
  
  make_option( c("--annotation_colors"), default = NULL,
               help = "List to specify the colours of the fields for row_metadata and col_metadata. e.g.:\"Time = c(\"white\", \"firebrick\"), CellType = c(CT1 = \"#1B9E77\", CT2 = \"#D95F02\")\". Remember to escape quotes [default = %default]." ),
  
  make_option( c("--show_row_metadata_names"), default = TRUE,
               help = "Whether to draw the names for row annotation tracks [default = %default]." ),
  
  make_option( c("--show_col_metadata_names"), default = TRUE,
               help = "Whether to draw the names for column annotation tracks [default = %default]." ),
  
  make_option( c("--show_matrix_values"), default = FALSE,
               help = "Whether to show the numeric values within the cells [default = %default]." ),
  
  make_option( c("--width"), default = NULL, type = 'numeric',
               help = "Cell width [default = %default]." ),
  
  make_option( c("--height"), default = NULL, type = 'numeric',
               help = "Cell height [default = %default]." ),
  
  make_option( c("--fontsize"), default = 10,
               help = "Fontsize of the plot [default = %default]."),
  
  make_option( c("--rotate_colnames"), default = FALSE,
               help = "Rotate column names diagonally [default = %default].")
)

parser <- OptionParser(
  usage = "%prog [options] file", 
  option_list=option_list,
  description = "\nCan compute up to 4 different heatmaps with and without hierarchical clustering."
)

arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options


#************
# LIBRARIES *
#************

suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(pheatmap))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(grid))


#************
# FUNCTIONS *
#************

draw_colnames_45 <- function (coln, ...) {
  m = length(coln)
  x = (1:m)/m - 1/2/m
  grid.text(coln, x = x, y = unit(0.96, "npc"), vjust = .5, 
            hjust = 1, rot = 45, gp = gpar(...)) ## Was 'hjust=0' and 'rot=270'
}

draw_colnames_45 <- function (coln, gaps, ...) {
  coord = pheatmap:::find_coordinates(length(coln), gaps)
  x = coord$coord - 0.5 * coord$size
  res = textGrob(coln, x = x, y = unit(1, "npc") - unit(3,"bigpts"), vjust = 0.5, hjust = 1, rot = 45, gp = gpar(...))
  return(res)}

if (opt$rotate_colnames) {
  
  assignInNamespace(x="draw_colnames", value="draw_colnames_45", ns=asNamespace("pheatmap"))
  
}



#***************
# READ OPTIONS *
#***************


# read input matrix
if ( ! is.null(opt$input) ) {
  
 
  if (opt$input == 'stdin') {
    
    input.matrix <- read.table( file = 'stdin', header = opt$header, quote = NULL, sep="\t")
    
  } else {
    
    input.matrix <- read.table( file = opt$input, header = opt$header, quote = NULL, sep="\t")
    
  }
  
} else {
  
  print('Missing input matrix!')
  quit(save = 'no')
  
}


# read row metadata
if ( ! is.null(opt$row_metadata) ) {
  
  if ( opt$row_metadata == 'stdin' ) {
    
    my.annotation_row <- read.table( file = 'stdin', header = opt$header_metadata, quote = NULL )
    
  } else {
    
    my.annotation_row <- 
      read.table( file = opt$row_metadata, header = opt$header_metadata, quote = NULL)
    
  }
  
  if (! opt$header_metadata) {
    
    rownames(my.annotation_row) <- my.annotation_row$V1
    my.annotation_row$V1 <- NULL
    
  }
  
  for(i in 1:ncol(my.annotation_row)){
    
    my.annotation_row[, i] <- as.character(my.annotation_row[,i])
  }

} else {
  
  my.annotation_row <- NA
  
}



# read col metadata
if ( ! is.null(opt$col_metadata) ) {
  
  if ( opt$col_metadata == 'stdin' ) {
    
    my.annotation_col <- read.table( file = 'stdin', header = opt$header_metadata, quote = NULL )
    
  } else {
    
    my.annotation_col <- read.table( file = opt$col_metadata, header = opt$header_metadata, quote = NULL)
    
  }
  
  if (! opt$header_metadata) {
    
    rownames(my.annotation_col) <- my.annotation_col$V1
    my.annotation_col$V1 <- NULL
    
  }
  
  for(i in 1:ncol(my.annotation_col)){
    
    my.annotation_col[, i] <- as.character(my.annotation_col[,i])
  }
  
 
  
} else {
  
  my.annotation_col <- NA
  
}


# clustering method (joint)
my.clustering_method_joint <- opt$joint_method

# clustering method (by rows)
my.clustering_method_rows <- opt$by_row_method

# clustering method (by cols)
my.clustering_method_cols <- opt$by_col_method


# hierarchical clustering by rows
if ( opt$by_row_hc | opt$joint_hc ) {
  
  # clustering_distance_rows
  my.clustering_distance_rows <- opt$by_row_distance 
  
}


# hierarchical clustering by cols
if ( opt$by_col_hc | opt$joint_hc ) {

  # clustering_distance_cols
  my.clustering_distance_cols <- opt$by_col_distance
  
}



# read palette
if ( !is.null(opt$palette_file) ) {

  my.color <- as.character( read.table( file = opt$palette_file, comment.char='%' )$V1 )

} else {

  my.color <- colorRampPalette( rev( brewer.pal( n = 7, name = "RdYlBu" ) ) )(100)

}



# palette breaks

if ( !is.null(opt$palette_breaks) ) {
  
  opt$palette_breaks <- gsub( "\\", "", opt$palette_breaks, fixed = TRUE )
  my.breaks <- as.numeric( strsplit( opt$palette_breaks, "," )[[1]] )

} else {
  
  my.breaks <- NA 
    
}



# show row names
my.show_rownames <- opt$show_rownames


# show col names 
my.show_colnames <- opt$show_colnames


# row labels
if ( !is.null(opt$row_labels) ) {
  
  c <- opt$row_labels
  my.labels_row <- my.annotation_row[ ,c ]
  
} else {
  
  my.labels_row <- NULL
  
}


# col labels
if ( !is.null(opt$col_labels) ) {
  
  c <- opt$col_labels
  my.labels_col <- my.annotation_col[ ,c ]
  
} else {
  
  my.labels_col <- NULL
  
}




# legend breakpoints
if ( !is.null(opt$legend_breakpoints) ) {
  
  opt$legend_breakpoints <- gsub( "\\", "", opt$legend_breakpoints, fixed = TRUE )
  my.legend_breaks <- as.numeric( strsplit( opt$legend_breakpoints, "," )[[1]] )
  
} else {
  
  my.legend_breaks <- NA
  
}


# legend labels
if ( !is.null(opt$legend_labels) ) {
  
  opt$legend_labels <- gsub( "\\", "", opt$legend_labels, fixed = TRUE )
  my.legend_labels <- as.numeric( strsplit( opt$legend_labels, "," )[[1]] )
  
} else {
  
  my.legend_labels <- NA
  
}




# annotation colors
if ( !is.null(opt$annotation_colors) ) {
  
  x <- paste0( "list(", opt$annotation_colors, ")" )
  my.annotation_colors <- eval( parse( text = x ) )
  
} else {
  
  my.annotation_colors <- NA
  
}



# annotation names
my.annotation_names_row <- opt$show_row_metadata_names
my.annotation_names_col <- opt$show_col_metadata_names


# show numbers within the cells
my.display_numbers <- opt$show_matrix_values


# heatmap width
if ( !is.null(opt$width) ){
  
  my.width <- opt$width
  
} else {
  
  my.width <- NA
  
}


# heatmap height
if ( !is.null(opt$height) ){
  
  my.height <- opt$height
  
} else {
  
  my.height <- NA
  
}


  
#********
# BEGIN *
#********

my.legend = FALSE
my.annotation_legend = FALSE



my.plot.list <- list()
i <- 1

if ( opt$log ) {
  
  input.matrix <- log10(input.matrix + opt$pseudocount)
  
}


if ( opt$no_hc ) {
  
  roworder <- rownames(my.annotation_row)
  sorted.input.matrix <- input.matrix[ roworder, ]
  sorted.input.matrix <- as.matrix(sorted.input.matrix)
  
  if ( opt$by_row_hc | opt$by_col_hc | opt$joint_hc ) {
    
    my.legend = FALSE
    my.annotation_legend = FALSE
    
  } else {
    
    if ( opt$show_legend ) {
      
      my.legend = TRUE
    
    }
    
    if ( opt$show_annotation_legend ) {
      
      my.annotation_legend = TRUE
      
    }
    
}
  

  
  
  my.plot.list[[i]] <- pheatmap( mat = sorted.input.matrix,
                                 color = my.color,
                                 breaks = my.breaks,
                                 cluster_rows = FALSE,
                                 cluster_cols = FALSE,
                                 legend = my.legend,
                                 legend_breaks = my.legend_breaks,
                                 legend_labels = my.legend_labels,
                                 annotation_row = my.annotation_row,
                                 annotation_col = my.annotation_col,
                                 annotation_legend = my.annotation_legend,
                                 annotation_names_row = my.annotation_names_row,
                                 annotation_names_col = my.annotation_names_col,
                                 annotation_colors = my.annotation_colors,
                                 show_rownames = my.show_rownames,
                                 show_colnames = my.show_colnames,
                                 labels_row = my.labels_row,
                                 labels_col = my.labels_col,
                                 fontsize = opt$fontsize,
                                 main = "Metadata row order",
                                 cellwidth = my.width,
                                 cellheight = my.height,
                                 display_numbers = my.display_numbers,
                                 border_color = F)$gtable
  i <- i+1
}


if ( opt$by_row_hc ) {
  
  if ( opt$by_col_hc | opt$joint_hc ) {
    
    my.legend = FALSE
    my.annotation_legend = FALSE
    
  } else {
    
    if ( opt$show_legend ) {
      
      my.legend = TRUE
      
    }
    
    if ( opt$show_annotation_legend ) {
      
      my.annotation_legend = TRUE
      
    }
    
  }
  
  

  my.by.row.pheatmap <- pheatmap( mat = input.matrix,
                                  color = my.color,
                                  breaks = my.breaks,
                                  cluster_rows = TRUE,
                                  cluster_cols = FALSE,
                                  clustering_distance_rows = my.clustering_distance_rows,
                                  clustering_method = my.clustering_method_rows,
                                  legend = my.legend,
                                  legend_breaks = my.legend_breaks,
                                  legend_labels = my.legend_labels,
                                  annotation_row = my.annotation_row,
                                  annotation_col = my.annotation_col,
                                  annotation_legend = my.annotation_legend,
                                  annotation_names_row = my.annotation_names_row,
                                  annotation_names_col = my.annotation_names_col,
                                  annotation_colors = my.annotation_colors,
                                  show_rownames = my.show_rownames,
                                  show_colnames = my.show_colnames,
                                  labels_row = my.labels_row,
                                  labels_col = my.labels_col,
                                  fontsize = opt$fontsize,
                                  main = paste0( "Hierarchical clustering by rows - ",
                                                 my.clustering_distance_rows,
                                                 " distance"),
                                  cellwidth = my.width,
                                  cellheight = my.height,
                                  display_numbers = my.display_numbers,
                                  border_color = F)
  
  my.plot.list[[i]] <- my.by.row.pheatmap$gtable
  
  if ( opt$cut_tree_row ) {
    
    cluster_row = as.data.frame( cutree( my.by.row.pheatmap$tree_row, k = opt$by_row_k ) )
    colnames(cluster_row) <- "hierarchical_cluster"
    write.table( cluster_row, opt$row_tree_output, quote = FALSE, sep = '\t' )
    cut_tree_row <- FALSE
    
  }
  
  i <- i+1
  
}


if ( opt$by_col_hc ) {
  
  if ( opt$joint_hc ) {
    
    my.legend = FALSE
    my.annotation_legend = FALSE
    
  } else {
    
    if ( opt$show_legend ) {
      
      my.legend = TRUE
      
    }
    
    if ( opt$show_annotation_legend ) {
      
      my.annotation_legend = TRUE
      
    }
    
  }
  
  
  my.by.col.pheatmap <- pheatmap( mat = input.matrix,
                                  color = my.color,
                                  breaks = my.breaks,
                                  cluster_rows = FALSE,
                                  cluster_cols = TRUE,
                                  clustering_distance_cols = my.clustering_distance_cols,
                                  clustering_method = my.clustering_method_cols,
                                  legend = my.legend,
                                  legend_breaks = my.legend_breaks,
                                  legend_labels = my.legend_labels,
                                  annotation_row = my.annotation_row,
                                  annotation_col = my.annotation_col,
                                  annotation_legend = my.annotation_legend,
                                  annotation_names_row = my.annotation_names_row,
                                  annotation_names_col = my.annotation_names_col,
                                  annotation_colors = my.annotation_colors,
                                  show_rownames = my.show_rownames,
                                  show_colnames = my.show_colnames,
                                  labels_row = my.labels_row,
                                  labels_col = my.labels_col,
                                  fontsize = opt$fontsize,
                                  main = paste0( "Hierarchical clustering by columns - ",
                                                 my.clustering_distance_cols,
                                                 " distance"),
                                  cellwidth = my.width,
                                  cellheight = my.height,
                                  display_numbers = my.display_numbers,
                                  border_color = F)
  
  my.plot.list[[i]] <- my.by.col.pheatmap$gtable
  
  if ( opt$cut_tree_col ) {
    
    cluster_col = as.data.frame( cutree( my.by.col.pheatmap$tree_col, k = opt$by_col_k ) )
    colnames(cluster_col) <- "hierarchical_cluster"
    write.table( cluster_col, opt$col_tree_output, quote = FALSE, sep = '\t' )
    cut_tree_col <- FALSE
    
  }
  
  
  
  i <- i+1
  
}



if ( opt$joint_hc ) {
  
  if ( opt$show_legend ) {
    
    my.legend = TRUE
    
  }
  
  if ( opt$show_annotation_legend ) {
    
    my.annotation_legend = TRUE
    
  }
  
  my.joint.pheatmap <- pheatmap( mat = input.matrix,
                                 color = my.color,
                                 breaks = my.breaks,
                                 cluster_rows = TRUE,
                                 cluster_cols = TRUE,
                                 clustering_distance_rows = my.clustering_distance_rows,
                                 clustering_distance_cols = my.clustering_distance_cols,
                                 clustering_method = my.clustering_method_joint,
                                 legend = my.legend,
                                 legend_breaks = my.legend_breaks,
                                 legend_labels = my.legend_labels,
                                 annotation_row = my.annotation_row,
                                 annotation_col = my.annotation_col,
                                 annotation_legend = my.annotation_legend,
                                 annotation_names_row = my.annotation_names_row,
                                 annotation_names_col = my.annotation_names_col,
                                 annotation_colors = my.annotation_colors,
                                 show_rownames = my.show_rownames,
                                 show_colnames = my.show_colnames,
                                 labels_row = my.labels_row,
                                 labels_col = my.labels_col,
                                 fontsize = opt$fontsize,
                                 main = paste0( "Hierarchical clustering by rows & columns - ",
                                                my.clustering_distance_rows, " & ",
                                                my.clustering_distance_cols,
                                                " distances"),
                                 cellwidth = my.width,
                                 cellheight = my.height,
                                 display_numbers = my.display_numbers,
                                 border_color = F)
  
  my.plot.list[[i]] <- my.joint.pheatmap$gtable
  
  if ( opt$cut_tree_row ) {
    
    cluster_row = as.data.frame( cutree( my.joint.pheatmap$tree_row, k = opt$by_row_k ) )
    colnames(cluster_row) <- "hierarchical_cluster"
    write.table( cluster_row, opt$row_tree_output, quote = FALSE, sep = '\t' )
    
  }
  
  if ( opt$cut_tree_col ) {
    
    cluster_col = as.data.frame( cutree( my.joint.pheatmap$tree_col, k = opt$by_col_k ) )
    colnames(cluster_col) <- "hierarchical_cluster"
    write.table( cluster_col, opt$col_tree_output, quote = FALSE, sep = '\t' )
    
  }
  
}


whole.plot <- plot_grid( plotlist = my.plot.list, align = "hv", scale = 0.75 )

if ( !is.null(opt$title) ){
  
  whole.plot <- whole.plot +
    draw_figure_label( label = opt$title ,
                       size = 10,
                       position = "top.left",
                       fontface = "bold")
  
  
}
  

pdf( file = opt$output, paper="a4r", width = 32, height = 14 )
print(whole.plot)
dev.off()



#*******
# EXIT *
#*******

quit( save = "no" )


