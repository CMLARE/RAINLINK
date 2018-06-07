# cml stats
library(tidyverse)
library(txtplot)
s2p <- function(str){return(as.POSIXct(str, format='%Y%m%d%H%M', tz='GMT'))}
source('Config.R')

# Load example data:
data("sriLanka")

# takes care of formatting 
colnames(x) <- c("ID", "Pmax","Pmin","YStart","XStart","YEnd","XEnd","DateTime","PathLength","Frequency")

negAttenuation <- x$Pmin - x$Pmax  # computes negative attenuation
x$Pmin <- x$Pmax <- negAttenuation

x$DateTime <- s2p(as.character(x$DateTime)) # DateTime as char string

length(unique(x$ID))
length(unique(x$PathLength))
length(unique(x$XStart))
length(unique(x$YStart))
length(unique(x$XEnd))
length(unique(x$YEnd))

x$PathLength <- round(x$PathLength, 2)
x$XStart <- round(x$XStart, 4)
x$YStart <- round(x$YStart, 4)
x$XEnd <- round(x$XEnd, 4)
x$YEnd <- round(x$YEnd, 4)

length(unique(x$PathLength))
length(unique(x$XStart))
length(unique(x$YStart))
length(unique(x$XEnd))
length(unique(x$YEnd))


ids <- unique(x$ID)
life <- as.numeric(max(x$DateTime)-min(x$DateTime))*4 

cml <- tibble()
for(i in 1:length(ids))
{
  index  <- which(x$ID==ids[i])
  rdings <- length(x$ID[index])
  alive  <- length(which(!is.na(x$Pmin[index])))
  ratio  <- alive/rdings #*100
  cover  <- alive/life #*100
  part   <- data.frame(ID         = ids[i], 
                       PathLength = x$PathLength[index][1], 
                       XStart     = x$XStart[index][1],
                       YStart     = x$YStart[index][1],
                       XEnd       = x$XEnd[index][1],
                       YEnd       = x$YEnd[index][1],
                       Readings   = rdings,
                       Quality    = ratio, #paste(sprintf("%.1f", ratio), '%'),
                       Coverage   = cover) #paste(sprintf("%.1f", cover), '%'))
  cml <- rbind(cml, part)
}

cml <- cml[order(cml$ID),]
# write_csv(cml, 'info.csv')



map <- get_map(location = c(81,7), maptype = GoogleMapType, source = "google",
               zoom=6,color=ColourType)

# Plot base map for the considered time interval:
fig <- ggmap(map, extent = "normal", maprange=FALSE) #+ 
#   theme(axis.title.x=element_text(size =rel(5),family=FontFamily)) + 
#   xlab(LabelAxisLon) + theme(axis.title.y=element_text(size =rel(5),family=FontFamily)) + 
#   ylab(LabelAxisLat) + theme(axis.text = element_text(size=rel(4),family=FontFamily)) + 
#   theme(axis.ticks = element_line(size = 22)) +  
#   theme(plot.title = element_text(family = FontFamily, face="bold", size=SizePlotTitle, vjust=3))


# Plot microwave link locations:
# Vodaf links in predef color
fig <- fig + geom_segment(aes(x=XStart,y=YStart,
                              xend=XEnd,yend=YEnd),data=x,alpha=AlphaLinkLocations,
                          col='red',size=SizeLinks)