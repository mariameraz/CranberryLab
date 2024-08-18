library(ape)
library(phangorn)


## IN R
setwd('Documents/CranLab/DiversityPanel_PopStruc/DiversityPanel/Phylogeny/')

identity_matrix <- as.matrix(read.table("identity_matrix.rel", header = FALSE, sep = "\t", fill = TRUE))
ids <- read.table("identity_matrix.rel.id", header = FALSE, stringsAsFactors = FALSE)
sample_names <- as.character(ids$V1)  # Ajusta si la columna tiene otro nombre
rownames(identity_matrix) <- sample_names
colnames(identity_matrix) <- sample_names

metadata <- read.csv('/home/zalapa/Documents/CranLab/DiversityPanel_PopStruc/Metadata/metadata.csv')

distance_matrix <- 1 - identity_matrix

# Asegúrate de que los nombres de las filas y columnas de la matriz de distancia son de tipo character
rownames(distance_matrix) <- as.character(rownames(distance_matrix))
colnames(distance_matrix) <- as.character(colnames(distance_matrix))

# Crear un vector de mapeo desde el código a ID
code_to_id <- setNames(metadata$ID, metadata$Code)

# Reemplazar los nombres en la matriz de distancia
rownames(distance_matrix) <- code_to_id[rownames(distance_matrix)]
colnames(distance_matrix) <- code_to_id[colnames(distance_matrix)]

# Verifica los cambios
head(distance_matrix)

#write.table(distance_matrix, file="distance_matrix.txt", sep="\t", row.names=FALSE, col.names=FALSE)


# Convertir la matriz de distancias en un objeto de clase dist:
dist_obj <- as.dist(distance_matrix)

# Generar el arbol
nj_tree <- nj(dist_obj)
upgma_tree <- upgma(dist_obj)

# Vizualizar
plot(nj_tree, main = "Neighbor-Joining Tree", cex = 0.6)
plot(upgma_tree, main = "UPGMA Tree")

# Save the tree file
#BiocManager::install("ggtree")
library(ggtree)

ggtree(nj_tree) + geom_tiplab()

library(ggplot2)

ggtree(nj_tree, layout = "circular") +
  geom_tiplab(size = 3) +  # Ajusta el tamaño de las etiquetas
  theme_tree() +           # Ajusta el tema para una mejor visualización
  theme(legend.position = "left") 

# Save tree
write.tree(as.phylo(nj_tree), file = "phylogenetic_tree.nwk")
