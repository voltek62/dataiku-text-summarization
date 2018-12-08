library(dataiku)
library(httr)
library(dplyr)
library(XML)
library(stringr)

# Recipe inputs
csv_crawl_out_prepared <- dkuReadDataset("csv_crawl_out_prepared")
csv_crawl_out_prepared$main_text <- ""

for (i in 1:nrow(csv_crawl_out_prepared)) {

  url <- as.character(csv_crawl_out_prepared[i,]$Address)
  # "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:61.0) Gecko/20100101 Firefox/61.0"
  request <- GET(url)
    
  Sys.sleep(1)
  doc <- htmlParse(request, encoding = "UTF-8")
    
  main_text <- xpathSApply(doc, "//text()[not(ancestor::script)][not(ancestor::style)][not(ancestor::noscript)][not(ancestor::form)][string-length(.) > 100]", xmlValue)
  main_text <- unique(main_text)
  main_text <- paste(main_text, collapse = ".")
    
  # remove useless sentences
  #main_text <- gsub("lorem ipsum.","",main_text)  

  main_text <- str_squish(main_text)
    
  #UTF-8  
  csv_crawl_out_prepared[i,]$main_text <- main_text

}

# Recipe outputs
dkuWriteDataset(csv_crawl_out_prepared,"csv_crawl_out_extracted")
