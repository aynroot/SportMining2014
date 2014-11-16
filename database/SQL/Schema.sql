CREATE TABLE "cities" (
	"id" INT NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"code" VARCHAR(255)
	,"synonyms" VARCHAR(255)
	,"country_id" INT NOT NULL
	,"region_id" INT
	,"city_id" INT
	,"pop" INT
	,"popm" INT
	,"area" INT
	,"lat" FLOAT
	,"lng" FLOAT
	,"m" BOOLEAN NOT NULL DEFAULT 'f'
	,"c" BOOLEAN NOT NULL DEFAULT 'f'
	,"d" BOOLEAN NOT NULL DEFAULT 'f'
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fkey1" FOREIGN KEY ("region_id") REFERENCES "regions" ("id")
	);

CREATE TABLE "continents" (
	"id" INT NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"synonyms" VARCHAR(255)
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	);

CREATE UNIQUE INDEX "index_continents_on_key" ON "continents" ("key" ASC);

CREATE TABLE "countries" (
	"id" INT NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"code" VARCHAR(255) NOT NULL
	,"synonyms" VARCHAR(255)
	,"pop" INT NOT NULL
	,"area" INT NOT NULL
	,"continent_id" INT
	,"country_id" INT
	,"s" BOOLEAN NOT NULL DEFAULT 'f'
	,"c" BOOLEAN NOT NULL DEFAULT 'f'
	,"d" BOOLEAN NOT NULL DEFAULT 'f'
	,"motor" VARCHAR(255)
	,"iso2" VARCHAR(255)
	,"iso3" VARCHAR(255)
	,"fifa" VARCHAR(255)
	,"net" VARCHAR(255)
	,"wikipedia" VARCHAR(255)
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fkey0" FOREIGN KEY ("continent_id") REFERENCES "continents" ("id")
	);

CREATE UNIQUE INDEX "index_countries_on_code" ON "countries" ("code" ASC);

CREATE UNIQUE INDEX "index_countries_on_key" ON "countries" ("key" ASC);

CREATE TABLE "events" (
	"id" INT NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"league_id" INT NOT NULL
	,"season_id" INT NOT NULL
	,"start_at" DATE NOT NULL
	,"end_at" DATE
	,"team3" BOOLEAN NOT NULL DEFAULT 't'
	,"sources" VARCHAR(255)
	,"config" VARCHAR(255)
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_events_leagues_1" FOREIGN KEY ("league_id") REFERENCES "leagues" ("id")
	,CONSTRAINT "fk_events_seasons_1" FOREIGN KEY ("season_id") REFERENCES "seasons" ("id")
	);

CREATE UNIQUE INDEX "index_events_on_key" ON "events" ("key" ASC);

CREATE TABLE "events_grounds" (
	"id" INT NOT NULL
	,"event_id" INT NOT NULL
	,"ground_id" INT NOT NULL
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_events_grounds_events_1" FOREIGN KEY ("event_id") REFERENCES "events" ("id")
	,CONSTRAINT "fk_events_grounds_grounds_1" FOREIGN KEY ("ground_id") REFERENCES "grounds" ("id")
	);

CREATE INDEX "index_events_grounds_on_event_id" ON "events_grounds" ("event_id" ASC);

CREATE UNIQUE INDEX "index_events_grounds_on_event_id_and_ground_id" ON "events_grounds" (
	"event_id" ASC
	,"ground_id" ASC
	);

CREATE TABLE "events_teams" (
	"id" INT NOT NULL
	,"event_id" INT NOT NULL
	,"team_id" INT NOT NULL
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_events_teams_events_1" FOREIGN KEY ("event_id") REFERENCES "events" ("id")
	,CONSTRAINT "fk_events_teams_teams_1" FOREIGN KEY ("team_id") REFERENCES "teams" ("id")
	);

CREATE INDEX "index_events_teams_on_event_id" ON "events_teams" ("event_id" ASC);

CREATE UNIQUE INDEX "index_events_teams_on_event_id_and_team_id" ON "events_teams" (
	"event_id" ASC
	,"team_id" ASC
	);

