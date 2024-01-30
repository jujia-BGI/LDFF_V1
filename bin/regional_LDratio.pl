#!/usr/bin/perl -w
use strict;
use File::Basename;

die "perl $0 <in.ori.vcf.gz> <in.imputed.vcf.gz> <sample list> <out> <1K genome>\n"unless(@ARGV==5);
#perl /zfssz2/ST_MCHRI/BIGDATA/USER/jvjia/fetalfraction/bin/checkImputedGenotypeChanges_batch_only_in_imputed_for_SE35_1KG.pl mpileup.chr9.15000001.20000000.vcf.gz stitch.chr9.15000001.20000000.vcf.gz fq.list cmp /zfssz2/ST_MCHRI/BIGDATA/USER/jvjia/nonpregnant/STITCH/hg19/1000GP_Phase3/1000GP_Phase3_chr9.legend.gz
my $ori = shift;
my $imp = shift;
my $sam = shift;
my $out = shift;
my $kg=shift;

my %sam_ori;
my %sam_imp;
my %share_EAF;
my %same_EAF;
my %share;
my %same ;

open O, "$sam"||die$!;
while (<O>){
        chomp;
	next if(/sample/);
	my $sam=(split /\s+/,$_)[0];#print "$sam","\n";
	$sam_ori{$sam}=0;
	$sam_imp{$sam}=0;
	$share{$sam}=0;
	$same{$sam}=0;
	for my $i (0.45,0.4,0.35,0.3,0.25,0.2,0.15,0.1,0.01){
                $share_EAF{$sam}{$i}=0;$same_EAF{$sam}{$i}=0;
        }

}
close O;

my %EAF;
open I, "gzip -cd $kg|"||die$!;
my $chr=basename $kg;
$chr=~s/.legend.gz//;
$chr=~s/1000GP_Phase3_//;
while (<I>){
        chomp;
	if (/id/){next;}
	else{
                my @line = split/\s+/,$_;

                if($line[7]> 0.5){
                        $line[7]=1-$line[7];
                }
	
 	#	next if($line[7]<0.1);       
if($line[7]<0.1){$EAF{$chr}{$line[1]}=0.01;}
elsif($line[7]>=0.1 && $line[7]<0.15){$EAF{$chr}{$line[1]}=0.1;}
elsif($line[7]>=0.15 && $line[7]<0.2){$EAF{$chr}{$line[1]}=0.15;}
elsif($line[7]>=0.2 && $line[7]<0.25){$EAF{$chr}{$line[1]}=0.2;}
elsif($line[7]>=0.25 && $line[7]<0.3){$EAF{$chr}{$line[1]}=0.25;}
elsif($line[7]>=0.3 && $line[7]<0.35){$EAF{$chr}{$line[1]}=0.3;}
elsif($line[7]>=0.35 && $line[7]<0.4){$EAF{$chr}{$line[1]}=0.35;}
elsif($line[7]>=0.4 && $line[7]<0.45){$EAF{$chr}{$line[1]}=0.4;}
elsif($line[7]>=0.45 && $line[7]<0.5){$EAF{$chr}{$line[1]}=0.45;}
	

#	$EAF{$chr}{$line[1]}=int($line[7]*10);
 #       if($EAF{$chr}{$line[1]}==5){$EAF{$chr}{$line[1]}=4;}
  #      if($EAF{$chr}{$line[1]}==4){$EAF{$chr}{$line[1]}=3;}
#	if($EAF{$chr}{$line[1]}==3){$EAF{$chr}{$line[1]}=2;}
 	}             
}
close I;

