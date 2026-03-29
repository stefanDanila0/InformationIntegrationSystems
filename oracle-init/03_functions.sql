-- ============================================================
-- Oracle Helper Function: get_rest_clob
-- Run as: SYSTEM @ XEPDB1
--
-- Makes an HTTP GET request and returns the response body
-- as a CLOB. Automatically injects Basic Auth headers when
-- the URL targets RestHeart.
-- ============================================================

CREATE OR REPLACE FUNCTION get_rest_clob(p_url IN VARCHAR2) RETURN CLOB IS
    req  UTL_HTTP.REQ;
    resp UTL_HTTP.RESP;
    val  VARCHAR2(32767);
    res  CLOB;
BEGIN
    DBMS_LOB.createtemporary(res, FALSE);
    req := UTL_HTTP.BEGIN_REQUEST(p_url, 'GET', 'HTTP/1.1');

    -- RestHeart requires Basic Auth
    IF INSTR(p_url, 'restheart-api') > 0 THEN
        UTL_HTTP.SET_HEADER(
            req, 'Authorization',
            'Basic ' || UTL_RAW.CAST_TO_VARCHAR2(
                UTL_ENCODE.BASE64_ENCODE(
                    UTL_RAW.CAST_TO_RAW('admin:secret')
                )
            )
        );
    END IF;

    resp := UTL_HTTP.GET_RESPONSE(req);
    BEGIN
        LOOP
            UTL_HTTP.READ_TEXT(resp, val);
            DBMS_LOB.writeappend(res, LENGTH(val), val);
        END LOOP;
    EXCEPTION
        WHEN UTL_HTTP.END_OF_BODY THEN
            UTL_HTTP.END_RESPONSE(resp);
    END;
    RETURN res;
END;
/

EXIT;
