# CANOES-centered workflow

The complete workflow is fully describe in "[Detection of copy-number variations from NGS data using read depth information: a diagnostic performance evaluation](https://www.nature.com/articles/s41431-020-0672-2)".

It is important to run this workflow with at least 30 samples. You can try with less, but precision can be reduced.


# Workflow description

Our work was to develop this analysis pipeline, and to define best practices for the upstream preparation of the data.

In order to obtain the best result, it is important:
* to analyses at least 30 samples (CANOES recommendation). You can increase the number of samples, but increasing the sample size will also increase computational time. We usually analysis sample per maximum 100 samples.
* to analyses samples as close as possible technically: ideally, samples has to come from the same sequencing run. If it's impossible (for example, if you have less than 30 samples per run), you can combine samples from different run/batch.


The bioinformatic pipeline is composed of 8 steps:

_Capture kit redefinition_

In order to reduce noise and false positive or false negative calls, the wrokflow starts by merging closed targets (less than 30bp). 

_Calculate GC content on each target_

CANOES use the GC ratio of each target to reduce capture bias and his impact on read depth. 

_ReadCount for each sample separately_

For each sample, we calculate the Depth of Coverage (DoC) for each target and for each sample separately. 

_Aggregate all samples_

We aggregate DoC sample files to generate an unique DoC file. Currently, we merge all samples, but new implementations will be available in order to take into account :
- male and female in order to analyse gonosome
- separate related samples using a standard pedigree file

_Clean data before calling_

We remove all regions from DoC where more than 90% of the cohort have less than 10reads aligned on the target. It allows to remove non information regions, leading to a gain in computational time.

_Calling CNVs using CANOES_

For each sample, CNVs are called using CANOES, one process per sample.

_Conversion from csv to bed format_

Convertion from csv format to standard bed format.

_Annotation using annotSV_

Annotation sample by sample using AnnotSV. See [AnnotSV documentation](https://lbgi.fr/AnnotSV/annotations) for more details.

# Requirement  

In order to use this pipeline, you will need :
* [Nextflow](https://www.nextflow.io/): a data driven workflow manager that encapsulate all the step 
* [bedtools v2.28 or superior](https://bedtools.readthedocs.io/en/latest/): a toolkit to manipulate bed files. If you plan to analyse data stored in CRAM format, it is mandatory to get a version >= 2.28.
* [gatk v3.X](https://software.broadinstitute.org/gatk/): the broad institute well established toolkit, here use to calculate the gc content of targeted regions.
* Perl (generally already installed on Linux distribution)
* R (also already available on Linux distribution)
* [CANOES.R](http://www.columbia.edu/~ys2411/canoes/) also available on this git repository
* Mandatory R package to Run CANOES : nnls, Hmisc, mgcv and plyr. You can use this command directly :
    `install.packages(c("nnls", "Hmisc", "mgcv", "plyr"))`
* [AnnotSV 2.3](https://lbgi.fr/AnnotSV/): offer complete annotation for your CNVs. Warning : our script use annotSV V2.3 and not v2.2 or less. Be sure to use the good version of the software.

# Configuration file

We split configuration into two separate files, one specific for tools configuration, the second one centered on the project.

_global configuration file calling.conf_
``` 
profiles { 
	standard { 
		process.executor = 'local' #nextflow parameters, define where you run the pipeline (here, on the local machine)
		params.GATK = "" #define the localization of GATK jar file, for example /opt/GenomeAnalysisTK-3.8-1-0/GenomeAnalysisTK.jar
		params.CANOES = "" #CANOES.R script
		params.installFolder = "" #define the folder containing all the script
		params.reference = "" #reference genome -if you're using multiples references (hg37/GRCh38 for example), you can move this parameters to the project specific configuration file if you use different references
		params.annotSVfolder = "" #installation folder of annotSV
	}
}
``` 
If you need further informations on nextflow configuration and how to run it on a cluster/cloud, go [there](https://www.nextflow.io/docs/latest/executor.html).

_project specific configuration file project.conf_
``` 

params.srcFolder = "" #output folder, two folder,"CANOES" and "READCOUNT" will be generated in it
params.kit = "" #bedFile corresponding to the capture kit definition
params.projectName = "" #project Name, used as prefix for readCount and GC content file 
params.bams	= "" #localization of bam file, see below
```

For the declaration of bam file, you need to define a pattern that include the sample name and the index for your bam file.
For example, if your bam are located in the /dataset1 folder and you have 5 samples:
```
/dataset1
|_ sample1.realign.bam
|_ sample1.realign.bam.bai
|_ sample2.realign.bam
|_ sample2.realign.bam.bai
|_ sample3.realign.bam
|_ sample3.realign.bam.bai
|_ sample4.realign.bam
|_ sample4.realign.bam.bai
|_ sample5.realign.bam
|_ sample5.realign.bam.bai
```
you should declare bams as "/dataset1/\*.realign.{bam,bam.bai}"

The "\*" character will replace the sample name, and {bam,bam.bai} indicate a pair of file (bam and index).

Note:
To run properly, bedtools need that the suffix for the bam index file is bam.bai and not directly bai (sample1.bam and his index sample1.bam.bai, not sample1.bai).

# Lauching the pipeline

To run the pipeline, use the command:

`nextflow run callingCNV.nf -c calling.conf -c project.conf`

nextflow will generate a "work" directory, that you can delete when the process is finished, all results will be generated in the "params.srcFolder" within two folders, CANOES and READCOUNT.

Nextflow can generate automatically report file, see the documentation [there](https://www.nextflow.io/docs/latest/tracing.html)
# OUTPUT

The workflow will generates two folders in your srcFolder (see configuration file below)
```
srcFolder
|
|__ CANOES
    |
    |_ sample1.cnv.bed
    |_ sample1.cnv.annot.tsv
    |_ sample2.cnv.bed
    |_ sample2.cnv.annot.tsv
    |_ sample3.cnv.bed
    |_ sample3.cnv.annot.tsv
    |_ ...
    |_ ...
|
|__ READCOUNT
    |
    |_ sample1.reads.txt
    |_ sample2.reads.txt
    |_ sample3.reads.txt
    |_ ...
    |_ ...
    |_ project.clean.reads.txt
    |_ project.clean.gc.txt
    |_

```

If you want complementary information concerning the annotation result file, see [here](https://lbgi.fr/AnnotSV/annotations).

# Citation

 Olivier Quenez, et al.. Detection of copy number variations from NGS data using read depth information: a diagnostic performance evaluation. 2019. ⟨hal-02317979⟩
