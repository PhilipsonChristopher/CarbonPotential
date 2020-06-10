# this script builds on hres_sclae.R but optimised for repeat runs where only things that need doing again - are done again
# here we changed 
# 1. vlia -> lia
# 2. hengl 0-5 -> hengle 0-200
# 3. N=10000 -> N=1000000

require(raster)
require(gdalUtils)
library(doParallel)

# OPTION
rasterOptions(tmpdir ="/media/hdd1/globTree/tmp")
# number sample points to extract
N=100000
Nclust=4
download =FALSE
wd="/media/hdd1/globTree/"

# input filepaths (relative to wd)
soc_file="./input/henglSoils2mSum.tif"

biome_file = "./input/biome.shp"
agb_list = "./input/Aboveground_live_woody_biomass_density.csv"
hansen_list = "./input/getfiles.txt"
# number of paralele clusters
myclusters=Nclust
cl <- makeCluster(myclusters) # 4 cores
registerDoParallel(cl)

# dirs
outDir="./output"

#MYBIOME=c(1,7)

#foreach(mybiome=MYBIOME) %dopar% {
#args = commandArgs(trailingOnly=TRUE)
#pytile=args[1]
#pytile=0


# py to R index
#tile=as.numeric(pytile)+1	
#start_time <- Sys.time()
#print(tile)
setwd(wd)
# ==============================================================================
# Read files
# ==============================================================================
# Hengl250m global t/Ha
soilC = raster(soc_file)
# Read global Biomes
biomes = shapefile(biome_file)
	
dat =read.csv(agb_list)
ntiles = dim(dat)[1]
ntiles_seq=1:ntiles
#tile=1
foreach(tile=ntiles_seq) %dopar% {
setwd(wd)
if(!file.exists(paste0("./logs/endTile_", tile))){
write(1, file = paste0("./logs/startTile_", tile))

require(raster)
require(gdalUtils)

# ==============================================================================
# AGB
# ==============================================================================
print(tile)
# Establish grid (AGB covers only land so we get this first
dat =read.csv(agb_list)
file2get = dat$download[tile] # this url wrong!
fileName = unlist(strsplit(as.character(file2get), "/"))[8]
#destfile = paste0("data/" , fileName, "_1km.tif")
position = unlist(strsplit(as.character(fileName), "_t"))[1]



# ==============================================================================
# Download AGB
# ==============================================================================
dl_file=paste0("./downloads/", fileName)
if(!file.exists(dl_file)){
	tryCatch(
	    expr = {
		system (paste0("wget -q -O ./downloads/", fileName, " ", file2get))
	message("success itertion ", tile)
	    },
	    error = function(e){ 
			    message("* Caught an error on itertion ", tile)
		    print(e)
	    },
	    warning = function(w){
		print("got a warning")
	    },
	    finally = {
		print("do not need finally bit")
	    }
	)
}

	AGB = raster(paste0("./downloads/",fileName))


# ==============================================================================
# Download hansen
# ==============================================================================
	dat = read.csv(hansen_list, header=F)
	id = which( dat$V1==dat$V1[grep(position, dat$V1)])
	file2get = dat$V1[id]
	fileName = unlist(strsplit(as.character(file2get), "/"))[6]

dl_file=paste0("./downloads/", fileName)
if(!file.exists(dl_file)){
	system (paste0("wget -q -O ./downloads/", fileName, " ", file2get))
}
	hansen = raster(paste0("./downloads/",fileName))


#===============================================================================
# Resample hengl250 -> hengl30
#===============================================================================
# rough crop to hansen tile
soil_crop = crop(soilC, hansen, snap="out")



# ==============================================================================
# *** Analysis starts here ***
# implemented on hpc /home/caduff/src/globTree/analysis
# ==============================================================================

# crop bio
bio = crop(biomes, hansen)

# read in files



dir.create(outDir)
#hansen_vlia=raster(paste0("./processing/hansen_mask",tile,".tif"))
#AGB_vlia=raster(paste0("./processing/AGB_mask",tile,".tif"))
#hengl30_vlia=raster(paste0("./processing/hengl30_mask",tile,".tif"))

biome= crop(biomes, hansen)



# parallel code

#cl <- makeCluster(myclusters) # 4 cores
#registerDoParallel(cl)

MYBIOME=as.vector(biome@data[biome@data<15]) #all biomes in grid
#MYBIOME=c(1,7)

#foreach(mybiome=MYBIOME) %dopar% {
for(mybiome in MYBIOME){
myrast=AGB

n = length(unlist(strsplit(myrast@file@name,"/")))

print(mybiome)
name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
	if (!file.exists(paste0(outDir, "/",name,"_",mybiome,".txt")) ){
		z =biome[biome$BIOME==mybiome,]
		x = spsample(z,n=N, type="random")
		data = extract(myrast,x)
		#mean(data, na.rm=T)
		name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
		write.table(data, paste0(outDir, "/",name,"_",mybiome,".txt" ),row.names=FALSE)
	}else{print(paste(paste0(outDir, "/",name,"_",mybiome,".txt"), "exists!"))}

myrast=soil_crop
print(mybiome)
name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
	if (!file.exists(paste0(outDir, "/",name,"_",mybiome,".txt")) ){
		z =biome[biome$BIOME==mybiome,]
		x = spsample(z,n=N, type="random")
		data = extract(myrast,x)
		#mean(data, na.rm=T)
		name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
		write.table(data, paste0(outDir, "/",name,"_",mybiome,".txt" ),row.names=FALSE)
	}else{print(paste(paste0(outDir, "/",name,"_",mybiome,".txt"), "exists!"))}

myrast=hansen
print(mybiome)
name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
	if (!file.exists(paste0(outDir, "/",name,"_",mybiome,".txt")) ){
		z =biome[biome$BIOME==mybiome,]
		x = spsample(z,n=N, type="random")
		data = extract(myrast,x)
		#mean(data, na.rm=T)
		name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
		write.table(data, paste0(outDir, "/",name,"_",mybiome,".txt" ),row.names=FALSE)
	}else{print(paste(paste0(outDir, "/",name,"_",mybiome,".txt"), "exists!"))}

}







write(1, file = paste0("./logs/endTile_", tile))
} # end of if file exists condition 


if(file.exists(paste0("./logs/endTile_", tile))){print(paste('tile', tile, 'already computed!'))}


} 



