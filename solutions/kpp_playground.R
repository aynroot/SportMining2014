
source(paste0(getwd(), "/data_preprocessing/soccerway_games/functions_basic_preprocessing.R"))
source(paste0(getwd(), "/feature_engineering/functions_kpp_features.R"))
source(paste0(getwd(), "/solutions/functions_selecting_model.R"))

require(caret)
set.seed(42)

preprocessed_data <- read_raw_data() %>% basic_preprocess() %>% make_diff_stats()

# split data by teams and calculate their (TG)KPP stats
K <- 4
varnames_lst <- list(
    c("ScoreA", "ScoreB", "ScoreDiff", "ScoreKPP", "ScoreDiffKPP",
      "ScoreTGKPP", "ScoreDiffTGKPP"),
    c("CornersA", "CornersB", "CornersDiff", "CornersKPP", "CornersDiffKPP",
      "CornersTGKPP", "CornersDiffTGKPP"),
    c("ShotsOnTargetA", "ShotsOnTargetB", "ShotsOnTargetDiff", "ShotsOnTargetKPP", "ShotsOnTargetDiffKPP",
      "ShotsOnTargetTGKPP", "ShotsOnTargetDiffTGKPP"),
    c("PosessionA", "PosessionB", "PosessionDiff", "PosessionKPP", "PosessionDiffKPP",
      "PosessionTGKPP", "PosessionDiffTGKPP")
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
}

# now drop rows with NAs
data <- na.omit(data)

# leave only necessary columns
vars <- c("IsWinnerA", "GameWeek", "Date")
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

# train models on different features and select the best one
varnames_sets <- list(
    vars[sapply(vars, function(x) grepl("*[^fG]KPP", x))],
    vars[sapply(vars, function(x) grepl("*[^f]TGKPP", x))],
    vars[sapply(vars, function(x) grepl("*[^f]KPP", x))],

    vars[sapply(vars, function(x) grepl("*DiffKPP", x))],
    vars[sapply(vars, function(x) grepl("*DiffTGKPP", x))],
    vars[sapply(vars, function(x) grepl("*Diff.*KPP", x))],

    vars[sapply(vars, function(x) grepl("*KPP", x))]
)

predictions <- vector("list", length(varnames_sets))
is_winner_predicted <- vector("list", length(varnames_sets))
glms <- vector("list", length(varnames_sets))
for (i in 1:length(varnames_sets)) {
    varnames <- unlist(c("IsWinnerA", "GameWeek", varnames_sets[i]))
    train_set <- tt_data$train[, names(tt_data$train) %in% varnames]
    test_set <- tt_data$test[, names(tt_data$test) %in% varnames]
    glms[[i]] <- glm(IsWinnerA ~ (.)^2, family = "binomial", data = train_set)
    predictions[[i]] <- predict(glms[[i]], newdata = test_set)
    is_winner_predicted[[i]] <- as.factor(ifelse(predictions[[i]] > 0, "TRUE", "FALSE"))
}

aucs <- select_by_auc(predictions, test_set$IsWinnerA)
best_model_index <- which.max(aucs)
best_model <- glms[[best_model_index]]
plot_roc(predictions[[best_model_index]], test_set$IsWinnerA)
plot_roc(predictions[[best_model_index - 1]], test_set$IsWinnerA)






