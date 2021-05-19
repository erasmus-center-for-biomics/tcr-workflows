#!/bin/env Rscript

library(tidyverse)

indir <- 'hisat2'
rpc_files <- file.path(indir, list.files(indir, pattern='.rpc$'))
mpc_files <- file.path(indir, list.files(indir, pattern='.mpc$'))


#
data <- left_join(
    rpc_files %>%
        map_df(function(path) {
            read_tsv(path) %>%
                mutate(sample = str_remove(path, '.rpc$'))
        }),
    mpc_files %>%
        map_df(function(path) {
            read_tsv(path) %>%
                mutate(sample = str_remove(path, '.mpc$'))
        }),
    by = c('cellid', 'sample')) %>%
    select(sample, cellid, reads = count, mapped) %>%
    mutate(
        `% mapping` = mapped / reads * 100
    )

write_tsv(data, 'hisat2/cell_overview.txt')