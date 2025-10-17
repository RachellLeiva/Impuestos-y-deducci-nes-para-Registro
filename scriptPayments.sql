CREATE PROCEDURE CalculatePaymentSheet_
AS
BEGIN
    SET NOCOUNT ON;
    
 
    INSERT INTO employeeDeductions (deductionId, grossSalaryId, periodId, amountDeduc)
    SELECT 
        d.deductionId,
        gs.id,
        pp.id,
        ROUND(gs.grossSalary * d.porcentage, 2)
    FROM GrossSalary gs
    CROSS JOIN payrollPeriod pp
    CROSS JOIN deductions d
    WHERE gs.isActive = 1
      AND pp.id BETWEEN 1 AND 25
      AND (d.endDate IS NULL OR d.endDate > GETDATE());
    
   
    CREATE TABLE #CalculosRapidos (
        grossSalaryId INT,
        periodId INT,
        totalDeductions DECIMAL(12,2),
        base_imponible DECIMAL(12,2),
        tax_amount DECIMAL(12,2),
        total_credit DECIMAL(12,2)
    );
    
    INSERT INTO #CalculosRapidos (grossSalaryId, periodId, totalDeductions, total_credit)
    SELECT 
        gs.id,
        pp.id,
        ISNULL(ed.total_ded, 0),
        CASE 
            WHEN gs.fiscal = 1 THEN ISNULL(cf.totalCredit, 0) 
            ELSE 0 
        END
    FROM GrossSalary gs
    CROSS JOIN payrollPeriod pp
    LEFT JOIN (
        SELECT grossSalaryId, periodId, SUM(amountDeduc) as total_ded
        FROM employeeDeductions
        GROUP BY grossSalaryId, periodId
    ) ed ON gs.id = ed.grossSalaryId AND pp.id = ed.periodId
    LEFT JOIN creditFiscalFamilyperEmployee cf ON gs.employeeId = cf.employeeId 
        AND (cf.endDate IS NULL OR cf.endDate >= GETDATE())
    WHERE gs.isActive = 1
      AND pp.id BETWEEN 1 AND 25;
    
    UPDATE #CalculosRapidos 
    SET 
        base_imponible = gs.grossSalary - totalDeductions,
        tax_amount = CASE 
            WHEN (gs.grossSalary - totalDeductions) <= 922000 THEN 0
            WHEN (gs.grossSalary - totalDeductions) <= 1352000 THEN 
                ((gs.grossSalary - totalDeductions) - 922000) * 0.10
            WHEN (gs.grossSalary - totalDeductions) <= 2373000 THEN 
                43000 + ((gs.grossSalary - totalDeductions) - 1352000) * 0.15
            WHEN (gs.grossSalary - totalDeductions) <= 4745000 THEN 
                196350 + ((gs.grossSalary - totalDeductions) - 2373000) * 0.20
            ELSE 
                670850 + ((gs.grossSalary - totalDeductions) - 4745000) * 0.25
        END
    FROM #CalculosRapidos cr
    INNER JOIN GrossSalary gs ON cr.grossSalaryId = gs.id;
    
    INSERT INTO PaymentSheet (grossSalaryId, periodId, totalDeductions, totalTaxRent, calculationDate, net_salary)
    SELECT 
        grossSalaryId,
        periodId,
        totalDeductions,
        tax_amount,
        GETDATE(),
        base_imponible - tax_amount + total_credit
    FROM #CalculosRapidos;
    
    
    INSERT INTO taxRentEmployee (employeeId, excessTaxRentId, periodId, isUpper, amount)
    SELECT 
        gs.employeeId,
        etr.id,
        cr.periodId,
        CASE 
            WHEN cr.base_imponible > etr.upperLimit THEN 1
            ELSE 0
        END,
        CASE 
            WHEN etr.id = 1 THEN 0
            WHEN etr.id = 2 THEN 
                CASE 
                    WHEN cr.base_imponible > 1352000 THEN 43000
                    ELSE (cr.base_imponible - 922000) * 0.10 
                END
            WHEN etr.id = 3 THEN 
                CASE 
                    WHEN cr.base_imponible > 2373000 THEN 153150
                    ELSE (cr.base_imponible - 1352000) * 0.15 
                END
            WHEN etr.id = 4 THEN 
                CASE 
                    WHEN cr.base_imponible > 4745000 THEN 474400
                    ELSE (cr.base_imponible - 2373000) * 0.20 
                END
            WHEN etr.id = 5 THEN 
                CASE 
                    WHEN cr.base_imponible > 4745000 THEN 
                        (cr.base_imponible - 4745000) * 0.25
                    ELSE 0
                END
        END
    FROM #CalculosRapidos cr
    INNER JOIN GrossSalary gs ON cr.grossSalaryId = gs.id
    CROSS JOIN excessTaxRent etr
    WHERE cr.base_imponible > etr.lowerLimit 
       OR (etr.id = 1 AND cr.base_imponible <= etr.upperLimit);
    
    DROP TABLE #CalculosRapidos;
    
   
    SET NOCOUNT OFF;
END;
EXEC CalculatePaymentSheet_