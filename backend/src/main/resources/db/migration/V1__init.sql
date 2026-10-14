create table clubs(
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(100) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

create table events(
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id uuid NOT NULL REFERENCES clubs (id),
    code varchar(8) NOT NULL ,
    title varchar(100) NOT NULL,
    status varchar(16) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status in ('ACTIVE', 'ENDED')),
    starts_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_events_code UNIQUE (code)
);

create index idx_events_club ON events (club_id);

create table guest_sessions(
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id uuid NOT NULL REFERENCES events (id),
    token uuid NOT NULL,
    nickname varchar(50) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_sessions_token UNIQUE (token)
);

create index idx_sessions_event ON guest_sessions (event_id);

create table content_items(
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id uuid NOT NULL REFERENCES events (id),
    author_id uuid NOT NULL REFERENCES guest_sessions (id),
    type VARCHAR(20) not null CHECK (type IN ('WISH', 'PHOTO')),
    body TEXT,
    status varchar(16) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'SHOWN')),
    created_at timestamptz NOT NULL DEFAULT now(),
    CHECK (type <> 'WISH' OR body IS NOT NULL)
);

create index idx_items_event_status ON content_items (event_id, status);