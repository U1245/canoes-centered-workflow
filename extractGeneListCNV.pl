#!/usr/bin/perl
use strict;
use Getopt::Long;
use Switch;
use List::Util qw(sum min max);

#Define boolean constant
use constant false => 0;
use constant true  => 1;

my $cnvFile;
my $outFile;
my $geneFile;

GetOptions(
    "cnv=s"=> \$cnvFile,
    "out=s" => \$outFile,
    "genes=s" => \$geneFile
);

open(INFILE,"<$cnvFile") or die("can't open cnv File : $cnvFile\n");
open(OUTFILE,">$outFile") or die("can't open the output File : $outFile\n");
open(GENEF,"<$geneFile") or die("can't open gene File : $geneFile\n");

my %gene;
while(<GENEF>){
    chomp($_);
    $gene{$_}=1;
}

my $header = <INFILE>;
print OUTFILE $header;
my %headCol;
chomp($header);
my @line = split("\t",$header);
for (my $i=0;$i<=scalar(@line);$i++){
    $headCol{$line[$i]}=$i;
}
my $geneColumn = $headCol{'Gene name'};

print "geneColumn = $geneColumn\n";
my $annotType = $headCol{'AnnotSV type'};
my $print = false;
while(<INFILE>){
    
    @line = split("\t",$_);
    if($line[$annotType] eq "full"){
        $print = false; 
        my @geneList=split("\/",$line[$geneColumn]);
        for my $g (@geneList){
            if(exists($gene{$g})){
                $print=true;
                
            }
        }
    }
    if($print){
        print OUTFILE $_;
    }
}
close(INFILE);
close(OUTFILE);
close(GENEF);