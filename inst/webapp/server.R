shinyServer(function(input, output, session) {
  params <- reactive(ParseParams(session))
  mode <- reactive(GetMode(params()))

  output$sidebar <- renderMenu({
    source(file.path(mode()$mode, "sidebar.R"), local=TRUE)$value
  })
  output$body <- renderUI({
    source(file.path(mode()$mode, "body.R"), local=TRUE)$value
  })
  observe(source(file.path(mode()$mode, "main.R"), local=TRUE))
})
