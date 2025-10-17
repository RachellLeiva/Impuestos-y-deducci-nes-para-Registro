CREATE OR ALTER PROCEDURE CalculatePaymentSheet
    @period_id INT,  
    @batch_size INT = 50000  
AS
BEGIN
    SET NOCOUNT ON;
    
    --  Validar que el periodo exista
    IF NOT EXISTS (SELECT 1 FROM payrollPeriod WHERE id = @period_id)
    BEGIN
        RAISERROR('El período especificado no existe', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Calcular deducciones por lote
        DECLARE @offset INT = 0;
        
        WHILE (1 = 1)
        BEGIN
            INSERT INTO employeeDeductions (deductionId, grossSalaryId, periodId, amountDeduc)
            SELECT 
                d.deductionId,
                gs.id,
                @period_id,  
                ROUND(gs.grossSalary * (d.porcentage/100), 2)  
            FROM (
                SELECT id, employeeId, grossSalary
                FROM GrossSalary 
                WHERE isActive = 1
                ORDER BY id
                OFFSET @offset ROWS 
                FETCH NEXT @batch_size ROWS ONLY
            ) gs
            CROSS JOIN deductions d  
            WHERE d.startDate <= GETDATE() 
              AND (d.endDate IS NULL OR d.endDate > GETDATE());
            
            IF @@ROWCOUNT = 0 BREAK;
            SET @offset = @offset + @batch_size;
        END;

        --  Tabla temporal
        CREATE TABLE #CalculosRapidos (
            grossSalaryId INT PRIMARY KEY,
            employeeId VARCHAR(10),
            grossSalary DECIMAL(12,2),
            totalDeductions DECIMAL(12,2),
            base_imponible DECIMAL(12,2),
            tax_amount DECIMAL(12,2),
            total_credit DECIMAL(12,2)
        );

        -- Calculos con agrupacion
        INSERT INTO #CalculosRapidos (grossSalaryId, employeeId, grossSalary, totalDeductions, total_credit)
        SELECT 
            gs.id,
            gs.employeeId,
            gs.grossSalary,
            ISNULL(SUM(ed.amountDeduc), 0),
            ISNULL(MAX(cf.totalCredit), 0)  -- MAX para evitar duplicados
        FROM GrossSalary gs
        LEFT JOIN employeeDeductions ed ON gs.id = ed.grossSalaryId 
            AND ed.periodId = @period_id  -- Solo deducciones del período actual
        LEFT JOIN creditFiscalFamilyperEmployee cf ON gs.employeeId = cf.employeeId 
            AND cf.isActive = 1
            AND (cf.endDate IS NULL OR cf.endDate >= GETDATE())
        WHERE gs.isActive = 1
        GROUP BY gs.id, gs.employeeId, gs.grossSalary;

        -- Actualizar calculos de impuesto
        UPDATE #CalculosRapidos 
        SET 
            base_imponible = grossSalary - totalDeductions,
            tax_amount = dbo.CalculateIncomeTax(grossSalary - totalDeductions) 
        FROM #CalculosRapidos cr;

        
        INSERT INTO PaymentSheet (grossSalaryId, periodId, totalDeductions, totalTaxRent, calculationDate, net_salary)
        SELECT 
            grossSalaryId,
            @period_id,  --  Período específico
            totalDeductions,
            tax_amount,
            GETDATE(),
            base_imponible - tax_amount + total_credit
        FROM #CalculosRapidos;


        INSERT INTO taxRentEmployee (employeeId, excessTaxRentId, periodId, isUpper, amount)
        SELECT 
            cr.employeeId,
            etr.id,
            @period_id,
            CASE WHEN cr.base_imponible > etr.upperLimit THEN 1 ELSE 0 END,
            dbo.CalculateTaxBracketAmount(cr.base_imponible, etr.id)  
        FROM #CalculosRapidos cr
        CROSS JOIN excessTaxRent etr
        WHERE etr.isActive = 1
          AND cr.base_imponible > etr.lowerLimit 
          AND (etr.upperLimit IS NULL OR cr.base_imponible <= etr.upperLimit);


        DROP TABLE #CalculosRapidos;
        
        COMMIT TRANSACTION;
        

        PRINT 'Proceso completado para período: ' + CAST(@period_id AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
    
    SET NOCOUNT OFF;
END;


--Funciones necesarias

CREATE FUNCTION CalculateIncomeTax(@taxable_income DECIMAL(12,2))
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN CASE 
        WHEN @taxable_income <= 922000 THEN 0
        WHEN @taxable_income <= 1352000 THEN (@taxable_income - 922000) * 0.10
        WHEN @taxable_income <= 2373000 THEN 43000 + ((@taxable_income - 1352000) * 0.15)
        WHEN @taxable_income <= 4745000 THEN 196350 + ((@taxable_income - 2373000) * 0.20)
        ELSE 670850 + ((@taxable_income - 4745000) * 0.25)
    END;
END;

CREATE FUNCTION CalculateTaxBracketAmount(@taxable_income DECIMAL(12,2), @bracket_id INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN CASE @bracket_id
        WHEN 1 THEN 0  -- Exento
        WHEN 2 THEN 
            CASE 
                WHEN @taxable_income > 1352000 THEN 43000
                ELSE (@taxable_income - 922000) * 0.10 
            END
        WHEN 3 THEN 
            CASE 
                WHEN @taxable_income > 2373000 THEN 153150
                ELSE (@taxable_income - 1352000) * 0.15 
            END
        WHEN 4 THEN 
            CASE 
                WHEN @taxable_income > 4745000 THEN 474400
                ELSE (@taxable_income - 2373000) * 0.20 
            END
        WHEN 5 THEN 
            CASE 
                WHEN @taxable_income > 4745000 THEN (@taxable_income - 4745000) * 0.25
                ELSE 0
            END
        ELSE 0
    END;
END;
