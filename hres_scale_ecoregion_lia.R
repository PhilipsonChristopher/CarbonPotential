


# this script builds on hres_scale_repeat.R but uses ecoregion and no impact area
# here we changed 
# 1. remove lia mask
# 2. use ecoregion instead of ecoreg
# 3. ensure all tiles covered


require(raster)
require(gdalUtils)
library(doParallel)


# number sample points to extract
N=10000
Nclust=4
download =TRUE
wd="/media/hdd1/globTree"
startT1=Sys.time() 
# OPTION
rasterOptions(tmpdir =paste0(wd,"/tmp"))

# input filepaths (relative to wd)
soc_file="./input/henglSoils2mSum.tif"
impact_file="./input/Low_Impact_MASK.tif_ll.tif"
#ecoreg_file = "./input/ecoreg.shp"
eco_reg_file="./input/ecoreg.shp"
agb_list = "./input/Aboveground_live_woody_biomass_density.csv"
hansen_list = "./input/getfiles.txt"
# number of paralele clusters
myclusters=Nclust
     system(paste0('rm ',wd, '/dopar.log'))
cl <- makeCluster(myclusters, outfile=paste0(wd, '/dopar.log')) # 4 cores
registerDoParallel(cl)

# dirs
outDir="./output"

#allmyecoreg=c(1,7)

#foreach(myecoreg=allmyecoreg) %dopar% {
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
# global very low impact areas mask at 1k
vlia = raster(impact_file)
# Read global ecoregs
ecoregs = shapefile(eco_reg_file)
	
