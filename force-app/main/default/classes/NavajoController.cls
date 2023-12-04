/***********************************************************
@class      NavajoController
@brief      Controller for the Navajo (Translate Errors) component

@revision   2020-07-21  Rajnikanth
    Created.

***********************************************************/
public class NavajoController {

    /***********************************************************
    @class      LotDetails
    @brief      Initializes public variables to hold lot properties

    ***********************************************************/
    public class LotDetails{
        @auraEnabled
        public String lotExpiryDate;
        @auraEnabled
        public String lotManufactureDate;
        @auraEnabled
        public boolean isLotExpired = false ;
        @auraEnabled
        public String lotRecordId;
        @auraEnabled
        public String lotDescription;
        @auraEnabled
        public boolean noRotorFound = false;
        @AuraEnabled
        public boolean rotorMismatch = true;
    }

    /***********************************************************
    @method     	getLotDetails
    @brief      	Query lot record and returns LotDetails

    @params     	lotNumber (string), materialNum (string)
    @return type	LotDetails

    ***********************************************************/
    @AuraEnabled
    public static LotDetails getLotDetails(String lotNumber, String materialNum){
        LotDetails details = new LotDetails();
        List<Rotor_Lot__c> lotrecords = new List<Rotor_Lot__c> ();
        Rotor_Lot__c lotRecord = new Rotor_Lot__c();
        List<String> chemistries = new List<String>();        
        lotrecords = [Select id, Expiry_Date__c,Description__c,Manufactured_Date__c ,
                        Product__r.Chemistries__c,Product__r.Product_External_ID__c
                        from Rotor_Lot__c where Lot__c = :lotNumber ];
        if(lotrecords.isEmpty()){
                details.noRotorFound = true;
        }
        if(!details.noRotorFound){
            for(Rotor_Lot__c eachRec : lotrecords){
                if(eachRec.Product__r.Product_External_ID__c==materialNum){
                    lotRecord = eachRec;
                    details.rotorMismatch = false;
                    break;
                }
            }
            if(details.rotorMismatch){
                lotRecord = lotrecords[0];
            }
        }
        
        details.lotRecordId = lotrecord.Id;
        details.lotExpiryDate = String.valueOf(lotrecord.Expiry_Date__c);
        details.lotDescription   = lotrecord.Description__c;
        details.lotManufactureDate = String.valueOf(lotrecord.Manufactured_Date__c);
        details.isLotExpired = (Date.today() > lotrecord.Expiry_Date__c) ;
        return details;
    }

    /***********************************************************
    @method     	getCaseDetails
    @brief      	Query and return case record

    @params     	caseId (string)
    @return type	Case record

    ***********************************************************/
    @auraEnabled
    public static Case getCaseDetails (String caseId){
        for(Case record :[Select Id, Account.Name,Serial__c,Primary_Lot_Num__c,Primary_Consumable__r.Product_External_ID__c ,Primary_Consumable__r.Chemistries__c ,Specimen__c,Sample__c,Primary_Error_Code__r.Name
                        from Case where id = :caseId] ) return record;
        return null;
    }

    /***********************************************************
    @class      SingleErrorTranslation
    @brief      Initializes public variables to hold translated results.

    ***********************************************************/
    public class SingleErrorTranslation{
        @auraEnabled
        public List<String> displayLabels ;
        @auraEnabled
        public Map<String,List<String>> labeltoSpecificMessages ;
        @auraEnabled
        public Map<String,String> labeltoGenericMessages ;

    }

    /***********************************************************
    @class      inputErrorCode
    @brief      Initializes public variables to hold input error codes.

    ***********************************************************/
    class InputErrorCode{
        public String result, fullErrorCode;
        InputErrorCode( String result, String fullErrorCode )
        {
            this.result = result;
            this.fullErrorCode = fullErrorCode;
        }
        Boolean isValid { get { return fullErrorCode != '00000000'; } }
    }

