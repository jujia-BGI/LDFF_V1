#!perl -w
use strict;
use File::Basename;
my ($filelist)=@ARGV;
my $reflen=3095693983;#3217346917
my $header=join("\t","sam","errorrate","totalread","unmapped","mappedcoverage","goodmapcoverage","ReadLen","duprate");
print "$header\n";
open(I,$filelist);
while(<I>){
    chomp;
    my $file=$_;
    my $sam=basename($file);
    $sam=~s/\.sort\.rmdup\.bam\.stats//;
    my ($totalread,$unmap,$totalmap,$goodmap,$dup)=("NA")x5;
    my ($error,$coverage,$goodcoverage,$readlen,$duprate)=("NA")x5; #goodmapp means removing the reads with MAQ 0
    open(F,$file);
    while(<F>){
        chomp;
        my @tmp=split(/\s+/,$_);
        if($.==8){
            $totalread=$tmp[4];
        }
        if($.==14){
            $totalmap=$tmp[3];
        }
        if($.==16){
            $unmap=$tmp[3];
        }
        if($.==19){
            $dup=$tmp[3];
        }
        if($.==20){
            $goodmap=$totalmap-$tmp[3];
        }
        if($.==32){
            $error=$tmp[3];
        }
        if($.==33){
            $readlen=$tmp[3];
        }
        if($totalmap ne "NA" && $readlen ne "NA" && $goodmap ne "NA" && $dup ne "NA"){
        $coverage=$totalmap*$readlen/$reflen;
        $goodcoverage=$goodmap*$readlen/$reflen;
        $duprate=$dup/$totalmap;
    }
    }
    print "$sam\t$error\t$totalread\t$unmap\t$coverage\t$goodcoverage\t$readlen\t$duprate\n";
    close F;
}
close I;
