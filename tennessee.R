source("johnhopkins.R")
source("semilog.R")


tennessee_timeseries <- function(category)
{
  source <- if(category == "cases") 
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv" else
  if(category == "deaths")
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"    else
  if(category == "recoveries")
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv" else
  stop("hopkins_raw category must be one of the following: cases, deaths, recoveries")
  
  data <- read.csv(source)
  raw  <- data[data$Country.Region %in% "US" &
                 (grepl("TN", data$Province.State) | grepl("Tennessee", data$Province.State)),]
  
  counts  <- raw[,5:ncol(raw)]
  
  dates <- strsplit(substr(colnames(counts), 2, nchar(colnames(counts))), "[.]")
  doy   <- julian(
    sapply(dates, function(x) as.numeric(x[1])),
    sapply(dates, function(x) as.numeric(x[2])),
    sapply(dates, function(x) as.numeric(x[3]))+2000,
    c(month=1, day=1, year=2020))+1
  dates <- sapply(dates, function(x) paste0(x[1], "/", x[2], "/20", x[3]))
  
  counts <-  colSums(raw[,5:ncol(raw)])
  
  data <- data.frame(
    date   = dates,
    doy    = doy,
    count  = counts
  )
  
  rownames(data) <- NULL
  colnames(data) <- c("date", "doy", category)
  
  data
}

tennessee <- function()
{
  cases      <- tennessee_timeseries("cases")
  deaths     <- tennessee_timeseries("deaths")
  recoveries <- tennessee_timeseries("recoveries")
  
  # This assumes consistency between published datasets
  cases$deaths     <- deaths$deaths
  cases$recoveries <- recoveries$recoveries
  
  cases
}

semilog(
  tennessee(),
  ylim=c(1, 1e6),
  xlim=c(20, 100),
  main="Tennessee COVID-19 Cases",
  sub="Source: John Hopkins Curated Dataset"
)

