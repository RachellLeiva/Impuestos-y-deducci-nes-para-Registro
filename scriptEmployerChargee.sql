
USE [Taller/empleados];
INSERT INTO deductionByEmployerCharge (employerChargeld, periodId, totalDeduction)
SELECT 
    ec.id AS employerChargeld,
    pp.id AS periodId,
   
    (SELECT SUM(grossSalary) FROM grossSalary) * ec.porcentage AS totalDeduction
FROM 
    employerCharge ec
CROSS JOIN 
    payrollPeriod pp
WHERE 
    ec.endDate IS NULL
    AND pp.id BETWEEN 1 AND 25;



SELECT * FROM PaymentSheet