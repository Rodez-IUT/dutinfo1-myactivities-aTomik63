DROP TRIGGER IF EXISTS log_register on registration;

CREATE OR REPLACE FUNCTION register_user_on_activity(in_user_id bigint, in_activity_id bigint) 
	RETURNS registration AS $$
	DECLARE
		res_registration registration%ROWTYPE;
	BEGIN
		SELECT * INTO res_registration
		FROM registration
		WHERE user_id = in_user_id AND activity_id = in_activity_id;
		IF FOUND THEN 
			RAISE EXCEPTION 'registration_already_exists';
		END IF;
		
		INSERT INTO registration (id, user_id, activity_id)
		VALUES(nextval('id_generator'), in_user_id, in_activity_id);
		
		SELECT * INTO res_registration
		FROM registration
		WHERE user_id = in_user_id AND activity_id = in_activity_id; 
		RETURN res_registration;
	END;
$$ LANGUAGE plpgsql;

DROP FUNCTION unregister_user_on_activity(in_user_id bigint, in_activity_id bigint);
 
CREATE OR REPLACE FUNCTION unregister_user_on_activity(in_user_id bigint, in_activity_id bigint) 
	RETURNS void AS $$
	DECLARE
		res_registration registration%ROWTYPE;
	BEGIN
		SELECT * INTO res_registration
		FROM registration
		WHERE user_id = in_user_id AND activity_id = in_activity_id;
		IF NOT FOUND THEN 
			RAISE EXCEPTION 'registration_not_found';
		END IF;
		
		DELETE FROM registration  
		WHERE user_id = in_user_id AND activity_id = in_activity_id;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION log_register() RETURNS trigger AS $$
	BEGIN
		INSERT INTO action_log (id, action_name, entity_name, entity_id, author, action_date)
		VALUES (nextval('id_generator'),'insert','registration', NEW.id, user, now());
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_register
	AFTER INSERT ON registration
	FOR EACH ROW
	EXECUTE PROCEDURE log_register();
	
CREATE OR REPLACE FUNCTION log_unregister() RETURNS trigger AS $$
	BEGIN
		INSERT INTO action_log (id, action_name, entity_name, entity_id, author, action_date)
		VALUES (nextval('id_generator'),'delete','registration', OLD.id, user, now());
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_unregister
	AFTER DELETE ON registration
	FOR EACH ROW
	EXECUTE PROCEDURE log_unregister();