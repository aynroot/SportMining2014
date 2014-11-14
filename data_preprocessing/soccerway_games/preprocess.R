#
## preprocessing games data from soccerway to use it inside RandomForest
#
require(dplyr)
require(sqldf)


read_raw_data <- function() {
    raw_data <- read.csv(paste0(getwd(), "/data/soccerway_games_stats.csv"))
    raw_data
}

split_data_by_date <- function(raw_data, date_threshold="2013-05-19") {
    # returns list of two data frames (train and test)
    train <- filter(raw_data, Date <= date_threshold)
    test <- filter(raw_data, Date > date_threshold)
    list(train=train, test=test)
}


save_data <- function() {

}

process_paired_variables <- function(data, name_a, name_b, name) {
    data[[name]] <- data[[name_a]] + data[[name_b]]
    data[[name_a]] <- data[[name_a]] / data[[name]]
    data[[name_b]] <- 1 - data[[name_a]]
    data
}

# TODO: there are mistakes in "gameweek" column in raw data (and at the site)

# get season (year of the beginning) for every game
get_season <- function(data) {
    cur_season <- as.integer(substr(data$Date[1], 1, 4))
    prev_week <- 0
    season <- rep(NA, dim(data)[1])
    for (i in 1:dim(data)[1]) {
        row <- data[i,]
        if (row$GameWeek == 1 && prev_week > 30)
            cur_season <- cur_season + 1
        prev_week <- row$GameWeek
        season[i] <- cur_season
    }
    season
}


# calc_cumulative_stats_per_season <- function(data, var_name, season_var_name) {
#     data_by_season_and_team <- group_by(data, Season, TeamA)
#     data_by_season_and_team <- mutate(data_by_season_and_team, ScoreDiffSeasonA=cumsum(ScoreDiff))
#     data <- ungroup(data_by_season_and_team)
# }


make_cumulative_stats_per_season <- function(data, var_prefix) {
    varA <- paste0(var_prefix, "A")
    varB <- paste0(var_prefix, "B")
    varDiffSeasonA <- paste0(var_prefix, "DiffSeasonA")
    varDiffSeasonB <- paste0(var_prefix, "DiffSeasonB")
    varDiffTeamSeason <- paste0(var_prefix, "DiffTeamSeason")

    data[[varDiffSeasonA]] <- rep(NA, dim(data)[1])
    data[[varDiffSeasonB]] <- rep(NA, dim(data)[1])
    for (season_year in unique(data$Season)) {
        season_data <- filter(data, Season == season_year)
        for (team_name in levels(factor(season_data$TeamA))) {
            cum_value <- 0
            query <- sprintf("select ID, TeamA, TeamB, %s, %s, Date from season_data
                             where TeamA = '%s' or TeamB = '%s' order by Date",
                             varA, varB, team_name, team_name)
            team_df <- sqldf(query)
            team_df[[varDiffTeamSeason]] <- apply(team_df, 1, function(row) {
                if (row[["TeamA"]] == team_name)
                    # access global cum_value
                    cum_value <<- cum_value + as.numeric(row[[varA]]) - as.numeric(row[[varB]])
                else
                    cum_value <<- cum_value + as.numeric(row[[varB]]) - as.numeric(row[[varA]])
                cum_value
            })
            data <- merge(data, team_df, by=c("ID", "TeamA", "TeamB", varA, varB, "Date"), all=T)
            data[[varDiffSeasonA]] <- as.numeric(apply(data, 1, function(row)
                ifelse(row[["TeamA"]] == team_name && !is.na(row[[varDiffTeamSeason]]),
                       row[[varDiffTeamSeason]], row[[varDiffSeasonA]])))
            data[[varDiffSeasonB]] <- as.numeric(apply(data, 1, function(row)
                ifelse(row[["TeamB"]] == team_name && !is.na(row[[varDiffTeamSeason]]),
                       row[[varDiffTeamSeason]], row[[varDiffSeasonB]])))
            data[[varDiffTeamSeason]] <- NULL
        }
    }
    data
}

preprocess <- function(raw_data) {
    data <- raw_data
    # make ID variable for better merging
    data <- arrange(data, Date)
    data <- mutate(data, ID = as.integer(rownames(data)))

    data$Date <- as.Date(raw_data$Date, "%d-%m-%Y")
    data$IsWinnerA <- as.factor((data$ScoreA > data$ScoreB))

    # make percetage data for some paired variables
    data <- process_paired_variables(data, "CornersA", "CornersB", "Corners")
    data <- process_paired_variables(data, "FoulsA", "FoulsB", "Fouls")
    data <- process_paired_variables(data, "OffsidesA", "OffsidesB", "Offsides")

    # convert posession to [0..1]
    data$PosessionA <- data$PosessionA / 100
    data$PosessionB <- data$PosessionB / 100

    # make Season variable
    data$Season <- get_season(data)

    # make cumulative variables (scores, posession, shots on target, shots wide)
    data$ScoreDiff <- data$ScoreA - data$ScoreB
    data$PosessionDiff <- data$PosessionA - data$PosessionB
    data$ShotsOnTargetDiff <- data$ShotsOnTargetA - data$ShotsOnTargetB
    data$ShotsWideDiff <- data$ShotsWideA - data$ShotsWideB

    data <- make_cumulative_stats_per_season(data, "Score")
    data <- make_cumulative_stats_per_season(data, "Posession")
    data <- make_cumulative_stats_per_season(data, "ShotsOnTarget")
    data <- make_cumulative_stats_per_season(data, "ShotsWide")

    # TODO: make GamesPlayedA, GamesPlayedB parameter (?)

    # TODO: make variables for median statistics (diff in halftime, diff in fulltime, corners, offsides)
    data
}

#
## main
#

preprocessed_data <- preprocess(read_raw_data())
data <- split_data_by_date(preprocessed_data)