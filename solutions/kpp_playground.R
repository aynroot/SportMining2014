
source(paste0(getwd(), "/data_preprocessing/soccerway_games/functions_basic_preprocessing.R"))
source(paste0(getwd(), "/data_aggregation/football-data/read_and_convert.R"))
source(paste0(getwd(), "/feature_engineering/functions_kpp_features.R"))
source(paste0(getwd(), "/solutions/functions_selecting_model.R"))

require(caret)
set.seed(42)

# preprocessed_data <- read_raw_data() %>% basic_preprocess() %>% make_diff_stats()
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
    #c("PosessionA", "PosessionB", "PosessionDiff", "PosessionKPP", "PosessionDiffKPP",
    #  "PosessionTGKPP", "PosessionDiffTGKPP"),
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
vars <- c("IsWinnerA", "GameWeek", "Date")
for (varnames in varnames_lst) {
    vars <- c(vars, sapply(varnames[4:7], function(x) paste0(x, "A")))
    vars <- c(vars, sapply(varnames[4:7], function(x) paste0(x, "B")))
}
data <- data[, names(data) %in% vars]

# split by train and test
tt_data <- split_data_by_date(data)

# drop Date column
date_index <- which(names(tt_data$train) == "Date")
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

# glm training
predictions <- vector("list", 2 * length(varnames_sets))
is_winner_predicted <- vector("list", 2 * length(varnames_sets))
glms <- vector("list", 2 * length(varnames_sets))
for (i in seq(1, 2 * length(varnames_sets), 2)) {
    varnames <- unlist(c("IsWinnerA", "GameWeek", varnames_sets[[(i + 1) / 2]]))
    train_set <- tt_data$train[, names(tt_data$train) %in% varnames]
    test_set <- tt_data$test[, names(tt_data$test) %in% varnames]

    glms[[i]] <- glm(IsWinnerA ~ ., family = "binomial", data = train_set)
    predictions[[i]] <- predict(glms[[i]], newdata = test_set)
    is_winner_predicted[[i]] <- as.factor(ifelse(predictions[[i]] > 0, "TRUE", "FALSE"))

    glms[[i + 1]] <- glm(IsWinnerA ~ (.)^2, family = "binomial", data = train_set)
    predictions[[i + 1]] <- predict(glms[[i + 1]], newdata = test_set)
    is_winner_predicted[[i + 1]] <- as.factor(ifelse(predictions[[i + 1]] > 0, "TRUE", "FALSE"))
}

aucs <- get_aucs(predictions, test_set$IsWinnerA)
accuracies <- get_accuracies(is_winner_predicted, test_set$IsWinnerA)
best_model_index <- which.max(aucs)
best_model <- glms[[best_model_index]]
plot_multiple_rocs(predictions, test_set$IsWinnerA)

# gbm caret training
fit_control <- trainControl(method = "cv",
                           number = 5,
                           classProbs = TRUE,
                           verboseIter = TRUE,
                           summaryFunction = twoClassSummary)
gbm_grid <- expand.grid(.interaction.depth=1:6, .n.trees=c(50, 100, 300, 500), .shrinkage=c(0.0001, 0.01, 0.1, 1))
gbm_fit <- train(IsWinnerA ~ .,
                 data = tt_data$train,
                 method = "gbm",
                 # preProc = c("center", "scale"),
                 trControl = fit_control,
                 tuneGrid = gbm_grid,
                 metric = "ROC")

gbm_final <- gbm(as.numeric(IsWinnerA) - 1 ~ ., data=tt_data$train, n.trees=500, interaction.depth=6, shrinkage=0.01)
gbm_predictions <- predict(gbm_final, newdata=tt_data$test, n.trees=500)
gbm_is_winner_predicted <- as.factor(ifelse(gbm_predictions > 0, "TRUE", "FALSE"))
gbm_accuracy <- sum(gbm_is_winner_predicted == tt_data$test$IsWinnerA) / length(tt_data$test$IsWinnerA)
gbm_auc <- AUC::auc(AUC::roc(gbm_predictions, as.numeric(tt_data$test$IsWinnerA) - 1))




