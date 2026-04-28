# Bigfoot Sightings Time Series Analysis

An interactive R Shiny application for analyzing temporal and spatial patterns in Bigfoot sighting reports from the 21st century.

## Overview

This project performs comprehensive time series analysis on Bigfoot sighting data from the Bigfoot Field Researchers Organization (BFRO) database, focusing on reports from January 2000 through March 2024. The application provides interactive visualizations, seasonal decomposition, autocorrelation analysis, and multiple forecasting methods to explore patterns in cryptid sighting reports.

## Features

### Interactive Visualizations
- **Full Time Series Display**: Monthly aggregated sighting counts with interactive hover details
- **Seasonality Analysis**: Three complementary views of seasonal patterns
  - X-13 seasonal component extraction
  - Monthly subseries comparison
  - Year-over-year seasonal patterns
- **Autocorrelation Function (ACF)**: Identifies temporal dependencies in the data
- **Time Series Decomposition**: Breaks down sightings into trend, seasonal, and irregular components using X-11 methodology

### Forecasting Models
Four distinct forecasting approaches with 24-month predictions:
- **Exponential Smoothing (ETS)**: Captures trend and seasonality with adaptive weighting
- **ARIMA**: Auto-regressive integrated moving average with Box-Cox transformation
- **Seasonal Naive (SNAIVE)**: Baseline model using last year's observations
- **Time Series Linear Model (TSLM)**: Linear regression with trend and seasonal components

### Geographic Visualization
- **Animated Map**: Interactive plotly map showing sighting locations over time
- **Date Range Filtering**: Explore specific time periods
- **Play/Pause Controls**: Step through the temporal evolution of sightings
- **North America Focus**: Geographically scoped to primary reporting region

## Installation

### Prerequisites
- R (version 4.0.0 or higher recommended)
- RStudio (optional but recommended)

### Required R Packages
```r
install.packages(c(
  "shiny",
  "fpp3",
  "tsibble",
  "seasonal",
  "plotly",
  "forecast",
  "urca"
))
```

### Data Acquisition
1. Download the BFRO Bigfoot sighting dataset from Kaggle:
   - Dataset: [BFRO Bigfoot Sighting Reports](https://www.kaggle.com/datasets/chemcnabb/bfro-bigfoot-sighting-report)
2. Place the `bfro_locations.csv` file in the same directory as `BigfootSightingsAndSearchesFinal.R`

## Usage

### Running the Application
```r
# In R or RStudio
source("BigfootSightingsAndSearchesFinal.R")
```

The Shiny application will launch in your default web browser.

### Navigation
The application is organized into five tabs:

1. **Full Series**: View the complete monthly time series from 2000-2024
2. **Seasonality**: Explore seasonal patterns using three different analytical views
3. **ACF**: Examine autocorrelation to identify temporal dependencies
4. **Full Decomposition**: View trend, seasonal, and irregular components
5. **Forecast**: Compare four different forecasting methods for the next 24 months

Use the date range selector at the bottom to filter the animated map visualization.

## Technical Details

### Data Processing
- Time series data structure using `tsibble` package
- Monthly aggregation of daily sighting records
- Gap filling to ensure continuous time series (zero-filled for missing months)
- Box-Cox transformation (λ = 0.231) applied to variance-stabilize forecasting models

### Decomposition Methods
- **Classical Decomposition**: Both additive and multiplicative variants
- **STL (Seasonal and Trend decomposition using Loess)**: Robust decomposition method
- **X-13ARIMA-SEATS**: Census Bureau's seasonal adjustment procedure

### Forecasting Evaluation
The author's analysis indicates:
- **ETS model preferred**: ~15% better at capturing trend and seasonal patterns
- **ARIMA competitive**: Marginally lower average error (0.03 per sighting)
- Both models use Box-Cox transformation for improved performance

## Key Findings

### Temporal Patterns
- Sighting reports show a **decreasing trend** over the 2000-2024 period
- **Range**: 0-37 sightings per month
- **Yearly seasonality** identified through ACF analysis
- Seasonal fluctuation appears to **diminish over time**

### Seasonal Characteristics
- Highest autocorrelation at 12-month lag (yearly cycle)
- Lowest similarity at 5-month and 17-month intervals
- Possible sub-yearly seasonal components in residuals

## Project Structure
```
hide-and-seek-champion/
├── BigfootSightingsAndSearchesFinal.R    # Main Shiny application
├── bfro_locations.csv                    # Dataset (not included - see Data Acquisition)
└── README.md                             # This file
```

## Technologies Used
- **R**: Statistical programming language
- **Shiny**: Interactive web application framework
- **fpp3**: Forecasting principles and practice package suite
- **tsibble**: Tidy temporal data structures
- **seasonal**: X-13ARIMA-SEATS interface
- **plotly**: Interactive JavaScript-based visualizations
- **forecast**: Time series forecasting methods

## Data Source
This project uses the BFRO Bigfoot Sighting Report dataset:
- **Source**: Bigfoot Field Researchers Organization (BFRO)
- **Platform**: Kaggle
- **Link**: https://www.kaggle.com/datasets/chemcnabb/bfro-bigfoot-sighting-report
- **Coverage**: Historical Bigfoot sighting reports with geographic coordinates and timestamps


## License
This project is provided as-is for educational and analytical purposes. Please respect the Kaggle dataset's terms of use.

## Acknowledgments
- BFRO for maintaining the sighting database
- Kaggle user chemcnabb for curating and publishing the dataset

## Author
Jason Staats
