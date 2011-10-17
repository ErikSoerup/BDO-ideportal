--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- Name: array_agg(anyelement); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE array_agg(anyelement) (
    SFUNC = array_append,
    STYPE = anyarray,
    INITCOND = '{}'
);


--
-- Name: default; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION "default" (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION "default"
    ADD MAPPING FOR uint WITH simple;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin_comments (
    id integer NOT NULL,
    idea_id integer,
    author_id integer,
    text text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_comments_id_seq OWNED BY admin_comments.id;


--
-- Name: admin_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin_tags (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: admin_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: admin_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_tags_id_seq OWNED BY admin_tags.id;


--
-- Name: client_applications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE client_applications (
    id integer NOT NULL,
    name character varying(255),
    url character varying(255),
    support_url character varying(255),
    callback_url character varying(255),
    key character varying(20),
    secret character varying(40),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: client_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE client_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: client_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE client_applications_id_seq OWNED BY client_applications.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    idea_id integer,
    author_id integer,
    text text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    inappropriate_flags integer DEFAULT 0,
    hidden boolean DEFAULT false,
    ip character varying(64),
    user_agent character varying(255),
    marked_spam boolean DEFAULT false
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: currents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE currents (
    id integer NOT NULL,
    title character varying(255),
    description text,
    inventor_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    vectors tsvector,
    closed boolean DEFAULT false,
    invitation_only boolean DEFAULT false,
    submission_deadline date
);


--
-- Name: currents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE currents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: currents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE currents_id_seq OWNED BY currents.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: ideas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ideas (
    id integer NOT NULL,
    title text,
    description text,
    rating numeric(10,2) DEFAULT 0,
    inventor_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    flagged boolean,
    viewed boolean DEFAULT false,
    inappropriate_flags integer DEFAULT 0,
    hidden boolean DEFAULT false,
    decayed_at timestamp without time zone,
    life_cycle_step_id integer,
    status character varying(20) DEFAULT 'new'::character varying NOT NULL,
    duplicate_of_id integer,
    marked_spam boolean DEFAULT false,
    current_id integer DEFAULT (-1),
    vote_count integer,
    ip character varying(64),
    user_agent character varying(255)
);


--
-- Name: ideas_admin_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ideas_admin_tags (
    idea_id integer,
    admin_tag_id integer
);


--
-- Name: ideas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ideas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: ideas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ideas_id_seq OWNED BY ideas.id;


--
-- Name: ideas_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ideas_tags (
    idea_id integer,
    tag_id integer
);


--
-- Name: life_cycle_steps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE life_cycle_steps (
    id integer NOT NULL,
    life_cycle_id integer,
    "position" integer,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: life_cycle_steps_admins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE life_cycle_steps_admins (
    user_id integer,
    life_cycle_step_id integer
);


--
-- Name: life_cycle_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE life_cycle_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: life_cycle_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE life_cycle_steps_id_seq OWNED BY life_cycle_steps.id;


--
-- Name: life_cycles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE life_cycles (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: life_cycles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE life_cycles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: life_cycles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE life_cycles_id_seq OWNED BY life_cycles.id;


--
-- Name: oauth_nonces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_nonces (
    id integer NOT NULL,
    nonce character varying(255),
    "timestamp" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: oauth_nonces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_nonces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: oauth_nonces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_nonces_id_seq OWNED BY oauth_nonces.id;


--
-- Name: oauth_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_tokens (
    id integer NOT NULL,
    user_id integer,
    type character varying(20),
    client_application_id integer,
    token character varying(20),
    secret character varying(40),
    callback_url character varying(255),
    verifier character varying(20),
    authorized_at timestamp without time zone,
    invalidated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: oauth_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: oauth_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_tokens_id_seq OWNED BY oauth_tokens.id;


--
-- Name: postal_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE postal_codes (
    id integer NOT NULL,
    code character varying(255),
    lat double precision,
    lon double precision
);


--
-- Name: postal_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE postal_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: postal_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE postal_codes_id_seq OWNED BY postal_codes.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(40),
    authorizable_type character varying(40),
    authorizable_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: roles_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles_users (
    user_id integer,
    role_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    crypted_password character varying(40),
    salt character varying(40),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    remember_token character varying(255),
    remember_token_expires_at timestamp without time zone,
    activation_code character varying(40),
    activated_at timestamp without time zone,
    state character varying(255) DEFAULT 'passive'::character varying,
    deleted_at timestamp without time zone,
    zip_code character varying(255),
    contribution_points double precision DEFAULT 0,
    decayed_at timestamp without time zone,
    moderator boolean,
    postal_code_id integer,
    twitter_handle character varying(255),
    tweet_ideas boolean,
    twitter_token character varying(255),
    twitter_secret character varying(255),
    facebook_uid character varying(255),
    notify_on_comments boolean DEFAULT false NOT NULL,
    notify_on_state boolean DEFAULT false NOT NULL,
    vectors tsvector,
    facebook_access_token character varying(255),
    facebook_post_ideas boolean,
    facebook_name character varying(255),
    recent_contribution_points double precision
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    idea_id integer,
    user_id integer,
    counted boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE admin_comments ALTER COLUMN id SET DEFAULT nextval('admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE admin_tags ALTER COLUMN id SET DEFAULT nextval('admin_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE client_applications ALTER COLUMN id SET DEFAULT nextval('client_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE currents ALTER COLUMN id SET DEFAULT nextval('currents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ideas ALTER COLUMN id SET DEFAULT nextval('ideas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE life_cycle_steps ALTER COLUMN id SET DEFAULT nextval('life_cycle_steps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE life_cycles ALTER COLUMN id SET DEFAULT nextval('life_cycles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE oauth_nonces ALTER COLUMN id SET DEFAULT nextval('oauth_nonces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE oauth_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE postal_codes ALTER COLUMN id SET DEFAULT nextval('postal_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


--
-- Name: admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_comments
    ADD CONSTRAINT admin_comments_pkey PRIMARY KEY (id);


--
-- Name: admin_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_tags
    ADD CONSTRAINT admin_tags_pkey PRIMARY KEY (id);


--
-- Name: client_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY client_applications
    ADD CONSTRAINT client_applications_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: currents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY currents
    ADD CONSTRAINT currents_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: ideas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ideas
    ADD CONSTRAINT ideas_pkey PRIMARY KEY (id);


--
-- Name: life_cycle_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY life_cycle_steps
    ADD CONSTRAINT life_cycle_steps_pkey PRIMARY KEY (id);


--
-- Name: life_cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY life_cycles
    ADD CONSTRAINT life_cycles_pkey PRIMARY KEY (id);


--
-- Name: oauth_nonces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_nonces
    ADD CONSTRAINT oauth_nonces_pkey PRIMARY KEY (id);


--
-- Name: oauth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_tokens
    ADD CONSTRAINT oauth_tokens_pkey PRIMARY KEY (id);


--
-- Name: postal_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY postal_codes
    ADD CONSTRAINT postal_codes_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: currents_fts_vectors_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX currents_fts_vectors_index ON currents USING gist (vectors);


--
-- Name: index_client_applications_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_client_applications_on_key ON client_applications USING btree (key);


--
-- Name: index_comments_on_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_author_id ON comments USING btree (author_id);


--
-- Name: index_comments_on_idea_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_idea_id ON comments USING btree (idea_id);


--
-- Name: index_ideas_admin_tags_on_admin_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ideas_admin_tags_on_admin_tag_id ON ideas_admin_tags USING btree (admin_tag_id);


--
-- Name: index_ideas_admin_tags_on_idea_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ideas_admin_tags_on_idea_id ON ideas_admin_tags USING btree (idea_id);


--
-- Name: index_ideas_on_inventor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ideas_on_inventor_id ON ideas USING btree (inventor_id);


--
-- Name: index_ideas_tags_on_idea_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ideas_tags_on_idea_id ON ideas_tags USING btree (idea_id);


--
-- Name: index_ideas_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ideas_tags_on_tag_id ON ideas_tags USING btree (tag_id);


--
-- Name: index_oauth_nonces_on_nonce_and_timestamp; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_nonces_on_nonce_and_timestamp ON oauth_nonces USING btree (nonce, "timestamp");


--
-- Name: index_oauth_tokens_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_tokens_on_token ON oauth_tokens USING btree (token);


--
-- Name: index_postal_codes_on_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_postal_codes_on_code ON postal_codes USING btree (code);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_state ON users USING btree (state);


--
-- Name: index_votes_on_user_id_and_idea_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_votes_on_user_id_and_idea_id ON votes USING btree (user_id, idea_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: users_fts_vectors_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX users_fts_vectors_index ON users USING gist (vectors);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20081006202540');

INSERT INTO schema_migrations (version) VALUES ('20081007172334');

INSERT INTO schema_migrations (version) VALUES ('20081007204253');

INSERT INTO schema_migrations (version) VALUES ('20081007223732');

INSERT INTO schema_migrations (version) VALUES ('20081007223913');

INSERT INTO schema_migrations (version) VALUES ('20081010191847');

INSERT INTO schema_migrations (version) VALUES ('20081017160245');

INSERT INTO schema_migrations (version) VALUES ('20081017215853');

INSERT INTO schema_migrations (version) VALUES ('20081021212114');

INSERT INTO schema_migrations (version) VALUES ('20081023210821');

INSERT INTO schema_migrations (version) VALUES ('20081028000846');

INSERT INTO schema_migrations (version) VALUES ('20081028163902');

INSERT INTO schema_migrations (version) VALUES ('20081029154833');

INSERT INTO schema_migrations (version) VALUES ('20081103173415');

INSERT INTO schema_migrations (version) VALUES ('20081103223053');

INSERT INTO schema_migrations (version) VALUES ('20081107172559');

INSERT INTO schema_migrations (version) VALUES ('20081111213749');

INSERT INTO schema_migrations (version) VALUES ('20081113202714');

INSERT INTO schema_migrations (version) VALUES ('20081120173545');

INSERT INTO schema_migrations (version) VALUES ('20081121223135');

INSERT INTO schema_migrations (version) VALUES ('20081126063009');

INSERT INTO schema_migrations (version) VALUES ('20090408144014');

INSERT INTO schema_migrations (version) VALUES ('20090709014856');

INSERT INTO schema_migrations (version) VALUES ('20090909191345');

INSERT INTO schema_migrations (version) VALUES ('20090909191811');

INSERT INTO schema_migrations (version) VALUES ('20090909200409');

INSERT INTO schema_migrations (version) VALUES ('20090916205550');

INSERT INTO schema_migrations (version) VALUES ('20090918185712');

INSERT INTO schema_migrations (version) VALUES ('20090923203134');

INSERT INTO schema_migrations (version) VALUES ('20090930191658');

INSERT INTO schema_migrations (version) VALUES ('20091001211738');

INSERT INTO schema_migrations (version) VALUES ('20091002025857');

INSERT INTO schema_migrations (version) VALUES ('20091002180642');

INSERT INTO schema_migrations (version) VALUES ('20091002204539');

INSERT INTO schema_migrations (version) VALUES ('20091008034759');

INSERT INTO schema_migrations (version) VALUES ('20091014181527');

INSERT INTO schema_migrations (version) VALUES ('20091014192351');

INSERT INTO schema_migrations (version) VALUES ('20091014224944');

INSERT INTO schema_migrations (version) VALUES ('20091020234614');

INSERT INTO schema_migrations (version) VALUES ('20091021192227');

INSERT INTO schema_migrations (version) VALUES ('20091021204720');

INSERT INTO schema_migrations (version) VALUES ('20091021215842');

INSERT INTO schema_migrations (version) VALUES ('20091023215528');

INSERT INTO schema_migrations (version) VALUES ('20091105004852');

INSERT INTO schema_migrations (version) VALUES ('20091105193251');

INSERT INTO schema_migrations (version) VALUES ('20100120214436');

INSERT INTO schema_migrations (version) VALUES ('20101021230149');

INSERT INTO schema_migrations (version) VALUES ('20101025152803');

INSERT INTO schema_migrations (version) VALUES ('20101029190525');

INSERT INTO schema_migrations (version) VALUES ('20101029215024');

INSERT INTO schema_migrations (version) VALUES ('20101101215458');

INSERT INTO schema_migrations (version) VALUES ('20101104160151');

INSERT INTO schema_migrations (version) VALUES ('20101105195504');

INSERT INTO schema_migrations (version) VALUES ('20101105203141');

INSERT INTO schema_migrations (version) VALUES ('20101109221707');

INSERT INTO schema_migrations (version) VALUES ('20101116192641');

INSERT INTO schema_migrations (version) VALUES ('20101208205302');