#!/usr/bin/nextflow

process annotSV{
	tag "$sampleId"
	publishDir "${params.srcFolder}/CANOES/", mode : 'copy'
    cpus 1
	module 'annotsv'
    errorStrategy 'ignore'
	input :
		tuple val(sampleId), path(cnv)
	output :
		tuple val(sampleId), path("${sampleId}.cnv.annot.tsv")
	script :
	"""	
		\$ANNOTSV/bin/AnnotSV -SVinputFile $cnv -SVinputInfo 1 -outputDir . -outputFile ${sampleId}.cnv.annot.tsv -genomeBuild GRCh37 -svtBEDcol 5
	"""
}