# Code for figures to accompany 03-draft

# PLOT: Age distribution -------------------------------------------------------
age_histogram <- 
  ggplot(mockdata, aes(age)) +
  geom_histogram(color = 'white',
                 fill = scico::scico(1, begin = .3, palette = "berlin"),
                 bins = 20) +
  labs(x = "Age", 
       y = "Count") +
  scale_y_continuous(
    breaks = scales::pretty_breaks()
  )

# Calculate proportion survived by arm------------------------------------------
prop_surv <- mockdata %>% 
  count(arm, fu_fct, name = "by_surv", .drop = FALSE) %>% 
  add_count(arm, wt = by_surv, name = "arm_total") %>% 
  mutate(prop = by_surv/arm_total) %>% 
  filter(fu_fct == "Lived")

# PLOT: percent survived--------------------------------------------------------
surv_pct_plot <- ggplot(prop_surv, aes(x = arm, y = prop)) +
  geom_col() +
  labs(y= "Percent Survived", x= "Study Arm") +
  scale_y_continuous(labels = scales::percent_format(accuracy = .1))

# PLOT: days survived by arm/status---------------------------------------------
surv_days_plot <- ggplot(mockdata) +
  aes(x=arm, y = fu_time, fill = fu_fct, group = interaction(arm, fu_fct)) +
  geom_violin(alpha = .6,
              colour = NA, 
              na.rm = TRUE, 
              position = position_dodge()) +
  geom_boxplot(alpha = .8,
               outlier.colour = "black",
               colour = "white",
               width = .2, 
               outlier.size = 2, 
               na.rm = TRUE, 
               position = position_dodge(width = .9),
               show.legend = FALSE) +
  labs(y= "Survival Time in \nDays (Censored)", x= "Study Arm") +
  scale_fill_scico_d(palette = "berlin", 
                     name = "Follow-up status:",
                     begin = .3) +
  theme(legend.position = "top")

# Calculate adverse event freq/props--------------------------------------------
ae_freq <- mockdata %>% 
  select(arm, starts_with("ae")) %>% 
  add_count(arm, name = "per_arm") %>% 
  gather(key = "ae_type", 
         value = "value", 
         -contains("arm"), 
         factor_key = TRUE) %>% 
  filter(value == 1) %>% 
  count(arm, per_arm, ae_type) %>% 
  mutate(ae_prop = n / per_arm)

# PLOT: adverse event freq dots-------------------------------------------------
ae_pct_plot <- ggplot(ae_freq, 
                 aes(x = ae_prop, 
                     y = ae_type, 
                     fill = arm, 
                     shape = arm)) +
  geom_point(size = 3, 
             colour = "black") +
  scale_fill_scico_d(palette = "berlin", 
                     name = "Treatment arm",
                     begin = .3) +
  scale_shape_manual(values = 21:23,
                     name = "Treatment arm") +
  ggtitle("Frequency of adverse events by type and treatment arm") +
  scale_x_continuous(name = "Percent of patients",
                     labels = scales::percent_format(accuracy = 1)) +
  expand_limits(x = c(0, .3))