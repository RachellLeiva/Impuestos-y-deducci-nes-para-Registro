USE [Taller/empleados];

INSERT INTO deductionByEmployerCharge (employerChargeld, periodId, organizationId, totalDeduction)
SELECT 
    ec.id AS employerChargeld,
    pp.id AS periodId,
    org.id AS organizationId,
    
    ISNULL((
        SELECT SUM(gs.grossSalary)
        FROM GrossSalary gs
        INNER JOIN Employee e ON gs.employeeId = e.Idcard
        INNER JOIN departments d ON e.departmentId = d.id
        WHERE gs.isActive = 1
          AND e.status = 1
          AND d.organizationId = org.id  
    ), 0) * ec.porcentage AS totalDeduction
FROM 
    employerCharge ec
CROSS JOIN 
    payrollPeriod pp
CROSS JOIN
    organizations org
WHERE 
    ec.endDate IS NULL
    AND pp.id BETWEEN 1 AND 25
    AND org.isActive = 1;

	Select * from deductionByEmployerCharge
	
