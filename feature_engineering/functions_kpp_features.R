#
## functions to make KPP and TGKPP features
#

require(dplyr)
require(caTools)

kpp <- function(data, k, varname, kpp_varname) {
    data[[kpp_varname]] <- runmean(data[[varname]], k, align="right", endrule="NA")
    data
}

tgkpp <- function(data, k, varname, tgkpp_varname) {
    convolution <- data[[varname]] - lag(data[[varname]])
    data[[tgkpp_varname]] <- runmean(convolution, k, align="right", endrule="NA")
    data
}
