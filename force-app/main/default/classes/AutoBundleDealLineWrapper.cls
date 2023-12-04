/**************************************************************************************************
* File Name     :   AutoBundleDealLineWrapper 
* Description   :   Abstract data definition of a Deal line with data collected in the auto bundle process
* @author       :   Cesar Sandrigo
* Modification Log
===================================================================================================
* Ver.  Date       Author              Modification
*--------------------------------------------------------------------------------------------------
* 1.0   11/11/19   Cesar Sandrigo 
* 2.0   2/5/20  Cory Bartholomew    Added descriptions
**************************************************************************************************/
public abstract class AutoBundleDealLineWrapper {
    /**
     * @description Default constructor
     */
    protected AutoBundleDealLineWrapper() {
    }

    /**
     * @description
     */
    protected AutoBundleDealLineWrapper(Vistex_Deal_Line_E1KOMG__c dealLine, Condition_Header_E1KONH__c dealLineCondition) {
        validationResults = new List<CPQ_VistexDealValidator.DealValidationResult>();
        // Arguments sanity check

        if (dealLine == null) {
            System.Debug('[dealLine] is required in MaterialLineWrapperInfo constructor.');
            validationResults.add(
                CPQ_VistexDealValidator.createResult(
                    '- Deal Line is required in MaterialLineWrapperInfo constructor. No Line was passed in',
                    false,
                    null
                )
            );
            return;
        }

        if (dealLineCondition == null) {
            System.Debug('[dealLineCondtition] is required in MaterialLineWrapperInfo constructor. ' + dealLine.Id);
            validationResults.add(
                CPQ_VistexDealValidator.createResult(
                    '- Deal Line Condition is required. No Deal Line condition was provided for Deal Line: ' + dealLine.Id,
                    false,
                    dealLine.Id
                )
            );
            return;
        }

        if (dealLineCondition.Vistex_ZO2C_E1KONP_CPQ__r.isEmpty()) {
            System.Debug('[dealLineCondition] does not have the child condition (Vistex ZO2C E1KONP CPQ) ' + dealLineCondition.Id);
            validationResults.add(
                CPQ_VistexDealValidator.createResult(
                    '- Deal Line Condition ' +
                    dealLineCondition.Id +
                    ' does not have the child condition (Vistex ZO2C E1KONP CPQ) that is required to determine if the deal has a commitment level.',
                    false,
                    dealLineCondition.Id
                )
            );
            return;
        }

        this.DealLine = dealLine;
        this.LineCondition = dealLineCondition;

        // Check if Commitment Unit of measure is provided when Commitment Quantity is provided.
        if (
            dealLineCondition != null && !dealLineCondition.Vistex_ZO2C_E1KONP_CPQ__r.isEmpty() &&
            CommitmentQuantity != null &&
            CommitmentQuantity > 0 &&
            String.isBlank(CommitmentQuantityUnitOfMeasure)
        ) {
            System.Debug(
                '[dealLineCondition] Commitment UOM is missing for a record that has a commitment quantity ' + dealLineCondition.Id
            );
            validationResults.add(
                CPQ_VistexDealValidator.createResult(
                    '- Deal Line Condition ' +
                    dealLineCondition.Id +
                    ' Commitment UOM is missing for a record that has a commitment quantity.',
                    false,
                    dealLineCondition.Id
                )
            );
        }
    }

    /**
     * @description : A list of validations about this deal line
     */
    public List<CPQ_VistexDealValidator.DealValidationResult> validationResults { get; private set; }

    /**
     * @description : The deal line record that this information was sourced from
     */
    public Vistex_Deal_Line_E1KOMG__c DealLine { get; private set; }

    /**
     * @description : The child condition for this deal line
     */
    public Condition_Header_E1KONH__c LineCondition { get; private set; }

    /**
     * @description Deal Line ID.
     */
    public Id DealLideId {
        get {
            return DealLine.Id;
        }
    }

