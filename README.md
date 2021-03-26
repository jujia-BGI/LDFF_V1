# LDFF_V1
This study was performed to establish a novel method named LDFF to accurately quantify cell-free fetal DNA fraction (FF) in maternal plasma by utilizing linkage disequilibrium (LD) information from maternal and fetal haplotypes. 


The workflow consists of three processes, the first of regional LD-ratios were calculated on the 521 genomic regions, as well as the genome coverage, coverage of the reads with a MQ score>0 and PCR duplication rate. Several multivariate regression models were generated with different MAF filtering cutoff using all training samples. Then, the outliers in the training samples in different MAF filtering models were identified and removed from the corresponding model to avoid over-fitting. Multivariate regression models were rebuilt using the remaining samples. Finally, MAF filtering cutoff was selected as the model has best accuracy.

Step1
perl checkImputedGenotypeChanges_batch_only_in_imputed_for_SE35_1KG.pl 
Stpe2
Rscript Linear_regression_chrYbasedff.R train.input test.input 
