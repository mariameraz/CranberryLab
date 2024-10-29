tacy_conc <- function(data){
  # Calculate A from data frame:
  data %>% 
    mutate(Diff = nm_520 - nm_700) %>%
    dplyr::select(pH, Rep, Sample_code, Diff) %>% 
    group_by(Sample_code, Rep) %>%
    pivot_wider(names_from = pH, 
                values_from = Diff, 
                names_prefix = "pH_") %>% 
    mutate(
      A = pH_1 - pH_4.5,
      Concentration = round((A * 449.2 * 5 * 10^3) / (26900 * 1), digits = 3)
    ) %>% 
    ungroup() %>%
    select(Sample_code, Rep, A, Concentration)
}