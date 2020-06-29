# Carbon Potential
## We estimate the carbon potential of the different biomes of the world using published global datasets

The aim is to estimate of Soil Oganic Carbon (SOC) and Plant Carbon for all global terrestrial ecoregions.



### Low impact areas mask
In order to estimate the carbon potential of undisturbed ecosystems, we only sample low impact areas (LIA) as defined in Jacobson *et al.* (2019). The reason for this is that we aim to estimate the carbon potential in ecosystems close to an undisturbed state as possible. 

### Computational steps
The following computational steps are followed to generate datasets of soil organic carbon (SOC), above ground biomass (AGB) and canopy cover (CANOPY) for all **Ecoregions**

#### 1. Retrieve all global data
Retrieve all global data tiles (AGB, SOC, CANOPY), AGB tiles define the computation domain. We loop the algorithm over all tiles that constitute the entire global land surface 
#### 2. Resample
Resample SOC and LIA tiles to a common 30m grid 
#### (3). Mask Low Impact Areas
mask all data layers by LIA to extract only low impact regions for further analysis.
#### (4). Random Sample
Extract a 10000 random-point sample of values of each component (SOC, AGB and CANOPY) for ecoregions. This results in a number of results tables per tile (AGB, SOC, CANOPY, 3 cols x 10000 rows) equal to number of biome or ecoregion members within a tile. 
#### (5) 
Finally, we aggregate all values by biome/ecoregion member resulting in global datasets per member of SOC, AGB, CANOPY.
#### (6) 
Results are plotted as xy density scatter plots per Biome, due to large size of datasets.


### Input datasets



This is a collaborative project. Please contact me if you wish to contribute 

Biome # |Canopy Cover (%)|Plant Carbon (Mg/ha)|SOC (Mg/ha)|Biome name| Bastin 2019 Area (Mha)|Current SOC Stock (Gt)|Plant Carbon Potential (Gt)|Soil Carbon Potential (Gt)
---- | -----|------|---|------|-------------------|------|---------|--------
1|83|217|501|Tropical & Subtropical Moist Broadleaf Forests|82|6.3|18|41
2|60|135|267|Tropical & Subtropical Dry Broadleaf Forests|19|0.5|3|5
3|60|149|372|Tropical & Subtropical Coniferous Forests|6.8|0.1|1|3
4|57|118|450|Temperate Broadleaf & Mixed Forests|123.5|5.8|15|56
5|40|130|419|Temperate Conifer Forests|39|1.9|5|16
6|41|49|826|Boreal Forests/Taiga|284.7|23.9|14|235
7|22|69|208|Tropical & Subtropical Grasslands, Savannas & Shrublands|166.2|2.3|11|35
8|12|58|302|Temperate Grasslands, Savannas & Shrublands|92.4|3.7|5|28
9|18|39|363|Flooded Grasslands & Savannas|8.3|0.3|0|3
10|13|61|370|Montane Grasslands & Shrublands|18.4|1.4|1|7
11|5|21|889|Tundra|110.9|16.5|2|99
12|21|68|206|Mediterranean Forests, Woodlands & Scrub|18.5|0.5|1|4
13|3|30|141|Deserts & Xeric Shrublands|73.7|2.1|2|10
14|87|248|905|Mangroves|2.1|0.2|1|2
||||||||
||||||Total|**65.5**|**79**| **544**|
||||||||
