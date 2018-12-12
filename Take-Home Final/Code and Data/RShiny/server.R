#shiny (server)
library(shiny)
#load data set
setwd("C:/Users/jacky/Desktop/HW/ANLY503/Final/RShiny")
mydf_shiny <- read.csv("503FinalR.csv")
#define server logic
shinyServer(function(input, output) {
  output$HPlot <- renderPlot({
    plot(mydf_shiny$GP, mydf_shiny$Salary, 
         main = "Game_Play VS Salary",
         ylab = "Expected Salary",
         xlab = "# of Games Played")
  })

  output$distPlot <- renderPlot({
    ExpectedSalary <- mydf_shiny$Salary
    bins <- seq(min(ExpectedSalary), max(ExpectedSalary), length.out = input$bins + 1)
    return(hist(ExpectedSalary, breaks = bins, col = "red", border = "black"))
  })  
})

#http://127.0.0.1:3377/
#https://anly503.shinyapps.io/R_Shiny/

