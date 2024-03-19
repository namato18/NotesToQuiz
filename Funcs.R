# Load required libraries
library(pdftools)
library(stringr)
library(httr)
library(jsonlite)

apiKey <- "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"


# Set the path to your PDF file
# pdf_filepath <- "~/Downloads/lecture.pdf"
# numQuestions <- 5

GenerateQuiz <- function(pdf_filepath, numQuestions){


# Read text from the PDF
pdf_text <- pdf_text(pdf_filepath)

# Combine pages into a single character vector
pdf_text_combined <- paste(pdf_text, collapse = "\n")

# Clean the text (remove extra whitespaces, special characters, etc.)
clean_text <- str_trim(pdf_text_combined) # Remove leading and trailing whitespaces
clean_text <- str_squish(clean_text) # Remove extra whitespaces
clean_text <- str_replace_all(clean_text, "[^[:graph:]]", " ") # Remove non-printable characters
clean_text <- str_replace_all(clean_text, "\\s+", " ") # Remove extra whitespaces

# Print the cleaned text
# cat(clean_text)

prompt <- paste0("Give me ",numQuestions," quiz questions (multiple choice) for the following lecture information. Also please include the answers: ", clean_text)

response <- POST(
  url = "https://api.openai.com/v1/chat/completions",
  add_headers(Authorization = paste("Bearer", apiKey)),
  content_type_json(),
  encode = "json",
  body = list(
    model = "gpt-3.5-turbo",
    temperature = 1,
    messages = list(list(
      role = "user",
      content = prompt
    ))
  )
)
# Extract response from API
x <- fromJSON(rawToChar(response$content))
x2 <- x$choices
text.response <- x2$message$content[1]

# Debugging code
# print(text.response)

# Split text into questions
questions <- strsplit(text.response, "\\d+\\.")

# Debugging code
print(length(questions))
print(head(questions))

# Generate formatted HTML with boxes and buttons
formatted_text <- ""
for(i in 1:length(questions[[1]])) {
  if (questions[[1]][i] != "") {
    # Split the question and choices
    question_and_choices <- strsplit(questions[[1]][i], "\n\nAnswer:")[[1]][1]
    question_and_choices <- paste0(question_and_choices,"\n")


    # Extract question and choices
    question <- paste0(i-1,": ",trimws(str_match(string = question_and_choices, pattern = "(.*?)\\nA"))[2])
    optionA <- paste0("A",trimws(str_match(string = paste0(question_and_choices), pattern = "\\nA(.*?)\\n")[2]))
    optionB <- paste0("B",trimws(str_match(string = paste0(question_and_choices), pattern = "\\nB(.*?)\\n")[2]))
    optionC <- paste0("C",trimws(str_match(string = paste0(question_and_choices), pattern = "\\nC(.*?)\\n")[2]))
    optionD <- paste0("D",trimws(str_match(string = paste0(question_and_choices), pattern = "\\nD(.*?)\\n")[2]))

    # Extract answer from choices
    answer <- str_match(string = questions[[1]][i], "Answer(.*)")[1]
    choices <- paste(optionA, optionB, optionC, optionD, sep = "\n")

    # Create HTML content for the question and choices
    question_html <- paste0("<div class='question'>", question, "</div>")
    choices_html = paste0("<div class='options' style='padding-left: 20px;'>",choices,"</div>")
    answer_html <- paste0("<div class='answer-box'>",
                          "<div class='answer' style='display:none'>", answer, "</div>",
                          "<button class='answer-toggle'>Toggle Answer</button>",
                          "<br>",
                          "<br>",
                          "<div class=separator></div>",
                          "</div>")
    # "<div class='question'>Question 1</div>
    # <div class='options'>A, B, C, D</div>
    # <div class='answer-box'>
    # <div class='answer' style='display:none'>Answer 1</div>
    # <button class='answer-toggle'>Toggle Answer</button>
    # </div>"

    # Combine question and choices HTML
    formatted_text <- paste0(formatted_text, question_html, choices_html,answer_html)
  }
}

formatted_text <- gsub("\n", "<br>", formatted_text)

# Print the formatted HTML for debugging
print(formatted_text)



# Return formatted HTML with JavaScript
return(formatted_text)
}

# GenerateQuiz <- function(pdf_filepath, numQuestions) {
#   # Your GenerateQuiz() function code here
#   return("<div class='question'>Question 1</div><div class='options'>A, B, C, D</div><div class='answer-box'><div class='answer' style='display:none'>Answer 1</div><button class='answer-toggle'>Toggle Answer</button></div>")
# }
