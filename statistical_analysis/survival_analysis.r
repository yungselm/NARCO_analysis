library(survival)
library(survminer)
library(ggplot2)
library(tidyverse)
library(readxl)

followup <- read_excel("C:/WorkingData/Documents/2_Coding/Python/NARCO_analysis/dataframes/follow_up.xlsx")
followup$ae_mace_type <- factor(followup$ae_mace_type, levels = c(0, 1, 2, 3, 4), labels = c("Death", "VT", "MI", "Emergency revascularization", "ICD"))
baseline <- readRDS("C:/WorkingData/Documents/2_Coding/Python/NARCO_analysis/statistical_analysis/data/baseline.rds")
index <- baseline %>% filter(!is.na(inv_ivusrest_mla)) %>% select(record_id, patient_id, ffr_0.8)
patho <- index %>% filter(ffr_0.8 == "yes")
normal <- index %>% filter(ffr_0.8 == "no")
followup <- followup %>% filter(record_id %in% index$record_id)
followup$ffr_0.8 <- index$ffr_0.8
followup$timeto_censor_y
followup$mace

median <- median(followup$timeto_censor_y, na.rm = TRUE)
quantile <- quantile(followup$timeto_censor_y, probs = c(0.25, 0.75), na.rm = TRUE)

surv_fit <- survfit(Surv(timeto_censor_y, mace) ~ ffr_0.8, data = followup)
gg <- ggsurvplot(surv_fit, pval = TRUE, conf.int = FALSE, risk.table = TRUE, 
                   legend.title = "FFR < 0.8", legend.labs = c("No", "Yes"), 
                   palette = "jco", xlab = "Time (years)", ylab = "Survival probability", 
                   legend = "right", xlim = c(0,5))

# Save plot
# ggsave("C:/WorkingData/Documents/2_Coding/Python/NARCO_analysis/figures/survival_curve.jpg", plot = print(gg), width = 3.3, height = 2.2, dpi = 1000 )
ggsave("C:/WorkingData/Documents/2_Coding/Python/NARCO_analysis/statistical_analysis/figures/survival_curve.jpg", 
       plot = gg$plot, width = 6, height = 4, dpi = 1000)

print(paste0("Median survival time: ", median, " (", quantile[1], "-", quantile[2], ") years"))

# followup %>%
#     select(record_id, timeto_censor_y, mace, ffr_0.8, ae_mace_type, ae_mace_type_2, ae_mace_type_3, ae_mace_type_4) %>% print(n = 50)