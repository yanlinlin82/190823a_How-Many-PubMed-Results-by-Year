library(tidyverse)

a <- read_tsv("data/gene-results.txt")
g <- a %>%
  left_join(a %>%
              distinct(gene, cosmic) %>%
              arrange(desc(cosmic)) %>%
              mutate(order = row_number()),
            by = c("gene", "cosmic")) %>%
  mutate(name = sprintf("(%d) %s", order, gene),
         name = factor(name, unique(name))) %>%
  filter(year >= 1980, year <= 2019) %>%
  ggplot(aes(x = year, y = pubmed, group = name)) +
  geom_line() +
  geom_point() +
  facet_wrap(~ name, nrow = 5) +
  scale_y_continuous(trans = "log10") +
  scale_x_continuous(breaks = seq(1980,2020,by=2)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
  geom_vline(xintercept = c(1980,1990,2000,2010,2020),
             alpha = .5, color = "blue", size = .2) +
  labs(x = "Year", y = "PubMed Results") +
  ggtitle("How Top-20 COSMIC Genes Are Studied?")
g %>% ggsave(filename = "genes.png", width = 12, height = 8)
