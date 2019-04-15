SELECT PREREL.PROJECTID        AS "projectId",
       PREREL.WBSCODE,
       PREREL.WBSNAME,
       PREREL.ID               AS "activityId",
       PREREL.objectId         AS "OriginalACTOBJECTID",
       PREREL.OBJECTID         AS "successorActivityObjectId",
       P6ACT.ObjectID          AS "predecessorActivityObjectId",
       P6ACT.NAME,
       PREREL.PREDECESSOR_LAG  AS "lag",
       PREREL.PREDECESSOR_TYPE AS "type",
       PREREL.TEMPLATE_ID,
       PREREL.SOURCE
  FROM (SELECT ACT.PROJECTID,
               ACT.WBSCODE,
               ACT.WBSNAME,
               ACT.ID,
               ACT.NAME,
               ACT.OBJECTID,
               REL.PREDECESSOR_MS_ACT_ID,
               REL.PREDECESSOR_MS_ACT_NAME,
               REL.PREDECESSOR_LAG,
               REL.PREDECESSOR_TYPE,
               REL.TEMPLATE_ID,
               ACT.SOURCE
          FROM (SELECT P.WBSCODE,
                       p.WBSNAME,
                       p.PROJECTID,
                       U.Template_id,
                       p.id,
                       p.name,
                       p.objectid,
                       u.source
                  FROM P6_ACTIVITY  P
                       JOIN
                       (SELECT DISTINCT Project_number, TEMPLATE_ID, A.SOURCE
                          FROM UNI_ESTIMATE A
                         WHERE (    A.PIF_STATUS LIKE '%Success%'
                                AND NOT EXISTS
                                        (SELECT 1
                                           FROM UNI_ESTIMATE
                                          WHERE     A.PROJECT_NUMBER =
                                                        Project_number
                                                AND pif_status NOT LIKE
                                                        '%Success%'))) U
                           ON     P.PROJECTID = U.PROJECT_NUMBER
                              AND p.cbscode <> 'null'
                              AND p.pif_status = 'New' --- existing Activities will have status OLD, no need to consider them
                                                      ) ACT
               JOIN P6_Relationship_mapping REL
                   ON     ACT.WBSCODE = REL.wbs_id
                      AND ACT.Template_id = REL.TEMPLATE_ID) PREREL
       JOIN P6_ACTIVITY P6ACT
           ON     PREREL.PREDECESSOR_MS_ACT_NAME = P6ACT.NAME
              AND PREREL.PROJECTID = P6ACT.ProjectID
              AND PREREL.source NOT IN ('PCO LI', 'ESCHG LI')
UNION ALL
SELECT PREREL.PROJECTID      AS "projectId",
       PREREL.WBSCODE,
      PREREL.WBSNAME,
       PREREL.ID             AS "activityId",
       PREREL.objectId       AS "OriginalACTOBJECTID",
       P6ACT.ObjectID        AS "successorActivityObjectId",
       PREREL.OBJECTID       AS "predecessorActivityObjectId",
       P6ACT.NAME,
       PREREL.SUCCESSOR_LAG  AS "lag",
       PREREL.SUCCESSOR_TYPE AS "type",
       PREREL.TEMPLATE_ID,
       PREREL.source
  FROM (SELECT ACT.PROJECTID,
               ACT.WBSCODE,
               ACT.WBSNAME,
               ACT.ID,
               ACT.NAME,
               ACT.OBJECTID,
               REL.SUCCESSOR_MS_ACT_ID,
               REL.SUCCESSOR_MS_ACT_NAME,
               REL.SUCCESSOR_LAG,
               REL.SUCCESSOR_TYPE,
               REL.TEMPLATE_ID,
               ACT.SOURCE
          FROM (SELECT P.WBSCODE,
                       p.WBSNAME,
                       p.PROJECTID,
                       U.Template_id,
                       p.id,
                       p.name,
                       p.objectid,
                       U.SOURCE
                  FROM P6_ACTIVITY  P
                       JOIN
                       (SELECT DISTINCT Project_number, TEMPLATE_ID, A.SOURCE
                          FROM UNI_ESTIMATE A
                         WHERE (    A.PIF_STATUS LIKE '%Success%'
                                AND NOT EXISTS
                                        (SELECT 1
                                           FROM UNI_ESTIMATE
                                          WHERE     A.PROJECT_NUMBER =
                                                        Project_number
                                                AND pif_status NOT LIKE
                                                        '%Success%'))) U
                           ON     P.PROJECTID = U.PROJECT_NUMBER
                              AND p.cbscode <> 'null'
                              AND p.pif_status = 'New' --- existing Activities will have status OLD, no need to consider them
                                                      ) ACT
               JOIN P6_Relationship_mapping REL
                   ON     ACT.WBSCODE = REL.wbs_id
                      AND ACT.Template_id = REL.TEMPLATE_ID) PREREL
       JOIN P6_ACTIVITY P6ACT
           ON     PREREL.SUCCESSOR_MS_ACT_NAME = P6ACT.NAME
              AND PREREL.PROJECTID = P6ACT.ProjectID
              AND PREREL.source NOT IN ('PCO LI', 'ESCHG LI')
