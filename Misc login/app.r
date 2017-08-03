library(shiny)
library(shinythemes)
setwd("~/Desktop/R/bit tracker")

login.df <- read.csv("User Database.csv")

ui <- fluidPage(
  theme = shinytheme("superhero"),
  
  includeCSS("title.css"),
  
  titlePanel(h1("Bit-Tracker", align = "center")),
  
  column(width = 8, offset = 4,
    sidebarPanel(width = 6,
                 textInput("name", "Name", ""),
                 passwordInput("password","Password",""),
                 actionButton("submit", "  Submit", icon("id-card-o"), 
                              style="color: #fff; background-color:green; border-color: green")
    )
  ),
  fluidRow(textOutput("text")
  )
)

## Need to check for NA ###
server <- function(input, output, session){
  observeEvent(input$submit, {
    if(input$name %in% login.df$Username && login.df[login.df$Username == input$name, "Password"] == input$password){
      output$text <- renderText("True")
    }
    else{
      output$text <- renderText("False")
    }})
}

shinyApp(ui = ui, server = server)