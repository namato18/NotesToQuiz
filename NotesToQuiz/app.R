library(shiny)
library(shinycssloaders)
library(shinythemes)
library(shinybusy)

source("Funcs.R")

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  theme = shinytheme("flatly"),
  add_busy_spinner(spin = "fading-circle"),
  
  
  tags$head(
    tags$script(
      '
      $(document).ready(function() {
        console.log("loaded");
        $(document).on("click", ".answer-toggle", function() {
          console.log("hello");
          $(this).closest(".answer-box").find(".answer").toggle();
        });
      });

      '
    ),
    tags$style(HTML("
      .answer-toggle {
        background: #3b5065;
        color: white;
        font-size: 15px;
        border-radius: 10px;
      }
      
      .question {
      font-size: 20px;
      border-radius: 5px;
      }
      
      .separator {
        width: 100%;
        border-top: 1px solid #ccc; /* Adjust color and thickness as needed */
        margin-top: 20px; /* Adjust margin as needed */
        margin-bottom: 20px; /* Adjust margin as needed */
      }
    "))
  ),
  
  
  sidebarLayout(
    sidebarPanel(
      # actionButton("answer-toggle", "Click Me"),
      
      strong("Instructions:"),
      paste0("Simply drag and drop or choose your pdf file from lecture/notes."),
      br(),
      br(),
      fileInput("pdfInput", label = "Drop Your PDF Here:"),
      sliderInput("numQuestions", label = "How Many Questions Would You Like to Generate?", min = 1, max = 10, value = 5),
      actionButton("submit1", label = "Submit", class = 'btn-primary')
    ),
    
    mainPanel(
      htmlOutput("response"),
      uiOutput("toggleAnswers")
      
    )
  )


)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  options(shiny.maxRequestSize=300*1024^2)
  
  
  observeEvent(input$submit1, {
    pdf_filepath = input$pdfInput$datapath
    numQuestions = input$numQuestions
    output$response = renderUI({
      response = GenerateQuiz(pdf_filepath, numQuestions)
      HTML(response)
      })
  })
  
  
}


# Run the application 
shinyApp(ui = ui, server = server)
