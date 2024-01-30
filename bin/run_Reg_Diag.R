args <- commandArgs(trailing=T)
        aa<- args[1]
load(aa)
source("./Reg_Diag.R")
Reg_Diag(l)
