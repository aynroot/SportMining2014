
source(paste0(getwd(), "/data_preprocessing/soccerway_games/functions_basic_preprocessing.R"))
source(paste0(getwd(), "/feature_engineering/functions_kpp_features.R"))

require(caret)
set.seed(42)

preprocessed_data <- read_raw_data() %>% basic_preprocess() %>% make_diff_stats()

# split data by teams and calculate their (TG)KPP stats
K <- 3
varnames_lst <- list(
    c("ScoreA", "ScoreB", "ScoreKPP", "ScoreDiff", "ScoreDiffKPP"),
    c("CornersA", "CornersB", "CornersKPP", "CornersDiff", "CornersDiffKPP"),
    c("ShotsOnTargetA", "ShotsOnTargetB", "ShotsOnTargetKPP", "ShotsOnTargetDiff", "ShotsOnTargetDiffKPP"),
    c("PosessionA", "PosessionB", "PosessionKPP", "PosessionDiff", "PosessionDiffKPP")
)

data <- preprocessed_data
for (team_name in levels(data$TeamA)) {
    team_data <- filter(data, TeamA == team_name | TeamB == team_name)
    tmp_team_varname <- "tmpTeamStat"
    for (varnames in varnames_lst) {
        team_data[[tmp_team_varname]] <- ifelse(team_data$TeamA == team_name, team_data[[varnames[1]]], team_data[[varnames[2]]])
        team_data <- kpp(team_data, K, tmp_team_varname, varnames[3])
        team_data[[tmp_team_varname]] <- ifelse(team_data$TeamA == team_name, team_data[[varnames[4]]], -team_data[[varnames[4]]])
        team_data <- kpp(team_data, K, tmp_team_varname, varnames[5])
    }
    team_data[[tmp_team_varname]] <- NULL

    # split by home/away team
    data_a <- filter(team_data, TeamA == team_name)
    data_b <- filter(team_data, TeamB == team_name)

    for (varnames in varnames_lst) {
        for (var in c(varnames[3], varnames[5])) {
            var_a <- paste0(var, "A")
            var_b <- paste0(var, "B")
            data <- update_values(data_a, data, var, var_a, "ID")
            data <- update_values(data_b, data, var, var_b, "ID")
        }
    }
}

# now drop rows with NAs
data <- na.omit(data)

# leave only necessary columns
vars <- c("GameWeek", "ScoreDiffKPPA", "ScoreDiffKPPB",
          "CornersDiffKPPA", "CornersDiffKPPB",
          "ShotsOnTargetDiffKPPA", "ShotsOnTargetDiffKPPB",
          "PosessionDiffKPPA", "PosessionDiffKPPB",
          "IsWinnerA", "Date")

data <- data[, vars]


# split by train and test
tt_data <- split_data_by_date(data)
# drop Date
date_index <- length(names(tt_data$train))
tt_data$train <- tt_data$train[, -date_index]
tt_data$test <- tt_data$test[, -date_index]

# train a glm
glm_fit <- glm(IsWinnerA ~ (.)^2, family = "binomial", data = tt_data$train)
tt_data$test$Predictions <- predict(glm_fit, newdata = tt_data$test)
tt_data$test$IsWinnerPredicted <- as.factor(ifelse(tt_data$test$Predictions > 0, "TRUE", "FALSE"))

cm <- confusionMatrix(tt_data$test$IsWinnerPredicted, tt_data$test$IsWinnerA)
cm


