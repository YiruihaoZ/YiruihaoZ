library(tidyverse)
library(shiny)
library(bslib)

cdc = read_csv("data/Provisional_COVID-19_Deaths_by_Sex_and_Age_subset.csv")

nd = c("COVID.19.Deaths",
       "Pneumonia.Deaths",
       "Influenza.Deaths",
       "Pneumonia.and.COVID.19.Deaths",
       "Pneumonia..Influenza..or.COVID.19.Deaths")

ui = navbarPage(
    theme = bs_theme(bootswatch = "cerulean"),
    title = "CDC 2021",
    tabPanel(
        title = "App",
        titlePanel("Provisional COVID-19 Deaths"),
        sidebarLayout(
            sidebarPanel(
                selectInput(inputId = "state", 
                            label = "State:",
                            choices = unique(cdc$State)),
                selectInput(inputId = "cdr",
                            label = "COVID Deaths Rate:",
                            choices = unique(cdc$COVID.Deaths.Rate)),
                selectInput(inputId = "cds",
                            label = "COVID.19.Deaths:",
                            choices = unique(cdc$COVID.19.Deaths)),
                selectInput(inputId = "td",
                            label = "Total Deaths:",
                            choices = unique(cdc$Total.Deaths)),
                checkboxInput(inputId = "scale",
                              label = "Scale in thousand")
            ),
            mainPanel(plotOutput("plot"))
        )
    ),
    tabPanel(title = "Table", dataTableOutput("table")),
    tabPanel(title = "About", includeMarkdown("about.Rmd"))
)





server = function(input, output) {
    
    cdc_sta = reactive({
        cdc %>% 
            filter(State == input$state) %>% 
            select(-State) 
        

    })
    
    observeEvent(
        eventExpr = input$state,
        handlerExpr = {
            updateSelectInput(inputId = "cdr", choices = unique(cdc_sta()$COVID.Deaths.Rate))
            updateSelectInput(inputId = "cds", choices = unique(cdc_sta()$COVID.19.Deaths))
            updateSelectInput(inputId = "td", choices = unique(cdc_sta()$Total.Deaths))
        })
    
    cdc_sta_cdr = reactive({
        cdc_sta_cdr = cdc_sta() %>% 
            filter(COVID.Deaths.Rate == input$cdr) %>% 
            select(-COVID.Deaths.Rate) 
        
        if(input$scale) {
            cdc_sta_cdr = cdc_sta_cdr %>% 
                mutate(across(COVID.19.Deaths:Pneumonia..Influenza..or.COVID.19.Deaths, scale_in_thousand))
        }
        
        cdc_sta_cdr
        
    })
    
    output$table = renderDataTable(cdc_sta_cdr())
    output$plot = renderPlot({
        ggplot(data = cdc_sta_cdr(), aes(x = COVID.19.Deaths, y = Total.Deaths)) +
            geom_point() +
            geom_smooth() +
            theme_bw()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

