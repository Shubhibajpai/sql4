use task4;
CREATE TABLE studentDetails (
    studentID INT PRIMARY KEY,
    studentName VARCHAR(100),
    GPA DECIMAL(3, 2) 
);
CREATE TABLE subjectDetails (
    subjectID INT PRIMARY KEY,
    subjectName VARCHAR(100),
    seatsAvailable INT
);
CREATE TABLE studentPreference (
    studentID INT,
    subjectID INT,
    preference INT,
    PRIMARY KEY (studentID, preference),
    FOREIGN KEY (studentID) REFERENCES studentDetails(studentID),
    FOREIGN KEY (subjectID) REFERENCES subjectDetails(subjectID)
);

INSERT INTO studentDetails (studentID, studentName, GPA) VALUES
(1, 'Amit', 3.75),
(2, 'Smith', 3.90),
(3, 'Shruti', 3.60),
(4, 'Akansha', 3.80),
(5, 'Ravi', 3.70);

INSERT INTO subjectDetails (subjectID, subjectName, seatsAvailable) VALUES
(101, 'Chemistry', 50),
(102, 'Computer Science', 60),
(103, 'Literature', 40),
(104, 'Physics', 55),
(105, 'Maths', 45);


INSERT INTO studentPreference (studentID, subjectID, preference) VALUES
(1, 102, 1), 
(1, 103, 2), 
(1, 105, 3), 
(2, 101, 1), 
(2, 103, 2), 
(2, 104, 3), 
(3, 105, 1), 
(3, 101, 2), 
(3, 104, 3), 
(4, 102, 1), 
(4, 105, 2), 
(4, 103, 3), 
(5, 104, 1), 
(5, 102, 2), 
(5, 101, 3);

DELIMITER $$

CREATE PROCEDURE allocateSubjects()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE student_id INT;
    DECLARE subject_id INT;
    DECLARE pref INT;
    DECLARE cur CURSOR FOR
        SELECT sp.studentID, sp.subjectID, sp.preference
        FROM studentPreference sp
        ORDER BY sp.preference; 
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    allocate_loop: LOOP
        FETCH cur INTO student_id, subject_id, pref;
        
        IF done THEN
            LEAVE allocate_loop;
        END IF;
        
        -- Check if the subject has available seats
        SELECT seatsAvailable INTO @seatsAvailable
        FROM subjectDetails
        WHERE subjectID = subject_id;
        
        IF @seatsAvailable > 0 THEN
            -- Allocate the subject to the student
            INSERT INTO allocatedSubjects (studentID, subjectID)
            VALUES (student_id, subject_id);
            
            
            UPDATE subjectDetails
            SET seatsAvailable = seatsAvailable - 1
            WHERE subjectID = subject_id;
        END IF;
        
    END LOOP;
    
    CLOSE cur;
    
   
    UPDATE studentDetails
    SET isAllocated = FALSE
    WHERE studentID NOT IN (SELECT DISTINCT studentID FROM allocatedSubjects);
    
END$$

DELIMITER ;

