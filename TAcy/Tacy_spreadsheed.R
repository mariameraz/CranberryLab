# Expandir el data frame
expanded_data <- data.frame()

# Definir combinaciones de pH y Rep
for (i in 1:nrow(data)) {
  for (Rep in 1:2) {
    for (pH in c(1, 4.5)) {
      new_row <- data.frame(
        Sample_name = data$Sample_name[i],
        Row = data$Row[i],
        Col = data$Col[i],
        Code = paste(data$Row[i], data$Col[i], sep = "-"),
        pH = pH,
        Rep = Rep
      )
      expanded_data <- rbind(expanded_data, new_row)
    }
  }
}

# Ordenar las filas de acuerdo al formato deseado
expanded_data <- expanded_data[order(expanded_data$Sample_name, expanded_data$Rep, expanded_data$pH), ]

# Mostrar el data frame expandido y ordenado
print(expanded_data)
write.csv(expanded_data, 'tacy_format.csv',quote = F)
