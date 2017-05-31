library("shiny")
library("shinythemes")
library("shinydashboard")
library("shinyjs")
library("RColorBrewer")
library("shinyBS")
library("plotly")
library("ggplot2")
library("ggthemes")
library("reshape2")
library("R.utils")
library("openxlsx")
library("readxl")
library("stringr")
library("readr")
library("magick")
library("DT")
library("gplots")
library("RODBC")
library("mixtools")
library("mem")
library("shinysky")
library("formattable")
shinyUI(dashboardPage(skin = "black",
                      ###################################
                      ### HEADER SECTION              ###
                      ###################################
                      # Tricky way of placing elements in dashboardHeader, expects a tag element of type li and class dropdown, 
                      # so we can pass such elements instead of dropdownMenus
                      dashboardHeader(title = "MEM dashboard",
                                      tags$li("31MAY2017, code under GPLv2 at",
                                              class = "dropdown"),
                                      tags$li(a(href = 'https://github.com/lozalojo/memapp',
                                                img(src = 'GitHub_Logo.png',
                                                    title = "José E. Lozano", height = "30px"),
                                                style = "padding-top:10px; padding-bottom:0px;"),
                                              class = "dropdown"),
                                      tags$li(a(href = 'http://www.icscyl.com',
                                                img(src = 'logoiecscyl.gif',
                                                    title = "IECSCyL", height = "40px"),
                                                style = "padding-top:5px; padding-bottom:0px;"),
                                              class = "dropdown"),
                                      tags$li(a(onclick = "setTimeout(function(){window.close();}, 100); ",
                                                icon("power-off", "fa-2x"),
                                                title = "Power off"),
                                              class = "dropdown")),
                      ###################################
                      ### LEFT PANEL SECTION          ###
                      ###################################
                      dashboardSidebar(width='250px', 
                                       ################################
                                       ###    Load data          ######
                                       ################################
                                       fileInput('file', label=h4("Load file", tags$style(type = "text/css", "#q1 {vertical-align: top;}"), bsButton("file_b", label = "", icon = icon("question"), style = "info", size = "extra-small")), accept = c("csv","dat","prn","txt","xls","xlsx","mdb","accdb", "rdata")),
                                       bsPopover(id = "file_b", title = "Load file",      content = "memapp is able to read text, excel, access and R.", placement = "right", trigger = "hover", options = list(container = "body")),
                                        box(title="Dataset", status = "warning", solidHeader = FALSE, width = 12, background = "navy", collapsible = TRUE, collapsed=TRUE,
                                           selectInput('dataset', h5(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Dataset"), size=1, selectize = FALSE, choices = "", selected = NULL),
                                           bsPopover(id = "dataset", title = "Select dataset", content = "If the format is able to store different datasets, select the one you want to open.", placement = "right", trigger = "hover", options = list(container = "body")),
                                           selectInput("firstWeek", h5(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "First Week"), size=1, selectize = FALSE, choices = "", selected = NULL),
                                           bsPopover(id = "firstWeek", title = "First week", content = "First week of the datasets` surveillance period.",                                    placement = "right", trigger = "hover", options = list(container = "body")),
                                           selectInput("lastWeek", h5(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Last Week" ), size=1, selectize = FALSE, choices = "", selected = NULL),
                                           bsPopover(id = "lastWeek", title = "Last week", content = "Last week of the datasets surveillance period.",                                     placement = "right", trigger = "hover", options = list(container = "body")),
                                           selectInput("transformation", h5(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Transform"), size=1, selectize = FALSE, choices = list("No transformation"=1, "Odd"=2, "Fill missings"=3, "Loess"=4, "Two waves (observed)"=5, "Two waves (expected)"=6), selected = 1),
                                           bsPopover(id = "transformation", title = "Transform data", content = "Select the transformation to apply to the original data.",                            placement = "right", trigger = "hover", options = list(container = "body"))
                                       ),
                                       ################################
                                       ###    Model                ####
                                       ################################
                                       box(title="Model", status = "primary", solidHeader = TRUE, width = 12,  background = "black", collapsible = TRUE, collapsed=TRUE,
                                           selectInput("SelectFrom", h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "From"), size=1, selectize = FALSE, choices = ""),
                                           bsPopover(id = "SelectFrom", title = "Select seasons for the model", content = "First column to include in the model selection.", placement = "right", trigger = "hover", options = list(container = "body")),
                                           selectInput("SelectTo", h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "To"), size=1, selectize = FALSE, choices = ""),
                                           bsPopover(id = "SelectTo", title = "Select seasons for the model", content = "Last column to include in the model selection.", placement = "right", trigger = "hover", options = list(container = "body")),
                                           selectInput('SelectExclude', h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Exclude"), multiple = TRUE, choices = NULL),
                                           bsPopover(id = "SelectExclude", title = "Select seasons for the model", content = "Select any number of seasons to be excluded from the model.", placement = "right", trigger = "hover", options = list(container = "body")),
                                           numericInput("SelectMaximum", h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Max. seasons:"), 10, step=1),
                                           bsPopover(id = "SelectMaximum", title = "Select seasons for the model", content = "Maximum number of seasons to be used in the model.<br>Note that this will probably override the rest options, since it will restrict data to the last number of seasons from the selection already made with From/To/Exclude.<br>For influenza it is not recommended to use more than 10 seasons to avoid cyclical trends.", placement = "right", trigger = "hover", options = list(container = "body"))
                                       ),
                                       
                                       ################################
                                       ###    Surveillance         ####
                                       ################################
                                       
                                       box(title="Surveillance", status = "primary", solidHeader = TRUE, width = 12, background = "black", collapsible = TRUE, collapsed=TRUE,
                                           selectInput("SelectSurveillance", h5(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Surveillance"), size=1, selectize = FALSE, choices = ""),
                                           bsPopover(id = "SelectSurveillance", title = "Current season", content = "Season you want to use for surveillance applying the MEM thresholds.<br>This season can be incomplete.<br> It is recommended not to use the surveillance season in the model selection.", placement = "right", trigger = "hover", options = list(container = "body")),
                                           selectInput("SelectSurveillanceWeek", h5(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Surveillance Week"), size=1, selectize = FALSE, choices = ""),
                                           bsPopover(id = "SelectSurveillanceWeek", title = "Surveillance week", content = "Week you want to create the surveillance graph for. It can be any week from the first week of the surveillance season to the last one that have data", placement = "right", trigger = "hover", options = list(container = "body")),
                                           selectInput("SelectSurveillanceForceEpidemic", h5(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Force epidemic start"), size=1, selectize = FALSE, choices = NULL, select = NULL),
                                           bsPopover(id = "SelectSurveillanceForceEpidemic", title = "Epidemic start", content = "Chose a week to force the start of the epidemic period.<br>The epidemic will start at the week selected and not at the first week over the epidemic threshold.", placement = "right", trigger = "hover", options = list(container = "body"))
                                       ),
                                       
                                       ################################
                                       ###    Visualize            ####
                                       ################################
                                       
                                       box(title="Visualize", status = "primary", solidHeader = TRUE, width = 12,  background = "black", collapsible = TRUE, collapsed=TRUE,
                                           selectInput('SelectSeasons', h5(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Seasons to graph"), choices = NULL, multiple = TRUE),
                                           bsPopover(id = "SelectSeasons", title = "Multiple seasons", content = "Select any number of seasons to display series, seasons and timing graphs and to apply thresholds from the current model.<br>To delete a season click on it and press delete on your keyboard.", placement = "right", trigger = "hover", options = list(container = "body"))
                                       ),
                                       
                                       ################################
                                       ###  Thresholds             ####
                                       ################################
                                       
                                       box(title="Thresholds", status = "primary", solidHeader = TRUE, width = 12,  background = "black", collapsible = TRUE, collapsed=TRUE,
                                           checkboxInput("preepidemicthr", label = h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Pre-epidemic threshold"), value = TRUE),
                                           bsPopover(id = "preepidemicthr", title = "Pre-epidemic threshold", content = "Check this tickbox if you want to include epidemic thresholds in the graphs.<br>This is a global option that will work on most graphs.", placement = "right", trigger = "hover", options = list(container = "body")),
                                           checkboxInput("postepidemicthr", label = h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Post-epidemic threshold"), value = FALSE),
                                           bsPopover(id = "postepidemicthr", title = "Post-epidemic threshold", content = "Check this tickbox if you want to include post-epidemic thresholds in the graphs.<br>This  is a global option that will work on most graphs.", placement = "right", trigger = "hover", options = list(container = "body")),
                                           checkboxInput("intensitythr", label = h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Intensity thresholds/levels"), value = TRUE),
                                           bsPopover(id = "intensitythr", title = "Intensity thresholds", content = "Check this tickbox if you want to include intensity thresholds in the graphs.<br>This  is a global option that will work on most graphs.", placement = "right", trigger = "hover", options = list(container = "body"))
                                       )
                                       
                      ),
                      
                      ###################################
                      ### BODY/MAIN SECTION           ###
                      ###################################
                      
                      dashboardBody(
                        tags$body(inlineCSS(list(".shinysky-busy-indicator" = "position: absolute !important; z-index:800; "))),
                        tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                        fluidPage(
                          # Application title
                          titlePanel(h1("The Moving Epidemics Method Shiny Web Application")),
                          fluidRow(
                            ###################################
                            ### BODY/MAIN SECTION           ###
                            ###   FIRST COLUMN DEFINITION   ###
                            ###################################
                            column(9,
                                   #######################################
                                   ### BODY/MAIN SECTION               ###
                                   ###   FIRST COLUMN DEFINITION       ###
                                   ###      FIRST PART: OUTPUTS        ###
                                   #######################################
                                   tabBox(
                                     title = "MEM", width = 12, height = "800px",
                                     tabPanel("Check & describe", busyIndicator(text = "Calculation in progress. This may take a while...", wait = 500), "Check data series, timing and describe the data", uiOutput("tbData")),
                                     tabPanel("Model", busyIndicator(text = "Calculation in progress. This may take a while...", wait = 500), "Summary, graphs, goodness and optimization of the MEM model", uiOutput("tbModel")),
                                     tabPanel("Surveillance", busyIndicator(text = "Calculation in progress. This may take a while...", wait = 500), "Surveillance tools", uiOutput("tbSurveillance")),
                                     tabPanel("Visualize", busyIndicator(text = "Calculation in progress. This may take a while...", wait = 500), "Visualize different sets of data with a MEM model", uiOutput("tbVisualize"))
                                   )
                            ),
                            ###################################
                            ### BODY/MAIN SECTION           ###
                            ###   SECOND COLUMN DEFINITION  ###
                            ###################################
                            column(3,
                                   box(
                                     title="Text options", status = "primary", solidHeader = TRUE, width = 12,  background = "black", collapsible = TRUE, collapsed=TRUE,
                                     textInput("textMain", label = h6("Main title", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), value = "Main title"),
                                     bsPopover(id = "textMain", title = "Main title", content = "Change the main title in most graphs.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     textInput("textY", label = h6("Y-axis", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), value = "Y-axis"),
                                     bsPopover(id = "textY", title = "Y-axis label", content = "Change the y-axis label in most graphs.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     textInput("textX", label = h6("X-axis", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), value = "X-axis"),
                                     bsPopover(id = "textX", title = "X-axis label", content = "Change the x-axis label in most graphs.", placement = "left", trigger = "hover", options = list(container = "body"))
                                   ),
                                   box(
                                     title="Graph options", status = "primary", solidHeader = TRUE, width = 12,  background = "black", collapsible = TRUE, collapsed=TRUE,
                                     selectInput("colObservedLines", h6("Observed (line)", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = c("default",colors()), size=1, selectize = FALSE, selected = "default"),
                                     bsPopover(id = "colObservedLines", title = "Observed (line)", content = "Color of the line of observed data.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     selectInput("colObservedPoints", h6("Observed (points)", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = c("default",colors()), size=1, selectize = FALSE, selected = "default"),
                                     bsPopover(id = "colObservedPoints", title = "Observed (points)", content = "Color of the points of observed data.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     selectInput("colEpidemicStart", h6("Epidemic start", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = c("default",colors()), size=1, selectize = FALSE, selected = "default"),
                                     bsPopover(id = "colEpidemicStart", title = "Epidemic start", content = "Color of the point of the epidemic start marker.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     selectInput("colEpidemicStop", h6("Epidemic end", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = c("default",colors()), size=1, selectize = FALSE, selected = "default"),
                                     bsPopover(id = "colEpidemicStop", title = "Epidemic end", content = "Color of the point of the epidemic end marker.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     selectInput("colThresholds", h6("Thresholds palette", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = c("default",rownames(brewer.pal.info)), size=1, selectize = FALSE, selected = "default"),
                                     bsPopover(id = "colThresholds", title = "Thresholds palette", content = "Palette used to generate color for epidemic and intensity thresholds.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     selectInput("colSeasons", h6("Seasons palette", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = c("default",rownames(brewer.pal.info)), size=1, selectize = FALSE, selected = "default"),
                                     bsPopover(id = "colSeasons", title = "Seasons palette", content = "Palette used to generate the colors of the lines of the series graphs and other graphs with multiple lines.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     selectInput("colEpidemic", h6("Timing palette", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = c("default",rownames(brewer.pal.info)), size=1, selectize = FALSE, selected = "default"),
                                     bsPopover(id = "colEpidemic", title = "Timing palette", content = "Palette used to generate the colors of the points of pre, epidemic and post markers in timing graphs.", placement = "left", trigger = "hover", options = list(container = "body"))
                                   ),
                                   box(
                                     title="MEM options", status = "danger", solidHeader = FALSE, width = 12,  background = "navy", collapsible = TRUE, collapsed=TRUE,
                                     h4(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Timing"),
                                     selectInput("method", h6("Method for timing", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = list("Original method"=1, "Fixed criterium method"=2, "Slope method"=3, "Second derivative method"=4), size=1, selectize = FALSE, selected = 2),
                                     bsPopover(id = "method", title = "Method for epidemic timing", content = "Original: uses the process shown in the original paper.<br>Fixed criterium: uses the slope of the MAP curve fo find the optimum, which is the point where the slope is lower than a predefined value.<br>Slope: calculates the slope of the MAP curve, but the optimum is the one that matches the global mean slope.<br>Second derivative: calculates the second derivative and equals to zero to search an inflexion point in the original curve.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     conditionalPanel(condition = "input.method == 2", 
                                                      numericInput("param", h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Slope parameter"), 2.8, step=0.1),
                                                      bsPopover(id = "param", title = "Window parameter", content = "Window parameter used in fixed criterium method.", placement = "left", trigger = "hover", options = list(container = "body"))),
                                     h4(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Thresholds"),
                                     fluidRow(
                                       column(6,
                                              selectInput("nvalues", h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Values per season"), choices = list("30 in total"=-1,"All"=0,"1/season"=1,"2/season"=2,"3/season"=3,"4/season"=4,"5/season"=5,"6/season"=6,"7/season"=7,"8/season"=8,"9/season"=9,"10/season"=10), size=1, selectize = FALSE, selected = -1),
                                              bsPopover(id = "nvalues", title = "Number of values per seasons", content = "Number of values taken each season for calculate thresholds. If -1, a total of 30 points are used (30/numberofseasons). If 0, all available points are used.", placement = "left", trigger = "hover", options = list(container = "body"))
                                       ),
                                       column(6,
                                              numericInput("ntails", h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Tails"), 1, step=1, min = 1, max = 2),
                                              bsPopover(id = "ntails", title = "Confidence intervals tails", content = "Choose if you want to use one-tailed or two-tailed confidence intervals for thresholds.", placement = "left", trigger = "hover", options = list(container = "body"))
                                       )
                                     ),
                                     selectInput("typethreshold", h6("Epidemic thr.", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = list("Arithmetic mean and mean confidence interval"=1, "Geometric mean and mean confidence interval"=2, "Median and the KC Method to calculate its confidence interval"=3, "Median and bootstrap confidence interval"=4, "Arithmetic mean and point confidence interval"=5, "Geometric mean and point confidence interval"=6), size=1, selectize = FALSE, selected = 5),
                                     bsPopover(id = "typethreshold", title = "Epidemic threshold", content = "Method for calculating the epidemic threshold.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     selectInput("typeintensity", h6("Intensity thr.", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = list("Arithmetic mean and mean confidence interval"=1, "Geometric mean and mean confidence interval"=2, "Median and the KC Method to calculate its confidence interval"=3, "Median and bootstrap confidence interval"=4, "Arithmetic mean and point confidence interval"=5, "Geometric mean and point confidence interval"=6), size=1, selectize = FALSE, selected = 6),
                                     bsPopover(id = "typeintensity", title = "Intensity thresholds", content = "Method for calculating the intensity threshold.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     fluidRow(
                                       column(4,
                                              numericInput("levelintensitym", h6("Medium lvl", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), 40, step=0.5, min = 0.5, max = 99.5),
                                              bsPopover(id = "levelintensitym", title = "Medium intensity threshold", content = "Level of the confidence interval used to calculate the medium threshold.", placement = "left", trigger = "hover", options = list(container = "body"))
                                       ),
                                       column(4,
                                              numericInput("levelintensityh", h6("High lvl", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), 90, step=0.5, min = 0.5, max = 99.5),
                                              bsPopover(id = "levelintensityh", title = "High intensity threshold", content = "Level of the confidence interval used to calculate the high threshold.", placement = "left", trigger = "hover", options = list(container = "body"))
                                       ),
                                       column(4,
                                              numericInput("levelintensityv", h6("Very high lvl", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), 97.5, step=0.5, min = 0.5, max = 99.5),
                                              bsPopover(id = "levelintensityv", title = "Very high intensity threshold", content = "Level of the confidence interval used to calculate the very high threshold.", placement = "left", trigger = "hover", options = list(container = "body"))
                                       )
                                     ),
                                     h4(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Goodness & optimize"),
                                     selectInput("validation", h6("Validation", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = list("Cross"="cross", "Sequential"="sequential"), size=1, selectize = FALSE, selected = "cross"),
                                     bsPopover(id = "validation", title = "Method for validation", content = "Cross: Extracts one season and the model is calculated with the remaining seasons.<br>Sequential: Extract a season and the model is calculated with previous seasons only.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     sliderInput("paramrange", label = h6(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Parameter range"), min = 0.1, max = 10, value = c(2, 4), step=0.1),
                                     bsPopover(id = "paramrange", title = "Window parameter range", content = "Range of possible of values of the window parameter used by goodness and optimize functions.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     h4(tags$style(type = "text/css", "#q1 {vertical-align: top;}"), "Other"),
                                     selectInput("typecurve", h6("Average curve thr.", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = list("Arithmetic mean and mean confidence interval"=1, "Geometric mean and mean confidence interval"=2, "Median and the KC Method to calculate its confidence interval"=3, "Median and bootstrap confidence interval"=4, "Arithmetic mean and point confidence interval"=5, "Geometric mean and point confidence interval"=6), size=1, selectize = FALSE, selected = 2),
                                     bsPopover(id = "typecurve", title = "Average curve intervals", content = "Method for calculating the average/typical curve confidence intervals.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     selectInput("typeother", h6("Other thr.", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), choices = list("Arithmetic mean and mean confidence interval"=1, "Geometric mean and mean confidence interval"=2, "Median and the KC Method to calculate its confidence interval"=3, "Median and bootstrap confidence interval"=4, "Arithmetic mean and point confidence interval"=5, "Geometric mean and point confidence interval"=6), size=1, selectize = FALSE, selected = 3),
                                     bsPopover(id = "typeother", title = "Otrher confidence intervals", content = "Method for calculating other confidence intervals: duration, epidemic percentage, epidemic start, etc.", placement = "left", trigger = "hover", options = list(container = "body")),
                                     numericInput("leveltypicalcurve", h6("Average curve level", tags$style(type = "text/css", "#q1 {vertical-align: top;}")), 95.0, step=0.5, min = 0.5, max = 99.5),
                                     bsPopover(id = "leveltypicalcurve", title = "Average curve intervals", content = "Level of the confidence interval used to calculate the average curve and other intervals.", placement = "left", trigger = "hover", options = list(container = "body"))
                                   )                                   
                            )
                          )
                        )
                      )
)
)
