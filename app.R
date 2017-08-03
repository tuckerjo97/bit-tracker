library(shiny)
library(shinythemes)

##### Intitial exchange Prices #####
kraken_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_kraken_price; get_kraken_price()'", intern = TRUE)
bitcoin_price <- reactiveValues(kraken_usd = strsplit(kraken_price_raw, ",")[[1]][1], 
                                kraken_eur = strsplit(kraken_price_raw, ",")[[1]][2])
bitstamp_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_bitstamp_price; get_bitstamp_price()'", intern = TRUE)
bitcoin_price$bitstamp_usd <- strsplit(bitstamp_price_raw, ",")[[1]][1]
bitcoin_price$bitstamp_eur <- strsplit(bitstamp_price_raw, ",")[[1]][2]

gdax_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_gdax_price; get_gdax_price()'", intern = TRUE)
bitcoin_price$gdax_usd <- strsplit(gdax_price_raw, ",")[[1]][1]
bitcoin_price$gdax_eur <- strsplit(gdax_price_raw, ",")[[1]][2]

###### SERVER ######
server <- function(input, output) {
  
  # Price update timers in milliseconds
  kraken_timer <- reactiveTimer(10000)
  bitstamp_timer <- reactiveTimer(10000)
  gdax_timer <- reactiveTimer(10000)
  
  # Kraken prices update
  observeEvent(kraken_timer(),{
    kraken_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_kraken_price; get_kraken_price()'", intern = TRUE)
    bitcoin_price$kraken_usd <- strsplit(kraken_price_raw, ",")[[1]][1]
    bitcoin_price$kraken_eur <- strsplit(kraken_price_raw, ",")[[1]][2]
  })
  
  # Bitstamp prices update
  observeEvent(bitstamp_timer(),{    
    bitstamp_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_bitstamp_price; get_bitstamp_price()'", intern = TRUE)
    bitcoin_price$bitstamp_usd <- strsplit(bitstamp_price_raw, ",")[[1]][1]
    bitcoin_price$bitstamp_eur <- strsplit(bitstamp_price_raw, ",")[[1]][2]
  })
  
  # GDAX prices update
  observeEvent(gdax_timer(),{    
    gdax_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_gdax_price; get_gdax_price()'", intern = TRUE)
    bitcoin_price$gdax_usd <- strsplit(gdax_price_raw, ",")[[1]][1]
    bitcoin_price$gdax_eur <- strsplit(gdax_price_raw, ",")[[1]][2]
  })
  
  # Outputs price to UI
  observeEvent(input$go,{
    currency_price <- paste0(tolower(input$exchange),"_",tolower(input$currency))
    exchange_text_temp <- paste("Exchange:", input$exchange)
    output$exchange_text <- renderText(exchange_text_temp)
    
    pair <- paste0("BTC/", input$currency)
    output$pair_text <- renderText(paste("Pair:", pair))
    
    currency_stats <- strsplit(bitcoin_price[[currency_price]], " ")
    ask <- currency_stats[[1]][1]
    bid <- currency_stats[[1]][2]
    last <- currency_stats[[1]][3]
    output$ask_text <- renderText(paste("Ask:", ask))
    output$bid_text <- renderText(paste("Bid:", bid))
    output$last_text <- renderText(paste("Last:", last))
  })
}
###### SERVER END ######

###### UI ######
ui <- fluidPage(
  
  theme = shinytheme("superhero"),
  includeCSS("title.css"),
  
  #### Application title ####
  titlePanel("Bit Tracker"),
  
  
  sidebarLayout(
    sidebarPanel(
      selectInput("exchange",
                  "Exchange",
                  choices = c("Bitstamp", "GDAX", "Kraken")),
      selectInput("currency",
                  "Currency",
                  choices = c("USD", "EUR")),
      actionButton("go", "GO", icon("piggy-bank", lib = "glyphicon"),  style="color: #fff; background-color:green; border-color: green")
    ),
    
    #### Main Panel ####
    mainPanel(
      textOutput("exchange_text"),
      textOutput("pair_text"),
      textOutput("ask_text"),
      textOutput("bid_text"),
      textOutput("last_text")
      
    )
  )
)
###### UI END ######

shinyApp(ui = ui, server = server)
#runApp(host = "0.0.0.0", port = 5050)