    /***********************************************************
    @method     	getTranslationDetails
    @brief      	Process input error codes and return translated results for suppression.

    @params     	errorCodeInputDetails (List<string>)
    @return type	SingleErrorTranslation

    ***********************************************************/
    @auraEnabled
    public static SingleErrorTranslation getTranslationDetails(List<String> errorCodeInputDetails){
        SingleErrorTranslation singleError =  new SingleErrorTranslation();
        Map<String,inputErrorCode> chemlabelToHexValueMap = new Map<String,inputErrorCode>();
        String errorCode1 ='';
        String errorCode2 ='';
        for(String eachErrorCode : errorCodeInputDetails){
            Map<String, Object> errorCodeMap = (Map<String, Object>) JSON.deserializeUntyped(eachErrorCode);

            errorCode1 = ( errorCodeMap.containsKey('errorCode1')
            ? ((String) errorCodeMap.get('errorCode1')).leftPad(4,'0').toUpperCase()
            : '0000'
            );
            errorCode2 = ( errorCodeMap.containsKey('errorCode2')
            ? ((String) errorCodeMap.get('errorCode2')).leftPad(4,'0').toUpperCase()
            : '0000'
            );
            InputErrorCode iec = new InputErrorCode(
                (errorCodeMap.containsKey('result'))?(String)errorCodeMap.get('result'):'',
                errorCode1+errorCode2
            );
            // populate map with labels as key and input error codes as values; only if full errorcode != 00000000
            if(iec.isValid) chemlabelToHexValueMap.put((String)errorCodeMap.get('chemistry'), iec);
        }

        if(!chemlabelToHexValueMap.isEmpty()) singleError = fetchChemistryMessages(chemlabelToHexValueMap);
        // after calculations, return translationDetails
        return singleError;
    }