CREATE TABLE "games" (
	"id" INT NOT NULL
	,"key" VARCHAR(255)
	,"round_id" INT NOT NULL
	,"pos" INT NOT NULL
	,"group_id" INT
	,"team1_id" INT NOT NULL
	,"team2_id" INT NOT NULL
	,"play_at" DATETIME NOT NULL
	,"postponed" BOOLEAN NOT NULL DEFAULT 'f'
	,"play_at_v2" DATETIME
	,"play_at_v3" DATETIME
	,"ground_id" INT
	,"city_id" INT
	,"knockout" BOOLEAN NOT NULL DEFAULT 'f'
	,"home" BOOLEAN NOT NULL DEFAULT 't'
	,"score1" INT
	,"score2" INT
	,"score1et" INT
	,"score2et" INT
	,"score1p" INT
	,"score2p" INT
	,"score1i" INT
	,"score2i" INT
	,"score1ii" INT
	,"score2ii" INT
	,"next_game_id" INT
	,"prev_game_id" INT
	,"winner" INT
	,"winner90" INT
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_games_rounds_1" FOREIGN KEY ("round_id") REFERENCES "rounds" ("id")
	,CONSTRAINT "fk_games_groups_1" FOREIGN KEY ("group_id") REFERENCES "groups" ("id")
	,CONSTRAINT "fkey2" FOREIGN KEY ("team1_id") REFERENCES "teams" ("id")
	,CONSTRAINT "fkey3" FOREIGN KEY ("team2_id") REFERENCES "teams" ("id")
	,CONSTRAINT "fkey4" FOREIGN KEY ("ground_id") REFERENCES "grounds" ("id")
	,CONSTRAINT "fkey6" FOREIGN KEY ("next_game_id") REFERENCES "games" ("id")
	,CONSTRAINT "fkey7" FOREIGN KEY ("prev_game_id") REFERENCES "games" ("id")
	);

CREATE INDEX "index_games_on_group_id" ON "games" ("group_id" ASC);

CREATE UNIQUE INDEX "index_games_on_key" ON "games" ("key" ASC);

CREATE INDEX "index_games_on_next_game_id" ON "games" ("next_game_id" ASC);

CREATE INDEX "index_games_on_prev_game_id" ON "games" ("prev_game_id" ASC);

CREATE INDEX "index_games_on_round_id" ON "games" ("round_id" ASC);

CREATE TABLE "goals" (
	"id" INT NOT NULL
	,"person_id" INT NOT NULL
	,"game_id" INT NOT NULL
	,"minute" INT
	,"offset" INT
	,"score1" INT
	,"score2" INT
	,"penalty" BOOLEAN NOT NULL DEFAULT 'f'
	,"owngoal" BOOLEAN NOT NULL DEFAULT 'f'
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_goals_persons_1" FOREIGN KEY ("person_id") REFERENCES "persons" ("id")
	,CONSTRAINT "fk_goals_games_1" FOREIGN KEY ("game_id") REFERENCES "games" ("id")
	);

CREATE TABLE "grounds" (
	"id" INT NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"synonyms" VARCHAR(255)
	,"country_id" INT NOT NULL
	,"city_id" INT
	,"since" INT
	,"capacity" INT
	,"address" VARCHAR(255)
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_grounds_cities_1" FOREIGN KEY ("city_id") REFERENCES "cities" ("id")
	);

CREATE UNIQUE INDEX "index_grounds_on_key" ON "grounds" ("key" ASC);

CREATE TABLE "groups" (
	"id" INT NOT NULL
	,"event_id" INT NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"pos" INT NOT NULL
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_groups_events_1" FOREIGN KEY ("event_id") REFERENCES "events" ("id")
	);

CREATE INDEX "index_groups_on_event_id" ON "groups" ("event_id" ASC);

CREATE TABLE "groups_teams" (
	"id" INT NOT NULL
	,"group_id" INT NOT NULL
	,"team_id" INT NOT NULL
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_groups_teams_groups_1" FOREIGN KEY ("group_id") REFERENCES "groups" ("id")
	,CONSTRAINT "fk_groups_teams_teams_1" FOREIGN KEY ("team_id") REFERENCES "teams" ("id")
	);

