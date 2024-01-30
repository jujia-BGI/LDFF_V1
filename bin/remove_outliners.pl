#!/usr/bin/perl -w
use strict;

die "perl $0 <train.input> <outliners_line>\n"unless(@ARGV==2);
my $in=shift;
my $sam = shift;
my %sample;
open O, "$sam"||die$!;
while (<O>){
        chomp;
        my $sam=(split /\s+/,$_)[0];
	$sample{$sam}=0;
}
close O;

my $i=-1;
open I, "$in"||die$!;
while (<I>){
	$i++;
	next if(exists $sample{$i});	
        chomp;
	print $_,"\n";
}
close I;



