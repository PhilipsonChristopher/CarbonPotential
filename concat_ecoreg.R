# ==== concat code
wd="/media/hdd1/globTree/output"
setwd(wd)
multmerge = function(mypattern, biomeindex){
filenames=list.files(pattern=mypattern, full.names=TRUE)
datalist = lapply(filenames[biomeindex], function(x){read.csv(file=x,header=T)})
unlist(datalist, use.names=FALSE)}


mypattern="AGB"
mypattern = "SOC"
mypattern = "CANOPY"
files = list.files(pattern=mypattern)

#mytiles = sapply(strsplit(files, "_"), "[", 2)
#mytiles = sapply(strsplit(files, "_"), "[", 2)
myecoreg = sapply(strsplit(files, "eco"), "[", 2)
myecoreg_clean = sapply(strsplit(myecoreg, ".txt"), "[", 1)
ecoregs =  unique(myecoreg_clean)

for (ecoreg in ecoregs){
print(ecoreg)
mypattern="AGB"
files = list.files(pattern=mypattern)
myecoreg = sapply(strsplit(files, "eco"), "[", 2)
myecoreg_clean = sapply(strsplit(myecoreg, ".txt"), "[", 1)
ecoindex = which (myecoreg_clean == ecoreg)
agb = multmerge(mypattern, ecoindex)

mypattern="SOC"
files = list.files(pattern=mypattern)
myecoreg = sapply(strsplit(files, "eco"), "[", 2)
myecoreg_clean = sapply(strsplit(myecoreg, ".txt"), "[", 1)
ecoindex = which (myecoreg_clean == ecoreg)
hengl = multmerge(mypattern, ecoindex)

mypattern="CANOPY"
files = list.files(pattern=mypattern)
myecoreg = sapply(strsplit(files, "eco"), "[", 2)
myecoreg_clean = sapply(strsplit(myecoreg, ".txt"), "[", 1)
ecoindex = which (myecoreg_clean == ecoreg)
hansen = multmerge(mypattern, ecoindex)
if (length(hansen)!=length(agb)){print(paste(ecoreg, "failed!"));next}
df = data.frame(hansen, agb,hengl)
names(df) <- c("canopy", "agb", "soc")

write.csv(df, paste0("E", ecoreg, ".txt"), row.names=F)
}
