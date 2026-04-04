-- Flyway Migration: Seed default communes/quartiers for the Flutter app
-- Version: 4
-- Created: 2026-04-03

-- The frontend expects quartiers to exist; otherwise it may fall back to a local list
-- whose IDs won't match the backend database.

INSERT INTO communes (name, prefecture)
VALUES ('Golfe 6', 'Golfe')
ON CONFLICT (name) DO NOTHING;

DO $$
DECLARE
    golfe6_id BIGINT;
BEGIN
    SELECT id INTO golfe6_id FROM communes WHERE name = 'Golfe 6' LIMIT 1;
    IF golfe6_id IS NULL THEN
        RETURN;
    END IF;

    WITH q(name) AS (
        SELECT unnest(ARRAY[
            'Baguida',
            'Kpogan',
            'Bè-Est',
            'Tokoin Wuiti',
            'Tokoin Tamé',
            'Tokoin Enyonam',
            'Hédzranawoé (1 et 2)',
            'Tokoin Aviation',
            'Kégué',
            'Atiégouvi',
            'Tokoin Elavagnon',
            'Gbonvié',
            'Doumasséssé (Adewi)',
            'Cité OUA',
            'Lomé II',
            'Kélégouvi',
            'Hanoukopé',
            'Dékon',
            'Bassadji',
            'N''tifafa-komé',
            'Aguiakomé',
            'Assivito',
            'Kodjoviakopé',
            'Adidogomé',
            'Sagbado',
            'Togblekopé',
            'Agoè-nyivé',
            'Agbalépédogan',
            'Attikoumè',
            'Avédji',
            'Sanguéra',
            'Klikamé',
            'Kohé',
            'Togblékopé',
            'Zossimé',
            'Dékpor',
            'Afiadényigban',
            'Adétikopé',
            'Vakpossito',
            'Légbassito'
        ])
    )
    INSERT INTO quartiers (name, commune_id)
    SELECT q.name, golfe6_id
    FROM q
    WHERE NOT EXISTS (
        SELECT 1
        FROM quartiers existing
        WHERE existing.name = q.name
          AND existing.commune_id = golfe6_id
    );
END $$;

