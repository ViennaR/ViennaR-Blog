# vim: set ft=r

library("ggplot2")
library("rgeos")
library("rgdal")

### data source: Stadt Wien - data.wien.gv.at
### http://data.wien.gv.at/katalog/bezirksgrenzen.html
url <- paste0("http://data.wien.gv.at/daten/geo?",
              "service=WFS&request=GetFeature&version=1.1.0&",
              "typeName=ogdwien:BEZIRKSGRENZEOGD&",
              "srsName=EPSG:4326&outputFormat=json")

if (!file.exists("VIE_districts.json"))
  download.file(url, "VIE_districts.json")

shp_vie <- readOGR("VIE_districts.json", layer="OGRGeoJSON")
shp_vie <- spTransform(shp_vie, CRS("+init=epsg:31253"))

### simplify geometry
shp_boundary <- gUnaryUnion(shp_vie)
shp_boundary <- gSimplify(shp_boundary, tol=0.005, topologyPreserve=TRUE)

p <- ggplot(data=fortify(shp_vie, region="BEZNR"), aes(x=long, y=lat, group=group)) +
     geom_path(data=shp_boundary, colour="darkgray", size=1.5) +
     geom_polygon(data=fortify(shp_vie, region="BEZNR"),
                  aes(fill=as.numeric(group)),
                  size=1.5, alpha=0.4) +
     scale_fill_continuous(low="darkgray", high="white", space="Lab") + 
     coord_equal() +
     theme_bw() +
     theme(legend.position="none",
           panel.grid.major=element_blank(),
           panel.grid.minor=element_blank(),
           panel.border=element_blank(),
           axis.ticks=element_blank(),
           axis.text=element_blank(),
           axis.title=element_blank())

### add contour lines
set.seed(1)
tmp <- as.data.frame(spsample(shp_vie, n=1000, type="random"))
p <- p + geom_density2d(data=tmp, aes(x=x, y=y), alpha=0.5, inherit.aes=FALSE)

svg("map.svg", width=8, height=4.75)
print(p)
dev.off()