dat =read.csv(agb_list)
ntiles = dim(dat)[1]
ntiles_seq=1:ntiles
#tile=1
foreach(tile=ntiles_seq) %dopar% {
#for (tile in ntiles_seq) {
startT1 = Sys.time()
setwd(wd)
# check if file exists, rest of script in this loop
if(!file.exists(paste0("./logs/endTile_", tile))){


write(1, file = paste0("./logs/startTile_", tile))

require(raster)
require(gdalUtils)
rasterOptions(tmpdir =paste0(wd,"/tmp/tile",tile))

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

# url actually has form:
# http://gfw2-data.s3.amazonaws.com/climate/WHRC_biomass/WHRC_V4/Processed/80N_010E_t_aboveground_biomass_ha_2000.tif

# construct URL
#file2get = paste0("http://gfw2-data.s3.amazonaws.com/climate/WHRC_biomass/WHRC_V4/Processed/",position,"_t_aboveground_biomass_ha_2000.tif")
#file2get <- fileName
#fileName = unlist(strsplit(as.character(file2get), "/"))[8]



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

# ==============================================================================
# HRES - tile loop (scales)
# ==============================================================================






#ntiles=length(AGB_list)

#for (tile in 1:ntiles){ # scale tghis as parallel jobs
#print(paste0("running tile ", tile))
#AGB= raster(paste0(wd,AGB_list[[tile]]))
#hansen=raster(paste0(wd,hansen_list[[tile]]))

#===============================================================================
# Resample hengl250 -> hengl30
#===============================================================================
startT = Sys.time()

# rough crop to hansen tile
soil_crop = crop(soilC, hansen, snap="out")

## dissag to hansen res
FACT = res(soil_crop)/res(hansen)
soil_dis = disaggregate(soil_crop, fact = FACT)

## more accurate crop
soil_crop = crop(soil_dis, hansen)

## resample to hansen
writeRaster(soil_crop, paste0("./processing/soil_crop",tile,".tif"),overwrite=TRUE)
myfile=paste0("./processing/soil_crop",tile,".tif")
if(!file.exists(paste0( myfile,"RESAMP",tile,".tif"))){
	R2 = hansen
	Routput=paste0(myfile,"RESAMP",tile,".tif")
	t1 <- c(xmin(R2), ymin(R2), xmax(R2), ymax(R2))
	t2 <- c(res(R2)[1], res(R2)[2]) 
	gdalwarp(myfile, dstfile = Routput, tr = t2, te = t1,  output_Raster = T, overwrite = T, verbose = T) #, co="COMPRESS=LZW" makes much smaller file but takes loads longer
	}
## can rm big file after converted
hengl30 = raster(paste0( myfile,"RESAMP",tile,".tif"))


#extent(hengl30)==extent(hansen)
#extent(AGB)==extent(hansen)

endT1=Sys.time() - startT

#===============================================================================
# Resample VLIA1l1km -> vlia30
#===============================================================================

# rough crop to hansen tile
vlia_crop = crop(vlia, hansen, snap="out")

## dissag to hansen res
FACT = res(vlia_crop)/res(hansen)
vlia_dis = disaggregate(vlia_crop, fact = FACT)

## more accurate crop
vlia_crop = crop(vlia_dis, hansen)

## resample to hansen
writeRaster(vlia_crop, paste0("./processing/vlia_crop",tile,".tif"), overwrite=TRUE)
myfile=paste0("./processing/vlia_crop",tile,".tif")
if(!file.exists(paste0( myfile,"RESAMP",tile,".tif"))){
	R2 = hansen
	Routput=paste0(myfile,"RESAMP",tile,".tif")
	t1 <- c(xmin(R2), ymin(R2), xmax(R2), ymax(R2))
	t2 <- c(res(R2)[1], res(R2)[2]) 
	gdalwarp(myfile, dstfile = Routput, tr = t2, te = t1,  output_Raster = T, overwrite = T, verbose = T) #, co="COMPRESS=LZW" makes much smaller file but takes loads longer
	}

vlia30 = raster(paste0(myfile,"RESAMP",tile,".tif"))

# ==============================================================================
# Mask layers by vlia
# ==============================================================================





# mask hansen by vlia 
if(!file.exists(paste0("./processing/hansen_mask",tile,".tif"))){
	hansen_vlia =hansen*vlia30
	writeRaster(hansen_vlia,paste0("./processing/hansen_mask",tile,".tif"),overwrite=T)
	}
## mask AGB by vlia 
if(!file.exists(paste0("./processing/AGB_mask",tile,".tif"))){
	AGB_vlia =AGB*vlia30
	writeRaster(AGB_vlia,paste0("./processing/AGB_mask",tile,".tif"),overwrite=T)
	}
## mask soc by vlia 
if(!file.exists(paste0("./processing/hengl30_mask",tile,".tif"))){
	hengl30_vlia =hengl30*vlia30
	writeRaster(hengl30_vlia,paste0("./processing/hengl30_mask",tile,".tif"),overwrite=T)
	}
# ==============================================================================
# *** Analysis starts here ***
# implemented on hpc /home/caduff/src/globTree/analysis
# ==============================================================================



# read in files

dir.create(outDir)
hansen_vlia=raster(paste0("./processing/hansen_mask",tile,".tif"))
AGB_vlia=raster(paste0("./processing/AGB_mask",tile,".tif"))
hengl30_vlia=raster(paste0("./processing/hengl30_mask",tile,".tif"))

ecoreg= crop(ecoregs, hansen)



# parallel code

#cl <- makeCluster(myclusters) # 4 cores
#registerDoParallel(cl)

allmyecoreg=as.vector(unique(ecoreg$ECO_NAME)) #all ecoregs in grid

#allmyecoreg=c(1,7)

#foreach(myecoreg=allmyecoreg) %dopar% {
for(myecoreg in allmyecoreg){
regID= unique(ecoreg$ECO_ID[ecoreg$ECO_NAME==myecoreg])

		startT = Sys.time()
myrast=AGB_vlia
n = length(unlist(strsplit(myrast@file@name,"/")))

print(myecoreg)
name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
	if (!file.exists(paste0(outDir, "/",name,"_",myecoreg,".txt")) ){
		z =ecoreg[ecoreg$ECO_NAME==myecoreg,]
		x = spsample(z,n=N, type="random")
		data = extract(myrast,x)
		#mean(data, na.rm=T)
		name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
		write.table(data, paste0(outDir, "/AGB_tile",tile,"_eco",regID,".txt" ),row.names=FALSE)
	}else{print(paste(paste0(outDir, "/",name,"_",myecoreg,".txt"), "exists!"))}

		endT2=Sys.time() - startT
		startT = Sys.time()

myrast=hengl30
#myrast=hengl30
print(myecoreg)
name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
	if (!file.exists(paste0(outDir, "/",name,"_",myecoreg,".txt")) ){
		z =ecoreg[ecoreg$ECO_NAME==myecoreg,]
		x = spsample(z,n=N, type="random")
		data = extract(myrast,x)
		#mean(data, na.rm=T)
		name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
		write.table(data, paste0(outDir, "/SOC_tile",tile,"_eco",regID,".txt" ),row.names=FALSE)
	}else{print(paste(paste0(outDir, "/",name,"_",myecoreg,".txt"), "exists!"))}

		endT3=Sys.time() - startT
		startT = Sys.time()

myrast=hansen_vlia

print(myecoreg)
name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
	if (!file.exists(paste0(outDir, "/",name,"_",myecoreg,".txt")) ){
		z =ecoreg[ecoreg$ECO_NAME==myecoreg,]
		x = spsample(z,n=N, type="random")
		data = extract(myrast,x)
		#mean(data, na.rm=T)
		name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
		write.table(data, paste0(outDir, "/CANOPY_tile",tile,"_eco",regID,".txt" ),row.names=FALSE)
	}else{print(paste(paste0(outDir, "/",name,"_",myecoreg,".txt"), "exists!"))}
		
		endT4=Sys.time() - startT

}





#clean up
system(paste0("rm ",wd,"/processing/soil_crop",tile, ".tif"))
system(paste0("rm ",wd,"/processing/soil_crop",tile, ".tifRESAMP",tile,".tif"))
system(paste0("rm -r ",wd,"/tmp/tile",tile,"/"))

system(paste0("rm ",wd,"/processing/vlia_crop",tile,".tif"))
system(paste0("rm ",wd,"/processing/vlia_crop",tile,".tifRESAMP",tile,".tif"))
system(paste0("rm ",wd,"/processing/hengl30_mask",tile,".tif"))
system(paste0("rm ",wd,"/processing/AGB_mask",tile,".tif"))
system(paste0("rm ",wd,"/processing/hengl30_mask",tile,".tif"))

write(1, file = paste0("./logs/endTile_", tile))
} # end of if file exists condition 


if(file.exists(paste0("./logs/endTile_", tile))){print(paste('tile', tile, 'already computed!'))}


} # end parallel

endT5=Sys.time() - startT1