    /***********************************************************
    @method     	fetchChemistryMessages
    @brief      	Process input error codes and return translated results for suppression. Invoked by getTranslationDetails.

    @params     	errorCodeInputDetails (List<string>)
    @return type	SingleErrorTranslation

    ***********************************************************/
    static SingleErrorTranslation fetchChemistryMessages(Map<String,inputErrorCode> inputDetailsMap){
        Map<String,List<Integer>> labelToBitPositionsMap = new Map<String,List<Integer>>();
        Map<String,String> flagToDisplayLabel = new Map<String,String>();
        List<Navajo_Error_Translation_Config__mdt> etc = [Select MasterLabel,Chemistry_Error_Mask__c, Display_Label__c
                                                          from Navajo_Error_Translation_Config__mdt
                                                 		  where MasterLabel in :inputDetailsMap.keySet()];
        Set<Integer> allBitPositions = new Set<Integer>(); // generic bit positions
        Set<Integer> filteredSpecificBits = new Set<Integer>();
        Set<Integer> filteredGenericBits = new Set<Integer>();
        for(Integer i=0;i<etc.size();i++){
            Navajo_Error_Translation_Config__mdt each_etc = etc[i];
            flagToDisplayLabel.put(each_etc.MasterLabel,each_etc.Display_Label__c);
            inputErrorCode iec = inputDetailsMap.get(each_etc.MasterLabel);
            Integer[] bitPositions = getBitPositions(each_etc.Chemistry_Error_Mask__c, iec.fullErrorCode);
            labelToBitPositionsMap.put(each_etc.MasterLabel,bitPositions);
            allBitPositions.addAll(bitPositions);
        }
        List<Integer> specificBits = New List<Integer>();
        List<Integer> genericBits = New List<Integer>();
        for ( Integer i = 31; i > 8; i-- ) {
            if ( allBitPositions.contains(i) ) filteredGenericBits.add(i);
        }
        for ( Integer i = 8; i >= 0; i-- ) {
            if ( allBitPositions.contains(i) ) filteredSpecificBits.add(i);
        }
        Map<Integer,Integer> bitPostionToPriorityMap = new Map<Integer,Integer>();
        List<Navajo_Suppression_Message__mdt> chemErrorMessages = [Select Chemistry_Label__c, Bit_Position__c,Priority__c,Error_Message__c
                                                                from Navajo_Suppression_Message__mdt
                                                                where Chemistry_Label__c in :flagToDisplayLabel.keySet()
                                                                       and Bit_Position__c in :filteredSpecificBits
                                                                 ];
        List<Navajo_Suppression_Message__mdt> genericMessageRecords =[Select Chemistry_Label__c, Bit_Position__c,Priority__c,Error_Message__c
                                                                from Navajo_Suppression_Message__mdt
                                                                where Bit_Position__c in :filteredGenericBits ];
        List<Integer> priority = new List<Integer>();
        Map<String,List<String>> chemToMessageMap = new Map<String,list<String>>();
        Map<Integer,Integer> bitPos_to_PriorityMap = new Map<Integer,Integer>();
        for(Integer i =0 ; i <chemErrorMessages.size(); i++){
            Navajo_Suppression_Message__mdt sem = chemErrorMessages[i];
            // set display label Ex: ALB_BCP Label etc
            if(sem.Chemistry_Label__c != '' && sem.Chemistry_Label__c != null){
                String label = flagToDisplayLabel.get(sem.Chemistry_Label__c);
                String translatedMessage_Specific = '';
                List<String> errorMessages ;
                if(chemToMessageMap.containsKey(label)){
                    errorMessages = chemToMessageMap.get(label);
                }else{
                    errorMessages = new List<String>();
                }
                List<Integer> labelToBitsSet = labelToBitPositionsMap.get(sem.Chemistry_Label__c);
                for(Integer j : filteredSpecificBits){
                    if(j==(Integer)sem.Bit_Position__c && labelToBitsSet.contains(j)){
                        translatedMessage_Specific = (sem.Error_Message__c != null) ? '* '+sem.Error_Message__c : '';
                        errorMessages.add(translatedMessage_Specific.replace('"', ''));
                    }
                }
                chemToMessageMap.put(label,errorMessages);
            }
        }
        for(Integer i=0;i<genericMessageRecords.size();i++){
            Navajo_Suppression_Message__mdt sem = genericMessageRecords[i];
            if(sem.Priority__c != null) bitPos_to_PriorityMap.put((Integer)sem.Bit_Position__c,(Integer)sem.Priority__c);
        }
        SingleErrorTranslation se = new SingleErrorTranslation();
        se.displayLabels = flagToDisplayLabel.values();
        se.labeltoSpecificMessages = chemToMessageMap;
        Map<String,String> labelToGenericMessages = new Map<String,String>();
        for(String label : labelToBitPositionsMap.keySet()){
            String translatedMessage_Generic = '';
            List<Integer> eachFlag_GenericBitPositions = new List<Integer>();
            for(Integer position : labelToBitPositionsMap.get(label)){
                if(position >= 9){
                    eachFlag_GenericBitPositions.add(bitPos_to_PriorityMap.get(position));
                }
            }
            eachFlag_GenericBitPositions.sort();
            if(!eachFlag_GenericBitPositions.isEmpty()){
                for(Integer i =0 ; i <genericMessageRecords.size(); i++){
                    Navajo_Suppression_Message__mdt sem = genericMessageRecords[i];
                    if(sem.Priority__c == eachFlag_GenericBitPositions[0]){
                        translatedMessage_Generic = (sem.Error_Message__c != null) ? sem.Error_Message__c : '';
                        break;
                    }
                }
            }
            labelToGenericMessages.put(flagToDisplayLabel.get(label), translatedMessage_Generic.replace('"', ''));
        }
        se.labeltoGenericMessages = labelToGenericMessages;
        return se;
    }

