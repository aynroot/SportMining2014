#
## functions to select best available model
#

require(caret)
require(AUC)

get_accuracies<- function(factor_predictions, true_values) {
    accuracies <- sapply(factor_predictions, function(predictions_vec) {
        sum(predictions_vec == true_values) / length(true_values)
    })
    accuracies
}

get_aucs <- function(predictions, true_values) {
    aucs <- sapply(predictions, function(predictions_vec) {
        auc(roc(predictions_vec, true_values))
    })
    aucs
}

plot_roc <- function(predictions_vec, true_values) {
    roc_plot <- roc(predictions_vec, true_values)
    plot(roc_plot)
}

plot_multiple_rocs <- function(predictions, true_values) {
    colors <- rainbow(length(predictions))
    for (i in 1:length(predictions)) {
        roc_plot <- roc(predictions[[i]], true_values)
        plot(roc_plot, add = (i != 1), col = colors[i], asp = 1)
    }
    legend("bottomright", legend=c(1:length(predictions)), col = colors,
           lty = rep(1, length(predictions)), bg = "gray90")
}

