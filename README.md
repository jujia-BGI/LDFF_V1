# LDFF_V1
This study was performed to establish a novel method named LDFF to accurately quantify cell-free fetal DNA fraction (FF) in maternal plasma by utilizing linkage disequilibrium (LD) information from maternal and fetal haplotypes. The workflow consists of four processes, the first of regional LD-ratios were calculated on the 521 genomic regions, as well as the genome coverage, coverage of the reads with a MQ score>0 and PCR duplication rate. Then, several multivariate regression models were generated with different MAF filtering cutoff using all training samples. Thrid, the outliers in the training samples in different MAF filtering models were identified and removed from the corresponding model to avoid over-fitting. Multivariate regression models were rebuilt using the remaining samples. Finally, MAF filtering cutoff was selected as the model has best accuracy.

### Dependence: 
The following steps are to work in the Perl 5 or R environment. And samtools (http://www.htslib.org/) and STITCH (version v1.5.3.0008, http://www.stats.ox.ac.uk/~myers/) should be installed.

### Step1:Regional LD-ratios and confounders calculation

samtools mpileup -f database_hg19/hg19.fasta -b bamlist -r chr1:1-5000000 -v -o result/chr1.1.5000000/mpileup.chr1.1.5000000.vcf.gz -l database_hg19/1kg.easaf0.2/chr1.pos.txt

Rscript bin/STITCH.full.step2.R result/chr1.1.5000000/ bamlist database_hg19/1kg.easaf0.01/chr1.pos.txt  chr1 1 5000000 database_hg19/1000GP_Phase3/1000GP_Phase3_chr1.legend.gz database_hg19/1000GP_Phase3/1000GP_Phase3_chr1.hap.gz database_hg19/1000GP_Phase3/1000GP_Phase3.sample

perl bin/regional_LDratio.pl result/chr1.1.5000000/mpileup.chr1.1.5000000.vcf.gz result/chr1.1.5000000/stitch.chr1.1.5000000.vcf.gz samplelist result/chr1.1.5000000/regional_LDratios.txt database_hg19/1000GP_Phase3/1000GP_Phase3_chr1.legend.gz

perl bin/bamstat.combine.pl bamstats > confounders

### Step2:Build multivariate regression models when MAF filtering cutoff=0.2

pastes the regional LD-ratios of maf 0.02 in regional_LDratios.txt and the genome coverage, coverage of the reads with a MQ score>0 and PCR duplication rate in confounders into train.input.maf0.2

Rscript bin/Linear_regression_chrYbasedff.R train.input.maf0.2 test.input.maf0.2

### Step3:Remove outliers in the training set

Rscript bin/run_Reg_Diag.R Linear-model.RData |grep '\*' > outliners_line.log

perl bin/remove_outliners.pl train.input.maf0.2 outliners_line.log > train.input.maf0.2.removeoutliners

### Step4:multivariate regression models retraining

Rscript bin/Linear_regression_chrYbasedff.R train.input.maf0.2.removeoutliners test.input.maf0.2> test.input.log

