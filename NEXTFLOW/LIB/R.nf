#!/usr/bin/nextflow

process callingCNV{
	tag "$sampleId"
	module 'canoes'
	errorStrategy 'ignore'
	cpus 1
	input :
		each sampleId
		tuple path(samples), path(reads), path(gc)
	output :
		tuple val(sampleId), path("${sampleId}.cnv.csv")
	script :
		sampleId=sampleId.replaceFirst(/\n/,"")
	"""
		Rscript $params.installFolder/run_monoCANOES.R $params.CANOES $gc $reads $samples $sampleId
	"""
}