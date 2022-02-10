CREATE SCHEMA IF NOT EXISTS nba3k AUTHORIZATION dbadmin;
GRANT USAGE ON SCHEMA nba3k TO dbadmin;
GRANT CREATE ON SCHEMA nba3k TO dbadmin;

CREATE TABLE IF NOT EXISTS nba3k.league (
	league_id                   SMALLINT PRIMARY KEY,
	name                        VARCHAR(100) NOT NULL,
	shortname                   CHAR(3),
	created_at					TIMESTAMP
);

CREATE TABLE IF NOT EXISTS nba3k.team (
	team_id                     INT PRIMARY KEY,
	league_id                   SMALLINT NOT NULL,
	name                        VARCHAR(30) NOT NULL,
	shortname                   CHAR(3),
	city                        VARCHAR(30) NOT NULL,
	state                       VARCHAR(5) NOT NULL,
	conference                  CHAR(4) NOT NULL,
	division                    VARCHAR (10) NOT NULL,
	created_at					TIMESTAMP,
	FOREIGN KEY (league_id)     REFERENCES nba3k.league (league_id)
);

CREATE TABLE IF NOT EXISTS nba3k.player (
	player_id                   SMALLINT PRIMARY KEY,
	first_name                  VARCHAR(50) NOT NULL,
	last_name                   VARCHAR(50),
	birth_year                  SMALLINT,
	draft_year                  SMALLINT,
	draft_pick                  SMALLINT,
	created_at					TIMESTAMP
);

CREATE TABLE IF NOT EXISTS nba3k.player_position (
	player_id                   SMALLINT NOT NULL,
	season                      SMALLINT NOT NULL,
	position_primary            VARCHAR(2) NOT NULL,
	position_secondary          VARCHAR(2),
	position_tertiary           VARCHAR(2),
	created_at					TIMESTAMP,
	PRIMARY KEY (player_id, season)
);

CREATE TABLE IF NOT EXISTS nba3k.player_team (
	player_team_id              SERIAL NOT NULL PRIMARY KEY,
	team_id                     INT,
	player_id                   SMALLINT NOT NULL,
	created_at					TIMESTAMP,
	FOREIGN KEY (team_id)       REFERENCES nba3k.team (team_id),
	FOREIGN KEY (player_id)     REFERENCES nba3k.player (player_id)
);

-- Create enum for game type
CREATE TYPE nba3k.GAME_TYPE AS ENUM (
	'pre-season',
	'post-season',
	'regular-season',
	'before-asb',
	'after-asb',
	'na'
);

CREATE TABLE IF NOT EXISTS nba3k.fixture (
	fixture_id                  BIGINT PRIMARY KEY,
	home_team_id                INT NOT NULL,
	away_team_id                INT NOT NULL,
	season                      SMALLINT NOT NULL,
	played_on                   TIMESTAMP NOT NULL,
	game_type                   nba3k.GAME_TYPE NOT NULL,
	home_team_score             FLOAT(1) NOT NULL,
	away_team_score             FLOAT(1) NOT NULL,
	home_team_win               BOOLEAN NOT NULL,
	away_team_win               BOOLEAN NOT NULL,
	created_at					TIMESTAMP
);

-- Create enum for player status
CREATE TYPE nba3k.PLAYER_STATUS AS ENUM (
	'INJ',
	'DNP-ILL',
	'DNP-CD',
	'DNP-REST',
	'NWT',
	'SUS',
	'PROTOCOL',
	'N/A'
);

CREATE TABLE IF NOT EXISTS nba3k.player_statistic (
	player_statistic_id         SERIAL NOT NULL,
	player_id                   SMALLINT NOT NULL,
	fixture_id                  BIGINT NOT NULL,
	player_status               nba3k.PLAYER_STATUS,
	is_starter                  BOOLEAN NOT NULL,
	seconds_played              SMALLINT,
	points                      FLOAT(1),
	threes_attempted            FLOAT(1),
	threes_made                 FLOAT(1),
	field_goals_attempted       FLOAT(1),
	field_goals_made            FLOAT(1),
	free_throws_attempted       FLOAT(1),
	free_throws_made            FLOAT(1),
	offensive_rebounds          FLOAT(1),
	defensive_rebounds          FLOAT(1),
	assists                     FLOAT(1),
	steals                      FLOAT(1),
	blocks                      FLOAT(1),
	turnovers                   FLOAT(1),
	created_at                  TIMESTAMP,
	PRIMARY KEY (player_statistic_id),
	FOREIGN KEY (player_id)     REFERENCES nba3k.player (player_id),
	FOREIGN KEY (fixture_id)    REFERENCES nba3k.fixture (fixture_id)
);