    /***********************************************************
    @method     	updateCaseWithErrorDetails
    @brief      	Updates case record with error translation details and creates case comment record.

    @params     	caseId (string); case record id to be updated
    @params	        translationResults(string); translation results from component screen
    @params	        lotNum (string); lot number received from input component screen
    @return type	Boolean

    ***********************************************************/
    @auraEnabled
    public static Boolean updateCaseWithErrorDetails(String caseId,String translationResults, String lotNum){
        Case c = new Case(id=caseId);
        c.Error_Translation_Results__c = translationResults;
        c.Primary_Lot_Num__c = lotNum;
        c.Primary_Lot_Num_Unknown__c = String.isBlank( lotNum );
        CaseComment comment = new CaseComment(parentId = caseId);
        comment.CommentBody = 'Error Translation Results \n' + translationResults;
        try{
            update c;
            insert comment;
            return True;
        }catch (Exception ex){
            return false;
        }
    }

    /***********************************************************
    @method     	fetchCancellationLabels
    @brief      	Queries and returns cancellation Error Flag Labels from Metadata records

    @params     	N/A
    @return type	List<Navajo_Error_Flag_Label__mdt>

    ***********************************************************/

    @auraEnabled
    public static List<Navajo_Error_Flag_Label__mdt> fetchCancellationLabels(){
        return [Select Cancellation_Label__c, Byte_Size__c,Flag_Row__c,Flag_Column__c
                from Navajo_Error_Flag_Label__mdt where Type__c ='Cancellation'
                Order by Flag_Row__c ASC];
    }


    /***********************************************************
    @class      cancellationErrorDetails
    @brief      Initializes public variables to hold translated resutls for cancellation.

    ***********************************************************/
    public class cancellationErrorDetails{
        @auraEnabled
        public Map<String,String> labelToMessage ;
        @auraEnabled
        public List<String> QCMessages;
        @auraEnabled
        public List<String> SystemMessages;
        @auraEnabled
        public string QCLabel;
        @auraEnabled
        public string SysLabel;
        @auraEnabled
        public string inputErrorCode;
        @auraEnabled
        public string errorInfoString;
    }

