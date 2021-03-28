# LDFF_V1
This study was performed to establish a novel method named LDFF to accurately quantify cell-free fetal DNA fraction (FF) in maternal plasma by utilizing linkage disequilibrium (LD) information from maternal and fetal haplotypes. 


The workflow consists of three processes, the first of regional LD-ratios were calculated on the 521 genomic regions, as well as the genome coverage, coverage of the reads with a MQ score>0 and PCR duplication rate. Several multivariate regression models were generated with different MAF filtering cutoff using all training samples. Then, the outliers in the training samples in different MAF filtering models were identified and removed from the corresponding model to avoid over-fitting. Multivariate regression models were rebuilt using the remaining samples. Finally, MAF filtering cutoff was selected as the model has best accuracy.

Step1:Regional LD-ratios calculation
perl regional_LDratio.pl mpileup.chr1.1.5000000.vcf.gz stitch.chr1.1.5000000.vcf.gz samplelist regional_LDratios.txt 1000GP_Phase3_chr1.legend.gz


Stpe2:Build multivariate regression models

Rscript Linear_regression_chrYbasedff.R train.input.maf0.2 test.input.maf0.2

Step3:Remove outliers in the training set

Rscript run_Reg_Diag.R Linear-model.RData |grep '\*' > outliners_line.log

perl remove_outliners.pl train.input.maf0.2 outliners_line.log > train.input.maf0.2.removeoutliners

Step4:multivariate regression models retraining

Rscript Linear_regression_chrYbasedff.R train.input.maf0.2.removeoutliners test.input.maf0.2> test.input.log

