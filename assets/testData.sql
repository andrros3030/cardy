INSERT INTO T_ACCOUNT(PK_ID, PV_EMAIL, PV_PSWD, PT_REG, IV_USER, IT_CHANGE) VALUES('GUID0', 'A@A.COM', 'HASHPSWD', '20200520', 'ANDRROS3030', '20200520');
INSERT INTO T_ACCOUNT(PK_ID, PV_EMAIL, PV_PSWD, PT_REG, IV_USER, IT_CHANGE) VALUES('GUID1', 'B@B.COM', 'HASHPSWD', '20200520', 'ANDRROS3030', '20200520');
INSERT INTO T_ACCOUNT(PK_ID, PV_EMAIL, PV_PSWD, PT_REG, IV_USER, IT_CHANGE) VALUES('GUID2', 'C@C.COM', 'HASHPSWD', '20200520', 'ANDRROS3030', '20200520');

INSERT INTO T_CARD(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CARD0', 'PYATEROCHKA', 'ANDRROS3030', '20200520');
INSERT INTO T_CARD(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CARD1', 'OBI', 'ANDRROS3030', '20200520');
INSERT INTO T_CARD(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CARD2', 'PEREKRESTOK', 'ANDRROS3030', '20200520');
INSERT INTO T_CARD(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CARD3', 'sportclub', 'ANDRROS3030', '20200520');
INSERT INTO T_CARD(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CARD4', 'parking', 'ANDRROS3030', '20200520');

INSERT INTO T_CATEGORY(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CATEGORY0', 'SHOPPING', 'ANDRROS3030', '20200520');
INSERT INTO T_CATEGORY(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CATEGORY1', 'PASSES', 'ANDRROS3030', '20200520');

INSERT INTO T_LINK(PK_ID, FK_CATEGORY, FK_CARD, IV_USER, IT_CHANGE) VALUES('LINK0', 'CATEGORY0', 'CARD0', 'ANDRROS3030', '20200520');
INSERT INTO T_LINK(PK_ID, FK_CATEGORY, FK_CARD, IV_USER, IT_CHANGE) VALUES('LINK1', 'CATEGORY0', 'CARD2', 'ANDRROS3030', '20200520');
INSERT INTO T_LINK(PK_ID, FK_CATEGORY, FK_CARD, IV_USER, IT_CHANGE) VALUES('LINK2', 'CATEGORY1', 'CARD3', 'ANDRROS3030', '20200520');

INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG0', 'GUID0', 'CARD0', 'ANDRROS3030', '20200520');
INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG1', 'GUID0', 'CARD1', 'ANDRROS3030', '20200520');
INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG2', 'GUID0', 'CARD2', 'ANDRROS3030', '20200520');
INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG3', 'GUID1', 'CARD1', 'ANDRROS3030', '20200520');
INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG4', 'GUID1', 'CARD2', 'ANDRROS3030', '20200520');
INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG5', 'GUID1', 'CARD3', 'ANDRROS3030', '20200520');
INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG6', 'GUID2', 'CARD4', 'ANDRROS3030', '20200520');


/*SELECT
    acc.PK_ID as accID,
    access.pi_priority as privilageLVL,
    ctg.PK_ID as ctgID,
    ctg.PV_NAME as ctgName,
    ctg.PI_ORDER as ctgORDER,
    lnk.PK_ID as lnkID,
    crd.PK_ID as CAD,
    crd.PV_NAME as CNAME,
    crd.PI_ORDER as CORDER
    from T_CARD crd LEFT join
    T_LINK lnk on crd.PK_ID = lnk.FK_CARD LEFT JOIN
    T_CATEGORY ctg on lnk.FK_CATEGORY = ctg.pk_id JOIN
    T_ACCESS access on crd.PK_ID = access.FK_CARD JOIN
    T_ACCOUNT acc ON access.FK_ACCOUNT = acc.PK_ID
    WHERE acc.PK_ID = 'GUID1' AND acc.IL_DEL = 0 AND crd.IL_DEL = 0 AND (lnk.IL_DEL = 0 or lnk.IL_DEL is NULL)AND (ctg.IL_DEL = 0 or ctg.il_del is NULL) AND access.IL_DEL = 0
    order BY ctg.pi_order asc
*/