    /**
     * @description Deal Line Type. Posible values: ZANC, ZCON, ZDEV
     */
    public String LineType {
        get {
            return DealLine.KSCHL__c;
        }
    }

    /**
     * @description Deal Line Suffix
     */
    public String Suffix {
        get {
            return DealLine.EBONU__c;
        }
    }

    /**
     * @description : identifies if this deal line has a specific or aggregeate commitment
     */
    public Double CommitmentQuantity {
        get {
            return LineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].ZCOMMIT_QTY__c == null
                ? null
                : Double.valueOf(LineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].ZCOMMIT_QTY__c);
        }
    }

    /**
     * @description : identifies if this deal line has Commitment Change Approval Required
     */
    public Boolean CommitmentChangeApprovalRequired {
        get {
            return LineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].Commitment_Change_Approval_Required__c;
        }
    }

    /**
     * @description : identigies if RX, Dx or null Aggr Commitment
     */
    public String AggregateCommitmentType {
        get {
            return LineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].Aggregate_Commitment_Type__c;
        }
    }

    /**
     * @description
     */
    public String CommitmentQuantityUnitOfMeasure {
        get {
            return LineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].ZCOMMITQTY_UOM__c;
        }
    }

    /**
     * @description
     */
    public Double CommitmentValue {
        get {
            return LineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].ZCOMMIT_VALUE__c == null
                ? null
                : Double.valueOf(LineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].ZCOMMIT_VALUE__c);
        }
    }

    /**
     * @description
     */
    public String CommitmentTerm {
        get {
            return LineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].ZCOMMIT_TERM__c;
        }
    }

    /**
     * @description Default supplier to be used when 'Ship By' field is null or has an unespected value.
     */
    private static final String DEFAULT_SUPPLIER = 'Zoetis';

    /**
     * @description Indicates the default supplier for the line.
     * Mapping: 01 -> Zoetis, 02 -> Distributor, 03 -> Co-Sourced
     */
    public String Supplier {
        get {
            String shipBy = LineCondition.Vistex_ZO2C_E1KONP_CPQ__r[0].Ship_By__c;

            switch on shipBy {
                when '01' {
                    return 'Zoetis';
                }
                when '02' {
                    return 'Distributor';
                }
                when '03' {
                    return 'Co-Sourced';
                }
                when else {
                    return DEFAULT_SUPPLIER;
                }
            }
        }
    }

    /**
     * Abstract method that should be implemented in every specific type of Deal Line.
     * Returns the number of Product Options that will be created by this specific deal line.
     */
    public abstract Integer getNumberOfProductOptions();

    /**
     * Abstract method that should be implemented in every specific type of Deal Line.
     * Depending on the line type and the configuration, the Product Options will be created and configured accordingly.
     */
    public abstract List<SBQQ__ProductOption__c> getRelatedProductOptions(Product2 parentProduct, Integer optionNumber, Boolean largeOffer);

    /**
     * Abstract method that should be implemented in every specific type of Deal Line.
     * Depending on the line type and the configuration, the Product Options will be created and configured accordingly.
     */
    public List<SBQQ__ProductOption__c> getRelatedProductOptions(Product2 parentProduct, Integer optionNumber) {
        return getRelatedProductOptions(parentProduct, optionNumber, false);
    }

    /**
     * Abstract method that should be implemented in every specific type of Deal Line.
     * Depending on the line type and the configuration, the Product Options will be created and configured accordingly.
     */
    public List<SBQQ__ProductOption__c> getRelatedProductOptions(Product2 parentProduct) {
        return getRelatedProductOptions(parentProduct, 10, false);
    }

    /**
     * @description
     */
    public Boolean isLease(String cpqMaterialType, String leaseType) {
        if (
            (cpqMaterialType == 'Device' ||
            cpqMaterialType == 'Operational Lease' ||
            cpqMaterialType == 'Service Item with Billing Plan') && (leaseType == 'Operating Lease' || leaseType == 'Sales Type Lease')
        ) {
            return true;
        } else {
            return false;
        }
    }
}