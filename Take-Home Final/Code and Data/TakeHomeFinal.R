## ANLY503 Take Home Final ##
# Jie He #
setwd("C:/Users/jacky/Desktop/HW/ANLY503/Final")
rm(list=ls())
cat("\014")
dev.off()
options(warn=-1)

#import libraries
require(MASS)
require(tidyverse)
require(ggplot2)
require(ggthemes)
library(plotly)
library(datasets)
library(xml2)
library(htmlwidgets)
library(leaflet)
library(RCurl)
library(rjson)
library(webshot)
library(tigris)
library(dplyr)
library(rgdal)

#load data set
mydf <- read.csv("nhl.csv")
mydf_1 <- read.csv("nhl_1.csv")
mydf_2 <- read.csv("test_salaries.csv")
mydf_3 <- read.csv("50statesCount.csv")

#combine data sets
mydf_1$Salary <- mydf_2$Salary
mydf <- rbind(mydf, mydf_1)

#clean data set
mydf <- mydf[, -c(4, 23:154)]
head(mydf, 5)
mydf <- mydf[complete.cases(mydf), ] #removing missing values
mydf$Nat_Group <- ifelse(mydf$Nat %in% c("CAN", "USA"), mydf$Nat, "Others") #create a new feature
for(i in 1:length(mydf$Nat_Group)){
  if(mydf$Nat_Group[i] == 2){
    mydf$Nat_Group[i] <- "CAN"
  } else if(mydf$Nat_Group[i] == 16){
    mydf$Nat_Group[i] <- "USA"
  } 
} 

#save dataframe to csv
write.csv(mydf, '503FinalR.csv')

#make graphs#

#ggplot
#G1
ggplot(data = mydf, aes(x = Ht, y = Salary, color = Hand)) + geom_point() + 
  geom_line(data = mydf, color = "yellow", size = 0.5) + 
  geom_smooth(size = 0.5, se = FALSE, method = 'loess') + 
  ggtitle("Relations between Salary and Height (labelled by Hands)") + xlab("Height") + ylab("Salary") + 
  theme_calc()
dev.copy(png,'ggplot_1.png') #save the graph
dev.off()

#G2
ggplot(data = mydf, aes(x = Nat_Group, y = Salary)) + 
  geom_boxplot(aes(fill = Hand)) + 
  geom_jitter() + 
  geom_hline(yintercept = 7e+06, color = "black", size = 0.8) + 
  ggtitle("Nationality Groups VS Salary (labelled by Hands)") + 
  theme_solarized()
dev.copy(png,'ggplot_2.png')
dev.off()

#G3
ggplot(data = mydf, aes(x = Ht, fill = Hand)) +  
  geom_bar(binwidth = 0.5) + 
  geom_histogram(binwidth = 0.5) + 
  geom_hline(yintercept = 25, color = "blue", size = 0.5) + 
  facet_wrap(~ Nat_Group, nrow = 1) + 
  ggtitle("Height Counter (labelled by Hands) based on Nationality Groups") + xlab("Height") + ylab("Count") + 
  theme_light()
dev.copy(png,'ggplot_3.png')
dev.off()

#other plot (PCP)
parcoord(mydf[, c(1, 10, 16)], col=rainbow(length(mydf[, 1])), lty=1:5, var.label=TRUE, main = "parallel coordinates plot (PCP)")
dev.copy(png,'PCP.png')
dev.off()

#plotly
#set API keys
Sys.setenv("plotly_username" = "anly503")
Sys.setenv("plotly_api_key" = "rnmEgpkrOTohJlCXLzKI")
pic <- plot_ly(mydf, x = ~GP, y = ~Ovrl, z = ~G, 
               marker = list(color = ~Salary, colorscale = c('#09043d', '#04b6f7'), showscale = TRUE)) %>%
  add_markers() %>%
  layout(title = "Performance and Salary in 3D", 
         scene = list(xaxis = list(title = '# of Games Played'),
                      yaxis = list(title = 'Overal NHL Draft pick'),
                      zaxis = list(title = 'Total Goals Scored')))
pic
api_create(pic, filename = "3D Scatter Plot")
htmlwidgets::saveWidget(as_widget(pic), "3d_scatter_plot.html")

pic_1 <- plot_ly(mydf, x = ~Wt, y = ~A, z = ~G, 
                 marker = list(color = ~Salary, colorscale = c('#184ea5', '#020e21'), showscale = TRUE)) %>%
  add_markers() %>%
  layout(title = "Goal/Assist/Weight and Salary in 3D", 
         scene = list(xaxis = list(title = 'Weight'),
                      yaxis = list(title = 'Total Assists Recorded'),
                      zaxis = list(title = 'Total Goals Scored')))
pic_1
api_create(pic_1, filename = "3D Scatter Plot (1)")
htmlwidgets::saveWidget(as_widget(pic_1), "3d_scatter_plot_1.html")

#leaflet
url <-"https://raw.githubusercontent.com/nhlscorebot/arenas/master/teams.json"
json <- getURL(url)
location <- fromJSON(json)
download.file(url = url, destfile = "nhl_teams.json", method = "libcurl")
#clean data and construct a useful dataframe 
arena <- data.frame("team_name" = names(location))
loc <- unlist(location)
arena$name <- loc[seq(1, length(loc), by=3)]
arena$lat <- loc[seq(2, length(loc), by=3)]
arena$lng <- loc[seq(3, length(loc), by=3)]
arena$lat <- as.numeric(arena$lat)
arena$lng <- as.numeric(arena$lng)
arena$label <- paste0(arena$team_name, '@', arena$name)
#create the map
outline <- arena[chull(arena$lng, arena$lat), ]
setwd("C:/Users/jacky/Desktop/HW/ANLY503/Final/cb_2017_us_state_500k")
us_states <- readOGR("cb_2017_us_state_500k.shp")           
plot(us_states)
setwd("C:/Users/jacky/Desktop/HW/ANLY503/Final")

