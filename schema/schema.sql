CREATE SCHEMA IF NOT EXISTS nba3k AUTHORIZATION db_admin;

CREATE TABLE IF NOT EXISTS league (
    league_id                   SMALLINT PRIMARY KEY,
    name                        VARCHAR(100) NOT NULL,
    shortname                   CHAR(3)
);

CREATE TABLE IF NOT EXISTS team (
    team_id                     SMALLINT PRIMARY KEY,
    league_id                   SMALLINT NOT NULL,
    name                        VARCHAR(30) NOT NULL,
    shortname                   CHAR(3),
    city                        VARCHAR(30) NOT NULL,
    state                       CHAR(2) NOT NULL,
    conference                  CHAR(4) NOT NULL,
    division                    VARCHAR (10) NOT NULL,
    FOREIGN KEY (league_id)     REFERENCES league (league_id)
);

-- Create enum for dexterity
CREATE TYPE IF NOT EXISTS DEXTERITY AS ENUM (
    'left', 
    'right'
);

CREATE TABLE IF NOT EXISTS player (
    player_id                   SMALLINT PRIMARY KEY,
    first_name                  VARCHAR(50) NOT NULL,
    last_name                   VARCHAR(50) NOT NULL,
    position_primary            VARCHAR(2) NOT NULL,
    position_secondary          VARCHAR(2),
    height_inches               SMALLINT,
    birthdate                   DATE,
    dexterity                   DEXTERITY,
    entered_league_on           DATE
);

CREATE TABLE IF NOT EXISTS player_team (
    player_team_id              SERIAL PRIMARY KEY,
    team_id                     SMALLINT NOT NULL,
    player_id                   SMALLINT NOT NULL,
    added_on                    DATE NOT NULL,
    FOREIGN KEY (team_id)       REFERENCES team (team_id),
    FOREIGN KEY (player_id)     REFERENCES player (player_id)
);

-- Create enum for game type
CREATE TYPE IF NOT EXISTS GAME_TYPE AS ENUM (
    'regular',
    'playoffs'
);

CREATE TABLE IF NOT EXISTS fixture (
    fixture_id                  SERIAL PRIMARY KEY,
    home_team_id                SMALLINT NOT NULL,
    away_team_id                SMALLINT NOT NULL,
    season                      SMALLINT NOT NULL,
    played_on                   TIMESTAMPZ NOT NULL,
    game_type                   GAME_TYPE NOT NULL,
    home_team_score             SMALLINT NOT NULL,
    away_team_score             SMALLINT NOT NULL,
    duration_seconds            SMALLINT NOT NULL,
    home_team_win               BOOLEAN NOT NULL,
    away_team_win               BOOLEAN NOT NULL
);

-- Create enum for player status
CREATE TYPE IF NOT EXISTS PLAYER_STATUS AS ENUM (
    'inj',
    'ill',
    'leave'
);

CREATE TABLE IF NOT EXISTS player_statistic (
    player_id                   SMALLINT NOT NULL,
    fixture_id                  INT NOT NULL,
    player_status               PLAYER_STATUS NOT NULL,
    is_starter                  BOOLEAN NOT NULL,
    seconds_played              SMALLINT NOT NULL,
    points                      SMALLINT NOT NULL,
    threes_attempted            SMALLINT NOT NULL,
    threes_made                 SMALLINT NOT NULL,
    field_goals_attempted       SMALLINT NOT NULL,
    field_goals_made            SMALLINT NOT NULL,
    free_throws_attempted       SMALLINT NOT NULL,
    free_throws_made            SMALLINT NOT NULL,
    offensive_rebounds          SMALLINT NOT NULL,
    defensive_rebounds          SMALLINT NOT NULL,
    assists                     SMALLINT NOT NULL,
    steals                      SMALLINT NOT NULL,
    blocks                      SMALLINT NOT NULL,
    turnovers                   SMALLINT NOT NULL,
    PRIMARY KEY (player_id, fixture_id),
    FOREIGN KEY (player_id)     REFERENCES player (player_id),
    FOREIGN KEY (fixture_id)    REFERENCES fixture (fixture_id)
);