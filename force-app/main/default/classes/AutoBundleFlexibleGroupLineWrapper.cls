/**************************************************************************************************
* File Name     :   AutoBundleFlexibleGroupLineWrapper 
* Description   :   Extension of the AutoBundleDealLineWrapper containing information specific to flexible groups
* @author       :   Cesar Sandrigo
* Modification Log
===================================================================================================
* Ver.  Date       Author              Modification
*--------------------------------------------------------------------------------------------------
* 1.0   11/11/19   Cesar Sandrigo
* 2.0   2/5/20  Cory Bartholomew        Added descriptions   
* 2.1   11/06/2020  Ramiro Alvarez @ ATG    CPQATG-881 - Adding unique key for product options  
* 2.1   11/06/2020  Ramiro Alvarez @ ATG    CPQATG-787 - uncheck SBQQ__Selected__c if there are more than 10 related prod
* 2.2   01/27/2021  Ramiro Alvarez @ ATG    CPQATG-1270 Check select flag based on Market (deprecate CPQATG-787)
* 2.3   02/10/2021  Ramiro Alvarez @ ATG    CPQATG-1245 Stamp Commitment_Change_Approval_Required__c 
* 2.4   03/17/2021  Ramiro Alvarez @ ATG    CPQATG-1289 Stamp Aggregate_Commitment_Type__c
**************************************************************************************************/
public class AutoBundleFlexibleGroupLineWrapper extends AutoBundleDealLineWrapper {
    /**
     * @description
     */
    public AutoBundleFlexibleGroupLineWrapper(
        Vistex_Deal_Line_E1KOMG__c dealLine,
        Condition_Header_E1KONH__c dealLineCondition,
        List<Product2> relatedProducts
    ) {
        // call parent class constructor
        super(dealLine, dealLineCondition);

        // Arguments sanity check
        System.assert(
            relatedProducts != null && !relatedProducts.isEmpty(),
            '[relatedProducts] is required in FlexibleGroupInfo constructor.'
        );

        this.RelatedProducts = relatedProducts;
    }

    /**
     * @description
     */
    public String FlexibleGroupNumber {
        get {
            return dealLine.LIFNR__c;
        }
    }

    /**
     * @description Indicates whether the Flexible Group represents an Aggregate Commitment.
     */
    public Boolean IsAggregateCommitment {
        get {
            return ((CommitmentQuantity != null && CommitmentQuantity > 0) || (CommitmentValue != null && CommitmentValue > 0));
        }
    }

    /**
     * @description Indicates whether the Flexible Group is composed by consumables for rebate.
     */
    public Boolean IsRebate {
        get {
            // If it's an aggregate commitment, is not a rebate
            if (IsAggregateCommitment) {
                return false;
            }

            // If some of the related products is not a consumable, is not a rebate
            for (Product2 product : RelatedProducts) {
                if (!product.CPQ_Material_Type__c.equals('Consumable')) {
                    return false;
                }
            }

            return true;
        }
    }

    /**
     * @description
     */
    public List<Product2> RelatedProducts { get; private set; }

    /**
     * Returns the number of Product Options that will be created by this specific deal line.
     */
    public override Integer getNumberOfProductOptions() {
        return IsAggregateCommitment ? RelatedProducts.size() + 1 : RelatedProducts.size();
    }

