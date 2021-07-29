/* */
/*    создание таблиц в БД (приложение+центральная БД MySQL), универсально для всех языков   */
/*    ! не использовать знак "точка с запятой" в комментариях                                */
/*    Поля с приставкой P._ - поля primary, либо ключи, либо обязательные поля в записи*/
/*    Поля с приставкой F._ - поля foreign, ссылаются на другие таблицы*/
/*    Поля с приставкой I._ - информационные поля для сохранения данных о редактировании записи в бд (поля аудита)*/
/*    Символ в приставке указывает на тип данных: KEY, VARCHAR, INT, TIMESTAMP, LOGICAL (BOOLEAN)*/
/* TODO: добавить таблицы для хранения изображений, добавить поля для хранения данных о пользователе/картах/категориях */


CREATE TABLE T_ACCOUNT
(
	PK_ID                VARCHAR(36) NOT NULL,
	PV_EMAIL             VARCHAR(255) NOT NULL,
	PV_PSWD              VARCHAR(255) NOT NULL,
	PT_REG               TIMESTAMP NOT NULL,
	V_FIRSTNAME          VARCHAR(36) NULL,
	V_SECONDNAME         VARCHAR(36) NULL,
	V_TELEGRAM           VARCHAR(255) NULL,
	V_SECRET             VARCHAR(255) NULL,
	V_PHONE              VARCHAR(36) NULL,
	IL_DEL               INT NOT NULL DEFAULT 0,
	IV_USER              VARCHAR(36) NOT NULL,
	IT_CHANGE            TIMESTAMP NOT NULL,
	PRIMARY KEY (PK_ID),
	UNIQUE(PV_EMAIL)
);

CREATE TABLE T_CATEGORY
(
	PK_ID                VARCHAR(36) NOT NULL,
	PV_NAME              VARCHAR(255) NOT NULL,
	PI_ORDER             INTEGER NOT NULL DEFAULT 0,
	FK_ACCOUNT           VARCHAR(36) NOT NULL,
	V_ICON               VARCHAR(255) NULL,
	V_ICON_COLOR         VARCHAR(255) NULL,
	V_BACKGROUND_COLOR   VARCHAR(255) NULL,
	IL_DEL               INT NOT NULL DEFAULT 0,
	IV_USER              VARCHAR(36) NOT NULL,
	IT_CHANGE            TIMESTAMP NOT NULL,
	PRIMARY KEY (PK_ID),
	FOREIGN KEY (FK_ACCOUNT) REFERENCES T_ACCOUNT (PK_ID) ON DELETE CASCADE
);

CREATE TABLE T_CARD
(
	PK_ID                VARCHAR(36) NOT NULL,
	PV_NAME              VARCHAR(255) NULL,
	PI_ORDER             INTEGER NOT NULL DEFAULT 0,
	V_COMMENT            VARCHAR(1000) NULL,
	B_IMAGE_FRONT        BLOB NULL,
	B_IMAGE_BACK         BLOB NULL,
	IL_DEL               INT NOT NULL DEFAULT 0,
	IV_USER              VARCHAR(36) NOT NULL,
	IT_CHANGE            TIMESTAMP NOT NULL,
	PRIMARY KEY (PK_ID)
);

CREATE TABLE T_ACCESS
(
	PK_ID                VARCHAR(36) NOT NULL,
	PI_PRIORITY          INTEGER NOT NULL DEFAULT 100,
	FK_ACCOUNT           VARCHAR(36) NOT NULL,
	FK_CARD              VARCHAR(36) NOT NULL,
	FK_CATEGORY          VARCHAR(36) NULL,
	IL_DEL               INT NOT NULL DEFAULT 0,
	IV_USER              VARCHAR(36) NOT NULL,
	IT_CHANGE            TIMESTAMP NOT NULL,
	PRIMARY KEY (PK_ID),
	FOREIGN KEY (FK_CARD) REFERENCES T_CARD (PK_ID) ON DELETE CASCADE,
    FOREIGN KEY (FK_CATEGORY) REFERENCES T_CATEGORY (PK_ID) ON DELETE SET NULL
);

