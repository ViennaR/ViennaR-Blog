library("grid")
library("grImport")
library("ggplot2")
library("extrafont")
library("rgdal")

set.seed(1)

PostScriptTrace("R_simple.eps")
x <- readPicture("R_simple.eps.xml")

tmp <- expand.grid(x=seq(0, 1, length=10), y=seq(0, 1, length=10))
tmp[["z"]] <- rnorm(nrow(tmp))

### data source: Stadt Wien - data.wien.gv.at
### http://data.wien.gv.at/katalog/bezirksgrenzen.html
url <- paste0("http://data.wien.gv.at/daten/geo?",
              "service=WFS&request=GetFeature&version=1.1.0&",
              "typeName=ogdwien:BEZIRKSGRENZEOGD&",
              "srsName=EPSG:4326&outputFormat=json")

if (!file.exists("VIE_districts.json"))
  download.file(url, "VIE_districts.json")

vie_boundary <- readOGR("VIE_districts.json", "OGRGeoJSON")
vie_boundary <- spTransform(vie_boundary, CRS("+init=epsg:31253"))

p <- ggplot(data.frame(x=-1, y=-1, cat=factor("Vienna"))) +
     coord_cartesian(xlim=c(0, 1), ylim=c(0, 1)) +
     geom_blank(aes(x=x, y=y)) +
     facet_wrap(~ cat) +
     theme(axis.line=element_blank(),
           axis.text.x=element_blank(),
           axis.text.y=element_blank(),
           axis.ticks=element_blank(),
           axis.title.x=element_blank(),
           axis.title.y=element_blank(),
           panel.grid.minor = element_blank(),
           strip.text.x = element_text(size=65, face="plain", colour="#2d2d2d", family="Redressed"),
           plot.margin=unit(c(5,5,0,0),"mm"),
           legend.position="none")

svg("logo_plain.svg", 4, 4)
print(p)
grid.picture(x, x=0.52, y=0.43, width=0.75, height=0.75, xscale=c(0, 500), yscale=c(0, 500))
dev.off()
png("logo_plain_256.png", 256, 256)
print(p)
grid.picture(x, x=0.52, y=0.43, width=0.75, height=0.75, xscale=c(0, 500), yscale=c(0, 500))
dev.off()

p1 <- p +
      geom_tile(data=tmp, aes(x=x, y=y, fill=z)) +
      scale_fill_gradient(low="gold", high="white") +

svg("logo_tile.svg", 4, 4)
print(p1)
grid.picture(x, x=0.50, y=0.43, width=0.75, height=0.75, xscale=c(0, 500), yscale=c(0, 500))
dev.off()
png("logo_tile_256.png", 256, 256)
print(p1)
grid.picture(x, x=0.50, y=0.43, width=0.75, height=0.75, xscale=c(0, 500), yscale=c(0, 500))
dev.off()

map_data <- fortify(vie_boundary, region="DISTRICT_CODE")
map_data[["cat"]] <- "Vienna"
p2 <- ggplot() +
      geom_polygon(data=map_data,
                   aes(x=long, y=lat, group=group), fill="gray90", colour="gray65") +
      scale_fill_continuous(low="darkgray", high="white", space="Lab") +
      coord_cartesian(xlim=extendrange(bbox(vie_boundary)[1, ]),
                      ylim=extendrange(bbox(vie_boundary)[2, ])) +
      facet_wrap(~ cat) +
      theme_bw() +
      theme(axis.line=element_blank(),
            axis.text.x=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            # http://www.fontsquirrel.com/fonts/redressed
            strip.text.x = element_text(size=65, face="plain", colour="#2d2d2d", family="Redressed"),
            plot.margin=unit(c(5,5,0,0),"mm"),
            legend.position="none")

svg("logo_map.svg", 4, 4)
print(p2)
grid.picture(x, x=0.75, y=0.46, width=0.45, height=0.45, xscale=c(0, 500), yscale=c(0, 500))
dev.off()
png("../logo.png", 256, 256)
print(p2)
grid.picture(x, x=0.75, y=0.43, width=0.45, height=0.45, xscale=c(0, 500), yscale=c(0, 500))
dev.off()
