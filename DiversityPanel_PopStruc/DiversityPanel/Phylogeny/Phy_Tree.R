## Using the previously builded identity matrix: 

setwd('Documents/CranLab/DiversityPanel_PopStruc/DiversityPanel/Phylogeny/')

identity_matrix <- as.matrix(read.table("identity_matrix.rel", header = FALSE, sep = "\t", fill = TRUE))
ids <- read.table("identity_matrix.rel.id", header = FALSE, stringsAsFactors = FALSE)
sample_names <- as.character(ids$V1)  # Ajusta si la columna tiene otro nombre
rownames(identity_matrix) <- sample_names
colnames(identity_matrix) <- sample_names

metadata <- read.csv('/home/zalapa/Documents/CranLab/DiversityPanel_PopStruc/Metadata/metadata.csv')

distance_matrix <- 1 - identity_matrix
write.table(distance_matrix, file="distance_matrix.txt", sep="\t", row.names=FALSE, col.names=FALSE)


library(ape)
library(phangorn)

# Convertir la matriz de distancias en un objeto de clase dist:
dist_obj <- as.dist(distance_matrix)


# Generar el arbol
nj_tree <- nj(dist_obj)
upgma_tree <- upgma(dist_obj)

# Vizualizar
plot(nj_tree, main = "Neighbor-Joining Tree", cex = 0.8)
plot(upgma_tree, main = "UPGMA Tree")

# Save the tree file
BiocManager::install("ggtree")
library(ggtree)

ggtree(nj_tree) + geom_tiplab()
