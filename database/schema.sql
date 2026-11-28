-- ==========================================================
-- N.O.H. CloudMesh — schéma PostgreSQL : module des demandes
-- Fichier : database/schema.sql
-- Propriétaire : Habiba (database/) — à relire avant fusion
-- ==========================================================

-- ----------------------------------------------------------
-- users : table minimale nécessaire aux clés étrangères.
-- Le module d'authentification (Abdourahim) la fait évoluer.
-- Si elle existe déjà, IF NOT EXISTS la laisse intacte :
-- vérifier que ses colonnes correspondent à celles ci-dessous.
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id            SERIAL PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(20)  NOT NULL CHECK (role IN ('STUDENT', 'AGENT')),
    service       VARCHAR(50),
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------
-- request_types : catalogue des demandes, géré par l'administration.
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS request_types (
    code       VARCHAR(50)  PRIMARY KEY,
    label      VARCHAR(120) NOT NULL,
    service    VARCHAR(50)  NOT NULL,
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE
);

-- ----------------------------------------------------------
-- requests : une demande soumise par un étudiant.
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS requests (
    id           SERIAL PRIMARY KEY,
    reference    VARCHAR(20)  UNIQUE,            -- renseignée par le trigger ci-dessous
    student_id   INTEGER      NOT NULL REFERENCES users(id),
    request_type VARCHAR(50)  NOT NULL REFERENCES request_types(code),
    description  TEXT         NOT NULL CHECK (btrim(description) <> ''),
    status       VARCHAR(20)  NOT NULL DEFAULT 'SUBMITTED'
                 CHECK (status IN ('SUBMITTED', 'IN_REVIEW', 'NEEDS_INFO', 'APPROVED', 'REJECTED')),
    service      VARCHAR(50)  NOT NULL,          -- copié depuis request_types à la création
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_requests_student       ON requests (student_id);
CREATE INDEX IF NOT EXISTS idx_requests_service_status ON requests (service, status);

-- Référence lisible, calculée à partir de l'id au moment de l'insertion.
-- Exemple : DEM-2026-000042
CREATE OR REPLACE FUNCTION set_request_reference() RETURNS TRIGGER AS $$
BEGIN
    NEW.reference := 'DEM-' || to_char(now(), 'YYYY') || '-' || lpad(NEW.id::text, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_requests_reference ON requests;
CREATE TRIGGER trg_requests_reference
    BEFORE INSERT ON requests
    FOR EACH ROW EXECUTE FUNCTION set_request_reference();

-- ----------------------------------------------------------
-- request_history : journal des changements de statut.
-- Une ligne par changement, jamais modifiée ni supprimée par l'application.
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS request_history (
    id          SERIAL PRIMARY KEY,
    request_id  INTEGER     NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
    from_status VARCHAR(20) CHECK (from_status IN ('SUBMITTED', 'IN_REVIEW', 'NEEDS_INFO', 'APPROVED', 'REJECTED')),
    to_status   VARCHAR(20) NOT NULL
                CHECK (to_status IN ('SUBMITTED', 'IN_REVIEW', 'NEEDS_INFO', 'APPROVED', 'REJECTED')),
    actor_id    INTEGER     NOT NULL REFERENCES users(id),
    comment     TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- Défense en profondeur : le commentaire est aussi exigé par la base.
    CONSTRAINT chk_comment_required CHECK (
        to_status NOT IN ('NEEDS_INFO', 'REJECTED')
        OR (comment IS NOT NULL AND btrim(comment) <> '')
    )
);

CREATE INDEX IF NOT EXISTS idx_history_request ON request_history (request_id, created_at);