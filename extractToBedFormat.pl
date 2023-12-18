#!/bin/perl
=for
 *******************************************************
 *-----------------------PERL--------------------------*
 *******************************************************  
 * new version of the extractor to bed format          * 
 * Now in Perl, with some supplementary step :         * 
 * - check if CANOES calls CNVs from multiples chr     *
 * - if chrX or Y, change the CNE to GAIN or LOSS      *
 ******************************************************* 
 * Version : v1.0.0                                    * 
 ******************************************************* 
 * #### Authors                                        *
 * Olivier Quenez   <olivier.quenez@inserm.fr>         * 
 *******************************************************/

=cut

use Getopt::Long;
use strict;
use List::Util qw[min max];
use Scalar::Util qw(looks_like_number);

#Define boolean constant
use constant false => 0;
use constant true  => 1;

my $in;
my $out;

GetOptions(
	"in=s"	=> \$in,
	"out=s"	=> \$out
);

open( INFILE, "<$in") or die("can't open input file\n");
open( OUTFILE, ">$out") or die("can't open output file\n");

print OUTFILE "#CHROM\tSTART\tEND\tSAMPLE\tTYPE\tSIZE(KB)\tNB TARGET\tCNE\tSCORE\n";

while(<INFILE>){
	chomp($_);
	$_ =~ s/\"//g;
	my @line = split(";",$_);
	my @pos=split("[:-]",$line[3]);
	if($pos[0]>=23){
		if($line[2] eq "DUP"){
			$line[9]="GAIN";
		}else{
			$line[9]="LOSS";	
		}
	}
	if($pos[2]>$pos[1]){
		print OUTFILE join("\t",@pos),"\t$line[1]\t$line[2]\t$line[4]\t$line[8]\t$line[9]\t$line[10]\n";
	}
	
}
close(INFILE);
close(OUTFILE);
