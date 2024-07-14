# installing relevant packages 
install.packages('raster')
install.packages("sf")
install.packages("RColorBrewer")
install.packages("dplyr")
install.packages("colorspace")
install.packages("rmarkdown")
install.packages("rasterVis")

library(raster)
library(sf)
library(RColorBrewer)
library(dplyr)
library(colorspace)
library(rmarkdown)
library(rasterVis)


# read bulk data w/ proper working directory FOR PRE FIRE 
a <- "C:/Users/sarp/Documents/NASA-U.S.-Wildfire-Analysis/code/REMOTEDATA/CALIFORNIAPreFire"
setwd(a)
getwd()

# 'bands' variable with tif file pattern 
pre_bands <- list.files(pattern = ".TIF")
print(pre_bands)

# creating multi-layer raster objects
pre_landsat_stack <- stack(pre_bands[1], pre_bands[2], pre_bands[3], pre_bands[4], pre_bands[5], pre_bands[6], pre_bands[7])
pre_landsat_brick <- brick(pre_landsat_stack)
print(pre_landsat_brick)

# defining the color palette
pre_nbr_color = colorRampPalette(brewer.pal(11, "PiYG"))(100)

# calculating Normalized Burn Ratio (NBR) [Landsat 8]
pre_NIR <- pre_landsat_brick[[5]]
pre_SWIR2 <- pre_landsat_brick[[7]]

pre_nbr <- (pre_NIR - pre_SWIR2) / (pre_NIR + pre_SWIR2)

plot(pre_nbr, main = "Csarf Smith River Complex (Landsat 8 - NBR)\n Pre Fire", col = pre_nbr_color, zlim = c(-1, 1))
  
  

# read bulk data w/ proper working directory FOR POST FIRE 
b <- "C:/Users/sarp/Documents/NASA-U.S.-Wildfire-Analysis/code/REMOTEDATA/CALIFORNIAPostFire"
setwd(b)
getwd()

# 'bands' variable with tif file pattern 
post_bands <- list.files(pattern = ".TIF")
print(post_bands)

# creating multi-layer raster objects
post_landsat_stack <- stack(post_bands[1], post_bands[2], post_bands[3], post_bands[4], post_bands[5], post_bands[6], post_bands[7])
post_landsat_brick <- brick(post_landsat_stack)
print(post_landsat_brick)

# defining the color palette
post_nbr_color = colorRampPalette(brewer.pal(11, "PiYG"))(100)

# calculating Normalized Burn Ratio (NBR) [Landsat 8]
post_NIR <- post_landsat_brick[[5]]
post_SWIR2 <- post_landsat_brick[[7]]

post_nbr <- (post_NIR - post_SWIR2) / (post_NIR + post_SWIR2)

plot(post_nbr, main = "Csarf Smith River Complex (Landsat 8 - NBR)\n Post Fire", col = post_nbr_color, zlim = c(-1, 1))

# difference NBR 
post_nbr_resampled <- resample(post_nbr, pre_nbr, method = "bilinear")
difference_nbr <- pre_nbr - post_nbr_resampled
plot(difference_nbr, main = "Difference in NBR\n Csarf Smith River Complex", zlim = c(-1, 1))

# classifying the difference NBR and plotting it
breaks <- c(-Inf, -0.1, 0.1, 0.27, 0.66, Inf)
labels <- c("Enhanced Regrowth", "Unburned", "Low Severity", "Moderate Severity", "High Severity")

reclass_matrix <- matrix(c(-Inf, -0.1, 1,
                           -0.1, 0.1, 2,
                           0.1, 0.27, 3,
                           0.27, 0.66, 4,
                           0.66, Inf, 5), 
                         ncol = 3, byrow = TRUE)

classified_nbr <- reclassify(difference_nbr, reclass_matrix)
class_colors <- c("#006400", "#ADFF2F", "#FFFF00", "#FFA500", "#8B0000")
plot(classified_nbr, main = "Classified dNBR\n Csarf Smith River Complex", col = class_colors, legend = FALSE)
legend("topleft", legend = labels, fill = class_colors, bty = "n")
