#! R
args=commandArgs(T)
outputdir=args[1]
bamlist=args[2]
# ref=args[3]
# human_posfile=args[4]
# human_K=as.numeric(args[5])
# human_nGen=as.numeric(args[6])
# nCores=as.numeric(args[7])
# niterations=as.numeric(args[8])
human_posfile=as.character(args[3])
chr=as.character(args[4])
regionStart=as.numeric(args[5])
regionEnd=as.numeric(args[6])
# buffer=as.numeric(args[12])
# human_genfile=as.character(args[13])
human_reference_sample_file=as.character(args[9])
human_reference_legend_file=as.character(args[7])
human_reference_haplotype_file=as.character(args[8])
# human_K=as.numeric(args[5])
options(scipen = 20)
# General variables - modify as appropriate
#tempdir <- tempdir() # - try /dev/shm/ or put on local fast disk if possible, the point is to find a fast disk with excellent IO performance
tempdir=outputdir # tempdir()
setwd(outputdir)
library("STITCH",lib.loc="Rpackages/STITCH/v1.5.3.0008")
sessionInfo("STITCH")

human_K = 40
nCores = 1
human_nGen = 4 * 20000 / human_K
buffer = 250000
ref="database_hg19/hg19.fasta"


STITCH(
    bamlist = bamlist,
    reference = ref,
    outputdir = outputdir,
    generateInputOnly = T,
    #regenerateInput = FALSE,
    regionStart = regionStart,
    regionEnd = regionEnd,
    #originalRegionName = originalRegionName,
    buffer = buffer,
    chr = chr,
    inputBundleBlockSize = 100,
    posfile = human_posfile,
    K = human_K,
    tempdir = tempdir,
    #environment = environment,
    nCores = nCores,
    nGen = human_nGen,
)
outputdir_ref = paste0("STITCH/hg19/Refpanel/",chr,".",regionStart,".",regionEnd)
system(paste0("rsync -a ", shQuote(outputdir_ref), "/* ", shQuote(outputdir)))


if(FALSE){
STITCH_prepare_reference( chr = chr,
    regionStart = regionStart,
    regionEnd = regionEnd,
    nCores = nCores,
    buffer = 250000,
    nGen = human_nGen,
    inputBundleBlockSize = 100,
    outputdir = outputdir,
    reference_haplotype_file = human_reference_haplotype_file,
    reference_legend_file = human_reference_legend_file,
    reference_sample_file = human_reference_sample_file,
    reference_populations = c("CHB", "CHS", "CDX"),
    K = human_K
)
}

 output_filename=paste0(outputdir,'/',basename(bamlist),'.stitch.',chr,".",regionStart,".",regionEnd,'.vcf.gz')
if(TRUE){
output_format <- "bgvcf"
originalRegionName=paste(chr,regionStart,regionEnd,sep=".")
STITCH_again(
#	bamlist = bamlist,
#	reference = ref,
    outputdir = outputdir,
    tempdir = tempdir,
    method = "diploid",
    chr = chr,
    nCores = nCores,
    regionStart = regionStart,
    regionEnd = regionEnd,
    regenerateInput = FALSE,
    originalRegionName = originalRegionName,
    buffer = 250000,
    inputBundleBlockSize = 2,
    # outputBlockSize = 100,
    outputSNPBlockSize = 20000,
    useTempdirWhileWriting = TRUE,
    rematch_SNPs = TRUE,
    sample_posfile = human_posfile,
    output_format = output_format,
output_filename=output_filename
)
}


