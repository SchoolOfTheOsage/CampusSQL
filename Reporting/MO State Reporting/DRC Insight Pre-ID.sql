WITH 
--Calendar
C AS (
    SELECT D.number AS districtNumber, S.number AS schoolNumber, C.calendarID
    FROM District D
    JOIN School S ON S.DistrictID = D.DistrictID AND s.exclude = 0
    JOIN Calendar C ON C.schoolID = S.schoolID AND C.summerSchool = 0 AND C.exclude = 0
    JOIN SchoolYear SY ON SY.endYear = C.endYear AND SY.active = 1
),
--Enrollment
E AS (
    SELECT E.enrollmentID, E.calendarID, E.personID, E.grade
    FROM Enrollment E
    JOIN C ON C.calendarID = E.calendarID AND E.stateExclude = 0 AND E.active = 1
),
--Person
P AS (
    SELECT
        P.personID, 
        COALESCE(P.stateID,'') AS stateID, 
        COALESCE(I.lastName,'') AS lastName, 
        COALESCE(I.firstName,'') AS firstName, 
        COALESCE(I.middleName,'') AS middleName, 
        COALESCE(I.suffix,'') AS suffix, 
        COALESCE(FORMAT(I.birthdate, 'd','us'),'') AS birthdate,
        I.gender,
        I.raceEthnicity,
        COALESCE(C.email,'') AS email
    FROM Person P
    JOIN [Identity] I ON I.identityID = P.currentIdentityID
    LEFT JOIN Contact C ON C.personID = P.personID
),
--Roster
R AS (
    SELECT 
    R.personID, 
    C.courseID, 
    S.sectionID, 
    S.teacherPersonID
    FROM Roster R
    JOIN 
        Trial T 
        ON R.trialID = T.trialID
        AND T.active = 1
    JOIN 
        Section S 
        ON R.sectionID = S.sectionID
        AND S.trialID = T.trialID
    JOIN 
        Course C 
        ON S.courseID = C.courseID
    JOIN 
        C Ca
        ON C.calendarID = Ca.calendarID
    JOIN 
        SectionPlacement SP
        ON SP.trialID = T.trialID
        AND SP.sectionID = S.sectionID
    --JOIN 
        --Term Te 
        --ON Te.termID = SP.termID
        --AND Te.startDate <= GETDATE()
        --AND (Te.endDate >= GETDATE() OR Te.endDate IS NULL)
    --WHERE 
        --R.startDate <= GETDATE() 
        --AND (R.endDate >= GETDATE() OR R.enddate IS NULL)
),
--Assessment Subject
[AS] AS (
    SELECT C.courseID, CC.value AS assessmentSubject
    FROM Course C
    JOIN CustomCourse CC
        ON C.courseID = CC.courseID
    JOIN CampusAttribute CA 
        ON CA.attributeID = CC.attributeID
        AND CA.object = 'Course'
        AND CA.element = 'assessmentSubject'
),
--Test Method
TM AS (
    SELECT S.sectionID, CS.value AS testMethod
    FROM Section S
    JOIN CustomSection CS
        ON S.sectionID = CS.sectionID
    JOIN CampusAttribute CA 
        ON CA.attributeID = CS.attributeID
        AND CA.object = 'Section'
        AND CA.element = 'testMethod'
),
--Assessment Type
[AT] AS (
    SELECT S.sectionID, CS.value AS assessmentType
    FROM Section S
    JOIN CustomSection CS
        ON S.sectionID = CS.sectionID
    JOIN CampusAttribute CA 
        ON CA.attributeID = CS.attributeID
        AND CA.object = 'Section'
        AND CA.element = 'assessmentType'
)
--Main Query
SELECT DISTINCT
C.districtNumber AS 'District Code',
C.schoolNumber AS 'School Code',
P.stateID AS 'Student State ID',
P.lastName AS 'Student Last Name',
P.firstName AS 'Student First Name',
P.middleName AS 'Student Middle Name',
P.suffix AS 'Student Suffix',
P.birthdate AS 'Student Date of Birth',
E.grade AS 'Student Grade Level',
P.gender AS 'Student Gender',
P.raceEthnicity AS 'Student Race Ethnicity',
T.firstName AS 'Educator First Name',
T.lastName AS 'Educator Last Name',
T.email AS 'Educator Email',
[AS].assessmentSubject AS 'Subject',
'' AS 'ELA_PaperBased',
'' AS 'MATH_PaperBased',
'' AS 'SC_PaperBased',
'' AS 'ELA_Braille',
'' AS 'MATH_Braille',
'' AS 'SC_Braille',
'' AS 'ELA_LargePrint',
'' AS 'MATH_LargePrint',
'' AS 'SC_LargePrint',
'' AS 'ELA_SCPaper',
'' AS 'MATH_SCPaper',
'' AS 'SC_SCPaper',
'' AS 'ELA_Read_TTS',
'' AS 'MATH_Read_TTS',
'' AS 'SC_Read_TTS',
'' AS 'ELA_Read_TTSPassage',
'' AS 'ELA_Read_Assist',
'' AS 'MATH_Read_Assist',
'' AS 'SC_Read_Assist',
'' AS 'ELA_Read_AssistPassage_Gr3-5',
'' AS 'ELA_Read_AssistPassage_Gr6-8',
'' AS 'ELA_Read_HumanReader',
'' AS 'MATH_Read_HumanReader',
'' AS 'SC_Read_HumanReader',
'' AS 'ELA_Read_HumanReaderPassage_Gr3-5',
'' AS 'ELA_Read_HumanReaderPassage_Gr6-8',
'' AS 'ELA_Read_NativeLanguage',
'' AS 'MATH_Read_NativeLanguage',
'' AS 'SC_Read_NativeLanguage',
'' AS 'ELA_Read_NativeLanguagePassage_Gr3-5',
'' AS 'LA_Read_NativeLanguagePassag_Gr6-8',
'' AS 'ELA_Read_HumanReaderBlind',
'' AS 'LA_Translation',
'' AS 'MATH_Translation',
'' AS 'SC_Translation',
'' AS 'ELA_ASL',
'' AS 'ELA_Closed_Captioning',
'' AS 'MATH_Abacus',
'' AS 'SC_Abacus',
'' AS 'ELA_AlternateResponseOptions',
'' AS 'MATH_AlternateResponseOptions',
'' AS 'SC_AlternateResponseOptions',
'' AS 'ELA_BilingualDictionary',
'' AS 'MATH_Calculator_Gr3',
'' AS 'MATH_Calculator_Gr4-5',
'' AS 'ELA_Magnification',
'' AS 'MATH_Magnification',
'' AS 'SC_Magnification',
'' AS 'MATH_MultiplicationTable_Gr3',
'' AS 'MATH_MultiplicationTable_Gr4-8',
'' AS 'SC_MultiplicationTable_Gr4-8',
'' AS 'MATH_Scribe',
'' AS 'SC_Scribe',
'' AS 'ELA_SeparateSetting',
'' AS 'ATH_SeparateSetting',
'' AS 'SC_SeparateSetting',
'' AS 'ATH_SpecializedCalculator',
'' AS 'SC_SpecializedCalculator',
'' AS 'ELA_SpeechToText',
'' AS 'MATH_SpeechToText',
'' AS 'SC_SpeechToText',
'' AS 'ELA_ColorContrast_Paper',
'' AS 'MATH_ColorContrast_Paper',
'' AS 'SC_ColorContrast_Paper',
'' AS 'ELA_ColorOverlay_Paper',
'' AS 'MATH_ColorOverlay_Paper',
'' AS 'SC_ColorOverlay_Paper',
'' AS 'ELA_Masking_Paper',
'' AS 'MATH_Masking_Paper',
'' AS 'SC_Masking_Paper'
FROM C
JOIN Enrollment E ON E.calendarID = C.calendarID 
JOIN P ON P.personID = E.personID
JOIN R ON R.personID = P.personID
JOIN [AS] ON [AS].courseID = R.courseID
LEFT JOIN TM ON TM.sectionID = R.sectionID AND TM.testMethod IN('ONLINE','O')
JOIN [AT] ON [AT].sectionID = R.sectionID AND [AT].assessmentType = 'MAPSPR'
LEFT JOIN P T ON T.personID = R.teacherPersonID