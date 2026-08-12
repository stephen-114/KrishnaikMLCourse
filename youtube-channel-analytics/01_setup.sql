-- YouTube Channel Analytics: database, schema, and sample data
-- MySQL 8.0+

DROP DATABASE IF EXISTS youtube_analytics_db;
CREATE DATABASE youtube_analytics_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE youtube_analytics_db;

CREATE TABLE channels (
    channel_id INT PRIMARY KEY,
    channel_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    created_date DATE NOT NULL
);

CREATE TABLE videos (
    video_id INT PRIMARY KEY,
    channel_id INT NOT NULL,
    video_title VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    publish_date DATETIME NOT NULL,
    duration_minutes DECIMAL(6,2) NOT NULL,
    views BIGINT UNSIGNED NOT NULL DEFAULT 0,
    likes INT UNSIGNED NOT NULL DEFAULT 0,
    comments INT UNSIGNED NOT NULL DEFAULT 0,
    shares INT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_videos_channel FOREIGN KEY (channel_id) REFERENCES channels(channel_id),
    CONSTRAINT chk_duration_positive CHECK (duration_minutes > 0)
);

CREATE TABLE subscribers (
    subscriber_id INT PRIMARY KEY,
    channel_id INT NOT NULL,
    subscribe_date DATE NOT NULL,
    unsubscribe_date DATE NULL,
    CONSTRAINT fk_subscribers_channel FOREIGN KEY (channel_id) REFERENCES channels(channel_id),
    CONSTRAINT chk_unsubscribe_after_subscribe CHECK (unsubscribe_date IS NULL OR unsubscribe_date >= subscribe_date)
);

CREATE INDEX idx_videos_channel_publish ON videos(channel_id, publish_date);
CREATE INDEX idx_videos_category ON videos(category);
CREATE INDEX idx_subscribers_channel_dates ON subscribers(channel_id, subscribe_date, unsubscribe_date);

INSERT INTO channels (channel_id, channel_name, category, country, created_date) VALUES
  (1, 'Data Simplifier', 'Education', 'India', '2023-01-10'),
  (2, 'Tech World', 'Technology', 'India', '2022-08-15'),
  (3, 'Finance Explained', 'Finance', 'USA', '2021-05-20'),
  (4, 'Travel Diaries', 'Travel', 'India', '2023-04-12');

INSERT INTO videos (video_id, channel_id, video_title, category, publish_date, duration_minutes, views, likes, comments, shares) VALUES
  (101, 1, 'SQL Interview Questions', 'Education', '2025-01-05 10:00:00', 12.00, 15000, 900, 120, 80),
  (102, 1, 'Power BI Dashboard Tutorial', 'Education', '2025-01-08 18:00:00', 18.00, 22000, 1400, 180, 150),
  (103, 2, 'Best AI Tools', 'Technology', '2025-01-10 12:00:00', 10.00, 35000, 2800, 310, 420),
  (104, 3, 'How to Invest', 'Finance', '2025-01-12 09:00:00', 15.00, 28000, 2100, 250, 300),
  (105, 4, 'Top Places in India', 'Travel', '2025-01-15 20:00:00', 14.00, 19000, 1300, 170, 200);

INSERT INTO subscribers (subscriber_id, channel_id, subscribe_date, unsubscribe_date) VALUES
  (1001, 1, '2025-01-01', NULL), (1002, 1, '2025-01-03', NULL),
  (1003, 1, '2025-01-05', '2025-03-01'), (1004, 2, '2025-01-02', NULL),
  (1005, 3, '2025-01-04', NULL), (1006, 4, '2025-01-10', NULL);
