
# ==== concat code
wd="/media/hdd1/globTree/output"
setwd(wd)
multmerge = function(mypattern, biomeindex){
filenames=list.files(pattern=mypattern, full.names=TRUE)
datalist = lapply(filenames[biomeindex], function(x){read.csv(file=x,header=T)})
unlist(datalist, use.names=FALSE)}


mypattern="AGB_mask"
mypattern = "hengl30"
mypattern = "hansen"
files = list.files(pattern=mypattern)

#mytiles = sapply(strsplit(files, "_"), "[", 2)
#mytiles = sapply(strsplit(files, "_"), "[", 2)
mybiomes = sapply(strsplit(files, "_"), "[", 3)
mybiomes_clean = sapply(strsplit(mybiomes, ".txt"), "[", 1)
biomes =  unique(mybiomes_clean)

for (biome in biomes){
print(biome)
mypattern="AGB_mask"
files = list.files(pattern=mypattern)
mybiomes = sapply(strsplit(files, "_"), "[", 3)
mybiomes_clean = sapply(strsplit(mybiomes, ".txt"), "[", 1)
biomeindex = which (mybiomes_clean == biome)
agb = multmerge(mypattern, biomeindex)

#mypattern="hengl30"
mypattern="c"
files = list.files(pattern=mypattern)
mybiomes = sapply(strsplit(files, "_"), "[", 3)
mybiomes_clean = sapply(strsplit(mybiomes, ".txt"), "[", 1)
biomeindex = which (mybiomes_clean == biome)
hengl = multmerge(mypattern, biomeindex)

mypattern="hansen"
files = list.files(pattern=mypattern)
mybiomes = sapply(strsplit(files, "_"), "[", 3)
mybiomes_clean = sapply(strsplit(mybiomes, ".txt"), "[", 1)
biomeindex = which (mybiomes_clean == biome)
hansen = multmerge(mypattern, biomeindex)

df = data.frame(hansen, agb,hengl)
names(df) <- c("canopy", "agb", "soc")

write.csv(df, paste0("b", biome, ".txt"), row.names=F)
}

