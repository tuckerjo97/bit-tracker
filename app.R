library(shiny)
library(shinythemes)
library(readr)


exchange_to_currency_df <- as.data.frame(read_csv("exchange_to_currency.csv"))

##### Intitial exchange Prices #####
kraken_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_kraken_price; get_kraken_price()'", intern = TRUE)
kraken_price_split <- strsplit(kraken_price_raw, ",")[[1]]
bitcoin_price <- reactiveValues(kraken_usd = kraken_price_split[1], 
                                kraken_eur = kraken_price_split[2],
                                kraken_cad = kraken_price_split[3],
                                kraken_gbp = kraken_price_split[4],
                                kraken_jpy = kraken_price_split[5])

bitstamp_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_bitstamp_price; get_bitstamp_price()'", intern = TRUE)
bitstamp_price_split <- strsplit(bitstamp_price_raw, ",")[[1]]
bitcoin_price$bitstamp_usd <- bitstamp_price_split[1]
bitcoin_price$bitstamp_eur <- bitstamp_price_split[2]

gdax_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_gdax_price; get_gdax_price()'", intern = TRUE)
gdax_price_split <- strsplit(gdax_price_raw, ",")[[1]]
bitcoin_price$gdax_usd <- gdax_price_split[1]
bitcoin_price$gdax_eur <- gdax_price_split[2]

###### SERVER ######
server <- function(input, output, session) {
  
  # Price update timers in milliseconds
  kraken_timer <- reactiveTimer(10000)
  bitstamp_timer <- reactiveTimer(10000)
  gdax_timer <- reactiveTimer(10000)
  
  # Kraken prices update
  observeEvent(kraken_timer(),{
    kraken_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_kraken_price; get_kraken_price()'", intern = TRUE)
    kraken_price_split <- strsplit(kraken_price_raw, ",")[[1]]
    bitcoin_price$kraken_usd <- kraken_price_split[1]
    bitcoin_price$kraken_eur <- kraken_price_split[2]
    bitcoin_price$kraken_cad <- kraken_price_split[3]
    bitcoin_price$kraken_gbp <- kraken_price_split[4]
    bitcoin_price$kraken_jpy <- kraken_price_split[5]
  })
  
  # Bitstamp prices update
  observeEvent(bitstamp_timer(),{    
    bitstamp_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_bitstamp_price; get_bitstamp_price()'", intern = TRUE)
    bitstamp_price_split <- strsplit(bitstamp_price_raw, ",")[[1]]
    bitcoin_price$bitstamp_usd <- bitstamp_price_split[1]
    bitcoin_price$bitstamp_eur <- bitstamp_price_split[2]
  })
  
  # GDAX prices update
  observeEvent(gdax_timer(),{    
    gdax_price_raw <- system("cd Python/Kraken; python3 -c 'from kraken import get_gdax_price; get_gdax_price()'", intern = TRUE)
    gdax_price_split <- strsplit(gdax_price_raw, ",")[[1]]
    bitcoin_price$gdax_usd <- gdax_price_split[1]
    bitcoin_price$gdax_eur <- gdax_price_split[2]
  })
  
  # Updates Currency choices
  observeEvent(input$exchange, {
    updateSelectInput(session, "currency", choices = exchange_to_currency_df[exchange_to_currency_df$exchange == input$exchange,"currency"])
  })
  
  # Outputs price to UI
  observeEvent(input$go, {
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
      style = "min-height: 240px", 
      width = 4,
      
      selectInput(
        "exchange",
        "Exchange",
        choices = unique(exchange_to_currency_df$exchange),
        selected = "Bitstamp"),
      
      selectInput(
        "currency",
        "Currency",
        choices = c("EUR", "USD")),
      
      actionButton(
        "go", 
        "GO",
        icon("piggy-bank", lib = "glyphicon"),  
        style="color: #fff; background-color:green; border-color: green")
    ),
    
    #### Main Panel ####
    mainPanel(
      fluidRow(
        sidebarPanel( 
        width = 4, 
        style = "min-height: 240px",
      
        textOutput("exchange_text"),
        textOutput("pair_text"),
        textOutput("ask_text"),
        textOutput("bid_text"),
        textOutput("last_text")
        )
      )
    )
  )
)
###### UI END ######

shinyApp(ui = ui, server = server)
#runApp(host = "0.0.0.0", port = 5050)
