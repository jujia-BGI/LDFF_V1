#!/usr/bin/perl -w
use strict;

die "perl $0 <train.input> <outliers_line>\n"unless(@ARGV==2);
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

open I, "$in"||die$!;
while (<I>){
        my $i=(split /\s+/,$_)[0];
        next if(exists $sample{$i});
        chomp;
        print $_,"\n";
}
close I;




