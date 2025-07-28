#!/bin/perl
=for
 *******************************************************
 *-----------------------PERL--------------------------*
 *******************************************************  
 * 
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

#Define boolean constant
use constant false => 0;
use constant true  => 1;

my $clinical;
my $outPrefix;

GetOptions(
	"clinical=s"	=> \$clinical,
	"outPrefix=s"	=> \$outPrefix
);


open(CLINICAL, "<$clinical") or die ("can't open clinical / pedigree file : $clinical \n");
open(OUT_MALE,">$outPrefix.male.list") or die ("can't open $outPrefix.male.list \n");
open(OUT_FEMALE,">$outPrefix.female.list") or die ("can't open $outPrefix.female.list \n");

my $fLine = <CLINICAL>;
chomp($fLine);
my %Header;
if($fLine =~ m/^#/){
	$fLine =~ s/#//;
	my @headerL = split("\t",$fLine);
	for (my $i =0;$i<scalar(@headerL);$i++){
		$Header{$headerL[$i]}=$i;
	}
}else{
	print "no header detected, considering first column as IID (Individual ID) and second column as Sex (1 for Male, 2 for Female)\n";
	$Header{'IID'}=0;
	$Header{'Sex'}=1;
	my @headerL = split("\t",$fLine);
	if($headerL[$Header{'Sex'}] eq 1){
                print OUT_MALE "$headerL[$Header{'IID'}]\n";
        }else{
                print OUT_FEMALE "$headerL[$Header{'IID'}]\n";
        }
	
}
while(<CLINICAL>){
	chomp($_);
	my @line = split("\t",$_);
	if($line[$Header{'Sex'}] eq 1){
		print OUT_MALE "$line[$Header{'IID'}]\n";
	}else{
		print OUT_FEMALE "$line[$Header{'IID'}]\n";
	}
}
