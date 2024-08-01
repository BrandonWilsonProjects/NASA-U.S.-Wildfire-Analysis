library(Synth)
library(ggplot2)
library(dplyr)

# load the data
data <- read.csv('C:/Users/bzwil/OneDrive/Desktop/NASA-U.S.-Wildfire-Analysis/code/NASASCMfiles/scmdata.csv')

# check column names
print(colnames(data))

# convert state names to numeric IDs
data$STATE_NUM <- as.numeric(factor(data$STATE))
state_ids <- data %>%
  distinct(STATE, STATE_NUM) %>%
  filter(STATE %in% c("CALIFORNIA", "TEXAS", "ARIZONA", "COLORADO"))

# data prep
dataprep.out <- dataprep(
  foo = data,
  predictors = c("POVERTY.RATE", "ACRES", "GDP.Per.Capita", "UNEMPLOYMENT.RATE", "WILDFIRES"),
  predictors.op = "mean",
  dependent = "POVERTY.RATE",
  unit.variable = "STATE_NUM",
  time.variable = "YEAR",
  special.predictors = list(
    list("POVERTY.RATE", 2015:2021, "mean")
  ),
  treatment.identifier = state_ids$STATE_NUM[state_ids$STATE == "CALIFORNIA"],
  controls.identifier = state_ids$STATE_NUM[state_ids$STATE %in% c("TEXAS", "ARIZONA", "COLORADO")],
  time.predictors.prior = 2015:2021,
  time.optimize.ssr = 2015:2021,
  unit.names.variable = "STATE",
  time.plot = 2016:2022
)

# run the synthetic control method
synth.out <- synth(dataprep.out)

# extraction
synth.tables <- synth.tab(dataprep.res = dataprep.out, synth.res = synth.out)

# [weighed] observed vs synthetic poverty rate
gdp_path.plot <- path.plot(synth.res = synth.out, dataprep.res = dataprep.out, 
                           tr.intake = 2019, Xlab = "Year", Ylab = " (Weighed) Poverty Rate %", 
                           Main = "[Weighed] Observed vs Synthetic Poverty Rate for California",
                           Legend = c("2019 Wildfire Fund", "Synthetic California"),
                           Legend.position = "bottomright")

# pointwise plot
gaps.plot(synth.res = synth.out, dataprep.res = dataprep.out, 
          Ylab = "Poverty Rate Gap", 
          Main = "Gap between Observed and Synthetic Poverty Rate")

# cumulative plot
gdp_cum.plot <- plot(2010:2023, cumsum(synth.out$Y0plot - synth.out$Y1plot), 
                     type = "l", xlab = "Year", ylab = "Cumulative Gap", 
                     main = "Cumulative Gap between Observed and Synthetic Poverty Rate")

# placebo plots
placebo <- placebo.plot(
  synth.res = synth.out, 
  dataprep.res = dataprep.out,
  Ylab = "Gap", 
  Main = "Placebo Tests for Poverty Rate"
)

# Show all plots
print(gdp_path.plot)
print(gdp_cum.plot)
print(placebo)
