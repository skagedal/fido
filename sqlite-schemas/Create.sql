CREATE TABLE IF NOT EXISTS `items` (
	`item_id`                  INTEGER PRIMARY KEY,
	`item_guid`                TEXT NOT NULL,
	`item_title`               TEXT,
	`item_content`             TEXT,
	`item_posted`              INTEGER,
	`item_updated`             INTEGER,
	`item_read_time`           INTEGER DEFAULT 0,
	`item_mute`                INTEGER,
	`item_stored`              INTEGER DEFAULT (strftime('%s')),
	`feed_id`                  INTEGER NOT NULL,

	UNIQUE (feed_id, item_guid)
);

CREATE TABLE IF NOT EXISTS `feeds` (
	`feed_id`                  INTEGER PRIMARY KEY,
	`feed_title`               TEXT,
	`feed_source`              TEXT UNIQUE NOT NULL,
	`feed_metadata`            TEXT,
	`feed_priority`            INTEGER DEFAULT 0,
	`feed_mute`                INTEGER,
	`feed_updated`             INTEGER DEFAULT 0
);


