#!/usr/bin/nextflow

process gcCount{
	cpus 1
	module 'gatk'

	input :
		path kitExtended
	output :
		path "gcCount.txt"
	script :
	"""
		gatk3 -Xmx2g -T GCContentByInterval -L $kitExtended -R $params.reference -o gcCount.txt
	"""
}