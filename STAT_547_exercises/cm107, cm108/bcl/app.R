#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)
#str(bcl)

#the skeleton required in all Shiny apps: ui, server, run the application (this will give a blank page)
#remember the commas in the UI! everything is an argument; BUT not needed for server side, since you're defining a function

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  titlePanel("BC Liquor price app", 
             windowTitle = "BCL app"
  ),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("priceInput", "Select your desired price range.",
                  min = 0, max = 100, value = c(15, 30), pre="$"),
      radioButtons("typeInput", "Select your alcoholic beverage type.", 
                   choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                   selected = "WINE")
    ),
    mainPanel(
    #ggplot2::qplot(bcl$Price) -> this throws an error! needs to be in HTML format to use here; so instead we will run this on the server
      plotOutput("price_hist"), #nothing will happen here until you define the plot on the server side
      tableOutput("bcl_data")
      
      ) 
  )
  
)

# Define server logic required to draw a histogram
server <- function(input, output) {  #cannot use ggplot directly, use render funtion
  observe(print(input$priceInput))
  bcl_filtered <- reactive({
    bcl %>% 
      filter(Price < input$priceInput[2],
             Price > input$priceInput[1],
             Type == input$typeInput)
  }) 
  
  
  #output$price_hist <- renderPlot(ggplot2::qplot(bcl$Price))  #the $ subsets the list; the assignment operator allows us to overwrite the data 
  output$price_hist <- renderPlot({
    bcl_filtered() %>% 
      ggplot(aes(Price)) +
      geom_histogram()
  })

  output$bcl_data <- renderTable({
     bcl_filtered() #using curly braces allows us to wrangle the data as much as we want and only takes the last line
     })
}

# Run the application 
shinyApp(ui = ui, server = server)


# tags$h1("Level 1 Header"), #using the tags list is one way to access tags, but not the only way, as shown below
# h1(em("Level 1 Header, Part 2")), #can nest tags, as shown here
# HTML("<h1>Level 1 Header, Part 3</h1>"),
# headerPanel("Yes!"),
# a(href="https://google.ca", "Link to Google!"),
# tags$b("This is bold."),
# tags$caption("This is a caption")



# # Application title
# titlePanel("Old Faithful Geyser Data"),
# 
# # Sidebar with a slider input for number of bins 
# sidebarLayout(
#   sidebarPanel(
#     sliderInput("bins",
#                 "Number of bins:",
#                 min = 1,
#                 max = 50,
#                 value = 30)
#   ),
#   
#   # Show a plot of the generated distribution
#   mainPanel(
#     plotOutput("distPlot")
#   )
# )
# output$distPlot <- renderPlot({
#   # generate bins based on input$bins from ui.R
#   x    <- faithful[, 2] 
#   bins <- seq(min(x), max(x), length.out = input$bins + 1)
#   
#   # draw the histogram with the specified number of bins
#   hist(x, breaks = bins, col = 'darkgray', border = 'white')
# })