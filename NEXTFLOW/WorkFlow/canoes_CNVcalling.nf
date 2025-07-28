#!/usr/bin/nextflow

include { defineTarget;countReads } from "../LIB/bedtools.nf"
include { gcCount } from "../LIB/gatk.nf"
include { compilSample; cleanEntries; csvToBed } from "../LIB/perl.nf"
include { callingCNV } from "../LIB/R.nf"
include { annotSV } from "../LIB/annotSV.nf"


workflow {

    main :
        target_ch = Channel.fromPath(params.kitCNV)
        bam_ch = Channel.fromFilePairs(params.bams)
        defineTarget(target_ch)
        gcCount(defineTarget.out)
        countReads(bam_ch,defineTarget.out)
        compilSample(countReads.out.collect())
        cleanEntries(compilSample.out[0],gcCount.out)
        sample_ch = compilSample.out[1].splitText()
        callingCNV(sample_ch,cleanEntries.out)
        csvToBed(callingCNV.out)
        annotSV(csvToBed.out)
}