CREATE INDEX "index_groups_teams_on_group_id" ON "groups_teams" ("group_id" ASC);

CREATE UNIQUE INDEX "index_groups_teams_on_group_id_and_team_id" ON "groups_teams" (
	"group_id" ASC
	,"team_id" ASC
	);

CREATE TABLE "langs" (
	"id" INT NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	);

CREATE TABLE "leagues" (
	"id" INT NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"country_id" INT
	,"club" BOOLEAN NOT NULL DEFAULT 'f'
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	);

CREATE TABLE "logs" (
	"id" INT NOT NULL
	,"msg" VARCHAR(255) NOT NULL
	,"level" VARCHAR(255) NOT NULL
	,"app" VARCHAR(255)
	,"tag" VARCHAR(255)
	,"pid" INT
	,"tid" INT
	,"ts" VARCHAR(255)
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	);

CREATE TABLE "persons" (
	"id" INT NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"name" VARCHAR(255) NOT NULL
	,"synonyms" VARCHAR(255)
	,"code" VARCHAR(255)
	,"born_at" DATE
	,"city_id" INT
	,"region_id" INT
	,"country_id" INT NOT NULL
	,"nationality_id" INT NOT NULL
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	);

CREATE TABLE "props" (
	"id" INT NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"value" VARCHAR(255) NOT NULL
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	);

CREATE TABLE "regions" (
	"id" INT NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"code" VARCHAR(255)
	,"abbr" VARCHAR(255)
	,"iso" VARCHAR(255)
	,"nuts" VARCHAR(255)
	,"synonyms" VARCHAR(255)
	,"country_id" INT NOT NULL
	,"pop" INT
	,"area" INT
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_regions_countries_1" FOREIGN KEY ("country_id") REFERENCES "countries" ("id")
	);

CREATE UNIQUE INDEX "index_regions_on_key_and_country_id" ON "regions" (
	"key" ASC
	,"country_id" ASC
	);

CREATE TABLE "rosters" (
	"id" INT NOT NULL
	,"person_id" INT NOT NULL
	,"team_id" INT NOT NULL
	,"event_id" INT
	,"pos" INT NOT NULL
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_rosters_persons_1" FOREIGN KEY ("person_id") REFERENCES "persons" ("id")
	,CONSTRAINT "fk_rosters_teams_1" FOREIGN KEY ("team_id") REFERENCES "teams" ("id")
	,CONSTRAINT "fk_rosters_events_1" FOREIGN KEY ("event_id") REFERENCES "events" ("id")
	);

CREATE TABLE "rounds" (
	"id" INT NOT NULL
	,"event_id" INT NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"title2" VARCHAR(255)
	,"pos" INT NOT NULL
	,"knockout" BOOLEAN NOT NULL DEFAULT 'f'
	,"start_at" DATE NOT NULL
	,"end_at" DATE
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	,CONSTRAINT "fk_rounds_events_1" FOREIGN KEY ("event_id") REFERENCES "events" ("id")
	);

CREATE INDEX "index_rounds_on_event_id" ON "rounds" ("event_id" ASC);

CREATE TABLE "seasons" (
	"id" INT NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	);

CREATE TABLE "teams" (
	"id" INT NOT NULL
	,"key" VARCHAR(255) NOT NULL
	,"title" VARCHAR(255) NOT NULL
	,"title2" VARCHAR(255)
	,"code" VARCHAR(255)
	,"synonyms" VARCHAR(255)
	,"country_id" INT NOT NULL
	,"city_id" INT
	,"club" BOOLEAN NOT NULL DEFAULT 'f'
	,"since" INT
	,"address" VARCHAR(255)
	,"web" VARCHAR(255)
	,"national" BOOLEAN NOT NULL DEFAULT 'f'
	,"created_at" DATETIME NOT NULL
	,"updated_at" DATETIME NOT NULL
	,PRIMARY KEY ("id")
	);

CREATE UNIQUE INDEX "index_teams_on_key" ON "teams" ("key" ASC);