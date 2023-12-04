@isTest
global class ZTS_EU_MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        String jsonProductSales = '{\"salesItems\": ['+
    '    {'+
    '      \"name\": \"dummy account - Other Health Feed - Poultry\",'+
    '      \"market\": \"Taiwan\",'+
    '      \"marketIsoCode\": \"TW\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"BRAND\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016\\/03\\/30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"TWN-\",'+
    '        \"srcBusinessKey\": \"301210\",'+
    '        \"erpBusinessKey\": \"1000063132\",'+
    '        \"crmTechnicalKey\": \"001230000030KasAAE\",'+
    '        \"businessName\": \"dummy account\",'+
    '        \"accountType\": \"Vet Practice\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+    
    '        \"ratingAll\": \"K\",'+
    '        \"ratingLS\": \"A\",'+
    '        \"ratingCTFL\": \"C\",'+
    '        \"ratingCTBF\": \"B\",'+
    '        \"ratingCTDY\": \"A\",'+
    '        \"ratingPH\": \"K\",'+
    '        \"ratingVPS\": \"Non-V\",'+
    '        \"ratingSW\": \"Non-SW\",'+
    '        \"ratingRU\": \"RU-Other\",'+
    '        \"ratingPY\": \"PY4\",'+
    '        \"ratingEQ\": \"E1\",'+
    '        \"ratingCA\": \"C1\",'+
    '        \"currencyIsoCode\": \"EUR\"'+
    '      },'+
    '      \"product\": {'+
    '        \"productNameAndReportUri\": \"Other Health Feed - Poultry - <a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOPc&amp;pv1=Other Health Feed - Poultry\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"masterId\": \"E1\",'+
    '        \"srcBusinessKey\": \"1000093\",'+
    '        \"erpBusinessKey\": \"1000063132\",'+
    '        \"crmTechnicalKey\": \"001i000000zfqqAAAQ\",'+
    '        \"productName\": \"1000063132\",'+
    '        \"productType\": \"SKU\",'+
    '        \"productSalesReportUri\": \"<a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOPc&amp;pv1=Other Health Feed - Poultry\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productHierarchies\": ['+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOPcAAO\",'+
    '            \"code\": \"BRAND\",'+
    '            \"name\": \"Other Health Feed - Poultry\"'+
    '          },'+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQAAA4\",'+
    '            \"code\": \"THERAPEUTIC_GROUP\",'+
    '            \"name\": \"Poultry Bios\"'+
    '          }'+
    '        ]'+
    '      },'+
    '      \"territory\":\"0-899;2-234234\",'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 36020,'+
    '          \"currentUnits\": 19192,'+
    '          \"previousSales\": 34642,'+
    '          \"previousUnits\": 22178,'+
    '          \"diffSales\": 1378,'+
    '          \"diffUnits\": -2986,'+
    '          \"percDiffSales\": 3.98,'+
    '          \"percDiffUnits\": -13.46'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 32689,'+
    '          \"currentUnits\": 22159,'+
    '          \"previousSales\": 35435,'+
    '          \"previousUnits\": 24594,'+
    '          \"diffSales\": -2746,'+
    '          \"diffUnits\": -2435,'+
    '          \"percDiffSales\": -7.75,'+
    '          \"percDiffUnits\": -9.9'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 37320,'+
    '          \"currentUnits\": 16455,'+
    '          \"previousSales\": 33396,'+
    '          \"previousUnits\": 14954,'+
    '          \"diffSales\": 3924,'+
    '          \"diffUnits\": 1501,'+
    '          \"percDiffSales\": 11.75,'+
    '          \"percDiffUnits\": 10.04'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 36286,'+
    '          \"currentUnits\": 14417,'+
    '          \"previousSales\": 37346,'+
    '          \"previousUnits\": 19761,'+
    '          \"diffSales\": -1060,'+
    '          \"diffUnits\": -5344,'+
    '          \"percDiffSales\": -2.84,'+
    '          \"percDiffUnits\": -27.04'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 36541,'+
    '          \"currentUnits\": 16132,'+
    '          \"previousSales\": 35183,'+
    '          \"previousUnits\": 21125,'+
    '          \"diffSales\": 1358,'+
    '          \"diffUnits\": -4993,'+
    '          \"percDiffSales\": 3.86,'+
    '          \"percDiffUnits\": -23.64'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 41229,'+
    '          \"currentUnits\": 16208,'+
    '          \"previousSales\": 34479,'+
    '          \"previousUnits\": 17297,'+
    '          \"diffSales\": 6750,'+
    '          \"diffUnits\": -1089,'+
    '          \"percDiffSales\": 19.58,'+
    '          \"percDiffUnits\": -6.3'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 37288,'+
    '          \"currentUnits\": 16435,'+
    '          \"previousSales\": 33074,'+
    '          \"previousUnits\": 21015,'+
    '          \"diffSales\": 4214,'+
    '          \"diffUnits\": -4580,'+
    '          \"percDiffSales\": 12.74,'+
    '          \"percDiffUnits\": -21.79'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 35362,'+
    '          \"currentUnits\": 21737,'+
    '          \"previousSales\": 33535,'+
    '          \"previousUnits\": 26261,'+
    '          \"diffSales\": 1827,'+
    '          \"diffUnits\": -4524,'+
    '          \"percDiffSales\": 5.45,'+
    '          \"percDiffUnits\": -17.23'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 33424,'+
    '          \"currentUnits\": 20029,'+
    '          \"previousSales\": 39959,'+
    '          \"previousUnits\": 23354,'+
    '          \"diffSales\": -6535,'+
    '          \"diffUnits\": -3325,'+
    '          \"percDiffSales\": -16.35,'+
    '          \"percDiffUnits\": -14.24'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 37324,'+
    '          \"currentUnits\": 16974,'+
    '          \"previousSales\": 42080,'+
    '          \"previousUnits\": 18242,'+
    '          \"diffSales\": -4756,'+
    '          \"diffUnits\": -1268,'+
    '          \"percDiffSales\": -11.3,'+
    '          \"percDiffUnits\": -6.95'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 39658,'+
    '          \"currentUnits\": 22403,'+
    '          \"previousSales\": 37865,'+
    '          \"previousUnits\": 24577,'+
    '          \"diffSales\": 1793,'+
    '          \"diffUnits\": -2174,'+
    '          \"percDiffSales\": 4.74,'+
    '          \"percDiffUnits\": -8.85'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 36891,'+
    '          \"currentUnits\": 17548,'+
    '          \"previousSales\": 33426,'+
    '          \"previousUnits\": 23737,'+
    '          \"diffSales\": 3465,'+
    '          \"diffUnits\": -6189,'+
    '          \"percDiffSales\": 10.37,'+
    '          \"percDiffUnits\": -26.07'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 440032,'+
    '        \"previousYearSalesTotal\": 430420,'+
    '        \"diffSalesTotal\": 9612,'+
    '        \"percDiffSalesTotal\": 2.23,'+
    '        \"currentYearUnitTotal\": 219689,'+
    '        \"previousYearUnitTotal\": 257095'+
    '      }'+
    '    },'+
    '    {'+
    '      \"name\": \"dummy account - FD Swine Yelcin\",'+
    '      \"market\": \"Taiwan\",'+
    '      \"marketIsoCode\": \"TW\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"BRAND\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016\\/03\\/30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"TWN-\",'+
    '        \"srcBusinessKey\": \"301210\",'+
    '        \"crmTechnicalKey\": \"001230000030KasAAE\",'+
    '        \"businessName\": \"dummy\",'+
    '        \"accountType\": \"Vet Practice\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"TWD\"'+
    '      },'+
    '      \"product\": {'+
    '        \"productNameAndReportUri\": \"FD Swine Yelcin - <a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOQW&amp;pv1=FD Swine Yelcin\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productSalesReportUri\": \"<a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOQW&amp;pv1=FD Swine Yelcin\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productHierarchies\": ['+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQWAA4\",'+
    '            \"code\": \"BRAND\",'+
    '            \"name\": \"FD Swine Yelcin\"'+
    '          },'+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQ5AAO\",'+
    '            \"code\": \"THERAPEUTIC_GROUP\",'+
    '            \"name\": \"Other\"'+
    '          }'+
    '        ]'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 10543,'+
    '          \"currentUnits\": 6561,'+
    '          \"previousSales\": 11598,'+
    '          \"previousUnits\": 4055,'+
    '          \"diffSales\": -1055,'+
    '          \"diffUnits\": 2506,'+
    '          \"percDiffSales\": -9.1,'+
    '          \"percDiffUnits\": 61.8'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 10244,'+
    '          \"currentUnits\": 5721,'+
    '          \"previousSales\": 12188,'+
    '          \"previousUnits\": 6204,'+
    '          \"diffSales\": -1944,'+
    '          \"diffUnits\": -483,'+
    '          \"percDiffSales\": -15.95,'+
    '          \"percDiffUnits\": -7.79'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 12380,'+
    '          \"currentUnits\": 7444,'+
    '          \"previousSales\": 10376,'+
    '          \"previousUnits\": 8138,'+
    '          \"diffSales\": 2004,'+
    '          \"diffUnits\": -694,'+
    '          \"percDiffSales\": 19.31,'+
    '          \"percDiffUnits\": -8.53'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 12647,'+
    '          \"currentUnits\": 7205,'+
    '          \"previousSales\": 10641,'+
    '          \"previousUnits\": 6490,'+
    '          \"diffSales\": 2006,'+
    '          \"diffUnits\": 715,'+
    '          \"percDiffSales\": 18.85,'+
    '          \"percDiffUnits\": 11.02'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 10504,'+
    '          \"currentUnits\": 6342,'+
    '          \"previousSales\": 10304,'+
    '          \"previousUnits\": 7587,'+
    '          \"diffSales\": 200,'+
    '          \"diffUnits\": -1245,'+
    '          \"percDiffSales\": 1.94,'+
    '          \"percDiffUnits\": -16.41'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 9822,'+
    '          \"currentUnits\": 4548,'+
    '          \"previousSales\": 12341,'+
    '          \"previousUnits\": 7110,'+
    '          \"diffSales\": -2519,'+
    '          \"diffUnits\": -2562,'+
    '          \"percDiffSales\": -20.41,'+
    '          \"percDiffUnits\": -36.03'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 12778,'+
    '          \"currentUnits\": 8143,'+
    '          \"previousSales\": 11154,'+
    '          \"previousUnits\": 5836,'+
    '          \"diffSales\": 1624,'+
    '          \"diffUnits\": 2307,'+
    '          \"percDiffSales\": 14.56,'+
    '          \"percDiffUnits\": 39.53'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 11572,'+
    '          \"currentUnits\": 8545,'+
    '          \"previousSales\": 13311,'+
    '          \"previousUnits\": 7802,'+
    '          \"diffSales\": -1739,'+
    '          \"diffUnits\": 743,'+
    '          \"percDiffSales\": -13.06,'+
    '          \"percDiffUnits\": 9.52'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 12053,'+
    '          \"currentUnits\": 8318,'+
    '          \"previousSales\": 11782,'+
    '          \"previousUnits\": 4394,'+
    '          \"diffSales\": 271,'+
    '          \"diffUnits\": 3924,'+
    '          \"percDiffSales\": 2.3,'+
    '          \"percDiffUnits\": 89.3'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 14343,'+
    '          \"currentUnits\": 5495,'+
    '          \"previousSales\": 12306,'+
    '          \"previousUnits\": 4361,'+
    '          \"diffSales\": 2037,'+
    '          \"diffUnits\": 1134,'+
    '          \"percDiffSales\": 16.55,'+
    '          \"percDiffUnits\": 26'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 14547,'+
    '          \"currentUnits\": 6543,'+
    '          \"previousSales\": 11220,'+
    '          \"previousUnits\": 6249,'+
    '          \"diffSales\": 3327,'+
    '          \"diffUnits\": 294,'+
    '          \"percDiffSales\": 29.65,'+
    '          \"percDiffUnits\": 4.7'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 10682,'+
    '          \"currentUnits\": 5691,'+
    '          \"previousSales\": 13853,'+
    '          \"previousUnits\": 5892,'+
    '          \"diffSales\": -3171,'+
    '          \"diffUnits\": -201,'+
    '          \"percDiffSales\": -22.89,'+
    '          \"percDiffUnits\": -3.41'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 142115,'+
    '        \"previousYearSalesTotal\": 141074,'+
    '        \"diffSalesTotal\": 1041,'+
    '        \"percDiffSalesTotal\": 0.74,'+
    '        \"currentYearUnitTotal\": 80556,'+
    '        \"previousYearUnitTotal\": 74118'+
    '      }'+
    '    },'+
    '    {'+
    '      \"name\": \"dummy - Other Agricultural Products-Cattle\",'+
    '      \"market\": \"Taiwan\",'+
    '      \"marketIsoCode\": \"TW\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"BRAND\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016\\/03\\/30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"TWN-\",'+
    '        \"srcBusinessKey\": \"301210\",'+
    '        \"crmTechnicalKey\": \"001230000030KasAAE\",'+
    '        \"businessName\": \"dummy\",'+
    '        \"accountType\": \"Vet Practice\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"TWD\"'+
    '      },'+
    '      \"product\": {'+
    '        \"productNameAndReportUri\": \"Other Agricultural Products-Cattle - <a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOQZ&amp;pv1=Other Agricultural Products-Cattle\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productSalesReportUri\": \"<a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOQZ&amp;pv1=Other Agricultural Products-Cattle\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productHierarchies\": ['+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQZAA4\",'+
    '            \"code\": \"BRAND\",'+
    '            \"name\": \"Other Agricultural Products-Cattle\"'+
    '          },'+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQ5AAO\",'+
    '            \"code\": \"THERAPEUTIC_GROUP\",'+
    '            \"name\": \"Other\"'+
    '          }'+
    '        ]'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 48737,'+
    '          \"currentUnits\": 17847,'+
    '          \"previousSales\": 49194,'+
    '          \"previousUnits\": 20995,'+
    '          \"diffSales\": -457,'+
    '          \"diffUnits\": -3148,'+
    '          \"percDiffSales\": -0.93,'+
    '          \"percDiffUnits\": -14.99'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 47178,'+
    '          \"currentUnits\": 20261,'+
    '          \"previousSales\": 48524,'+
    '          \"previousUnits\": 22782,'+
    '          \"diffSales\": -1346,'+
    '          \"diffUnits\": -2521,'+
    '          \"percDiffSales\": -2.77,'+
    '          \"percDiffUnits\": -11.07'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 51972,'+
    '          \"currentUnits\": 16810,'+
    '          \"previousSales\": 49258,'+
    '          \"previousUnits\": 19537,'+
    '          \"diffSales\": 2714,'+
    '          \"diffUnits\": -2727,'+
    '          \"percDiffSales\": 5.51,'+
    '          \"percDiffUnits\": -13.96'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 43237,'+
    '          \"currentUnits\": 18561,'+
    '          \"previousSales\": 44853,'+
    '          \"previousUnits\": 18688,'+
    '          \"diffSales\": -1616,'+
    '          \"diffUnits\": -127,'+
    '          \"percDiffSales\": -3.6,'+
    '          \"percDiffUnits\": -0.68'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 43695,'+
    '          \"currentUnits\": 19894,'+
    '          \"previousSales\": 45943,'+
    '          \"previousUnits\": 23445,'+
    '          \"diffSales\": -2248,'+
    '          \"diffUnits\": -3551,'+
    '          \"percDiffSales\": -4.89,'+
    '          \"percDiffUnits\": -15.15'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 50937,'+
    '          \"currentUnits\": 16545,'+
    '          \"previousSales\": 50699,'+
    '          \"previousUnits\": 22426,'+
    '          \"diffSales\": 238,'+
    '          \"diffUnits\": -5881,'+
    '          \"percDiffSales\": 0.47,'+
    '          \"percDiffUnits\": -26.22'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 50990,'+
    '          \"currentUnits\": 20001,'+
    '          \"previousSales\": 46829,'+
    '          \"previousUnits\": 17672,'+
    '          \"diffSales\": 4161,'+
    '          \"diffUnits\": 2329,'+
    '          \"percDiffSales\": 8.89,'+
    '          \"percDiffUnits\": 13.18'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 42917,'+
    '          \"currentUnits\": 19162,'+
    '          \"previousSales\": 44350,'+
    '          \"previousUnits\": 22178,'+
    '          \"diffSales\": -1433,'+
    '          \"diffUnits\": -3016,'+
    '          \"percDiffSales\": -3.23,'+
    '          \"percDiffUnits\": -13.6'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 48234,'+
    '          \"currentUnits\": 13947,'+
    '          \"previousSales\": 46833,'+
    '          \"previousUnits\": 20452,'+
    '          \"diffSales\": 1401,'+
    '          \"diffUnits\": -6505,'+
    '          \"percDiffSales\": 2.99,'+
    '          \"percDiffUnits\": -31.81'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 43914,'+
    '          \"currentUnits\": 20421,'+
    '          \"previousSales\": 46725,'+
    '          \"previousUnits\": 19317,'+
    '          \"diffSales\": -2811,'+
    '          \"diffUnits\": 1104,'+
    '          \"percDiffSales\": -6.02,'+
    '          \"percDiffUnits\": 5.72'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 48622,'+
    '          \"currentUnits\": 20246,'+
    '          \"previousSales\": 42889,'+
    '          \"previousUnits\": 16748,'+
    '          \"diffSales\": 5733,'+
    '          \"diffUnits\": 3498,'+
    '          \"percDiffSales\": 13.37,'+
    '          \"percDiffUnits\": 20.89'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 46157,'+
    '          \"currentUnits\": 20069,'+
    '          \"previousSales\": 47357,'+
    '          \"previousUnits\": 20505,'+
    '          \"diffSales\": -1200,'+
    '          \"diffUnits\": -436,'+
    '          \"percDiffSales\": -2.53,'+
    '          \"percDiffUnits\": -2.13'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 566590,'+
    '        \"previousYearSalesTotal\": 563454,'+
    '        \"diffSalesTotal\": 3136,'+
    '        \"percDiffSalesTotal\": 0.56,'+
    '        \"currentYearUnitTotal\": 223764,'+
    '        \"previousYearUnitTotal\": 244745'+
    '      }'+
    '    },'+
    '    {'+
    '      \"name\": \"dummy - Rimadyl Chewable\",'+
    '      \"market\": \"Taiwan\",'+
    '      \"marketIsoCode\": \"TW\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"BRAND\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016\\/03\\/30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"TWN-\",'+
    '        \"srcBusinessKey\": \"301210\",'+
    '        \"crmTechnicalKey\": \"001230000030KasAAE\",'+
    '        \"businessName\": \"dummy\",'+
    '        \"accountType\": \"Vet Practice\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"TWD\"'+
    '      },'+
    '      \"product\": {'+
    '        \"productNameAndReportUri\": \"Rimadyl Chewable - <a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOPw&amp;pv1=Rimadyl Chewable\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productSalesReportUri\": \"<a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOPw&amp;pv1=Rimadyl Chewable\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productHierarchies\": ['+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOPwAAO\",'+
    '            \"code\": \"BRAND\",'+
    '            \"name\": \"Rimadyl Chewable\"'+
    '          },'+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOPqAAO\",'+
    '            \"code\": \"THERAPEUTIC_GROUP\",'+
    '            \"name\": \"NSAID\"'+
    '          }'+
    '        ]'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 12936,'+
    '          \"currentUnits\": 5551,'+
    '          \"previousSales\": 10993,'+
    '          \"previousUnits\": 4655,'+
    '          \"diffSales\": 1943,'+
    '          \"diffUnits\": 896,'+
    '          \"percDiffSales\": 17.67,'+
    '          \"percDiffUnits\": 19.25'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 11723,'+
    '          \"currentUnits\": 6526,'+
    '          \"previousSales\": 10463,'+
    '          \"previousUnits\": 7876,'+
    '          \"diffSales\": 1260,'+
    '          \"diffUnits\": -1350,'+
    '          \"percDiffSales\": 12.04,'+
    '          \"percDiffUnits\": -17.14'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 13105,'+
    '          \"currentUnits\": 7031,'+
    '          \"previousSales\": 11369,'+
    '          \"previousUnits\": 5164,'+
    '          \"diffSales\": 1736,'+
    '          \"diffUnits\": 1867,'+
    '          \"percDiffSales\": 15.27,'+
    '          \"percDiffUnits\": 36.15'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 12756,'+
    '          \"currentUnits\": 7777,'+
    '          \"previousSales\": 10638,'+
    '          \"previousUnits\": 6166,'+
    '          \"diffSales\": 2118,'+
    '          \"diffUnits\": 1611,'+
    '          \"percDiffSales\": 19.91,'+
    '          \"percDiffUnits\": 26.13'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 13405,'+
    '          \"currentUnits\": 4620,'+
    '          \"previousSales\": 13950,'+
    '          \"previousUnits\": 4296,'+
    '          \"diffSales\": -545,'+
    '          \"diffUnits\": 324,'+
    '          \"percDiffSales\": -3.91,'+
    '          \"percDiffUnits\": 7.54'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 15079,'+
    '          \"currentUnits\": 4122,'+
    '          \"previousSales\": 13692,'+
    '          \"previousUnits\": 8786,'+
    '          \"diffSales\": 1387,'+
    '          \"diffUnits\": -4664,'+
    '          \"percDiffSales\": 10.13,'+
    '          \"percDiffUnits\": -53.08'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 14823,'+
    '          \"currentUnits\": 5395,'+
    '          \"previousSales\": 13227,'+
    '          \"previousUnits\": 6876,'+
    '          \"diffSales\": 1596,'+
    '          \"diffUnits\": -1481,'+
    '          \"percDiffSales\": 12.07,'+
    '          \"percDiffUnits\": -21.54'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 11401,'+
    '          \"currentUnits\": 6423,'+
    '          \"previousSales\": 10918,'+
    '          \"previousUnits\": 8243,'+
    '          \"diffSales\": 483,'+
    '          \"diffUnits\": -1820,'+
    '          \"percDiffSales\": 4.42,'+
    '          \"percDiffUnits\": -22.08'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 13710,'+
    '          \"currentUnits\": 7720,'+
    '          \"previousSales\": 13689,'+
    '          \"previousUnits\": 8939,'+
    '          \"diffSales\": 21,'+
    '          \"diffUnits\": -1219,'+
    '          \"percDiffSales\": 0.15,'+
    '          \"percDiffUnits\": -13.64'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 14949,'+
    '          \"currentUnits\": 6735,'+
    '          \"previousSales\": 13086,'+
    '          \"previousUnits\": 4204,'+
    '          \"diffSales\": 1863,'+
    '          \"diffUnits\": 2531,'+
    '          \"percDiffSales\": 14.24,'+
    '          \"percDiffUnits\": 60.2'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 14569,'+
    '          \"currentUnits\": 7318,'+
    '          \"previousSales\": 11411,'+
    '          \"previousUnits\": 4454,'+
    '          \"diffSales\": 3158,'+
    '          \"diffUnits\": 2864,'+
    '          \"percDiffSales\": 27.68,'+
    '          \"percDiffUnits\": 64.3'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 14493,'+
    '          \"currentUnits\": 8068,'+
    '          \"previousSales\": 13432,'+
    '          \"previousUnits\": 8186,'+
    '          \"diffSales\": 1061,'+
    '          \"diffUnits\": -118,'+
    '          \"percDiffSales\": 7.9,'+
    '          \"percDiffUnits\": -1.44'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 162949,'+
    '        \"previousYearSalesTotal\": 146868,'+
    '        \"diffSalesTotal\": 16081,'+
    '        \"percDiffSalesTotal\": 10.95,'+
    '        \"currentYearUnitTotal\": 77286,'+
    '        \"previousYearUnitTotal\": 77845'+
    '      }'+
    '    }'+
    '  ],'+
    '        \"recordsPerPage\": 10,'+
    '        \"Offset\": 1,'+
    '   \"links\": ['+
    '          {'+
    '            \"ref\": \"previousPage\",'+
    '            \"href\": \"Rimadyl Chewable\"'+
    '          },'+
    '          {'+
    '            \"ref\": \"nextPage\",'+
    '            \"href\": \"NSAID\"'+
    '          }'+
    '        ]'+
    '}';
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonProductSales);
        res.setStatusCode(200);
        return res;
    }
}