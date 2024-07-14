# installing relevant packages 
install.packages('raster')
install.packages("sf")
install.packages("RColorBrewer")
install.packages("dplyr")
install.packages("colorspace")
install.packages("rmarkdown")

library(raster)
library(sf)
library(RColorBrewer)
library(dplyr)
library(colorspace)
library(rmarkdown)


# read bulk data w/ proper working directory FOR PRE FIRE 
a <- "C:/Users/sarp/Documents/NASAWildfireAnalysis/REMOTEDATA/CALIFORNIAPreFire"
setwd(a)
getwd()

# 'bands' variable with tif file pattern 
pre_bands <- list.files(pattern = ".TIF")
print(pre_bands)

# creating multi-layer raster objects
pre_landsat_stack <- stack(pre_bands[1], pre_bands[2], pre_bands[3], pre_bands[4], pre_bands[5], pre_bands[6], pre_bands[7])
pre_landsat_brick <- brick(pre_landsat_stack)
print(pre_landsat_brick)
# defining the # of divisions for the color palette

# calculating Normalized Burn Ratio (NBR) [Landsat 8]
pre_NIR <- pre_landsat_brick[[5]]
pre_RED <- pre_landsat_brick[[4]]

pre_ndiv <- (pre_NIR - pre_RED) / (pre_NIR + pre_RED)

plot(pre_ndiv, main = "Csarf Smith River Complex (Landsat 8 - NDIV)\n Pre Fire", zlim = c(-1, 1))



# read bulk data w/ proper working directory FOR POST FIRE 
b <- "C:/Users/sarp/Documents/NASAWildfireAnalysis/REMOTEDATA/CALIFORNIAPostFire"
setwd(b)
getwd()

# 'bands' variable with tif file pattern 
post_bands <- list.files(pattern = ".TIF")
print(post_bands)

# creating multi-layer raster objects
post_landsat_stack <- stack(post_bands[1], post_bands[2], post_bands[3], post_bands[4], post_bands[5], post_bands[6], post_bands[7])
post_landsat_brick <- brick(post_landsat_stack)
print(post_landsat_brick)
# defining the # of divisions for the color palette

# calculating Normalized Burn Ratio (NBR) [Landsat 8]
post_NIR <- post_landsat_brick[[5]]
post_RED <- post_landsat_brick[[4]]

post_nbr <- (post_NIR - post_RED) / (post_NIR + post_RED)

plot(post_nbr, main = "Csarf Smith River Complex (Landsat 8 - RED)\n Post Fire", zlim = c(-1, 1))


