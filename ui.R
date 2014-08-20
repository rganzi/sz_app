## sz_app ui.R

# shinyUI(pageWithSidebar(
#         titlePanel("StrikeZoneVis"),
#         
#         sidebarPanel(
#                 helpText("These are PitchFX data from the 2013 Red Sox World Series-winning season for starting pitchers, Clay Buchholz and Jon Lester."),
#                                
#                 withTags(br()),
#                                
#                radioButtons("plot.type", "Plot Type",
#                             c("Density Plot of the PitchFX Data" = "density",
#                               "GAM Model of P(Called Strike)" = "model")),
#                                
#                 selectInput("name",
#                         label = "Pitcher Name",
#                         choices = c("Clay Buchholz", "Jon Lester"),
#                         selected = "Clay Buchhoz"),
#                     
#                 withTags(br()),
#                 checkboxInput("zone", "Draw Strike Zones", value = TRUE),
#                 
#                 withTags(br()),
#                 sliderInput("x.axis", "X-axis Bounds", value=c(-2.5,2.5), min=-3.5, max=3.5, step=0.5),
#                 sliderInput("y.axis", "Y-axis Bounds", value=c(0,5), min=-1, max=6, step=0.5)
#                             
#         ),
#         
#         mainPanel(plotOutput("plot"))
# ))

## vertical layout

shinyUI(fluidPage(
        
        titlePanel("StrikeZoneVis"),
        
        verticalLayout(
                p(plotOutput("plot")),
                withTags(hr()),
                
                fluidRow(
                        
                        column(4,
                                helpText("Description"),
                                
                                withTags(p("These are PitchFX data from the 2013 MLB seasons for a selection
                                        of starting pitchers.")),
                                
                                withTags(p("Select the pitcher you want to view, then choose whether to
                                        display a density plot of the locations of that pitchers actual
                                        called balls and strikes or a graph of probability boundaries 
                                        for a called strike according to a generalized additive model."))
                                ),

                        column(4,
                               helpText("Select"),
                               
                               selectInput("name", 
                                        label = "Pitcher Name",
                                        choices = c("Clay Buchholz", "Jon Lester", "Yu Darvish", "Clayton Kershaw", "Justin Verlander", "Max Scherzer"),
                                        selected = "Clay Buchhoz"
                                        ),
                                withTags(br()),
                                radioButtons("plot.type", "Plot Type",
                                c("Density Plot" = "density",
                                        "GAM Model" = "model")
                                        )
                                ),
                        
                        column(4,
                                helpText("Options"),
                                checkboxInput("zone", "Draw Strike Zones", value = TRUE),
                                withTags(br()),
                                sliderInput("x.axis", "X-axis Bounds", value=c(-2.5,2.5), min=-3.5, max=3.5, step=0.5),
                                sliderInput("y.axis", "Y-axis Bounds", value=c(0,5), min=-1, max=6, step=0.5)
                                )
                )
        )
))