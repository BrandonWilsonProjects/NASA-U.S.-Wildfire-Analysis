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
pre_ndiv_color = colorRampPalette(brewer.pal(11, "PiYG"))(100)

# calculating Normalized Difference In Vegetation (NDIV) [Landsat 8]
pre_NIR <- pre_landsat_brick[[5]]
pre_RED <- pre_landsat_brick[[4]]

pre_ndiv <- (pre_NIR - pre_RED) / (pre_NIR + pre_RED)

plot(pre_ndiv, main = "Csarf Smith River Complex (Landsat 8 - NDIV)\n Pre Fire", col = pre_ndiv_color, zlim = c(-1, 1))



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
post_ndiv_color = colorRampPalette(brewer.pal(11, "PiYG"))(100)

# calculating Normalized Difference In Vegetation (NDIV) [Landsat 8]
post_NIR <- post_landsat_brick[[5]]
post_RED <- post_landsat_brick[[4]]

post_ndiv <- (post_NIR - post_RED) / (post_NIR + post_RED)

plot(post_ndiv, main = "Csarf Smith River Complex (Landsat 8 - NDIV)\n Post Fire", col = post_ndiv_color, zlim = c(-1, 1))

post_ndiv_resampled <- resample(post_ndiv, pre_ndiv, method = "bilinear")
difference_ndiv <- pre_ndiv - post_ndiv_resampled
plot(difference_ndiv, main = "Difference in NDIV\n Csarf Smith River Complex", zlim = c(-1, 1))

# classifying the difference NBR and plotting it
breaks <- c(-Inf, -0.1, 0.1, 0.27, 0.66, Inf)
labels <- c("None Detected", "Low", "Moderate", "High", "Very High")

reclass_matrix <- matrix(c(-Inf, -0.1, 1,
                           -0.1, 0.1, 2,
                           0.1, 0.27, 3,
                           0.27, 0.66, 4,
                           0.66, Inf, 5), 
                         ncol = 3, byrow = TRUE)

classified_ndiv <- reclassify(difference_ndiv, reclass_matrix)
class_colors <- c("#68228B", "#9932CC", "#FFFFF0", "#7FFF00", "#458B00")
plot(classified_ndiv, main = "Classified dNDIV\n Csarf Smith River Complex", col = class_colors, legend = FALSE)
legend("topleft", legend = labels, fill = class_colors, bty = "n")