    /***********************************************************
    @method     	getCancellationErrorDetails
    @brief      	Process input error codes and returns translated results for cancellation

    @params     	errorCodeInputDetails (List<String>)
    @return type	cancellationErrorDetails

    ***********************************************************/
    @auraEnabled
    public static cancellationErrorDetails getCancellationErrorDetails(List<String> errorCodeInputDetails){
        cancellationErrorDetails ced = new cancellationErrorDetails();
        Map<String,String> sysLabelsToValues = new Map<String,String>();
        String errorCodeValue ='';
        String QC_Flag ='';
        for(String eachInput : errorCodeInputDetails){
            Map<String, Object> errorCodeMap = (Map<String, Object>) JSON.deserializeUntyped(eachInput);
            String label = (String) errorCodeMap.get('label') ;
            Boolean mergeValues = (errorCodeMap.containsKey('mergeValues')) ? (Boolean) errorCodeMap.get('mergeValues') : false;
            switch on label{
                when 'errorcode'{
                    errorCodeValue = (String)errorCodeMap.get('errorCodeValue');
                    errorCodeValue = errorCodeValue.leftPad(4, '0');
                }
                when 'QC Flags'{
                    QC_Flag = (String) errorCodeMap.get('QCFlagValue');
                    sysLabelsToValues.put(label,QC_Flag);
                }
                when else{
                    if(mergeValues){
                        String value1 = (String) errorCodeMap.get('firstValue');
                        //padd, capatilize
                        value1 = value1.leftPad(4,'0').toUpperCase();
                        String value2 = (String) errorCodeMap.get('secondValue');
                        value2 = value2.leftPad(4,'0').toUpperCase();
                        sysLabelsToValues.put(label,value1+value2);
                    }else{
                        String value = (String) errorCodeMap.get('singleValue') ;
                        sysLabelsToValues.put(label,value.leftPad(4,'0').toUpperCase());
                    }
                }
            }
        }
        String translatedErrorCode ='';
        if(errorCodeValue !='' && errorCodeValue != null){
            ced.inputErrorCode = errorCodeValue ;
            for(Navajo_Cancellation_Message__mdt cem : [Select Message__c,Vet_Message__c,Short_Description__c from Navajo_Cancellation_Message__mdt
                                                        where Error_Code__c = : errorCodeValue limit 1]){
                                                            translatedErrorCode = (cem.Vet_Message__c != null ? cem.Vet_Message__c : cem.Message__c);
                                                            ced.inputErrorCode = errorCodeValue+'       '+cem.Short_Description__c;
                                                            ced.errorInfoString = translatedErrorCode.replace('"', '');
                                                        }
            // if no error code records
            if(translatedErrorCode=='') ced.errorInfoString = 'Not a valid error code for this type of analyzer.';
        }
        Map<String,String> syslabelToDisplayLabel = new Map<String,String>();
        Map<String,String> sysLabelToTypeMap = new Map<String,String>();
        Map<String,List<Integer>> sysLabelToBitsMap = new Map<String,List<Integer>>();
        Set<Integer> allBits = new Set<Integer>();
        List<Navajo_Error_Translation_Config__mdt> configRecs = [Select MasterLabel,System_Error_Mask__c,Type__c,Display_Label__c
                                                        from Navajo_Error_Translation_Config__mdt
                                                        where MasterLabel in :sysLabelsToValues.keySet()];
        Integer[] bitPositions = new List<Integer>();
        for(integer i = 0; i<configRecs.size(); i++){
            Navajo_Error_Translation_Config__mdt etf = configRecs[i];
            syslabelToDisplayLabel.put(etf.MasterLabel,etf.Display_Label__c);
            sysLabelToTypeMap.put(etf.MasterLabel,etf.Type__c);
            bitPositions = getBitPositions(etf.System_Error_Mask__c,sysLabelsToValues.get(etf.MasterLabel).toUpperCase());
            allBits.addAll(bitPositions);
            sysLabelToBitsMap.put(etf.MasterLabel,bitPositions);
        }
        List<Navajo_Cancellation_Message__mdt> cemRecords =[Select Type__c,Bit_Position__c,Message__c,Vet_Message__c from Navajo_Cancellation_Message__mdt
                                                         where Bit_Position__c in : allBits
                                                         and Type__c in :sysLabelToTypeMap.values() ORDER BY Type__c
                                                        ];
        Map<String,String> labelToMessage_FinalMap = new Map<String,String>();
        Map<String,List<String>> QCMsgsMap = new Map<String,List<String>>();
        String qcDisplaylabel ='';
        List<String> QCMessages = new list<String>();
        String sysDisplayLabel ='';
        List<String> SysMessages = new list<String>();
        // load count values
        for(String sysLabel : sysLabelsToValues.keySet()){
            String displayLabel = syslabelToDisplayLabel.get(sysLabel);
            if(sysLabel.contains('Count')){
                labelToMessage_FinalMap.put(displayLabel, String.valueOf(hexToInt(sysLabelsToValues.get(sysLabel))));
            }
        }
        // load remaining values
        for(String sysLabel : sysLabelToTypeMap.keySet()){
            String displayLabel = syslabelToDisplayLabel.get(sysLabel);
            String displayMessage ='';
            String errorType = sysLabelToTypeMap.get(sysLabel);
            for(Integer i = 0; i<cemRecords.size(); i++){
                Navajo_Cancellation_Message__mdt cem = cemRecords[i];
                if(cem.Type__c == errorType){
                    List<Integer> labelBits = sysLabelToBitsMap.get(sysLabel);
                    for(integer j = labelBits.size() - 1; j>=0;j--){
                        integer bitPosition = labelBits[j];
                        if((Integer)cem.Bit_Position__c == bitPosition){
                            String eachMessage = (cem.Vet_Message__c != null) ? cem.Vet_Message__c : cem.Message__c ;
                            switch on sysLabel{
                                when 'QC Flags'{
                                    qcDisplaylabel = displayLabel;
                                    displayMessage = '* '+eachMessage ;
                                    QCMessages.add(displayMessage);
                                }
                                when 'System Flags'{
                                    sysDisplayLabel = displayLabel;
                                    displayMessage = '* '+eachMessage ;
                                    SysMessages.add(displayMessage);
                                }
                                when else{
                                    displayMessage += eachMessage + ',';
                                    labelToMessage_FinalMap.put(displayLabel, displayMessage.replace('"', ''));
                                }
                            }
                        }
                    }
                }
            }
        }
        ced.QCLabel  = qcDisplaylabel;
        ced.QCMessages = QCMessages;
        ced.SysLabel = sysDisplayLabel;
        ced.SystemMessages = SysMessages;
        ced.labelToMessage = labelToMessage_FinalMap;
        return ced;
    }


