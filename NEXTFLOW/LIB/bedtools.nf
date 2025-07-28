#!/usr/bin/nextflow

process defineTarget {

    cpus 1 
    module 'bedtools'

    input:
        path (initialTarget)

    output:
        path 'merged.bed'
	
	script:
    """

		bedtools merge -d 30 -i  $initialTarget | sort -k1,1 -k2,2n > merged.bed

    """
}

process countReads{
	tag "${sampleId}"
    publishDir "${params.srcFolder}/READCOUNT/", mode : 'copy'
	module 'bedtools'
	maxForks 36
	cpus 1
	
	input :
		tuple val(sampleId), path(bam)
        each path (target)
	output :
		path("${sampleId}.reads.txt") 
	script :
	"""
		CRAM_REFERENCE=$params.reference
		bedtools multicov -bams ${bam[0]} -bed $target -q 20 > ${sampleId}.reads.txt
	"""
}