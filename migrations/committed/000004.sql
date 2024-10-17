--! Previous: sha1:04fbd9b251f7a3d274ef7f6014e0cafebbf74cec
--! Hash: sha1:bc62df145480bcf6395559dcc60d95fe473cff01

DROP FUNCTION IF EXISTS notify_changes () CASCADE;

CREATE
OR REPLACE FUNCTION notify_changes_text_target () RETURNS TRIGGER AS $$
DECLARE
  v_process_new bool = (TG_OP = 'INSERT' OR TG_OP = 'UPDATE');
  v_process_old bool = (TG_OP = 'UPDATE' OR TG_OP = 'DELETE');
  v_event text = TG_ARGV[0];
  v_topic_template text = TG_ARGV[1];
  v_attribute text = TG_ARGV[2];
  v_id text = TG_ARGV[3];
  v_record record;
  v_sub text;
  v_target text;
  v_topic text;
  v_i int = 0;
  v_last_topic text;
BEGIN
  -- On UPDATE sometimes topic may be changed for NEW record,
  -- so we need notify to both topics NEW and OLD.
  FOR v_i in 0..1 LOOP
    IF (v_i = 0) AND v_process_new IS TRUE THEN
      v_record = NEW;
    ELSIF (v_i = 1) AND v_process_old IS TRUE THEN
      v_record = OLD;
    ELSE
      CONTINUE;
    END IF;
    IF v_attribute IS NOT NULL THEN
      EXECUTE 'select $1.' || quote_ident(v_attribute) || ', $1.' || quote_ident(v_id)
        USING v_record
        INTO v_sub, v_target;
    END IF;
    IF v_sub IS NOT NULL THEN
      v_topic = replace(v_topic_template, '$1', v_sub);
    ELSE
      v_topic = v_topic_template;
    END IF;
    IF v_topic IS DISTINCT FROM v_last_topic THEN
      -- This if statement prevents us from triggering the notification twice for the same row
      v_last_topic = v_topic;
      PERFORM pg_notify(v_topic, json_build_object(
        'event', v_event,
        'subject', v_sub,
        'target', v_target
      )::text);
    END IF;
  END LOOP;
  RETURN v_record;
end;
$$ LANGUAGE PLPGSQL VOLATILE;

CREATE
OR REPLACE FUNCTION notify_changes_int_target () RETURNS TRIGGER AS $$
DECLARE
  v_process_new bool = (TG_OP = 'INSERT' OR TG_OP = 'UPDATE');
  v_process_old bool = (TG_OP = 'UPDATE' OR TG_OP = 'DELETE');
  v_event text = TG_ARGV[0];
  v_topic_template text = TG_ARGV[1];
  v_attribute text = TG_ARGV[2];
  v_id text = TG_ARGV[3];
  v_record record;
  v_sub text;
  v_target bigint;
  v_topic text;
  v_i int = 0;
  v_last_topic text;
BEGIN
  -- On UPDATE sometimes topic may be changed for NEW record,
  -- so we need notify to both topics NEW and OLD.
  FOR v_i in 0..1 LOOP
    IF (v_i = 0) AND v_process_new IS TRUE THEN
      v_record = NEW;
    ELSIF (v_i = 1) AND v_process_old IS TRUE THEN
      v_record = OLD;
    ELSE
      CONTINUE;
    END IF;
    IF v_attribute IS NOT NULL THEN
      EXECUTE 'select $1.' || quote_ident(v_attribute) || ', $1.' || quote_ident(v_id)
        USING v_record
        INTO v_sub, v_target;
    END IF;
    IF v_sub IS NOT NULL THEN
      v_topic = replace(v_topic_template, '$1', v_sub);
    ELSE
      v_topic = v_topic_template;
    END IF;
    IF v_topic IS DISTINCT FROM v_last_topic THEN
      -- This if statement prevents us from triggering the notification twice for the same row
      v_last_topic = v_topic;
      PERFORM pg_notify(v_topic, json_build_object(
        'event', v_event,
        'subject', v_sub,
        'target', v_target
      )::text);
    END IF;
  END LOOP;
  RETURN v_record;
end;
$$ LANGUAGE PLPGSQL VOLATILE;

CREATE
OR REPLACE TRIGGER _500_subscription_fields_created
AFTER INSERT ON fields FOR EACH ROW
EXECUTE PROCEDURE notify_changes_int_target ('new_field', 'fields:$1', 'account_id', 'id');

CREATE
OR REPLACE TRIGGER _500_subscription_fields_changed
AFTER
UPDATE ON fields FOR EACH ROW
EXECUTE PROCEDURE notify_changes_int_target ('edit_field', 'fields:$1', 'account_id', 'id');

CREATE
OR REPLACE TRIGGER _500_subscription_card_moved
AFTER INSERT
OR
UPDATE ON field_cards FOR EACH ROW
EXECUTE PROCEDURE notify_changes_int_target (
  'place_card',
  'field_cards:$1',
  'field_id',
  'card_id'
);

CREATE
OR REPLACE TRIGGER _500_subscription_card_removed
AFTER DELETE ON field_cards FOR EACH ROW
EXECUTE PROCEDURE notify_changes_int_target (
  'unplace_card',
  'field_cards:$1',
  'field_id',
  'card_id'
);

CREATE
OR REPLACE TRIGGER _500_subscription_card_transferred
AFTER INSERT
OR
UPDATE
OR DELETE ON card_accounts FOR EACH ROW
EXECUTE PROCEDURE notify_changes_int_target (
  'transfer_card',
  'card_accounts:$1',
  'account_id',
  'card_id'
);
