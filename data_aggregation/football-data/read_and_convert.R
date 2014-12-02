#
## read football-data.co.uk season data and convert names
#

require(sprintf)
require(dplyr)

read_raw_data <- function(season) {
    read.csv(paste0(getwd(), sprintf('/data/football-data.co.uk/%d.csv', season)))
}

convert_colnames <- function(raw_data, season) {
    names_factor_original <- c("HomeTeam", "AwayTeam")
    names_factor_final <- c("TeamA", "TeamB")

    names_numeric_original <- c("FTHG", "FTAG",
                                "HS", "AS",
                                "HST", "AST",
                                "HC", "AC")
    names_numeric_final <- c("ScoreA", "ScoreB",
                             "ShotsWideA", "ShotsWideB",
                             "ShotsOnTargetA", "ShotsOnTargetB",
                             "CornersA", "CornersB")

    data <- raw_data
    apply(data.frame(names_numeric_original, names_numeric_final), 1, function(row) {
        data[[row[2]]] <<- as.numeric(raw_data[[row[1]]])
    })
    apply(data.frame(names_factor_original, names_factor_final), 1, function(row) {
        data[[row[2]]] <<- as.factor(raw_data[[row[1]]])
    })
    data <- data[, sapply(names(data), function(x) {x %in% names_numeric_final || x %in% names_factor_final})]
    data$Season <- season
    data$Date <- as.Date(raw_data$Date, "%d/%m/%y")
    data <- arrange(data, Date)
    data <- mutate(data, ID = as.integer(rownames(data)))
    data$IsWinnerA <- as.factor((data$ScoreA > data$ScoreB))
    data
}