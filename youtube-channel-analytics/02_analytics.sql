-- YouTube Channel Analytics: KPI and business-analysis queries
USE youtube_analytics_db;

-- 1. Executive KPI dashboard
SELECT
  (SELECT COUNT(*) FROM channels) AS total_channels,
  (SELECT COUNT(*) FROM videos) AS total_videos,
  (SELECT COALESCE(SUM(views), 0) FROM videos) AS total_views,
  (SELECT COALESCE(SUM(likes), 0) FROM videos) AS total_likes,
  (SELECT COALESCE(SUM(comments), 0) FROM videos) AS total_comments,
  (SELECT COALESCE(SUM(shares), 0) FROM videos) AS total_shares,
  (SELECT COUNT(*) FROM subscribers WHERE unsubscribe_date IS NULL) AS active_subscribers,
  (SELECT ROUND(COALESCE(AVG(views), 0), 2) FROM videos) AS avg_views_per_video,
  (SELECT ROUND(COALESCE(SUM(duration_minutes * views), 0), 2) FROM videos) AS estimated_watch_minutes;

-- 2. Video-level engagement metrics
SELECT video_id, video_title, category, views, likes, comments, shares,
  ROUND(100.0 * (likes + comments + shares) / NULLIF(views, 0), 2) AS engagement_rate_pct,
  ROUND(100.0 * likes / NULLIF(views, 0), 2) AS like_to_view_pct,
  ROUND(100.0 * comments / NULLIF(views, 0), 2) AS comment_to_view_pct,
  ROUND(100.0 * shares / NULLIF(views, 0), 2) AS share_to_view_pct
FROM videos ORDER BY engagement_rate_pct DESC, views DESC;

-- 3. Top five videos by reach
SELECT video_title, views FROM videos ORDER BY views DESC LIMIT 5;

-- 4. Best video in every category
WITH ranked_videos AS (
  SELECT video_title, category, views,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY views DESC) AS category_rank
  FROM videos
)
SELECT video_title, category, views FROM ranked_videos WHERE category_rank = 1 ORDER BY views DESC;

-- 5. Channel performance and audience engagement
SELECT c.channel_name, c.category AS channel_category, COUNT(v.video_id) AS total_videos,
  COALESCE(SUM(v.views), 0) AS total_views, COALESCE(SUM(v.likes), 0) AS total_likes,
  COALESCE(SUM(v.comments), 0) AS total_comments, COALESCE(SUM(v.shares), 0) AS total_shares,
  ROUND(100.0 * COALESCE(SUM(v.likes + v.comments + v.shares), 0) / NULLIF(SUM(v.views), 0), 2) AS engagement_rate_pct
FROM channels c LEFT JOIN videos v ON v.channel_id = c.channel_id
GROUP BY c.channel_id, c.channel_name, c.category ORDER BY total_views DESC;

-- 6. Category comparison
SELECT category, COUNT(*) AS videos_published, SUM(views) AS total_views,
  ROUND(AVG(views), 0) AS avg_views,
  ROUND(100.0 * SUM(likes + comments + shares) / NULLIF(SUM(views), 0), 2) AS engagement_rate_pct,
  ROUND(SUM(duration_minutes * views), 2) AS estimated_watch_minutes
FROM videos GROUP BY category ORDER BY total_views DESC;

-- 7. Publishing day and hour performance
SELECT DAYNAME(publish_date) AS publish_day, HOUR(publish_date) AS publish_hour,
  COUNT(*) AS total_videos, ROUND(AVG(views), 0) AS avg_views, SUM(views) AS total_views
FROM videos GROUP BY DAYNAME(publish_date), HOUR(publish_date) ORDER BY avg_views DESC;

-- 8. Subscriber status and churn by channel
SELECT c.channel_name, COUNT(s.subscriber_id) AS subscribers_ever_acquired,
  SUM(s.unsubscribe_date IS NULL) AS active_subscribers,
  SUM(s.unsubscribe_date IS NOT NULL) AS unsubscribed,
  ROUND(100.0 * SUM(s.unsubscribe_date IS NOT NULL) / NULLIF(COUNT(s.subscriber_id), 0), 2) AS churn_rate_pct
FROM channels c LEFT JOIN subscribers s ON s.channel_id = c.channel_id
GROUP BY c.channel_id, c.channel_name ORDER BY active_subscribers DESC;

-- 9. Monthly subscriber acquisition and net growth
WITH monthly_subscribes AS (
  SELECT channel_id, DATE_FORMAT(subscribe_date, '%Y-%m-01') AS month_start, COUNT(*) AS new_subscribers
  FROM subscribers GROUP BY channel_id, DATE_FORMAT(subscribe_date, '%Y-%m-01')
), monthly_unsubscribes AS (
  SELECT channel_id, DATE_FORMAT(unsubscribe_date, '%Y-%m-01') AS month_start, COUNT(*) AS lost_subscribers
  FROM subscribers WHERE unsubscribe_date IS NOT NULL GROUP BY channel_id, DATE_FORMAT(unsubscribe_date, '%Y-%m-01')
)
SELECT c.channel_name, ms.month_start, ms.new_subscribers, COALESCE(mu.lost_subscribers, 0) AS lost_subscribers,
  ms.new_subscribers - COALESCE(mu.lost_subscribers, 0) AS net_subscriber_growth
FROM monthly_subscribes ms JOIN channels c ON c.channel_id = ms.channel_id
LEFT JOIN monthly_unsubscribes mu ON mu.channel_id = ms.channel_id AND mu.month_start = ms.month_start
ORDER BY ms.month_start, c.channel_name;

-- 10. Promotion candidates: high engagement but below-average reach
WITH video_metrics AS (
  SELECT video_id, video_title, category, views,
    100.0 * (likes + comments + shares) / NULLIF(views, 0) AS engagement_rate
  FROM videos
)
SELECT video_title, category, views, ROUND(engagement_rate, 2) AS engagement_rate_pct
FROM video_metrics
WHERE engagement_rate > (SELECT AVG(engagement_rate) FROM video_metrics)
  AND views < (SELECT AVG(views) FROM video_metrics)
ORDER BY engagement_rate DESC;
