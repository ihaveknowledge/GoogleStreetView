#---Load libraries-------------------------------------------------------
library(jsonlite)
library(ggplot2)
library(curl)
library(RCurl)
library(jpeg)

setwd("C:\\Users\\msinclair\\Offline Documents\\GIS\\GoogleSV")

#---Set parameters for Google SV request---------------------------------
size <- "600x400"
#location <- "6.249331,-62.846035" #Angel Falls, Parque Nacional Canaima
location <- "51.5963148,0.3117262"
heading <- 45
pitch <- 10
key <-  "AIzaSyA8CR5AeI2wP_fRZcmRw5mX3LTGoqAv1qU"

#---Pass parameters into url---------------------------------------------
url <- paste0('https://maps.googleapis.com/maps/api/streetview?size=',size,'&location=',location,'&heading=',heading,'&pitch=',pitch,'&key=',key)

#---Create a JPEG file---------------------------------------------------
z <- tempfile()
download.file(url,z,mode="wb")
pic <- readJPEG(z)
file.remove(z) # cleanup

#---Write JPEG to a file-------------------------------------------------
#file.name <- paste0("test", location, heading,".jpeg")
#writeJPEG(pic, file.name)

#---Add the RGB values and hex code to the image data--------------------
img <- pic
remove(pic)

imgDm <- dim(img)

imgRGB <- data.frame(
  x = rep(1:imgDm[2], each = imgDm[1]),
  y = rep(imgDm[1]:1, imgDm[2]),
  R = as.vector(img[,,1]),
  G = as.vector(img[,,2]),
  B = as.vector(img[,,3])
)

remove(img)

imgRGB$hex <- paste0("#",as.hexmode(imgRGB$R*255),as.hexmode(imgRGB$G*255),as.hexmode(imgRGB$B*255))
imgRGB$diff1 <- imgRGB$G - imgRGB$R
imgRGB$diff2 <- imgRGB$G - imgRGB$B
imgRGB$diff <- imgRGB$diff1 * imgRGB$diff2
imgRGB$green <- 1

for (i in 1:240000)
{
  if (imgRGB$diff1[i] < 0)
  {
    imgRGB$green[i] <- 0
  }

  if (imgRGB$diff[i] < 0)
  {
    imgRGB$green[i] <- 0
  }
}

#---GGplot image--------------------------------------------------------
ggplot(imgRGB, aes(x=x, y=y)) + geom_point(col = imgRGB$hex) + theme(legend.position="none")


ggplot(imgRGB, aes(x=diff1, y=diff)) + geom_point(col = imgRGB$hex) + theme(legend.position="none")

#---Classfy the image into "green" and "not green"----------------------


#---Clear environment
rm(list=ls())
