library(shiny)

ui <- fluidPage(
  tags$head(
    tags$script(
      '
      document.addEventListener("DOMContentLoaded", function() {
        var button = document.getElementById("clickMeButton");
        button.addEventListener("click", function() {
          alert("Button clicked!");
        });
      });
      '
    )
  ),
  actionButton("clickMeButton", "Click Me")
)

server <- function(input, output) {
}

shinyApp(ui, server)
