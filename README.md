# Carbon Potential
## We estimate the carbon potential of all Biomes and their Ecoregions using published global datasets
### This is a collaborative project. Please contact me if you wish to contribute.
Joel Fiddes and Christopher Philipson
The aim is to estimate both the soil and plant **carbon potential** for all global terrestrial **Biomes** and **Ecoregions.**

## Example Biomes
For areas of low human impact, we explore the relationship between Soil Oganic Carbon (SOC), Plant Carbon and Canopy Cover for all Biomes accounting for variation in Ecoregions.  Here we present four example Biomes:
![Fig 2](https://github.com/PhilipsonChristopher/CarbonPotential/blob/master/Fig2_Biomes.png)
Fig 2. The relationship between carbon density and canopy cover for ‘low impact areas’. Data are presented as a heat scatter plot with separate columns for Aboveground Carbon Density (first column), Soil Organic Carbon (second column) and Total Carbon (third column). We present four example Biomes: In the first row, tropical moist forests, in the second row, tropical coniferous forests, in the third row tropical grasslands, savannahs & schrublands, and in the forth row mangroves. All biomes are presented in Fig S1. Frequency density plots adjacent to the axis highlight the distribution of each variable (carbon density and canopy cover) and therefor the highlight most common canopy cover % and most common carbon density independently of their relationship.


## Methods
### Low impact areas mask
In order to estimate the carbon potential of undisturbed ecosystems, we only sample Low Impact Areas (LIA) as defined in Jacobson *et al.* (2019). The reason for this is that we aim to estimate the carbon potential in ecosystems close to an undisturbed state as possible. 

### Input datasets
We use the following datasets.  We are open to using other datasets if available (dependent on funding for computational time).
[!Insert Joels Input datasets markdown table]

### Computational steps:
We follow these computational steps to generate datasets of soil organic carbon (SOC), aboveground biomass (AGB) and canopy cover (CANOPY) for all **Ecoregions**

#### 1. Retrieve all global data
To retrieve all global data tiles (AGB, SOC, CANOPY), we loop the algorithm over all tiles that constitute the entire global land surface. The AGB tiles define the computation domain.
#### 2. Resample
Resample SOC and LIA tiles to a common 30m grid
#### 3. Mask Low Impact Areas
Mask all data layers by LIA to extract data only from low impact regions for further analysis.
#### 4. Random Sample
Extract a 10000 random-point sample of values of each component (SOC, AGB and CANOPY) for each ecoregion. This results in a number of results tables per tile (AGB, SOC, CANOPY, 3 cols x 10000 rows) equal to number of ecoregions within a tile. 
#### 5. Aggregate tiles
Finally, we aggregate all values by Ecoregion resulting in a global dataset of Ecoregions each with SOC, AGB, CANOPY.
#### 6. Predictions and graphs
Results are plotted as xy density scatter plots per Biome, due to large size of datasets.  We model the realtionship between carbon (each SOC and AGB) and canopy cover for each Biome using linear mixed effects models with a random effect for Ecoregion.  We estimate the carbon potential by predicting the SOC and AGB at the mean canopy cover for each biome. We will do this at the ecoregion level.

## Example Ecoregions
Five example ecoregions from Biome 1, 'Tropical & Subtropical Moist Broadleaf Forests'
![Fig 3](https://github.com/PhilipsonChristopher/CarbonPotential/blob/master/LI_Ecoregions1-5.png)


## Table 2. Carbon Potential aggregated at the Biome level.  
This is the average of all Ecoregions.
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
||||||Total|**65.5 (Gt)**|**79 (Gt)**| **544 (Gt)**|
||||||||
