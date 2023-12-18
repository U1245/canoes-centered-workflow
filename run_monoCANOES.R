#launch CANOES
args<-commandArgs(TRUE)
############################################
#--------------------R---------------------#
############################################
# Launch CANOES analysis for each sample   #
# Generate a unique file per sample        #
############################################
# Version : v1.0.0                         #
############################################
# Authors                                  #
# Olivier Quenez <olivier.quenez@inserm.fr #
############################################
#	args[1] #path CANOES.R             #
#	args[2] #path gc file              #
#	args[3] #path reads file           #
#	args[4] #path to allSample list    #
#	args[5] #sample to analyses        #
############################################

source(args[1])

gc <- read.table(args[2])$V2
canoes.reads <- read.table(args[3])
sample.names <- unlist(read.table(args[4], stringsAsFactors=FALSE))
names(canoes.reads) <- c("chromosome", "start", "end", sample.names)
target <- seq(1, nrow(canoes.reads))
canoes.reads <- cbind(target, gc, canoes.reads)
xcnvs <- CallCNVs(args[5], canoes.reads)

write.csv2(xcnvs,file=paste0(args[5],".cnv.csv"))
