/**************************************************************************************************
* File Name     :   AutoBundleMaterialLineWrapper 
* Description   :   Extension of the AutoBundleDealLineWrapper containing information specific to material item based deal lines (non flexible group)
* @author       :   Cesar Sandrigo @ ATG
* Modification Log
===================================================================================================
* Ver.  Date       Author               Modification
*--------------------------------------------------------------------------------------------------
* 1.0   11/11/19    Cesar Sandrigo      Created the class and added the basic functionallity.
* 2.0   02/05/19    Cory Bartholomew    Updated Descriptions.
* 2.1   06/06/20    Cesar Sandrigo      Added Product Names translated.
* 2.2   11/06/2020  Ramiro Alvarez @ ATG    CPQATG-881 - Adding unique key for product options
* 2.3   02/10/2021  Ramiro Alvarez @ ATG    CPQATG-1245 Stamp Commitment_Change_Approval_Required__c 
**************************************************************************************************/
public class AutoBundleMaterialLineWrapper extends AutoBundleDealLineWrapper {
    /**
     * @description Constructor
     * @param dealLine The related Vistex Deal Line
     * @param dealLineCondition The Deal Line condition
     * @param relatedProduct The product record related to the material
     */
    public AutoBundleMaterialLineWrapper(
        Vistex_Deal_Line_E1KOMG__c dealLine,
        Condition_Header_E1KONH__c dealLineCondition,
        Product2 relatedProduct
    ) {
        // call parent class constructor
        super(dealLine, dealLineCondition);

        // Is expected that a Material Lin has a Material Number
        if (dealLine != null && String.isBlank(dealLine.MATNR__c)) {
            validationResults.add(
                CPQ_VistexDealValidator.createResult('- Deal line ' + dealLine.Id + ' does not have a Material Number.', false, dealLine.Id)
            );
        }

        // sanity check for related product argument
        if (relatedProduct == null) {
            validationResults.add(
                CPQ_VistexDealValidator.createResult(
                    '- Deal line ' +
                    dealLine.Id +
                    ' does not have a realted product2.',
                    false,
                    dealLine.Id
                )
            );
        }

        this.Product = relatedProduct;
    }

    /**
     * @description Product record related with the Material
     */
    public Product2 Product { get; private set; }

    /**
     * @description SAP Material Number
     */
    public String MaterialNumber {
        get {
            return DealLine.MATNR__c;
        }
    }

    /**
     * @description CPQ Material Type (Device, Consumable, Warranty, Ancillary)
     */
    public String MaterialType {
        get {
            return Product.CPQ_Material_Type__c;
        }
    }

    /**
     * @description CPQ Material Type Group
     */
    public String MaterialTypeGroup {
        get {
            return Product.CPQ_Material_Type_Group__c;
        }
    }

    /**
     * @description Product Name
     */
    public String ProductName {
        get {
            return Product.Name;
        }
    }

    /**
     * @description Indicate whether the line represent an Specific Quantity Commitment or not
     */
    public Boolean IsSpecificQuantityCommitment {
        get {
            return CommitmentQuantity != null && CommitmentQuantity > 0;
        }
    }

    /**
     * @description Indicate whether the line represent an Specific Value Commitment or not
     */
    public Boolean IsSpecificValueCommitment {
        get {
            return CommitmentValue != null && CommitmentValue > 0;
        }
    }

    /**
     * @description Indicate whether the line represent an Specific Commitment or not
     */
    public Boolean IsSpecificCommitment {
        get {
            return IsSpecificQuantityCommitment || IsSpecificValueCommitment;
        }
    }

    /**
     *
     */
    private Map<String, String> langCodeProductNameMap;

    /**
     *
     */
    public Map<String, String> TranslatedProductName {
        get {
            if (langCodeProductNameMap != null) {
                return langCodeProductNameMap;
            }

            langCodeProductNameMap = new Map<String, String>();

            if (Product.SBQQ__Localizations__r == null || Product.SBQQ__Localizations__r.isEmpty()) {
                return langCodeProductNameMap;
            }

            for (SBQQ__Localization__c local : Product.SBQQ__Localizations__r) {
                if (String.isBlank(local.SBQQ__Text__c)) {
                    continue;
                }

                langCodeProductNameMap.put(local.SBQQ__Language__c, local.SBQQ__Text__c);
            }

            return langCodeProductNameMap;
        }
    }

    /**
     * Returns the number of Product Options that will be created by this specific deal line.
     */
    public override Integer getNumberOfProductOptions() {
        // Material lines will always generate one product option
        return 1;
    }

    /**
     * @description Get the Product Option that represents this line.
     */
    public override List<SBQQ__ProductOption__c> getRelatedProductOptions(
        Product2 parentProduct,
        Integer optionNumber,
        Boolean largeOffer
    ) {
        String prodOptionUniqueKey = parentProduct.ProductCode + '-' + Product.ProductCode + '-' + Suffix;

        System.debug(
            'AutoBundleMaterialLineWrapper, Commitment_Change_Approval_Required__c ' + CommitmentChangeApprovalRequired
        );

        return new List<SBQQ__ProductOption__c>{
            new SBQQ__ProductOption__c(
                SBQQ__ConfiguredSKU__c = parentProduct.Id,
                SBQQ__OptionalSKU__c = Product.Id,
                SBQQ__Number__c = optionNumber,
                SBQQ__Quantity__c = 1,
                Commitment_UOM__c = IsSpecificQuantityCommitment ? CommitmentQuantityUnitOfMeasure : null,
                Deal_Line_Group__c = Suffix,
                Flexible_Group__c = null,
                Ineligible_for_Auto_Shipping__c = false,
                CPQ_Commitment_Quantity__c = IsSpecificQuantityCommitment ? CommitmentQuantity : null,
                CPQ_Commitment_Value__c = IsSpecificValueCommitment ? CommitmentValue : null,
                SBQQ__QuantityEditable__c = true,
                SBQQ__Required__c = false,
                Sales_Type__c = null,
                SBQQ__Selected__c = true,
                Specific_Commitment__c = IsSpecificCommitment,
                Supplier__c = Supplier,
                SBQQ__Type__c = 'Related Product',
                Lease_Type__c = parentProduct.Lease_Type__c,
                Lease__c = isLease(Product.CPQ_Material_Type__c, parentProduct.Lease_Type__c),
                Valid_From__c = LineCondition.DATAB__c,
                Valid_To__c = LineCondition.DATBI__c,
                Unique_Key__c = prodOptionUniqueKey,
                Commitment_Change_Approval_Required__c = IsSpecificCommitment ? CommitmentChangeApprovalRequired : false
            )
        };
    }
}