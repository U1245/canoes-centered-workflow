#!/usr/bin/env nextflow

/*****************************************************  
 *--------------------NEXTFLOW-----------------------*
 *****************************************************  
 * NGS pipeline processes for CANOES analysis        * 
 * Can be configured using nextflow settings         * 
 ***************************************************** 
 * Version : v1.0.0                                  * 
 ***************************************************** 
 * #### Authors                                      *
 * Olivier Quenez   <olivier.quenez@inserm.fr>       * 
 * Sophie Coutant   <sophie.coutant@inserm.fr>       * 
 *****************************************************/


/*** Assuming Nextflow to be launched from run folder* 
 * ------------------------------------------------- * 
 *** ---- Command to use to launch Nextflow : ---- *** 
 * --------------------------------------------------* 
 *---> nextflow callingCNV.nf \  
 *     -c project.config \ 
 *     -c calling.config \
 *     -with-report NextflowProcess-report.html \ 
 *     -with-trace trace.txt  
 ****/


kit_file	= file(params.kit)
srcFolder	= file(params.srcFolder)
project		= params.project
bam_ch		= Channel.fromFilePairs(params.bams)
installFolder	= file(params.installFolder)
reference 	= file(params.reference)
canoes		= params.CANOES

	/**************************************
 	 *--------Redefine captureKit---------*
 	 *************************************/

process 'defineTarget'{

	cpus 1
	module 'bedtools'

	input :
		file(kit_File) from kit_file
	output :
		file("extendKit.bed") into (extendedKit_ch,gcCountKit_ch)
	script :
	"""
                bedtools merge -d 30 -i $kit_file > tmp2
                sort -k 1,1 -k2,2n tmp2 > extendKit.bed
	"""
}

        /**************************************
         *---------Calculate GC ratio---------*
         *************************************/

process 'gcCount'{
	cpus 1
	module 'gatk'

	input :
		file kitExtended from gcCountKit_ch
	output :
		file ("gcCount.txt") into gcCount_ch
	script :
	"""
		gatk3 -Xmx2g -T GCContentByInterval -L $kitExtended -R $reference -o gcCount.txt
	"""
}

        /**************************************
         *-----ReadCount for each sample------*
         *************************************/

process 'countReads'{
	tag "${sampleId}"
        publishDir "${srcFolder}/READCOUNT/", mode : 'copy'
	module 'bedtools'
	maxForks 36
	cpus 1
	
	input :
		set sampleId, file(bam) from bam_ch
		file (target) from extendedKit_ch
	output :
		file("${sampleId}.reads.txt") into read_ch
	script :
	"""
		CRAM_REFERENCE=$reference
		bedtools multicov -bams ${bam[0]} -bed $target -q 20 > ${sampleId}.reads.txt
	"""
}

        /**************************************
         *---------Regroup readCount----------*
         *************************************/

process 'compilSample'{
	tag "${project}"
	cpus 1
	input :
		file(read) from read_ch.collect()

	output :
		set file("${project}.sample.list"), file("${project}.reads.txt") into projectRead_ch
		file ("${project}.sample.list") into sampleSplit_ch
	script :
	"""
		echo -e "${read.join('\n')}" | sed -e "s/\\.reads\\.txt//" > ${project}.sample.list
		perl $installFolder/compilSample.pl -sample ${project}.sample.list -output ${project}.reads.txt
	"""

}

        /*****************************************************************************
         *cleanEntries:                                                              *
	 *- remove Region with more than 90% of the sample above 10 reads            *
	 *- check for "chr" before the chromosome name, avoid sorting error in CANOES*
	 *- generate two file with the same number of rows                           *
         ****************************************************************************/

process 'cleanEntries'{
	publishDir "${srcFolder}/READCOUNT/", mode : 'copy'
	tag "$project"
	cpus 1
	input :
		set file(samples), file (reads) from projectRead_ch
		file gcCount from gcCount_ch
	output :
		set file(samples), file ("${project}.clean.reads.txt"), file ("${project}.clean.gc.txt") into cleanEntries_ch
	script :
	"""
		perl $installFolder/cleanCANOESentries.pl --gc $gcCount --reads $reads --outPrefix ${project}.clean
	"""
}

sample_ch = sampleSplit_ch.splitText()

        /**************************************
         *--------CANOES CNV calling----------*
         *************************************/

process 'callingCNV'{
	tag "$sampleId"
	module 'canoes'
	errorStrategy 'ignore'
	cpus 1
	input :
		val sampleId from sample_ch
		set file(samples), file(reads), file(gc) from cleanEntries_ch 
	output :
		set sampleId, file ("${sampleId}.cnv.csv") into callCNVraw_ch
	script :
		sampleId=sampleId.replaceFirst(/\n/,"")
	"""
		Rscript $installFolder/run_monoCANOES.R $canoes $gc $reads $samples $sampleId

	"""
}

        /***************************************
         *--Conversion from csv to Bed Format--*
         **************************************/

process 'csvToBed'{
	tag "$sampleId"
	publishDir "${srcFolder}/CANOES/", mode : 'copy'
	cpus 1
	errorStrategy 'ignore'
	input :
		set sampleId, file (csvFile) from callCNVraw_ch
	output :
		set sampleId, file ("${sampleId}.cnv.bed") into callCNV_ch
		
	script :
	"""
		touch ${sampleId}.cnv.bed
		perl $installFolder/extractToBedFormat.pl -in $csvFile -out ${sampleId}.cnv.bed
	"""
}

        /**************************************
         *-------Annotate using annotSV-------*
         *************************************/

process 'annotSV'{
	tag "$sampleId"
	publishDir "${srcFolder}/CANOES/", mode : 'copy'
        cpus 1
	module 'annotsv'
        errorStrategy 'ignore'
	input :
		set sampleId, file (cnv) from callCNV_ch
	output :
		set sampleId, file ("${sampleId}.cnv.annot.tsv") into annotCNV_ch
	script :
	"""	
		\$ANNOTSV/bin/AnnotSV -SVinputFile $cnv -SVinputInfo 1 -outputDir . -outputFile ${sampleId}.cnv.annot.tsv -genomeBuild GRCh37 -svtBEDcol 5
	"""
}