mydf_4 <- merge(us_states, mydf_3)
popup_1 <- paste0("<span style='color: #7f0000'><strong>US NHL Players </strong></span>",
                  "<br><span style='color: salmon;'><strong>State: </strong></span>", 
                  mydf_4$NAME, 
                  "<br><span style='color: salmon;'><strong># of Players: </strong></span>", 
                  mydf_4$NumOfPlayer
)
col_bin <- colorBin(c('#fee0d2',  
                      '#fcbba1',
                      '#fc9272',
                      '#fb6a4a',
                      '#ef3b2c',
                      '#cb181d',
                      '#a50f15',
                      '#67000d'), 
                    bins = c(1,10,20,25,30,35,40,50))

map <- leaflet(arena) %>% 
  #base layer (choropleth)
  addTiles() %>% 
  addPolygons(data = us_states, 
              fillColor = ~col_bin(mydf_4$NumOfPlayer),
              fillOpacity = 0.5,       
              color = "grey",      
              weight = 1.5, 
              popup = popup_1) %>%
  addLegend(position = 'bottomleft', 
            colors = c('#fee0d2',
                       '#fcbba1',
                       '#fc9272',
                       '#fb6a4a',
                       '#ef3b2c',
                       '#cb181d',
                       '#a50f15',
                       '#67000d'), 
            labels = c('0%', "", "", "", "", "", "", '100%'), 
            opacity = 0.5,      
            title = "scale") %>%
  #overlay layer
  addMarkers(popup = arena$label, group = "layer1") %>% 
  addPolygons(data = outline, lng = ~lng, lat = ~lat,
              fill = TRUE, weight = 3, color = "blue", group = "layer2") %>% 
  #layer controller
  addLayersControl(
    overlayGroups = c("layer1", "layer2"),
    options = layersControlOptions(collapsed = FALSE)
  )
map
#save the map
require(htmlwidgets)
saveWidget(map, file = "Leaflet_map.html")


#D3js
#import libraries
library(threejs)
library(htmlwidgets)
#make the plot
myJ3 <- scatterplot3js(mydf$GP, mydf$Ovrl, mydf$Salary, 
                       color = c("green", "yellow", "red")[as.factor(mydf$Nat_Group)], 
                       axisLabels = c("Games_Played", "Salary", "Overall_Draft"), main = "Games VS Draft VS Salary")
saveWidget(myJ3, file = "D3js.html", selfcontained = TRUE, libdir = NULL, background = "white")

#Network D3
#import libraries
library(igraph)
library(networkD3)
library(xlsx)
#load data
mydf <- read.xlsx("nd3.xlsx", 1)
edgeList <- mydf
#create a graph
gd <- igraph::simplify(igraph::graph.data.frame(edgeList, directed=FALSE))
#create node list
nodeList <- data.frame(ID = c(0:(igraph::vcount(gd) - 1)), nName = igraph::V(gd)$name)
getNodeID <- function(x){
  which(x == igraph::V(gd)$name) - 1
}
edgeList <- plyr::ddply(edgeList, .variables = c("player_", "Nat_Group", "salary_"), 
                        function (x) data.frame(SourceID = getNodeID(x$player_), 
                                                TargetID = getNodeID(x$Nat_Group)))
#calculate node degrees
nodeList <- cbind(nodeList, nodeDegree=igraph::degree(gd, v = igraph::V(gd), mode = "all"))
#calculate node betweenness
betAll <- igraph::betweenness(gd, v = igraph::V(gd), directed = FALSE) / (((igraph::vcount(gd) - 1) * (igraph::vcount(gd)-2)) / 2)
betAll.norm <- (betAll - min(betAll))/(max(betAll) - min(betAll))
nodeList <- cbind(nodeList, nodeBetweenness = 100*betAll.norm)
#calculate node dice similarities
dsAll <- igraph::similarity.dice(gd, vids = igraph::V(gd), mode = "all")
F1 <- function(x) {
  data.frame(diceSim = dsAll[x$SourceID + 1, x$TargetID + 1])
}
edgeList <- plyr::ddply(edgeList, .variables=c("player_", "Nat_Group", "salary_", "SourceID", "TargetID"), function(x) data.frame(F1(x)))
#set color of edges
F2 <- colorRampPalette(c("#FFFF00", "#FF0000"), bias = nrow(edgeList), space = "rgb", interpolate = "linear")
colCodes <- F2(length(unique(edgeList$diceSim)))
edges_col <- sapply(edgeList$diceSim, function(x) colCodes[which(sort(unique(edgeList$diceSim)) == x)])
#create the network
D3_network <- networkD3::forceNetwork(Links = edgeList, 
                                      Nodes = nodeList, 
                                      Source = "SourceID", 
                                      Target = "TargetID", 
                                      Value = "salary_", 
                                      NodeID = "nName", 
                                      Nodesize = "nodeBetweenness",  
                                      Group = "nodeDegree", 
                                      height = 1500, 
                                      width = 1500,  
                                      fontSize = 15, 
                                      linkDistance = networkD3::JS("function(d) { return 0.8*d.value; }"),
                                      linkWidth = networkD3::JS("function(d) { return d.value/0.5; }"),
                                      opacity = 0.5, 
                                      zoom = TRUE,
                                      opacityNoHover = 0.2,
                                      linkColour = edges_col) 
D3_network #plot
networkD3::saveNetwork(D3_network, "D3_R.html", selfcontained = TRUE) #save as html


























