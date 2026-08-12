# YouTube Channel Analytics (MySQL)

This project analyses YouTube channels, videos, and subscriber activity using MySQL 8.0.

## Contents

- `01_setup.sql` creates the database, tables, indexes, and sample data.
- `02_analytics.sql` contains KPI, engagement, content, publishing-time, and subscriber queries.

## Run in MySQL Workbench

1. Start MySQL Server and open MySQL Workbench.
2. Connect as a user that can create databases.
3. Open and run `01_setup.sql` (lightning-bolt button).
4. Open and run individual sections of `02_analytics.sql` to explore the results.

The scripts target MySQL 8.0 because they use common table expressions and window functions.

## Business questions answered

- Which videos and creators generate the most views?
- Which content has the highest engagement rate?
- How does performance vary by category, day, and hour of publishing?
- How many active subscribers does each channel have, and what is its churn rate?
- Which videos should be promoted because they combine high engagement with below-average reach?