my %data;
open I, "gzip -cd $imp|"||die$!;
while (<I>){
	chomp;
	if (/#/){
		if (/#CHROM/){
			my @line = split/\s+/,$_;
			for my $i (0..$#line){
				if (exists $sam_imp{$line[$i]} ){
					$sam_imp{$line[$i]} = $i;
				}
			}
			for my $s (sort keys %sam_imp){
				if ($sam_imp{$s} == 0){die "WARNNING: there is no sample $s in imputed vcf file!!\n";}
			}
		}
	}else {
		my @line = split/\s+/,$_;
		next unless(exists $EAF{$line[0]}{$line[1]});
		
		my $ref = $line[3];
                my $alt = $line[4];
                $ref =~ tr/acgt/ACGT/;
                $alt =~ tr/acgt/ACGT/;
		next if ((length($ref)>1)||(length($alt)>1));

		for my $s(sort keys %sam_imp){
			my $id=$sam_imp{$s};
			my $info = $line[$id];
			my @info = split/:/,$info;

			if ($info[0] eq './.'){
				next;
			}elsif($info[0] eq "0/1"){
				$data{$line[0]}{$line[1]}{$s}= "$ref"."$alt";
			}elsif($info[0] eq "0/0"){
				$data{$line[0]}{$line[1]}{$s} = "$ref"."$ref";
			}elsif($info[0] eq "1/1"){
				$data{$line[0]}{$line[1]}{$s}= "$alt"."$alt";
			}elsif($info[0] eq "1/0"){
				$data{$line[0]}{$line[1]}{$s}= "$ref"."$alt";
			}
		}
	}
}
close I;



open O, "gzip -cd $ori|"||die$!;
while (<O>){
	chomp;
	if (/^#/){
		if (/#CHROM/){
			my @line = split/\s+/,$_;
			for my $i (0..$#line){
				if (exists $sam_ori{$line[$i]} ){
					$sam_ori{$line[$i]} = $i;
				}
			}
			for my $s (sort keys %sam_ori){
				if ($sam_ori{$s} == 0){die "WARNNING: there is no sample $s in ori vcf file!!\n"; }
			}
		}
	}else {
		my @line = split/\s+/,$_;
		next unless(exists $EAF{$line[0]}{$line[1]});
		my $ref = $line[3];
                my $alt = $line[4];
                $ref =~ tr/acgt/ACGT/;
                $alt =~ tr/acgt/ACGT/;
		$alt =~ s/,<\*>//g;
                $alt =~ s/<\*>//g;#print $alt,"\t",length($alt),"\n";
		next if ((length($ref)>1) || (length($alt)>1));
	#	print join("\t",@line),"\n";
		for my $s(sort keys %sam_ori){
			next unless(exists $data{$line[0]}{$line[1]}{$s});
	
			my $id=$sam_ori{$s};		
			my $info = $line[$id];
			my @info = split/,/,$info;

			my $geno;
			if (($info[0] == 0) && ($info[1] == 0) && ($info[2] == 0)){
				next;
			}elsif (($info[0]<=$info[1]) && ($info[0]<=$info[2])){
				$geno = "$ref"."$ref";
			}elsif (($info[1]<=$info[0]) && ($info[1]<=$info[2])){
				$geno = "$ref"."$alt";
			}else{
				$geno = "$alt"."$alt";
			}
			my $imp_i = $data{$line[0]}{$line[1]}{$s};

			my $eaf=$EAF{$line[0]}{$line[1]};

			$share{$s}++;			
			$share_EAF{$s}{$eaf}++;
			if($imp_i eq $geno){
				$same{$s}++;
				$same_EAF{$s}{$eaf}++;
			}
			#print join ("\t", @line[0,1,3],$geno,$imp_i,$s,$eaf,$share{$s},$share_EAF{$s}{$eaf},$same{$s},$same_EAF{$s}{$eaf}),"\n";
	
		}
	}
}
close O;

open OUT, "> $out"||die$!;
for my $s (sort keys %same){
	my @out;
	my ($sum1,$sum2)=(0,0);
	push @out,$s,$share{$s},$same{$s},sprintf("%.6f",($share{$s}-$same{$s})/($share{$s}+0.0000001));
	for my $i (0.45,0.4,0.35,0.3,0.25,0.2,0.15,0.1,0.01){
#                push @out,$share_EAF{$s}{$i},$same_EAF{$s}{$i},sprintf("%.6f",($share_EAF{$s}{$i}-$same_EAF{$s}{$i})/($share_EAF{$s}{$i}+0.0000001));
	$sum1+=$share_EAF{$s}{$i};
	$sum2+=$same_EAF{$s}{$i};
	push @out,$sum1,$sum2,sprintf("%.6f",($sum1-$sum2)/($sum1+0.0000001));
        }
        print OUT join("\t",@out),"\n";

}
close OUT;
#print "Number of original variants:\t$ori_c\n";
#print "Number of imputed variants:\t$imp_c\n";
#print "Number of shared variants:\t$share\n";
#print "Number of same variants:\t$same\n";
#print "Precent of changed variants:\t".(($share-$same)/$share)."\n";

