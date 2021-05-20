/* */
/*    создание таблиц в БД (приложение+центральная БД MySQL), универсально для всех языков   */
/*    ! не использовать знак "точка с запятой" в комментариях                                */
/*    Поля с приставкой P._ - поля primary, либо ключи, либо обязательные поля в записи*/
/*    Поля с приставкой F._ - поля foreign, ссылаются на другие таблицы*/
/*    Поля с приставкой I._ - информационные поля для сохранения данных о редактировании записи в бд (поля аудита)*/
/*    Символ в приставке указывает на тип данных: KEY, VARCHAR, INT, TIMESTAMP, LOGICAL (BOOLEAN)*/
/* TODO: добавить таблицы для хранения изображений, добавить поля для хранения данных о пользователе/картах/категориях */


CREATE TABLE T_CARD
(
	PK_ID                VARCHAR(36) NOT NULL,
	PV_NAME              VARCHAR(255) NOT NULL,
	PI_ORDER             INTEGER NOT NULL DEFAULT 0,
	V_COMMENT            VARCHAR(1000) NULL,
	IL_DEL               BOOLEAN NOT NULL DEFAULT FALSE,
	IV_USER              VARCHAR(36) NOT NULL,
	IT_CHANGE            TIMESTAMP NOT NULL,
	PRIMARY KEY (PK_ID)
);

CREATE TABLE T_CATEGORY
(
	PK_ID                VARCHAR(36) NOT NULL,
	PV_NAME              VARCHAR(255) NOT NULL,
	PI_ORDER             INTEGER NOT NULL DEFAULT 0,
	V_PICTURE            VARCHAR(255) NULL,
	IL_DEL               BOOLEAN NOT NULL DEFAULT FALSE,
	IV_USER              VARCHAR(36) NOT NULL,
	IT_CHANGE            TIMESTAMP NOT NULL,
	PRIMARY KEY (PK_ID)
);

CREATE TABLE T_LINK
(
	PK_ID          VARCHAR(36) NOT NULL,
	FK_CATEGORY    VARCHAR(10) NOT NULL,
	FK_CARD        VARCHAR(10) NOT NULL,
	IL_DEL               BOOLEAN NOT NULL DEFAULT FALSE,
	IV_USER              VARCHAR(36) NOT NULL,
	IT_CHANGE            TIMESTAMP NOT NULL,
	PRIMARY KEY (PK_ID),
	FOREIGN KEY (FK_CATEGORY) REFERENCES T_CATEGORY (PK_ID) ON DELETE CASCADE,
	FOREIGN KEY (FK_CARD) REFERENCES T_CARD (PK_ID) ON DELETE CASCADE
);

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
	IL_DEL               BOOLEAN NOT NULL DEFAULT FALSE,
	IV_USER              VARCHAR(36) NOT NULL,
	IT_CHANGE            TIMESTAMP NOT NULL,
	PRIMARY KEY (PK_ID),
	UNIQUE(PV_EMAIL)
);

CREATE TABLE T_ACCESS
(
	PK_ID                VARCHAR(36) NOT NULL,
	PI_PRIORITY          INTEGER NOT NULL DEFAULT 100,
	FK_ACCOUNT           VARCHAR(36) NOT NULL,
	FK_CARD              VARCHAR(36) NOT NULL,
	IL_DEL               BOOLEAN NOT NULL DEFAULT FALSE,
	IV_USER              VARCHAR(36) NOT NULL,
	IT_CHANGE            TIMESTAMP NOT NULL,
	PRIMARY KEY (PK_ID),
	FOREIGN KEY (FK_CARD) REFERENCES T_CARD (PK_ID) ON DELETE CASCADE
);

CREATE TABLE T_PASS_RECOVERY
(
    PK_ID                VARCHAR(36) NOT NULL,
    FK_ACCOUNT           VARCHAR(8) NOT NULL,
    IL_DEL               BOOLEAN NOT NULL DEFAULT FALSE,
    IT_CHANGE            TIMESTAMP NOT NULL,
    PRIMARY KEY (PK_ID),
    FOREIGN KEY (FK_ACCOUNT) REFERENCES T_ACCOUNT (PK_ID) ON DELETE CASCADE
);