@isTest
public with sharing class CSE_RegexUtilityTest {
    

    static testMethod void isRegexValidPassingStringTest() {
        String string1 = 'ascanhsjncac';
        String string2 = '156185184157';
        String String3 = 'aocz12355';

        Pattern regexPattern = Pattern.compile('^[\\p{ASCII}\\. \'-]+$');

        Boolean shouldBeTrueString1 = CSE_RegexUtility.isRegexValid(string1);
        Boolean shouldBeTrueString2 = CSE_RegexUtility.isRegexValid(String2);
        Boolean shouldBeTrueString3 = CSE_RegexUtility.isRegexValid(String3);

        System.assertEquals(true, shouldBeTrueString1, 'Valid string failed to pass regex: '+ '\'shouldBeTrueString1\'');
        System.assertEquals(true, shouldBeTrueString2, 'Valid string failed to pass regex: '+ '\'shouldBeTrueString2\'');
        System.assertEquals(true, shouldBeTrueString3, 'Valid string failed to pass regex: '+ '\'shouldBeTrueString3\'');
    } 

    static testMethod void isRegexValidFailingStringTest() {
        System.assert(!CSE_RegexUtility.isRegexValid('¿'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('À È Ì Ò Ù Ỳ Ǹ Ẁ	`A	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Á É Í Ó Ú Ý Ć Ǵ Ḱ Ĺ Ḿ Ń Ṕ Ŕ Ś Ẃ Ź	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Â Ê Î Ô Û Ŷ Ĉ Ĝ Ĥ Ĵ Ŝ Ŵ Ẑ	^A'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ã Ẽ Ĩ Õ Ũ Ỹ Ñ Ṽ	~A'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ä Ë Ï Ö Ü Ÿ Ḧ Ẅ Ẍ ẗ	"A'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Å Ů ẘ ẙ	oA'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ā Ē Ī Ō Ū Ȳ Ḡ	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ă Ĕ Ĭ Ŏ Ŭ Ğ	UA |'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ą Ę Į Ǫ Ų	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ǎ Ě Ǐ Ǒ Ǔ Č Ď Ǧ Ȟ ǰ Ǩ Ľ Ň Ř Š Ť Ž	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ɨ Ø ƀ Đ Ǥ Ħ Ł Ŧ Ƶ	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ȩ Ç Ḑ Ģ Ḩ Ķ Ļ Ņ Ŗ Ş Ţ	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ő Ű	=O	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('ǖ ǘ ǚ ǜ	_"u'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Æ æ	AE ae	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Œ œ	OE oe	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ð ð	DH dh'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Þ þ	TH th	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('Ŋ ŋ	NG ng	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('ẞ ß	SS ss	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('ſ ſ	fS fs	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('İ ı	I. i.	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('ĸ	kk	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('ə	ee'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('ʻ'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('ⁱ ⁿ ª º	^_i ^_n ^_a ^_o	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('ʰ ʲ ˡ ʳ ˢ ʷ ˣ ʸ	^_h^_j^_l^_r^_s ^_w^_x^_y	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹	^0'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('⁽ ⁺ ⁼ ⁾	^('), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₍ ₊ ₌ ₎	_('), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉	_0	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('½⅓¼⅕⅙⅐⅛⅑ ⅔⅖ ¾⅗ ⅘ ⅚⅝ ⅞	12'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('± × ÷ √	+- xx :- | -: v/ | /v	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('≠ ≤ ≥ ≡	/= <= >= =_	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('← → ⇒	<- -> =;>	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('∴ ∵	.: :.	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('¦ ¬ ⋄	!^ -, | ,- <> | ><'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('° ∞ ‰	oo 88 %o	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('µ ∅	mu {}	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('«»<<>>'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('‹ ›	.< .>	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('“ ”	"< | <" "> | >"'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('‘ ’	\'< | <\' \'> | >\''), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('‚ „	|  " | "'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('〞〝	"/ "\\	'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('¡'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('¿'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('§'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('¶'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('…'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('·'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('¸'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid(' '), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('–'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('—'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('©'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('®'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('℠'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('™'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₥'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('¢'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('¤'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('€'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('£'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₡'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('¥'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₦'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₨'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₩'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('฿'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₫'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₠'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₣'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₤'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₧'), 'Special character should have failed regex: ');
        System.assert(!CSE_RegexUtility.isRegexValid('₢'), 'Special character should have failed regex: ');
    } 


    static testMethod void getFieldsApiNameTest() {
        Set<String> fields = CSE_RegexUtility.getFieldsApiName('Contact', 'Regex_Validation');
        System.assertEquals(fields.size(), 5);
        
        Boolean fieldSetContainsMailingCity = fields.contains('MailingCity');
        Boolean fieldSetContainsMailingCountry = fields.contains('MailingCountry');
        Boolean fieldSetContainsMailingPostalCode = fields.contains('MailingPostalCode');
        Boolean fieldSetContainsMailingStreet = fields.contains('MailingStreet');
        Boolean fieldSetContainsMailingState = fields.contains('MailingState');
        
        System.assert(fieldSetContainsMailingCity, 'Field set missing field: '+fieldSetContainsMailingCity);
        System.assert(fieldSetContainsMailingCountry, 'Field set missing field: '+fieldSetContainsMailingCountry);
        System.assert(fieldSetContainsMailingPostalCode, 'Field set missing field: '+fieldSetContainsMailingPostalCode);
        System.assert(fieldSetContainsMailingStreet, 'Field set missing field: '+fieldSetContainsMailingStreet);
        System.assert(fieldSetContainsMailingState, 'Field set missing field: '+fieldSetContainsMailingState);
    }
}