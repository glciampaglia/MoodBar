pp <- read.table('../../data/pp_control_treatment.tsv', header=T, sep='\t')
pp <- within(pp, {
             date <- as.Date(date)
})
siz <- read.table('../../data/ppsize.tsv', header=T, sep='\t')



