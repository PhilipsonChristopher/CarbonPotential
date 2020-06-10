require(raster)
require(gdalUtils)
library(doParallel)

rasterOptions(tmpdir ="/media/hdd1/globTree/tmp")
# number sample points to extract
N=10000

# number of paralele clusters
myclusters=1
cl <- makeCluster(myclusters) # 4 cores
registerDoParallel(cl)

#MYBIOME=c(1,7)

#foreach(mybiome=MYBIOME) %dopar% {
#args = commandArgs(trailingOnly=TRUE)
#pytile=args[1]
#pytile=0


# py to R index
#tile=as.numeric(pytile)+1	
#start_time <- Sys.time()
#print(tile)

# ==============================================================================
# Read files
# ==============================================================================
# Hengl250m global t/Ha
soilC = raster("input/OCSTHA_M_sd1_250m_ll.tif")
# global very low impact areas mask at 1k
vlia = raster("input/Very_Low_Impact_MASK.tif_ll.tif")
# Read global Biomes
biomes = shapefile("input/biome.shp")
	
dat =read.csv("input/Aboveground_live_woody_biomass_density.csv")
ntiles = dim(dat)[1]
ntiles_seq=1:ntiles
# tile=1
# foreach(tile=ntiles_seq) %dopar% {
for (tile in ntiles_seq){
require(raster)
require(gdalUtils)
# ==============================================================================
# AGB
# ==============================================================================
print(tile)
# Establish grid (AGB covers only land so we get this first
dat =read.csv("input/Aboveground_live_woody_biomass_density.csv")
file2get = dat$download[tile] # this url wrong!
fileName = unlist(strsplit(as.character(file2get), "/"))[5]
#destfile = paste0("data/" , fileName, "_1km.tif")
position = unlist(strsplit(as.character(fileName), "_merge.tif"))[1]

# url actually has form:
# http://gfw2-data.s3.amazonaws.com/climate/WHRC_biomass/WHRC_V4/Processed/80N_010E_t_aboveground_biomass_ha_2000.tif

# construct URL
file2get = paste0("http://gfw2-data.s3.amazonaws.com/climate/WHRC_biomass/WHRC_V4/Processed/",position,"_t_aboveground_biomass_ha_2000.tif")
fileName = unlist(strsplit(as.character(file2get), "/"))[8]


# check if file exists, rest of script in this loop
if(!file.exists(fileName)){

# ==============================================================================
# Download AGB
# ===========================================================================

tryCatch(
    expr = {
	system (paste0("wget ", file2get))
AGB = raster(fileName)

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


# ==============================================================================
# Download hansen
# ==============================================================================
	dat = read.csv("input/getfiles.txt", header=F)
	id = which( dat$V1==dat$V1[grep(position, dat$V1)])
	file2get = dat$V1[id]
	fileName = unlist(strsplit(as.character(file2get), "/"))[6]

	system (paste0("wget ", file2get))
	hansen = raster(fileName)

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
# rough crop to hansen tile
soil_crop = crop(soilC, hansen, snap="out")

# dissag to hansen res
FACT = res(soil_crop)/res(hansen)
soil_dis = disaggregate(soil_crop, fact = FACT)

# more accurate crop
soil_crop = crop(soil_dis, hansen)

# resample to hansen
writeRaster(soil_crop, paste0("soil_crop",tile,".tif"),overwrite=TRUE)
myfile=paste0("soil_crop",tile,".tif")
R2 = hansen
Routput=paste0(myfile,"RESAMP",tile,".tif")
t1 <- c(xmin(R2), ymin(R2), xmax(R2), ymax(R2))
t2 <- c(res(R2)[1], res(R2)[2]) 
gdalwarp(myfile, dstfile = Routput, tr = t2, te = t1,  output_Raster = T, overwrite = T, verbose = T) #, co="COMPRESS=LZW" makes much smaller file but takes loads longer

# can rm big file after converted
hengl30 = raster(paste0(myfile,"RESAMP",tile,".tif"))


extent(hengl30)==extent(hansen)
extent(AGB)==extent(hansen)

#===============================================================================
# Resample VLIA1l1km -> vlia30
#===============================================================================

# rough crop to hansen tile
vlia_crop = crop(vlia, hansen, snap="out")

# dissag to hansen res
FACT = res(vlia_crop)/res(hansen)
vlia_dis = disaggregate(vlia_crop, fact = FACT)

# more accurate crop
vlia_crop = crop(vlia_dis, hansen)

# resample to hansen
writeRaster(vlia_crop, paste0("vlia_crop",tile,".tif"), overwrite=TRUE)
myfile=paste0("vlia_crop",tile,".tif")
R2 = hansen
Routput=paste0(myfile,"RESAMP",tile,".tif")
t1 <- c(xmin(R2), ymin(R2), xmax(R2), ymax(R2))
t2 <- c(res(R2)[1], res(R2)[2]) 
gdalwarp(myfile, dstfile = Routput, tr = t2, te = t1,  output_Raster = T, overwrite = T, verbose = T) #, co="COMPRESS=LZW" makes much smaller file but takes loads longer


vlia30 = raster(paste0(myfile,"RESAMP",tile,".tif"))

# ==============================================================================
# Mask layers by vlia
# ==============================================================================





# mask hansen by vlia 
hansen_vlia =hansen*vlia30
writeRaster(hansen_vlia,paste0("hansen_mask",tile,".tif"),overwrite=T)

# mask AGB by vlia 
AGB_vlia =AGB*vlia30
writeRaster(AGB_vlia,paste0("AGB_mask",tile,".tif"),overwrite=T)

# mask soc by vlia 
hengl30_vlia =hengl30*vlia30
writeRaster(hengl30_vlia,paste0("hengl30_mask",tile,".tif"),overwrite=T)

# ==============================================================================
# *** Analysis starts here ***
# implemented on hpc /home/caduff/src/globTree/analysis
# ==============================================================================

# crop bio
bio = crop(biomes, hansen)

# read in files

dirRoot=paste0("./output")

dir.create(dirRoot)
hansen_vlia=raster(paste0("hansen_mask",tile,".tif"))
AGB_vlia=raster(paste0("AGB_mask",tile,".tif"))
hengl30_vlia=raster(paste0("hengl30_mask",tile,".tif"))

biome= crop(biomes, hansen_vlia)



# parallel code

#cl <- makeCluster(myclusters) # 4 cores
#registerDoParallel(cl)

MYBIOME=as.vector(biome@data[biome@data<15]) #all biomes in grid
#MYBIOME=c(1,7)

#foreach(mybiome=MYBIOME) %dopar% {
for(mybiome in MYBIOME){
myrast=AGB_vlia

n = length(unlist(strsplit(myrast@file@name,"/")))

print(mybiome)
name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
	if (!file.exists(paste0(dirRoot, "/",name,"_",mybiome,".txt")) ){
		z =biome[biome$BIOME==mybiome,]
		x = spsample(z,n=N, type="random")
		data = extract(myrast,x)
		#mean(data, na.rm=T)
		name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
		write.table(data, paste0(dirRoot, "/",name,"_",mybiome,".txt" ),row.names=FALSE)
	}else{print(paste(paste0(dirRoot, "/",name,"_",mybiome,".txt"), "exists!"))}

myrast=hengl30_vlia
print(mybiome)
name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
	if (!file.exists(paste0(dirRoot, "/",name,"_",mybiome,".txt")) ){
		z =biome[biome$BIOME==mybiome,]
		x = spsample(z,n=N, type="random")
		data = extract(myrast,x)
		#mean(data, na.rm=T)
		name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
		write.table(data, paste0(dirRoot, "/",name,"_",mybiome,".txt" ),row.names=FALSE)
	}else{print(paste(paste0(dirRoot, "/",name,"_",mybiome,".txt"), "exists!"))}

myrast=hansen_vlia
print(mybiome)
name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
	if (!file.exists(paste0(dirRoot, "/",name,"_",mybiome,".txt")) ){
		z =biome[biome$BIOME==mybiome,]
		x = spsample(z,n=N, type="random")
		data = extract(myrast,x)
		#mean(data, na.rm=T)
		name = strsplit(unlist(strsplit(myrast@file@name,"/"))[n], ".tif")
		write.table(data, paste0(dirRoot, "/",name,"_",mybiome,".txt" ),row.names=FALSE)
	}else{print(paste(paste0(dirRoot, "/",name,"_",mybiome,".txt"), "exists!"))}

}




} # end of main loop
} # end parallel
