#!/usr/bin/nextflow

process compilSample{
	tag "${params.project}"
	cpus 1
	module 'perl'

	input :
		path(readCount) 
	output :
		tuple path("${params.project}.sample.list"), path("${params.project}.reads.txt")
		path ("${params.project}.sample.list")
	script :
	"""
		echo -e "${readCount.join('\n')}" | sed -e "s/\\.reads\\.txt//" > ${params.project}.sample.list
		perl $params.installFolder/compilSample.pl -sample ${params.project}.sample.list -output ${params.project}.reads.txt
	"""

}


process cleanEntries{
	publishDir "${params.srcFolder}/READCOUNT/", mode : 'copy'
	tag "$params.project"
	cpus 1
	module 'perl'

	input :
		tuple path(samples), path (reads)
		path(gcCount)
	output :
		tuple path(samples), path ("${params.project}.clean.reads.txt"), path ("${params.project}.clean.gc.txt")
	script :
	"""
		perl $params.installFolder/cleanCANOESentries.pl --gc $gcCount --reads $reads --outPrefix ${params.project}.clean
	"""
}

process csvToBed{
	tag "$sampleId"
	publishDir "${params.srcFolder}/CANOES/", mode : 'copy'
	cpus 1
	module 'perl'
	errorStrategy 'ignore'
	input :
		tuple val(sampleId), path(csvFile)
	output :
		tuple val(sampleId), path("${sampleId}.cnv.bed")
		
	script :
	"""
		touch ${sampleId}.cnv.bed
		perl $params.installFolder/extractToBedFormat.pl -in $csvFile -out ${sampleId}.cnv.bed
	"""
}