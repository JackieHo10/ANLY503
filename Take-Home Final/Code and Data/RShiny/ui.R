#shiny (ui)
library(shiny)
#load data set
mydf_shiny <- read.csv("503FinalR.csv")
shinyUI(fluidPage(
  titlePanel("R Shiny -- NHL"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30),
      hr(),
      helpText("NHL Data")
    ),
    mainPanel(
      plotOutput(outputId = "distPlot"),
      plotOutput(outputId = "HPlot")
    )
  )
))