    /***********************************************************
    @method             getBitPositions
    @brief              generate bit positions for a hexdata and hex mask

    @params             hexMask (string) ; mask string for chemistry
    @params             hexData(String)  ; hex input string for chemistry
    @return type        Integer[]

    ***********************************************************/
    Static integer[] getBitPositions(String hexMask,String hexData){
        Integer[] bitPositions = new List<Integer>();
        if ( hexData == null ) return null;
        hexData = hexData.toUpperCase().reverse();
        hexMask =
            (	hexMask == null                         ?	'F'.repeat( hexData.length() )
             :	hexMask.length() < hexData.length()     ?	hexMask.leftPad( hexData.length(), '0' ).toUpperCase().reverse()
             :	                                                hexMask.toUpperCase().reverse()
            );
        String[] dataChars = hexData.split( '' );
        String[] maskChars = hexMask.split( '' );
        for ( Integer index = 0; index < dataChars.size(); index++ )
        {
            Boolean[] dataBits = bitsSet.get( dataChars[index] );
            Boolean[] maskBits = bitsSet.get( maskChars[index] );
            if ( dataBits == null || maskBits == null ) return null;

            for ( Integer bitPos = 0; bitPos < 4; bitPos++ )
            {
                if ( dataBits[ bitPos ] && maskBits[ bitPos ] ) bitPositions.add( index * 4 + bitPos );
            }
        }
        return bitPositions;
    }

    /*******************************************************
bitsSet

Maps hexidecimal digits to bit states.
*******************************************************/

    private static Map<String,Boolean[]> bitsSet = new Map<String,Boolean[]>
    {
        '0' => new Boolean[]{ false, false, false, false },
        '1' => new Boolean[]{ true,  false, false, false },
        '2' => new Boolean[]{ false, true,  false, false },
        '3' => new Boolean[]{ true,  true,  false, false },
        '4' => new Boolean[]{ false, false, true,  false },
        '5' => new Boolean[]{ true,  false, true,  false },
        '6' => new Boolean[]{ false, true,  true,  false },
        '7' => new Boolean[]{ true,  true,  true,  false },
        '8' => new Boolean[]{ false, false, false, true  },
        '9' => new Boolean[]{ true,  false, false, true  },
        'A' => new Boolean[]{ false, true,  false, true  },
        'B' => new Boolean[]{ true,  true,  false, true  },
        'C' => new Boolean[]{ false, false, true,  true  },
        'D' => new Boolean[]{ true,  false, true,  true  },
        'E' => new Boolean[]{ false, true,  true,  true  },
        'F' => new Boolean[]{ true,  true,  true,  true  }
    };

    public static final List<String> hex = '0123456789abcdef'.split('');

    /***********************************************************
    @method     	hexToInt
    @brief      	generate long integer for a hex string

    @params     	str (string) ; hex string for count values
    @return type	Long

    ***********************************************************/
    public static Long hexToInt(String str) {
        str = str.toLowerCase().reverse();
        String[] hexValue = str.split('');
        Long retVal = 0;
        for(Integer i = 0; i < hexValue.size(); i++) {
            retVal = (retVal << 4) + hex.indexOf(hexValue[i]);
        }
        return -retVal & 4294967295L; //0xFFFFFFFF
    }
}