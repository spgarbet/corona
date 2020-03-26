library(chron)

hopkins_timeseries <- function(region, category, excludes=NULL)
{
  source <- if(category == "cases") 
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv" else
  if(category == "deaths")
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"    else
  if(category == "recoveries")
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv" else
  stop("hopkins_raw category must be one of the following: cases, deaths, recoveries")
  
  data <- read.csv(source)
  raw  <- data[data$Country.Region %in% region,]
  if(!is.null(excludes))
  {
    keep <- !Reduce(`|`, lapply(excludes, function(x) grepl(x, as.character(raw$Province.State), ignore.case=TRUE)))
    raw  <- raw[keep,]
  }
  counts  <- raw[,5:ncol(raw)]
  
  dates <- strsplit(substr(colnames(counts), 2, nchar(colnames(counts))), "[.]")
  doy   <- julian(
    sapply(dates, function(x) as.numeric(x[1])),
    sapply(dates, function(x) as.numeric(x[2])),
    sapply(dates, function(x) as.numeric(x[3]))+2000,
    c(month=1, day=1, year=2020))+1
  dates <- sapply(dates, function(x) paste0(x[1], "/", x[2], "/20", x[3]))
  
  # Goddamn it John Hopkins, why the mixed data now? 
  # If they recorded it consistently then this wouldn't be so difficult
  # And now they changed it back to just simple sum
  counts <-  colSums(raw[,5:ncol(raw)], na.rm=TRUE)
  
  # <- if(region == "US")
  # {
  #   county.level <- !Reduce(`|`, lapply(
  #     c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID",
  #       "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO",
  #       "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA",
  #       "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
  #     , function(x) grepl(x, as.character(raw$Province.State))))
  #   
  #   raw1 <- raw[county.level,5:ncol(raw)]
  #   raw2 <- raw[!county.level,5:ncol(raw)]
  #   pmax(colSums(raw1), colSums(raw2), na.rm=TRUE)
  # } else
  # {
  #   colSums(raw[,5:ncol(raw)])
  # }
  
  data <- data.frame(
    date   = dates,
    doy    = doy,
    count  = counts
  )
  
  rownames(data) <- NULL
  colnames(data) <- c("date", "doy", category)
  
  data
}

hopkins <- function(region, excludes=NULL)
{
  cases      <- hopkins_timeseries(region, "cases",      excludes)
  deaths     <- hopkins_timeseries(region, "deaths",     excludes)
  #recoveries <- hopkins_timeseries(region, "recoveries", excludes)
  
  # This assumes consistency between published datasets
  cases$deaths     <- deaths$deaths
  #cases$recoveries <- recoveries$recoveries
  
  cases
}
  