CREATE TABLE T_PASS_RECOVERY
(
    PK_ID                VARCHAR(36) NOT NULL,
    FK_ACCOUNT           VARCHAR(36) NOT NULL,
    IL_DEL               INT NOT NULL DEFAULT 0,
    IT_CHANGE            TIMESTAMP NOT NULL,
    PRIMARY KEY (PK_ID),
    FOREIGN KEY (FK_ACCOUNT) REFERENCES T_ACCOUNT (PK_ID) ON DELETE CASCADE
);



INSERT INTO T_ACCOUNT(PK_ID, PV_EMAIL, PV_PSWD, PT_REG, IV_USER, IT_CHANGE) VALUES('GUID0', 'a@a.com', '3dbe00a167653a1aaee01d93e77e730e', '20200520', 'ANDRROS3030', '20200520');
INSERT INTO T_ACCOUNT(PK_ID, PV_EMAIL, PV_PSWD, PT_REG, IV_USER, IT_CHANGE) VALUES('GUID1', 'b@b.com', '810247419084c82d03809fc886fedaad', '20200520', 'ANDRROS3030', '20200520');
/*два аккаунта, пароли - 8 символов a или b соответственно*/

INSERT INTO T_CARD(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CARD0', 'PYATEROCHKA', 'ANDRROS3030', '20200520');
INSERT INTO T_CARD(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CARD1', 'OBI', 'ANDRROS3030', '20200520');
INSERT INTO T_CARD(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CARD2', 'PEREKRESTOK', 'ANDRROS3030', '20200520');
INSERT INTO T_CARD(PK_ID, PV_NAME, IV_USER, IT_CHANGE) VALUES('CARD3', 'sportclub', 'ANDRROS3030', '20200520');
/*4 карты*/

INSERT INTO T_CATEGORY(PK_ID, PV_NAME, FK_ACCOUNT, IV_USER, IT_CHANGE) VALUES('CATEGORY0', 'SHOPPING', 'GUID0', 'ANDRROS3030', '20200520');
/*Категория, принадлежит первому пользователю - отображается только ему*/
INSERT INTO T_CATEGORY(PK_ID, PV_NAME, FK_ACCOUNT, IV_USER, IT_CHANGE) VALUES('CATEGORY1', 'PASSES', 'GUID1', 'ANDRROS3030', '20200520');
/*Категория, принадлежит второму пользователю - отображается только ему*/

INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, FK_CATEGORY, IV_USER, IT_CHANGE) VALUES('AG0', 'GUID0', 'CARD0', 'CATEGORY0','ANDRROS3030', '20200520');
/*Первая карта, принадлежит первому пользователю и отображается внутри его категории*/
INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG1', 'GUID0', 'CARD1', 'ANDRROS3030', '20200520');
/*Вторая карта, принадлежит первому пользователю, отображается без категории*/
INSERT INTO T_ACCESS(PK_ID, PI_PRIORITY, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG2', 99, 'GUID0', 'CARD2', 'ANDRROS3030', '20200520');
/*Третья карта, принадлежит второму пользователю, отображается первому без категории*/
INSERT INTO T_ACCESS(PK_ID, PI_PRIORITY, FK_ACCOUNT, FK_CARD, FK_CATEGORY, IV_USER, IT_CHANGE) VALUES('AG3', 99, 'GUID1', 'CARD0', 'CATEGORY1', 'ANDRROS3030', '20200520');
/*Первая карта, отображается второму пользователю внутри его категории*/
INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, IV_USER, IT_CHANGE) VALUES('AG4', 'GUID1', 'CARD2', 'ANDRROS3030', '20200520');
/*Третья карта, отображается второму пользователю без категории*/
INSERT INTO T_ACCESS(PK_ID, FK_ACCOUNT, FK_CARD, FK_CATEGORY, IV_USER, IT_CHANGE) VALUES('AG5', 'GUID1', 'CARD3', 'CATEGORY1', 'ANDRROS3030', '20200520');
/*Четвертая карта, отображается второму пользователю внутри его категории*/