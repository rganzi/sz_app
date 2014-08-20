## sz_app server.R

library(gam)
library(ggplot2)
library(gridExtra)

# redsox <- read.table("data/redsox.rds")
# na.values <- is.na(redsox$px)
# redsox <- redsox[!na.values, ]

source("helpers.R")

shinyServer(function(output, input) {
        output$plot <- renderPlot({
                
                args <- list()
                
                args$plot.type <- switch(input$plot.type,
                                        "density" = "dens",
                                        "model" = "mod")
                
                args$name <- switch(input$name, 
                                    "Clay Buchholz" = "Clay Buchholz",
                                    "Jon Lester" = "Jon Lester",
                                    "Yu Darvish" = "Yu Darvish",
                                    "Clayton Kershaw" = "Clayton Kershaw",
                                    "Justin Verlander" = "Justin Verlander",
                                    "Max Scherzer" = "Max Scherzer")
                
                args$zone <- if(input$zone == TRUE) {
                        zone <- 0.8
                } else {
                        zone <- 0
                }
                
                args$x.min <- min(input$x.axis)
                args$x.max <- max(input$x.axis)
                args$y.min <- min(input$y.axis)
                args$y.max <- max(input$y.axis)
                
                do.call(type, args)
        })
}
)