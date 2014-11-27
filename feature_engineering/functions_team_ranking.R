#
## implementation of different ranking systems
#

require(hash)
source(paste0(getwd(), '/data_preprocessing/soccerway_games/functions_basic_preprocessing.R'))


h <- function(x) {
    0.5 + 0.5 * sign(x - 0.5) * sqrt(abs(2 * x - 1))
}

make_command_index <- function(data) {
    team_names <- levels(factor(data$TeamA))
    data$IDA <- sapply(data$TeamA, function(x) which(x == team_names))
    data$IDB <- sapply(data$TeamB, function(x) which(x == team_names))
    data
}

count_games <- function(data, team_names, team_type) {
    n_games <- hash(keys = team_names, values = rep(0, length(team_names)))
    apply(data, 1, function(row) {
        n_games[[row[["TeamA"]]]] <- n_games[[row[["TeamA"]]]] + 1
        n_games[[row[["TeamB"]]]] <- n_games[[row[["TeamB"]]]] + 1
        as.numeric(n_games[[row[[team_type]]]])
    })
}

count_games_per_team <- function(data) {
    data <- arrange(data, Date)
    team_names <- levels(factor(data$TeamA))

    data$NGamesA <- count_games(data, team_names, "TeamA")
    data$NGamesB <- count_games(data, team_names, "TeamB")
    data
}

get_team_ranks <- function(data, season) {
    season_data <- filter(data, Season == season)
    season_data <- make_command_index(season_data)

    # count number of games played in current season for each team
    season_data <- count_games_per_team(season_data)

    team_names <- levels(factor(season_data$TeamA))
    A_matrix <- matrix(0, nrow=length(team_names), ncol=length(team_names))

    for (team_name in team_names) {
        team_data <- filter(season_data, TeamA == team_name | TeamB == team_name)
        team_data <- mutate(team_data, Type = ifelse(team_name == TeamA, "A", "B"))
        a_vec <- apply(team_data, 1, function(row) {
            denominator <- as.numeric(row[["ScoreA"]]) + as.numeric(row[["ScoreB"]]) + 2
            nominator <- as.numeric(ifelse(row[["Type"]] == "A", row[["ScoreB"]], row[["ScoreA"]])) + 1
            h(nominator / denominator)
        })
        n_games <- ifelse(team_data$Type == "A", team_data$NGamesB, team_data$NGamesA)

        j <- which(team_name == team_names)
        i_indices <- as.numeric(apply(team_data, 1, function(row) {
            ifelse(row[["Type"]] == "A", row[["IDB"]], row[["IDA"]])
        }))
        A_matrix[i_indices, j] <- a_vec / n_games
    }

    # find positive eigenvector (also with max eigenvalue)
    eigenvecs <- eigen(A_matrix)$vectors
    eigenvals <- eigen(A_matrix)$values
    indices <- which(apply(eigenvecs, 2, function(vec) {
        all(Im(vec) == 0)
    } == TRUE))
    final_rate_vec <- Re(eigenvecs[, indices][, which.max(Re(eigenvals[indices]))])
    if (all(final_rate_vec <= 0))
        final_rate_vec <- abs(final_rate_vec)
    else if (!all(final_rate_vec >= 0))
        stop("Rank vector is screwed (mixed signes of the values)")

    season_data <- mutate(season_data,
                          RankA=final_rate_vec[IDA],
                          RankB=final_rate_vec[IDB])
    data <- update_values(season_data, data, "RankA", "RankA", "ID")
    data <- update_values(season_data, data, "RankB", "RankB", "ID")
    data
}
