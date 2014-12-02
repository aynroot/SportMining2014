
source(paste0(getwd(), "/data_preprocessing/soccerway_games/functions_basic_preprocessing.R"))
source(paste0(getwd(), "/data_aggregation/football-data/read_and_convert.R"))
source(paste0(getwd(), "/feature_engineering/functions_kpp_features.R"))

require(caret)
set.seed(42)

preprocessed_data <- data.frame()
for (season in 2000:2014) {
    season_data <- read_raw_data(season) %>% convert_colnames(season) %>% make_diff_stats()
    print(dim(season_data))
    preprocessed_data <- rbind(preprocessed_data, season_data)
}

# fix ID's
preprocessed_data <- arrange(preprocessed_data, Date)
preprocessed_data <- mutate(preprocesseddata, ID = as.integer(rownames(preprocessed_data)))

# split data by teams and calculate their (TG)KPP stats
K <- 4
varnames_lst <- list(
    c("ScoreA", "ScoreB", "ScoreDiff", "ScoreKPP", "ScoreDiffKPP",
      "ScoreTGKPP", "ScoreDiffTGKPP"),
    c("CornersA", "CornersB", "CornersDiff", "CornersKPP", "CornersDiffKPP",
      "CornersTGKPP", "CornersDiffTGKPP"),
    c("ShotsOnTargetA", "ShotsOnTargetB", "ShotsOnTargetDiff", "ShotsOnTargetKPP", "ShotsOnTargetDiffKPP",
      "ShotsOnTargetTGKPP", "ShotsOnTargetDiffTGKPP"),
    c("ShotsWideA", "ShotsWideB", "ShotsWideDiff", "ShotsWideKPP", "ShotsWideDiffKPP",
      "ShotsWideTGKPP", "ShotsWideDiffTGKPP")
)

data <- preprocessed_data
for (team_name in levels(data$TeamA)) {
    team_data <- filter(data, TeamA == team_name | TeamB == team_name)
    tmp_team_varname <- "tmpTeamStat"
    for (varnames in varnames_lst) {
        team_data[[tmp_team_varname]] <- ifelse(team_data$TeamA == team_name,
                                                team_data[[varnames[1]]],
                                                team_data[[varnames[2]]])
        team_data <- kpp(team_data, K, tmp_team_varname, varnames[4])
        team_data <- tgkpp(team_data, K, tmp_team_varname, varnames[6])

        team_data[[tmp_team_varname]] <- ifelse(team_data$TeamA == team_name,
                                                team_data[[varnames[3]]],
                                                -team_data[[varnames[3]]])
        team_data <- kpp(team_data, K, tmp_team_varname, varnames[5])
        team_data <- tgkpp(team_data, K, tmp_team_varname, varnames[7])
    }
    team_data[[tmp_team_varname]] <- NULL

    # split by home/away team
    data_a <- filter(team_data, TeamA == team_name)
    data_b <- filter(team_data, TeamB == team_name)

    for (varnames in varnames_lst) {
        for (var in varnames[4:7]) {
            var_a <- paste0(var, "A")
            var_b <- paste0(var, "B")
            data <- update_values(data_a, data, var, var_a, "ID")
            data <- update_values(data_b, data, var, var_b, "ID")
        }
    }
    gc()
    print(sprintf("Done with %s", team_name))
}

# now drop rows with NAs
data <- na.omit(data)

# leave only necessary columns
vars <- c("IsWinnerA", "Date")
for (varnames in varnames_lst) {
    vars <- c(vars, sapply(varnames[4:7], function(x) paste0(x, "A")))
    vars <- c(vars, sapply(varnames[4:7], function(x) paste0(x, "B")))
}
data <- data[, names(data) %in% vars]

# split by train and test
tt_data <- split_data_by_date(data)

# drop Date column
date_index <- length(names(tt_data$train))
tt_data$train <- tt_data$train[, -date_index]
tt_data$test <- tt_data$test[, -date_index]

gbm_final <- gbm(as.numeric(IsWinnerA) - 1 ~ ., data=tt_data$train, n.trees=500, interaction.depth=6, shrinkage=0.01)
predictions <- predict(gbm_final, newdata = tt_data$test, n.trees=500)
is_winner_predicted <- as.factor(ifelse(predictions > 0, "TRUE", "FALSE"))
accuracy <- sum(is_winner_predicted == tt_data$test$IsWinnerA) / length(tt_data$test$IsWinnerA)
auc <- AUC::auc(AUC::roc(predictions, as.numeric(tt_data$test$IsWinnerA) - 1))


#
## accuracy ~ 84.2 %
## auc: ~ 0,92
#





