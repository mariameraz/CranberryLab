library(tidiyverse)
library(ggplot2)
lib.size <- read.table('Documents/ABEJAS/lib_size.txt', header = F) %>%
  'colnames<-'(c('lib.name','reads'))

lib.size$lib.name <- gsub('_S.*', '', lib.size$lib.name)
lib.size <- lib.size %>% 
  mutate(primer = gsub('.*-','',lib.size$lib.name))

ggplot(lib.size, aes(x = lib.name, y = reads, fill = primer)) +
  geom_bar(stat="identity") +
  theme(axis.text.x =  element_text(angle = 90))
                 