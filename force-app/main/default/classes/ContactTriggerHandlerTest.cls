@isTest
private class ContactTriggerHandlerTest {
    @isTest
    static void testUpdateAddressOnInsert() {
        // Create test Account with billing address
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'San Francisco',
            BillingState = 'CA',
            BillingPostalCode = '94105',
            BillingCountry = 'USA'
        );
        insert testAccount;

        // Create Contact with AccountId
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id
        );

        Test.startTest();
        insert testContact;
        Test.stopTest();

        // Verify address was populated from Account
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('123 Main St', result.MailingStreet, 'MailingStreet should match Account BillingStreet');
        System.assertEquals('San Francisco', result.MailingCity, 'MailingCity should match Account BillingCity');
        System.assertEquals('CA', result.MailingState, 'MailingState should match Account BillingState');
        System.assertEquals('94105', result.MailingPostalCode, 'MailingPostalCode should match Account BillingPostalCode');
        System.assertEquals('USA', result.MailingCountry, 'MailingCountry should match Account BillingCountry');
    }

    @isTest
    static void testUpdateAddressOnAccountChange() {
        // Create two test Accounts with different addresses
        Account account1 = new Account(
            Name = 'Account 1',
            BillingStreet = '123 First St',
            BillingCity = 'New York',
            BillingState = 'NY',
            BillingPostalCode = '10001',
            BillingCountry = 'USA'
        );
        Account account2 = new Account(
            Name = 'Account 2',
            BillingStreet = '456 Second Ave',
            BillingCity = 'Los Angeles',
            BillingState = 'CA',
            BillingPostalCode = '90001',
            BillingCountry = 'USA'
        );
        insert new List<Account>{ account1, account2 };

        // Create Contact with first Account
        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            AccountId = account1.Id
        );
        insert testContact;

        // Update Contact to use second Account
        testContact.AccountId = account2.Id;

        Test.startTest();
        update testContact;
        Test.stopTest();

        // Verify address was updated from new Account
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('456 Second Ave', result.MailingStreet, 'MailingStreet should match new Account BillingStreet');
        System.assertEquals('Los Angeles', result.MailingCity, 'MailingCity should match new Account BillingCity');
        System.assertEquals('CA', result.MailingState, 'MailingState should match new Account BillingState');
        System.assertEquals('90001', result.MailingPostalCode, 'MailingPostalCode should match new Account BillingPostalCode');
    }

    @isTest
    static void testUpdateAddressWhenFieldsAreEmpty() {
        // Create test Account with billing address
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '789 Third Blvd',
            BillingCity = 'Chicago',
            BillingState = 'IL',
            BillingPostalCode = '60601',
            BillingCountry = 'USA'
        );
        insert testAccount;

        // Create Contact with AccountId but empty address fields
        Contact testContact = new Contact(
            FirstName = 'Bob',
            LastName = 'Johnson',
            AccountId = testAccount.Id,
            MailingStreet = '',
            MailingCity = '',
            MailingState = '',
            MailingPostalCode = '',
            MailingCountry = ''
        );
        insert testContact;

        // Clear the address fields
        testContact.MailingStreet = '';
        testContact.MailingCity = '';
        testContact.MailingState = '';
        testContact.MailingPostalCode = '';
        testContact.MailingCountry = '';

        Test.startTest();
        update testContact;
        Test.stopTest();

        // Verify address was populated from Account
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('789 Third Blvd', result.MailingStreet, 'MailingStreet should be populated');
        System.assertEquals('Chicago', result.MailingCity, 'MailingCity should be populated');
        System.assertEquals('IL', result.MailingState, 'MailingState should be populated');
        System.assertEquals('60601', result.MailingPostalCode, 'MailingPostalCode should be populated');
        System.assertEquals('USA', result.MailingCountry, 'MailingCountry should be populated');
    }

    @isTest
    static void testNoUpdateWhenAccountIdIsNull() {
        // Create Contact without AccountId
        Contact testContact = new Contact(
            FirstName = 'Alice',
            LastName = 'Williams',
            MailingStreet = '999 Test St',
            MailingCity = 'Boston',
            MailingState = 'MA',
            MailingPostalCode = '02101',
            MailingCountry = 'USA'
        );

        Test.startTest();
        insert testContact;
        Test.stopTest();

        // Verify address remains unchanged
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('999 Test St', result.MailingStreet, 'MailingStreet should remain unchanged');
        System.assertEquals('Boston', result.MailingCity, 'MailingCity should remain unchanged');
        System.assertEquals('MA', result.MailingState, 'MailingState should remain unchanged');
        System.assertEquals('02101', result.MailingPostalCode, 'MailingPostalCode should remain unchanged');
        System.assertEquals('USA', result.MailingCountry, 'MailingCountry should remain unchanged');
    }

    @isTest
    static void testNoUpdateWhenAddressFieldsArePopulated() {
        // Create test Account with billing address
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '111 Account St',
            BillingCity = 'Seattle',
            BillingState = 'WA',
            BillingPostalCode = '98101',
            BillingCountry = 'USA'
        );
        insert testAccount;

        // Create Contact with AccountId and existing address
        Contact testContact = new Contact(
            FirstName = 'Charlie',
            LastName = 'Brown',
            AccountId = testAccount.Id,
            MailingStreet = '222 Contact St',
            MailingCity = 'Portland',
            MailingState = 'OR',
            MailingPostalCode = '97201',
            MailingCountry = 'USA'
        );
        insert testContact;

        // Update Contact without changing AccountId or clearing address
        testContact.FirstName = 'Charles';

        Test.startTest();
        update testContact;
        Test.stopTest();

        // Verify address was NOT overwritten (should remain as originally set)
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('222 Contact St', result.MailingStreet, 'MailingStreet should remain unchanged when already populated');
        System.assertEquals('Portland', result.MailingCity, 'MailingCity should remain unchanged when already populated');
        System.assertEquals('OR', result.MailingState, 'MailingState should remain unchanged when already populated');
        System.assertEquals('97201', result.MailingPostalCode, 'MailingPostalCode should remain unchanged when already populated');
        System.assertEquals('USA', result.MailingCountry, 'MailingCountry should remain unchanged when already populated');
    }

    @isTest
    static void testBulkInsert() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Bulk Test Account',
            BillingStreet = '555 Bulk St',
            BillingCity = 'Denver',
            BillingState = 'CO',
            BillingPostalCode = '80201',
            BillingCountry = 'USA'
        );
        insert testAccount;

        // Create multiple Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            contacts.add(
                new Contact(
                    FirstName = 'Bulk',
                    LastName = 'Contact ' + i,
                    AccountId = testAccount.Id
                )
            );
        }

        Test.startTest();
        insert contacts;
        Test.stopTest();

        // Verify all contacts got addresses
        List<Contact> results = [
            SELECT MailingStreet, MailingCity
            FROM Contact
            WHERE Id IN :contacts
        ];

        System.assertEquals(200, results.size(), 'All contacts should be created');
        for (Contact con : results) {
            System.assertEquals('555 Bulk St', con.MailingStreet, 'All contacts should have address populated');
            System.assertEquals('Denver', con.MailingCity, 'All contacts should have city populated');
        }
    }

    @isTest
    static void testAccountWithNullAddress() {
        // Create test Account without billing address
        Account testAccount = new Account(Name = 'Account No Address');
        insert testAccount;

        // Create Contact with AccountId
        Contact testContact = new Contact(
            FirstName = 'Null',
            LastName = 'Address',
            AccountId = testAccount.Id
        );

        Test.startTest();
        insert testContact;
        Test.stopTest();

        // Verify Contact was created (no error) but address fields remain null
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingState,
                MailingPostalCode,
                MailingCountry
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals(null, result.MailingStreet, 'MailingStreet should be null when Account has no address');
        System.assertEquals(null, result.MailingCity, 'MailingCity should be null when Account has no address');
    }
}

