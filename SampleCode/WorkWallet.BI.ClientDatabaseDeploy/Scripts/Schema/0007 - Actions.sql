CREATE TABLE mart.ActionPriority
(
    ActionPriority_key int IDENTITY
    ,ActionPriorityCode int NOT NULL /* business key */
    ,ActionPriority nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ActionPriority__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ActionPriority] PRIMARY KEY (ActionPriority_key)
    ,CONSTRAINT [UQ_mart.ActionPriority_Code] UNIQUE(ActionPriorityCode)
);

INSERT INTO mart.ActionPriority (ActionPriorityCode, ActionPriority) VALUES (1, N'Low');
INSERT INTO mart.ActionPriority (ActionPriorityCode, ActionPriority) VALUES (2, N'Medium');
INSERT INTO mart.ActionPriority (ActionPriorityCode, ActionPriority) VALUES (4, N'High');
INSERT INTO mart.ActionPriority (ActionPriorityCode, ActionPriority) VALUES (8, N'Critical');

CREATE TABLE mart.ActionStatus
(
    ActionStatus_key int IDENTITY
    ,ActionStatusCode int NOT NULL /* business key */
    ,ActionStatus nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ActionStatus__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ActionStatus] PRIMARY KEY (ActionStatus_key)
    ,CONSTRAINT [UQ_mart.ActionStatus_Code] UNIQUE(ActionStatusCode)
);

INSERT INTO mart.ActionStatus (ActionStatusCode, ActionStatus) VALUES (1, N'Open');
INSERT INTO mart.ActionStatus (ActionStatusCode, ActionStatus) VALUES (2, N'In Progress');
INSERT INTO mart.ActionStatus (ActionStatusCode, ActionStatus) VALUES (4, N'Closed');

CREATE TABLE mart.ActionType
(
    ActionType_key int IDENTITY
    ,ActionTypeCode int NOT NULL /* business key */
    ,ActionType nvarchar(50) NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ActionType__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ActionType] PRIMARY KEY (ActionType_key)
    ,CONSTRAINT [UQ_mart.ActionType_Code] UNIQUE(ActionTypeCode)
);

INSERT INTO mart.ActionType (ActionTypeCode, ActionType) VALUES (1, N'Audit');
INSERT INTO mart.ActionType (ActionTypeCode, ActionType) VALUES (2, N'Issue');
INSERT INTO mart.ActionType (ActionTypeCode, ActionType) VALUES (4, N'Safety Card');
INSERT INTO mart.ActionType (ActionTypeCode, ActionType) VALUES (8, N'Asset');
INSERT INTO mart.ActionType (ActionTypeCode, ActionType) VALUES (16, N'Briefing');

CREATE TABLE mart.[Action]
(
    Action_key int IDENTITY
    ,ActionId uniqueidentifier NOT NULL /* business key */
    ,ActionType_key int NOT NULL
    ,TargetId uniqueidentifier NOT NULL
    ,TargetReference nvarchar(128) NOT NULL
    ,Title nvarchar(100) NOT NULL
    ,[Description] nvarchar(max) NOT NULL
    ,AssignedTo nvarchar(100) NOT NULL
    ,ActionPriority_key int NOT NULL
    ,DueOn date NOT NULL
    ,OriginalDueOn date NOT NULL
    ,ActionStatus_key int NOT NULL
    ,Deleted bit NOT NULL
    ,CreatedOn datetimeoffset(7) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.Action__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.Action] PRIMARY KEY (Action_key)
    ,CONSTRAINT [UQ_mart.Action_ActionId] UNIQUE(ActionId)
    ,CONSTRAINT [FK_mart.Action_mart.ActionType_ActionType_key] FOREIGN KEY(ActionType_key) REFERENCES mart.ActionType
    ,CONSTRAINT [FK_mart.Action_mart.ActionStatus_ActionStatus_key] FOREIGN KEY(ActionStatus_key) REFERENCES mart.ActionStatus
    ,CONSTRAINT [FK_mart.Action_mart.ActionPriority_ActionPriority_key] FOREIGN KEY(ActionPriority_key) REFERENCES mart.ActionPriority
    ,CONSTRAINT [FK_mart.Action_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

CREATE TABLE mart.ActionUpdate
(
    ActionUpdate_key int IDENTITY
    ,ActionUpdateId uniqueidentifier NOT NULL /* business key */
    ,Action_key int NOT NULL
    ,Comments nvarchar(max) NOT NULL
    ,ActionStatus_key int NOT NULL
    ,Deleted bit NOT NULL
    ,CreatedOn datetimeoffset(7) NOT NULL
    ,Wallet_key int NOT NULL
    ,_created datetime2(7) NOT NULL CONSTRAINT [DF_mart.ActionUpdate__created] DEFAULT SYSUTCDATETIME()
    ,_edited datetime2(7) NULL
    ,CONSTRAINT [PK_mart.ActionUpdate] PRIMARY KEY (ActionUpdate_key)
    ,CONSTRAINT [FK_mart.ActionUpdate_mart.Action_Action_key] FOREIGN KEY(Action_key) REFERENCES mart.[Action]
    ,CONSTRAINT [FK_mart.ActionUpdate_mart.ActionStatus_ActionStatus_key] FOREIGN KEY(ActionStatus_key) REFERENCES mart.ActionStatus
    ,CONSTRAINT [FK_mart.ActionUpdate_mart.Wallet_Wallet_key] FOREIGN KEY(Wallet_key) REFERENCES mart.Wallet
);

GO