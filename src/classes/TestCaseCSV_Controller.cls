@isTest
public class TestCaseCSV_Controller
{

	 /**
     * Class wide entry point for creation of test data.
     */
    @testSetup static void dataSetup() {
		Account theAccount = new Account();
    	theAccount.Name = 'CaseCSV_BatchProcess UnitTest Account';
    	insert theAccount;

    	Case theCase = new Case();
    	theCase.AccountId = theAccount.id;
    	theCase.Subject = 'CaseCSV_BatchProcess UnitTest Case';
    	insert theCase;

  		String line1 = 'Co Number,Customer Number,Customer Name,Item Class,Item Subclass,Item SKU,Item Description,Item Quantity Sold,Item Sales Total,Period End Date\r';
  		String line2 = '1,331000,OFFICE DEPOT CONSIGNMENT,42,FB,95432,"All In One Foldable Headset,",9,85,12/31/14\r';
  		String line3 = '1,331000,OFFICE DEPOT CONSIGNMENT,42,FB,98934,Headset With Detachable,238,2349,12/31/14\r';
		String line4 = '1,331000,OFFICE DEPOT CONSIGNMENT,42,FB,98946,"All In One Headset, VOIP",162,1011,12/31/14';
  		String testcsv = line1+line2+line3+line4;

		Attachment theAttachment = new Attachment();
		theAttachment.Body = Blob.valueOf(testcsv);
		theAttachment.Name = 'test__RoyaltyProductData.csv';
		theAttachment.Description = 'A small file used for unit testing';
		theAttachment.ContentType = 'text/csv';
		theAttachment.ParentId = theCase.id; 
		insert theAttachment;


    }

	@isTest
	static void itShould() {

    	Case testCase = [SELECT Id, OwnerId, Status, Comments__c, AccountId FROM Case LIMIT 1];

		Test.startTest();
		PageReference pageToTest = Page.CaseUploadCSV;
        Test.setCurrentPage(pageToTest);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseCSV_Controller controller = new CaseCSV_Controller(stdController);
        controller.process();
		Test.stopTest();

		// Verify merchandise items got deleted 
		Integer testCount = [SELECT COUNT() FROM CV_Royalty_Data__c WHERE Royalty_Submission_Case__c = :testCase.id];
		System.assertEquals(3, testCount);

		/*
		delete [SELECT id FROM CV_Royalty_Data__c WHERE Royalty_Submission_Case__c = :theCase.id];
		delete theAttachment;
		delete theCase;
		delete theAccount;
		*/

	}
}