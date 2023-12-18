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
#	args[5] #CNVs to genotype          #
#	args[6] #sample to genotype	   #
############################################
#launch CANOES
args<-commandArgs(TRUE)

source(args[1])

gc <- read.table(args[2])$V2
canoes.reads <- read.table(args[3])
sample.names <- unlist(read.table(args[4], stringsAsFactors=FALSE))
names(canoes.reads) <- c("chromosome", "start", "end", sample.names)
target <- seq(1, nrow(canoes.reads))
canoes.reads <- cbind(target, gc, canoes.reads)
x<-read.table(file=args[5],sep=";",header=T)
result <- GenotypeCNVs(x,args[6],canoes.reads)
addSample<-data.frame(matrix(args[6],nrow(result),1))
names(addSample)<-c("SAMPLE")
out <- cbind(addSample,result)
write.csv2(out,file=paste0(args[6],".genotype.csv"))