    /**
     * @description
     */
    public override List<SBQQ__ProductOption__c> getRelatedProductOptions(
        Product2 parentProduct,
        Integer optionNumber,
        Boolean largeOffer
    ) {
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();

        // If it's an aggregate commitment, add the aggregate commitment line.
        if (IsAggregateCommitment) {
            // Get the Aggregate commitment product - FIXME: This can be query in the AutoBundleDataCollectorClass, but doing it here as for now
            Product2 aggregateCommitmentProduct = [
                SELECT Id, ProductCode
                FROM Product2
                WHERE CPQ_Material_Type__c = 'Aggregate Commitment Service Item'
                LIMIT 1
            ];

            if (aggregateCommitmentProduct != null) {
                String prodOptionUniqueKey =
                    parentProduct.ProductCode +
                    '-' +
                    aggregateCommitmentProduct.ProductCode +
                    '-' +
                    FlexibleGroupNumber +
                    '-' +
                    Suffix;

                // Create the product option
                productOptions.add(
                    new SBQQ__ProductOption__c(
                        SBQQ__ConfiguredSKU__c = parentProduct.Id,
                        SBQQ__OptionalSKU__c = aggregateCommitmentProduct.Id,
                        SBQQ__Number__c = optionNumber,
                        SBQQ__Quantity__c = 1,
                        Commitment_UOM__c = CommitmentQuantityUnitOfMeasure,
                        Deal_Line_Group__c = Suffix, //CPQATG-1326
                        Flexible_Group__c = FlexibleGroupNumber,
                        Ineligible_for_Auto_Shipping__c = false,
                        CPQ_Commitment_Quantity__c = (CommitmentQuantity != null && CommitmentQuantity > 0) ? CommitmentQuantity : null,
                        CPQ_Commitment_Value__c = (CommitmentValue != null && CommitmentValue > 0.0) ? CommitmentValue : null,
                        SBQQ__QuantityEditable__c = true,
                        SBQQ__Required__c = true,
                        Sales_Type__c = null,
                        SBQQ__Selected__c = true,
                        Specific_Commitment__c = false,
                        Supplier__c = Supplier,
                        SBQQ__Type__c = 'Related Product',
                        Lease_Type__c = parentProduct.Lease_Type__c,
                        Unique_Key__c = prodOptionUniqueKey,
                        Commitment_Change_Approval_Required__c = IsAggregateCommitment ? CommitmentChangeApprovalRequired : false,
                        Aggregate_Commitment_Type__c = IsAggregateCommitment ? AggregateCommitmentType : null
                    )
                );

                System.debug(
                    'AutoBundleFlexibleGroupLineWrapper, aggregateCommitmentProduct != null:, prodOptionUniqueKey' + prodOptionUniqueKey
                );
                System.debug(
                    'AutoBundleFlexibleGroupLineWrapper, Commitment_Change_Approval_Required__c ' + CommitmentChangeApprovalRequired
                );

            }

            /* If it's a 'Large Offer', only the Header of the Aggregate Commitments should be created. */
            if (largeOffer) {
                return productOptions;
            }
        }

        //CPQATG-1270 Check select flag based on Market
        List<Market__c> markets = [SELECT Id, Number_for_Selected_Product_Options__c
                                  FROM Market__c
                                  WHERE Sales_Org__c = :dealLine.DEALK01_Ext_Id__r.ORGID__c
                                  ORDER BY CreatedDate DESC];        
        System.debug('AutoBundleFlexibleGroupLineWrapper, markets: ' + markets);

        for (Product2 product : RelatedProducts) {
            String prodOptionUniqueKey = parentProduct.ProductCode + '-' + product.ProductCode + '-' + FlexibleGroupNumber + '-' + Suffix;

            System.debug('AutoBundleFlexibleGroupLineWrapper, product: ' + product);
            System.debug('AutoBundleFlexibleGroupLineWrapper, prodOptionUniqueKey: ' + prodOptionUniqueKey);
            System.debug('AutoBundleFlexibleGroupLineWrapper, RelatedProducts size: ' + RelatedProducts.size());

            productOptions.add(
                new SBQQ__ProductOption__c(
                    SBQQ__ConfiguredSKU__c = parentProduct.Id,
                    SBQQ__OptionalSKU__c = product.Id,
                    SBQQ__Number__c = optionNumber += 1,
                    SBQQ__Quantity__c = 1,
                    Commitment_UOM__c = IsAggregateCommitment ? CommitmentQuantityUnitOfMeasure : null,
                    Deal_Line_Group__c = Suffix, //CPQATG-1326
                    Flexible_Group__c = FlexibleGroupNumber,
                    Ineligible_for_Auto_Shipping__c = false,
                    CPQ_Commitment_Quantity__c = null,
                    CPQ_Commitment_Value__c = null,
                    SBQQ__QuantityEditable__c = true,
                    SBQQ__Required__c = false,
                    Sales_Type__c = null,
                    //SBQQ__Selected__c = RelatedProducts.size() < 11,
                    SBQQ__Selected__c = (!markets.isEmpty() && markets[0].Number_for_Selected_Product_Options__c != null) ? RelatedProducts.size() < markets[0].Number_for_Selected_Product_Options__c : false,
                    Specific_Commitment__c = false,
                    Supplier__c = Supplier,
                    SBQQ__Type__c = 'Related Product',
                    Lease_Type__c = parentProduct.Lease_Type__c,
                    Rebate_Consumable__c = IsRebate,
                    Lease__c = isLease(product.CPQ_Material_Type__c, parentProduct.Lease_Type__c),
                    Valid_From__c = LineCondition.DATAB__c,
                    Valid_To__c = LineCondition.DATBI__c,
                    Unique_Key__c = prodOptionUniqueKey,
                    Commitment_Change_Approval_Required__c = IsAggregateCommitment ? CommitmentChangeApprovalRequired : false
                )
            );
        }

        return productOptions;
    }
}