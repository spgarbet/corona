
library(chron)

hopkins_daily <- function(date, verbose=FALSE)
{
  root <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/"

  if(class(date) == "Date") date <- format(date, "%m-%d-%Y")
  
  if(verbose) cat("Pulling", date, "from John Hopkins github\n")
  

  data <- read.csv(paste0(root, date, ".csv"))
  if(verbose) cat(" ", colnames(data), "\n")
  
  
  x    <- strsplit(substr(date, 2, nchar(date)), "-")[[1]]
  doy  <- julian( as.numeric(x[1]),
                  as.numeric(x[2]),
                  as.numeric(x[3]),
                  c(month=1, day=1, year=2020)) + 1
  
  # John Hopkins does not maintain consistent naming
  if(as.Date(date,"%m-%d-%Y") < as.Date("03-22-2020", "%m-%d-%Y"))
    data <- data[,c("Province.State", "Country.Region", "Confirmed", "Deaths")]
  else
  {
    data <- data[,c("Province_State", "Country_Region", "Confirmed", "Deaths")]
    colnames(data) <- c("Province.State", "Country.Region", "Confirmed", "Deaths")
  }
  
  data$date <- as.Date(date, "%m-%d-%Y")
  data$doy  <- doy

  data
}

hopkins_cases <- function(start="03-05-2020", end=Sys.Date()-1, verbose=FALSE)
{
  if(class(start) != "Date") start <- as.Date(start, "%m-%d-%Y")
  if(class(end  ) != "Date") end   <- as.Date(end,   "%m-%d-%Y")
  dates <- seq(start, end, "days")
  
  data <- do.call(rbind, lapply(dates, function(x) hopkins_daily(x, verbose)))
  
  colnames(data) <- c("Province.State", "Country.Region", "cases", "deaths", "date", "doy")
  
  data
}

tennessee <- function()
{
  data <- hopkins_cases()

  data <- data[data$Country.Region %in% "US" &
               (grepl("TN", data$Province.State) | grepl("Tennessee", data$Province.State)),]
  
  cases  <- aggregate(tn_data$cases,  by=list(tn_data$doy), sum)
  deaths <- aggregate(tn_data$deaths, by=list(tn_data$doy), sum)
  
  data.frame(date=unique(data$date), doy=cases$Group.1, cases=cases$x, deaths=deaths$x)
}


tn_data <- tennessee()
tn_data <- tn_data[tn_data$cases>0 & !is.na(tn_data$cases),]

# Always keep most recent pull in case of upstream changes
save(tn_data, file="tennessee.Rdata")


