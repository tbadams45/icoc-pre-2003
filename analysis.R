library(tidyverse)
library(readxl)
library(cowplot)

cities <- as.tibble(maps::world.cities)
icoc_raw   <- read_excel("20180413-pre-2003-icoc-statistics.xlsx")

# some "cities" actually have states in them too
just_city <- function(city_and_state) {
  str_split(city_and_state, ",")[[1]][1]
}

icoc <- icoc_raw %>%
  rename(city_with_state = city) %>%
  mutate(city = map(city_with_state, just_city))

yearly_stats <- icoc %>%
  group_by(year) %>%
  select(year, members_beginning, in_baptism, in_restoration, in_mission, in_move, in_reconstruction,
         out_leaver, out_death, out_mission, out_move, out_reconstruction, members_end) %>%
  summarize_all(funs(sum))

calc_statistics <- yearly_stats %>%
  arrange(year) %>%
  mutate(cum_baptism = cumsum(in_baptism),
         cum_leaver  = cumsum(out_leaver),
         percent_leavers = cum_leaver/cum_baptism)


cum_baptisms_and_leavers <- calc_statistics %>%
  gather(key, value, members_end, in_baptism, out_leaver, cum_baptism, cum_leaver, percent_leavers) %>%
  group_by(year, key) %>%
  summarize(value = sum(value)) %>%
  ungroup()

ggplot(cum_baptisms_and_leavers, aes(x = year, y = value, color = key)) +
  geom_line(size = 2)

plot_percent_left <- ggplot(calc_statistics, aes(year, percent_leavers)) + 
  geom_line() +
  labs(x = "Year", y = "Percent\nwho left\n(cumulative)") +
  scale_y_continuous(limits = c(0, 0.8), breaks = seq(0, 0.8, by = 0.1),
                     sec.axis = dup_axis(name = "")) +
  theme(axis.title.y = element_text(angle = 0))

yearly_in_out <- calc_statistics %>%
  select(year, in_baptism, out_leaver) %>%
  gather(key = "in_or_out", value = "value", in_baptism, out_leaver) %>%
  mutate(in_or_out = ifelse(in_or_out == "in_baptism", "Baptized (In)", "Left (Out)"))

plot_in_and_out <- ggplot(yearly_in_out, aes(x = year, 
                          y = value, 
                          color = in_or_out)) +
  geom_line(size = 2) +
  scale_y_continuous(sec.axis = dup_axis(name = "")) +
  labs(x = "Year", 
       y = "People", 
       color = "In or Out?") + 
  scale_color_brewer(palette = "Pastel1", direction = -1) +
  theme(axis.title.y = element_text(angle = 0),
        legend.position = "top")


plot_grid(plot_in_and_out, plot_percent_left, ncol = 1)




## BOSTON

yearly_stats <- icoc %>%
  filter(city_with_state == "Boston, Massachusetts") %>%
  group_by(year) %>%
  select(year, members_beginning, in_baptism, in_restoration, in_mission, in_move, in_reconstruction,
         out_leaver, out_death, out_mission, out_move, out_reconstruction, members_end) %>%
  summarize_all(funs(sum))

calc_statistics <- yearly_stats %>%
  arrange(year) %>%
  mutate(cum_baptism = cumsum(in_baptism),
         cum_leaver  = cumsum(out_leaver),
         percent_leavers = cum_leaver/cum_baptism)


cum_baptisms_and_leavers <- calc_statistics %>%
  gather(key, value, members_end, in_baptism, out_leaver, cum_baptism, cum_leaver, percent_leavers) %>%
  group_by(year, key) %>%
  summarize(value = sum(value)) %>%
  ungroup()

plot_percent_left <- ggplot(calc_statistics, aes(year, percent_leavers)) + 
  geom_line() +
  labs(x = "Year", y = "Percent\nwho left\n(cumulative)") +
  scale_y_continuous(limits = c(0, 0.8), 
                     breaks = seq(0, 0.8, by = 0.1),
                     labels = scales::percent,
                     sec.axis = dup_axis(name = "")) +
  theme(axis.title.y = element_text(angle = 0))

yearly_in_out <- calc_statistics %>%
  select(year, in_baptism, out_leaver) %>%
  gather(key = "in_or_out", value = "value", in_baptism, out_leaver) %>%
  mutate(in_or_out = ifelse(in_or_out == "in_baptism", "Baptized (In)", "Left (Out)"))

plot_in_and_out <- ggplot(yearly_in_out, aes(x = year, 
                                             y = value, 
                                             color = in_or_out)) +
  geom_line(size = 2) +
  scale_y_continuous(sec.axis = dup_axis(name = "")) +
  labs(x = "Year", 
       y = "People", 
       color = "In or Out?") + 
  scale_color_brewer(palette = "Pastel1", direction = -1) +
  theme(axis.title.y = element_text(angle = 0),
        legend.position = "top")


plot_grid(plot_in_and_out, plot_percent_left, ncol = 1)

