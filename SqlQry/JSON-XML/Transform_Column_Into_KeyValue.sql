DECLARE @vJson AS NVARCHAR(MAX);

SET @vJson = '
 {
	"exostarId": "112722079",
	"mpId": "04b0851f-e7d6-4944-bd51-f6510f3d0fa1",
	"federalTaxId": null,
	"federalTaxType": "",
	"dunsNumber": "123456789",
	"parentCompanyName": "ytytyt",
	"parentCompanyFlag": true,
	"parentCompanyUsTaxId": "111111111",
	"organizationType": "C-Corporation",
	"mainAddressOne": "2964 Marine Lines Suite 498",
	"mainAddressTwo": "",
	"mainCity": "Alexandria",
	"mainProvince": "CA",
	"mainCountryCode": "US",
	"mainPostalCode": "21234234",
	"businessType": null,
	"iso9000Flag": false,
	"cmmiFlag": false,
	"cmmiLevel": "",
	"as9100Flag": false,
	"as9120Flag": false,
	"greenProductDetails": "",
	"greenPrgmInPlaceDetails": "",
	"greenPackageDetails": "",
	"ethnicityType": null,
	"diverseBusinessType": "",
	"primaryNaicsCode": "",
	"contacts": [
	{
			"contactType": "Mfg,Marketing Mgr,Debit Memo,Supplier Report Card,Parent,Main,Remit To,Mfg Mgr,Send PO,Quality Manager,Sole Proprietor,Program Return to,Return to,Accounts Receivable Mgr,Sales Mgr,RFQ Submittal,CEO,Shipping Mgr,Additional RFQ Contact,Shipped From",
			"firstName": "ccFN",
			"lastName": "ccLN",
			"jobTitle": "Chaiwalla",
			"phoneNumber": "180-055-51212",
			"emailAddr": "ravi.kollu+_cc@exostar.com",
			"cellNumber": "",
			"faxNumber": "180-155-51212",
			"webAddr": "",
			"streetAddr1": "2964 Marine Lines Suite 498",
			"streetAddr2": "",
			"city": "Alexandria",
			"province": "CA",
			"postalCode": "21234234",
			"country": "US",
			"timezone": "America/New_York"
	}
	],
	"naics": [],
	"orgBanks": [
	{
			"paymentTerms": null,
			"freightTerms": "Free on board",
			"bankName": "111",
			"bankAccountNumber": "",
			"bankRoutingNumber": "111",
			"bankSwiftCode": "111",
			"bankPocPhoneNumber": "",
			"bankPocFirstName": "",
			"bankPocLastName": "",
			"bankPocEmailAddr": "",
			"bankIb": "",
			"bankCountry": "AS"
	}
	]
 } ';

 SELECT 1
 FROM OPENJSON()