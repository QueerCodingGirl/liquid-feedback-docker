-- 
-- Insert default db values into liquid feedback
--

INSERT INTO system_setting (member_ttl) VALUES ('1 year');

INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (false, '1 hour', 20, 6);
INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (false, '1 day', 80, 12);
INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (true, '1 hour', 200, 60);
INSERT INTO contingent (polling, time_frame, text_entry_limit, initiative_limit) VALUES (true, '1 day', 800, 120);

INSERT INTO "policy" (
        "index",
        "active",
        "name",
        "description",
        "min_admission_time",
        "max_admission_time",
        "discussion_time",
        "verification_time",
        "voting_time",
        "issue_quorum",
        "issue_quorum_num",
        "issue_quorum_den",
        "initiative_quorum",
        "initiative_quorum_num",
        "initiative_quorum_den"
    ) VALUES (
        1,
        TRUE,
        'Extensive proceeding',
        DEFAULT,
        '15 days',
        '1 month',
        '5 months',
        '1 month',
        '3 weeks',
        1, 10, 100,
        1, 10, 100
    ), (
        2,
        TRUE,
        'Standard proceeding',
        DEFAULT,
        '15 days',
        '1 month',
        '1 month',
        '1 week',
        '1 week',
        1, 10, 100,
        1, 10, 100
    ), (
       3,
       TRUE,
       'Fast proceeding',
       DEFAULT,
       '20 hours',
       '48 hours',
       '3 hours',
       '1 hour',
       '20 hours',
        1, 1, 100,
        1, 1, 100 );
    
INSERT INTO "privilege" ("unit_id", "member_id", "voting_right")
  SELECT 1 AS "unit_id", "id" AS "member_id", TRUE AS "voting_right"
  FROM "member";

INSERT INTO unit (name) VALUES ('Our organization');

INSERT INTO area (unit_id, name) VALUES (1, 'Default area');

INSERT INTO allowed_policy (area_id, policy_id, default_policy) VALUES (1, 1, TRUE);

-- Admin user with invite sesam
INSERT INTO member (invite_code, admin) VALUES ('sesam', true);
