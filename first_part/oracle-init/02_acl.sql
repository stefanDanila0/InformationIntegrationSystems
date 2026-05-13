-- ============================================================
-- Oracle Network ACL Configuration
-- Run as: SYS @ XE (CDB root) AS SYSDBA
--
-- IMPORTANT: ACLs must be created at CDB root level, not
-- inside the PDB, for UTL_HTTP outbound access to work.
-- ============================================================

BEGIN
    BEGIN
        DBMS_NETWORK_ACL_ADMIN.DROP_ACL('fdb_rest_access.xml');
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(
        acl         => 'fdb_rest_access.xml',
        description => 'FDB REST API outbound access',
        principal   => 'SYSTEM',
        is_grant    => TRUE,
        privilege   => 'connect'
    );

    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
        acl         => 'fdb_rest_access.xml',
        principal   => 'SYSTEM',
        is_grant    => TRUE,
        privilege   => 'resolve'
    );

    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(
        acl  => 'fdb_rest_access.xml',
        host => '*'
    );

    COMMIT;
END;
/

EXIT;
