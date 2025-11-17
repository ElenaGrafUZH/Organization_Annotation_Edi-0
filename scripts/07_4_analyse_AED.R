library(Cairo)
# get data from parameter
args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]

#read AED values
aed <- read.table(file.path(wd, "/output/07_Final/UpdateFilter/Edi-0.maker.AED.txt"), header = TRUE)
colnames(aed) <- c("AED", "Cumulative_fraction")

#create distribution plot
out_file <- file.path(wd, "/output/07_Final/plots/AED_distribution.png")
CairoPNG(out_file, width = 1600, height = 1200, res = 300)
plot(aed$AED, aed$Cumulative_fraction, type = "l", lwd = 2,
    xlab = "Annotation Edit Distance (AED)",
    ylab = "Cumulative Fraction of Gene Models",
    main = "AED Distribution of MAKER Gene Models")
abline(v = 0.5, col = "red", lty = 2)
dev.off()
