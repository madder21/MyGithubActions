/**
 * @author Samodi
 * @date 17/03/2025
 * @Type Apex Trigger
 *****************************************************************************************************************************************************************
 * @description This trigger is fired for any event on the Case
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|17032025			|.Asamodi		|.					|.
*/

public with sharing class CaseServices {

    /*
    * @description main purpose of the method below is to recalculate all custom formula fields on a Case
    * @param List<Case> cases - List of Cases which will be updated
    * @return void
    */
    public static void formulaEval(List<Case> cases, Boolean isInsert) {

        // Avoid unnecessary processing
        if (cases == null || cases.isEmpty()) return;
    
        // Fetch Metadata for the given object
        List<FieldFormulaConfig__mdt> formulaList = new List<FieldFormulaConfig__mdt>([
            SELECT Object_Name__c, Field_Name__c, Formula_Expression__c, Return_Type__c, Trigger_Event__c
            FROM FieldFormulaConfig__mdt 
            WHERE Object_Name__c = 'Case'
        ]);
    
        // No formulaList to evaluate
        if (formulaList.isEmpty()) return;

        // Create the map with Field_Name__c as the key
        Map<String, FieldFormulaConfig__mdt> formulas = new Map<String, FieldFormulaConfig__mdt>();
        
        // Populate the map using Field_Name__c as the key
        for (FieldFormulaConfig__mdt formula : formulaList) formulas.put(formula.Field_Name__c, formula);
    
        // Prepare formulas dynamically
        Map<String, FormulaEval.FormulaInstance> formulaMap = new Map<String, FormulaEval.FormulaInstance>();
    
        for (FieldFormulaConfig__mdt meta : formulaList) {
            FormulaEval.FormulaReturnType returnType;
    
            // Handle different return types properly
            switch on meta.Return_Type__c {
                when 'String'   { returnType = FormulaEval.FormulaReturnType.STRING; }
                when 'Boolean'  { returnType = FormulaEval.FormulaReturnType.BOOLEAN; }
                when 'Integer'  { returnType = FormulaEval.FormulaReturnType.INTEGER; }
                when 'Decimal'  { returnType = FormulaEval.FormulaReturnType.DECIMAL; }
                when 'Double'   { returnType = FormulaEval.FormulaReturnType.DOUBLE; }
                when 'Date'     { returnType = FormulaEval.FormulaReturnType.DATE; }
                when 'DateTime' { returnType = FormulaEval.FormulaReturnType.DATETIME; }
                // Skip unknown types
                when else       { continue; }
            }

            // Build the Formula using the metadata Formula Expression
            try {
                FormulaEval.FormulaInstance formulaInstance = Formula.builder()
                    .withType(Schema.Case.class)
                    .withReturnType(returnType)
                    .withFormula(meta.Formula_Expression__c)
                    .build();
    
                formulaMap.put(meta.Field_Name__c, formulaInstance);
            } catch (Exception e) {
                System.debug('Error while creating formula for field: ' + meta.Field_Name__c + ' - ' + e.getMessage());
            }
        }

        // No valid formulas available
        if (formulaMap.isEmpty()) return;
    
        // Determine if the formula should be evaluated based on the trigger event
        String TriggerEvent;
        Boolean evaluateFormula;

        for (Case record : cases) {
    
            for (String fieldName : formulaMap.keySet()) {

                // Retrieve the Context Associated with the Formula
                TriggerEvent = (String) formulas.get(fieldName).Trigger_Event__c;
                evaluateFormula = false;

                // If Insert and field requires insert calculation
                if (isInsert && TriggerEvent == 'Insert') {
                    evaluateFormula = true;
                }
                // If Update and field requires update calculation
                else if (!isInsert && TriggerEvent == 'Update') {
                    evaluateFormula = true;
                }
                // If Insert and Update
                else if (TriggerEvent == 'Both') {
                    evaluateFormula = true;
                }
                
                // Evaluate the Formula
                if(evaluateFormula){
                    try {
                        record.put(fieldName, formulaMap.get(fieldName).evaluate(record));
                    }
                    catch (Exception e) {
                        System.debug('Error evaluating formula for field: ' + fieldName + ' - ' + e.getMessage());
                    }
                }
            }
        }
    }    
}