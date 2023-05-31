# Returned data is consistent

    Code
      get_consumption(meter_type = "electricity", group_by = "week", period_from = "2022-01-01",
        period_to = "2022-01-31")
    Output
      # A tibble: 6 x 3
        consumption interval_start       interval_end        
              <dbl> <chr>                <chr>               
      1       0.147 2022-01-31T00:00:00Z 2022-01-31T00:30:00Z
      2      91.2   2022-01-24T00:00:00Z 2022-01-31T00:00:00Z
      3     137.    2022-01-17T00:00:00Z 2022-01-24T00:00:00Z
      4      97.4   2022-01-10T00:00:00Z 2022-01-17T00:00:00Z
      5     125.    2022-01-03T00:00:00Z 2022-01-10T00:00:00Z
      6      41.8   2022-01-01T00:00:00Z 2022-01-03T00:00:00Z

---

    Code
      get_consumption(meter_type = "electricity", group_by = "week", period_from = "2022-01-01",
        period_to = "2022-01-31", tz = "UTC")
    Output
      # A tibble: 6 x 3
        consumption interval_start      interval_end       
              <dbl> <dttm>              <dttm>             
      1       0.147 2022-01-31 00:00:00 2022-01-31 00:30:00
      2      91.2   2022-01-24 00:00:00 2022-01-31 00:00:00
      3     137.    2022-01-17 00:00:00 2022-01-24 00:00:00
      4      97.4   2022-01-10 00:00:00 2022-01-17 00:00:00
      5     125.    2022-01-03 00:00:00 2022-01-10 00:00:00
      6      41.8   2022-01-01 00:00:00 2022-01-03 00:00:00

---

    Code
      get_consumption(meter_type = "electricity", group_by = "week", period_from = "2022-01-01",
        period_to = "2022-01-31", tz = "UTC", order_by = "period")
    Output
      # A tibble: 6 x 3
        consumption interval_start      interval_end       
              <dbl> <dttm>              <dttm>             
      1      41.8   2022-01-01 00:00:00 2022-01-03 00:00:00
      2     125.    2022-01-03 00:00:00 2022-01-10 00:00:00
      3      97.4   2022-01-10 00:00:00 2022-01-17 00:00:00
      4     137.    2022-01-17 00:00:00 2022-01-24 00:00:00
      5      91.2   2022-01-24 00:00:00 2022-01-31 00:00:00
      6       0.147 2022-01-31 00:00:00 2022-01-31 00:30:00

