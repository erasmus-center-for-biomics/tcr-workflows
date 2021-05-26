#!/bin/env Rscript

#
library(tidyverse)
library(cowplot)
library(ggbeeswarm)


# prepare the output directory
outdir <- 'report'
if(!dir.exists(outdir))
  dir.create(outdir)

#
# Loading the data
#

# read the welllist
welllist <- read_tsv('welllist.txt') %>%
  mutate(
    cellid = str_c(Sample, Row, Col, sep = '_')
  )

# get the demultiplexed cluster
demultiplexed <- read_delim(
  'demultiplexed_reads.csv', " ", 
  trim_ws = TRUE, col_names = c('clusters', 'x'),
  col_types = 'ic') %>%
  separate(x, c('file', 'y'), sep = ',') %>%
  mutate(cellid = str_remove(basename(file), '_R1.fastq')) %>%
  select(-y, -file) 


# get the assembled reads
assembled <- read_delim(
  'assembled_reads.csv', " ", 
  trim_ws = TRUE, col_names = c('assembled', 'x'),
  col_types = 'ic') %>%
  separate(x, c('file', 'y'), sep = ',') %>%
  mutate(cellid = str_remove(basename(file), '.assembled.fastq')) %>%
  select(-y, -file) 


# get 
reports <- file.path('tcr-blast', list.files('tcr-blast', pattern = '.report.csv')) %>%
  map_df(function(path){
    read_delim(path, ";", col_types = 'ccclcccd') %>%
      mutate(
        cellid = str_remove(basename(path), '.report.csv'))
  }) 

report_tbl <- left_join(
  reports %>%
    group_by(cellid, locus) %>%
    mutate(
      fraction = n / sum(n),
      rnk = rank(-fraction)
    ) %>%
    ungroup() %>%
    filter(rnk <= 2) %>%
    group_by(cellid, locus) %>%
    summarise(
      fraction = sum(fraction)
    ) %>%
    ungroup() %>%
    pivot_wider(
      cellid,
      names_from = locus,
      names_prefix = "fraction ",
      values_from = fraction
    ),
  reports %>%
    group_by(cellid, locus) %>%
    summarise(
      n = sum(n)
    ) %>%
    ungroup() %>%
    pivot_wider(
      cellid,
      names_from = locus,
      names_prefix = "clusters ",
      values_from = n
    ),
  by = 'cellid'
)

# combine the data
all_tbl <- left_join( 
  left_join(
    welllist %>%
      select(cellid, sample = Sample, row = Row, col = Col),
    left_join(
      demultiplexed,
      assembled,
      by = 'cellid'),
    by = 'cellid'),
  report_tbl,
  by = 'cellid')

write_tsv(all_tbl, file.path(outdir, 'combined_data.tsv'))

#
# Plots
#

cell_plt <- all_tbl %>%
  mutate(
    `no receptor` = is.na(`clusters TRA`) & is.na(`clusters TRA`)
  ) %>%
  ggplot(aes(x = sample, fill = `no receptor`)) +
  labs(y = 'Cells (n)') +
  geom_bar(colour = 'gray80') +
  scale_fill_manual(values = c('FALSE' = 'gray50', 'TRUE' = 'darkred')) +
  theme_light()

ggsave(
  cell_plt, 
  filename = file.path(outdir, 'cell_plot.png'), 
  width = 8, height = 4, dpi = 600)

# yield plot
yld_plt <- all_tbl %>%
  pivot_longer(
    cols = c(clusters, assembled),
    names_to = "type",
    values_to = "fragments"
  ) %>%
  mutate(
    type = parse_factor(type, levels = c('clusters', 'assembled'))
  ) %>%
  ggplot(aes(x = sample, y = fragments/1e3, fill = type)) +
  geom_bar(stat = 'identity', position = 'dodge', colour = 'gray20') +
  labs(y = 'Clusters (K)') +
  scale_y_continuous(breaks = seq(0, 10000, 50)) +
  theme_light()

ggsave(
  yld_plt, 
  filename = file.path(outdir, 'yield_plot.png'), 
  width = 8, height = 4, dpi = 600)


# receptor plot
X <- all_tbl %>%
  pivot_longer(
    cols = c(`clusters TRA`, `clusters TRB`),
    names_to = "locus",
    values_to = "fragments"
  ) %>%
  mutate(
    locus = str_remove(locus, 'clusters '),
    locus = parse_factor(locus, levels = c('TRA', 'TRB')),
    fragments = ifelse(is.na(fragments), 0, fragments)
  )
S <- X %>% 
  group_by(sample, locus) %>% 
  summarise(
    med = median(fragments), 
    q25 = quantile(fragments, probs = 0.25),
    q75 = quantile(fragments, probs = 0.75)) %>%
  ungroup()

receptor_plt <- X %>%
  ggplot(aes(x = sample, y = fragments + 1)) +
  geom_beeswarm(pch = 21, fill = 'gray20', colour = 'gray80') +
  geom_hline(aes(yintercept = q25+1), linetype = 2, colour = 'red', data = S) +
  geom_hline(aes(yintercept = med+1), linetype = 2, data = S) +
  geom_hline(aes(yintercept = q75+1), linetype = 2, colour = 'blue', data = S) +
  labs(y = 'Fragments (+1)') +
  scale_y_continuous(
    trans = 'log10', 
    breaks = c(1, 10, 100, 1e3, 1e4, 1e5, 1e6),
    minor_breaks = c(5, 50, 500, 5e3, 5e4, 5e5, 5e6)) +
  facet_grid(locus ~ sample, scales = 'free_x') +
  theme_light()

ggsave(
  receptor_plt, 
  filename = file.path(outdir, 'receptor_plot.png'), 
  width = 12, height = 8, dpi = 600)
