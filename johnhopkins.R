library(chron)

hopkins_timeseries <- function(region, category, excludes=NULL)
{
  source <- if(category == "cases") 
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv" else
  if(category == "deaths")
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"    else
  if(category == "recoveries")
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv" else
  stop("hopkins_raw category must be one of the following: cases, deaths, recoveries")
  
  data <- read.csv(source)
  raw  <- data[data$Country.Region %in% region,]
  if(!is.null(excludes))
  {
    keep <- !Reduce(`|`, lapply(excludes, function(x) grepl(x, as.character(raw$Province.State), ignore.case=TRUE)))
    raw  <- raw[keep,]
  }
  raw  <- raw[,5:ncol(raw)]
  
  dates <- strsplit(substr(colnames(raw), 2, nchar(colnames(raw))), "[.]")
  doy   <- julian(
    sapply(dates, function(x) as.numeric(x[1])),
    sapply(dates, function(x) as.numeric(x[2])),
    sapply(dates, function(x) as.numeric(x[3]))+2000,
    c(month=1, day=1, year=2020))+1
  dates <- sapply(dates, function(x) paste0(x[1], "/", x[2], "/20", x[3]))
  
  data <- data.frame(
    date   = dates,
    doy    = doy,
    count  = colSums(raw)
  )
  
  rownames(data) <- NULL
  colnames(data) <- c("date", "doy", category)
  
  data
}

hopkins <- function(region, excludes=NULL)
{
  cases      <- hopkins_timeseries(region, "cases",  excludes)
  deaths     <- hopkins_timeseries(region, "deaths", excludes)
  recoveries <- hopkins_timeseries(region, "recoveries", excludes)
  
  # This assumes consistency between published datasets
  cases$deaths     <- deaths$deaths
  cases$recoveries <- recoveries$recoveries
  
  cases
}
  



