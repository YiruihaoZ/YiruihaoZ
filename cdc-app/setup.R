
cdc = read.csv("data/Provisional_COVID-19_Deaths_by_Sex_and_Age.csv")


cdc = cdc %>% 
  select(State:Pneumonia..Influenza..or.COVID.19.Deaths) %>% 
  filter(!is.na(COVID.19.Deaths)) %>% 
  filter(!is.na(Total.Deaths)) %>% 
  filter(!is.na(Pneumonia.Deaths)) %>% 
  filter(!is.na(Pneumonia.and.COVID.19.Deaths)) %>% 
  filter(!is.na(Influenza.Deaths)) %>% 
  filter(!is.na(Pneumonia..Influenza..or.COVID.19.Deaths)) %>%
  filter(!is.na(COVID.Deaths.Rate)) %>% 
  mutate(COVID.Deaths.Rate = round(COVID.19.Deaths / Total.Deaths, digits = 1) ) 
 



write_csv(cdc_sub, "data/Provisional_COVID-19_Deaths_by_Sex_and_Age_subset.csv")


view(cdc_sub)


cdc_sub %>% 
  group_by(COVID.Deaths.Rate) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n))
