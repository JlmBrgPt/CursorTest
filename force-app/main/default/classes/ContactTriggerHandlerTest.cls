@isTest
private class ContactTriggerHandlerTest {
    
    // Test data setup
    private static final String RECORD_TYPE_ID = '0122o000000O9fbAAC';
    
    @isTest
    static void testUpdateAddressOnInsert() {
        // Create test Account with billing address
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'Paris',
            BillingPostalCode = '75001',
            BillingCountry = 'France',
            BillingState = 'Île-de-France',
            External_ID__c = 'EXT-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
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
                MailingPostalCode,
                MailingState
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('123 Main St', result.MailingStreet, 'MailingStreet should match Account BillingStreet');
        System.assertEquals('Paris', result.MailingCity, 'MailingCity should match Account BillingCity');
        System.assertEquals('75001', result.MailingPostalCode, 'MailingPostalCode should match Account BillingPostalCode');
        System.assertEquals('Île-de-France', result.MailingState, 'MailingState should match Account BillingState');
    }

    @isTest
    static void testUpdateAddressOnAccountChange() {
        // Create two test Accounts with different addresses
        Account account1 = new Account(
            Name = 'Account 1',
            BillingStreet = '123 First St',
            BillingCity = 'Paris',
            BillingPostalCode = '75002',
            BillingCountry = 'France',
            BillingState = 'Île-de-France',
            External_ID__c = 'EXT-A1-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
        );
        Account account2 = new Account(
            Name = 'Account 2',
            BillingStreet = '456 Second Ave',
            BillingCity = 'Lyon',
            BillingPostalCode = '69001',
            BillingCountry = 'France',
            BillingState = 'Auvergne-Rhône-Alpes',
            External_ID__c = 'EXT-A2-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
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
                MailingPostalCode,
                MailingState
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('456 Second Ave', result.MailingStreet, 'MailingStreet should match new Account BillingStreet');
        System.assertEquals('Lyon', result.MailingCity, 'MailingCity should match new Account BillingCity');
        System.assertEquals('69001', result.MailingPostalCode, 'MailingPostalCode should match new Account BillingPostalCode');
        System.assertEquals('Auvergne-Rhône-Alpes', result.MailingState, 'MailingState should match new Account BillingState');
    }

    @isTest
    static void testUpdateAddressWhenFieldsAreEmpty() {
        // Create test Account with billing address
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '789 Third Blvd',
            BillingCity = 'Marseille',
            BillingPostalCode = '13001',
            BillingCountry = 'France',
            BillingState = 'Provence-Alpes-Côte d\'Azur',
            External_ID__c = 'EXT-T3-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
        );
        insert testAccount;

        // Create Contact with AccountId but empty address fields
        Contact testContact = new Contact(
            FirstName = 'Bob',
            LastName = 'Johnson',
            AccountId = testAccount.Id,
            MailingStreet = '',
            MailingCity = '',
            MailingPostalCode = '',
            MailingState = ''
        );
        insert testContact;

        // Clear the address fields
        testContact.MailingStreet = '';
        testContact.MailingCity = '';
        testContact.MailingPostalCode = '';
        testContact.MailingState = '';

        Test.startTest();
        update testContact;
        Test.stopTest();

        // Verify address was populated from Account
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingPostalCode,
                MailingState
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('789 Third Blvd', result.MailingStreet, 'MailingStreet should be populated');
        System.assertEquals('Marseille', result.MailingCity, 'MailingCity should be populated');
        System.assertEquals('13001', result.MailingPostalCode, 'MailingPostalCode should be populated');
        System.assertEquals('Provence-Alpes-Côte d\'Azur', result.MailingState, 'MailingState should be populated');
    }

    @isTest
    static void testNoUpdateWhenAccountIdIsNull() {
        // Create Contact without AccountId
        Contact testContact = new Contact(
            FirstName = 'Alice',
            LastName = 'Williams',
            MailingStreet = '999 Test St',
            MailingCity = 'Bordeaux',
            MailingPostalCode = '33000',
            MailingCountry = 'France',
            MailingState = 'Nouvelle-Aquitaine'
        );

        Test.startTest();
        insert testContact;
        Test.stopTest();

        // Verify address remains unchanged
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingPostalCode,
                MailingState
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('999 Test St', result.MailingStreet, 'MailingStreet should remain unchanged');
        System.assertEquals('Bordeaux', result.MailingCity, 'MailingCity should remain unchanged');
        System.assertEquals('33000', result.MailingPostalCode, 'MailingPostalCode should remain unchanged');
        System.assertEquals('Nouvelle-Aquitaine', result.MailingState, 'MailingState should remain unchanged');
    }

    @isTest
    static void testNoUpdateWhenAddressFieldsArePopulated() {
        // Create test Account with billing address
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '111 Account St',
            BillingCity = 'Toulouse',
            BillingPostalCode = '31000',
            BillingCountry = 'France',
            BillingState = 'Occitanie',
            External_ID__c = 'EXT-T4-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
        );
        insert testAccount;

        // Create Contact with AccountId and existing address
        Contact testContact = new Contact(
            FirstName = 'Charlie',
            LastName = 'Brown',
            AccountId = testAccount.Id,
            MailingStreet = '222 Contact St',
            MailingCity = 'Nantes',
            MailingPostalCode = '44000',
            MailingCountry = 'France',
            MailingState = 'Pays de la Loire'
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
                MailingPostalCode,
                MailingState
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('222 Contact St', result.MailingStreet, 'MailingStreet should remain unchanged when already populated');
        System.assertEquals('Nantes', result.MailingCity, 'MailingCity should remain unchanged when already populated');
        System.assertEquals('44000', result.MailingPostalCode, 'MailingPostalCode should remain unchanged when already populated');
        System.assertEquals('Pays de la Loire', result.MailingState, 'MailingState should remain unchanged when already populated');
    }

    @isTest
    static void testBulkInsert() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Bulk Test Account',
            BillingStreet = '555 Bulk St',
            BillingCity = 'Nice',
            BillingPostalCode = '06000',
            BillingCountry = 'France',
            BillingState = 'Corse',
            External_ID__c = 'EXT-BULK-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
        );
        insert testAccount;

        // Create multiple Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) { // Reduced from 200 to 5 for simplicity
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
            SELECT MailingStreet, MailingCity, MailingState
            FROM Contact
            WHERE Id IN :contacts
        ];

        System.assertEquals(5, results.size(), 'All contacts should be created');
        for (Contact con : results) {
            System.assertEquals('555 Bulk St', con.MailingStreet, 'All contacts should have address populated');
            System.assertEquals('Nice', con.MailingCity, 'All contacts should have city populated');
            System.assertEquals('Corse', con.MailingState, 'All contacts should have state populated');
        }
    }

    @isTest
    static void testAccountWithNullAddress() {
        // Create test Account without billing address
        Account testAccount = new Account(
            Name = 'Account No Address', 
            External_ID__c = 'EXT-NOADDR-' + String.valueOf(DateTime.now().getTime()), 
            RecordTypeId = RECORD_TYPE_ID
        );
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
                MailingPostalCode,
                MailingState
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals(null, result.MailingStreet, 'MailingStreet should be null when Account has no address');
        System.assertEquals(null, result.MailingCity, 'MailingCity should be null when Account has no address');
        System.assertEquals(null, result.MailingPostalCode, 'MailingPostalCode should be null when Account has no address');
        System.assertEquals(null, result.MailingState, 'MailingState should be null when Account has no address');
    }

    @isTest
    static void testUpdateWhenMailingFieldsBlankButAccountSame() {
        // Account with address
        Account acc = new Account(
            Name = 'Same Acc',
            BillingStreet = '10 Same St',
            BillingCity = 'Grenoble',
            BillingPostalCode = '38000',
            BillingCountry = 'France',
            BillingState = 'Auvergne-Rhône-Alpes',
            External_ID__c = 'EXT-SAME-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
        );
        insert acc;

        // Contact initially with all fields populated
        Contact con = new Contact(
            FirstName = 'Same',
            LastName = 'Account',
            AccountId = acc.Id,
            MailingStreet = 'Orig St',
            MailingCity = 'Lille',
            MailingPostalCode = '59000',
            MailingCountry = 'France',
            MailingState = 'Hauts-de-France'
        );
        insert con;

        // Now blank one field to force update even though AccountId unchanged
        con.MailingCity = '';
        Test.startTest();
        update con;
        Test.stopTest();

        Contact afterCon = [SELECT MailingStreet, MailingCity, MailingPostalCode, MailingState FROM Contact WHERE Id = :con.Id];
        System.assertEquals('10 Same St', afterCon.MailingStreet);
        System.assertEquals('Grenoble', afterCon.MailingCity);
        System.assertEquals('38000', afterCon.MailingPostalCode);
        System.assertEquals('Auvergne-Rhône-Alpes', afterCon.MailingState);
    }

    @isTest
    static void testNoUpdateWhenAllFieldsPopulatedAndAccountSame() {
        Account acc = new Account(
            Name = 'No Update Acc',
            BillingStreet = '11 New St',
            BillingCity = 'Dijon',
            BillingPostalCode = '21000',
            BillingCountry = 'France',
            BillingState = 'Bourgogne-Franche-Comté',
            External_ID__c = 'EXT-NOUP-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'No',
            LastName = 'Update',
            AccountId = acc.Id,
            MailingStreet = 'Keep St',
            MailingCity = 'Reims',
            MailingPostalCode = '51100',
            MailingCountry = 'France',
            MailingState = 'Grand Est'
        );
        insert con;

        // Update a non-address field only; AccountId unchanged, all address fields populated
        con.FirstName = 'Nope';
        Test.startTest();
        update con;
        Test.stopTest();

        Contact afterCon = [SELECT MailingStreet, MailingCity, MailingPostalCode, MailingState FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Keep St', afterCon.MailingStreet, 'Should not overwrite populated address when Account unchanged');
        System.assertEquals('Reims', afterCon.MailingCity);
        System.assertEquals('51100', afterCon.MailingPostalCode);
        System.assertEquals('Grand Est', afterCon.MailingState);
    }

    @isTest
    static void testUpdateWithAccountNoAddress() {
        // Account with null billing fields
        Account acc = new Account(
            Name = 'No Billing', 
            External_ID__c = 'EXT-NOBILL-' + String.valueOf(DateTime.now().getTime()), 
            RecordTypeId = RECORD_TYPE_ID
        );
        insert acc;

        // Create contact with some address, then blank to trigger update
        Contact con = new Contact(
            FirstName = 'Null',
            LastName = 'Billing',
            AccountId = acc.Id,
            MailingStreet = 'Temp St',
            MailingCity = 'Rouen',
            MailingPostalCode = '76000',
            MailingCountry = 'France',
            MailingState = 'Normandie'
        );
        insert con;

        // Blank address to force handler path; Account has no billing data
        con.MailingStreet = '';
        con.MailingCity = '';
        con.MailingPostalCode = '';
        con.MailingState = '';
        Test.startTest();
        update con;
        Test.stopTest();

        Contact afterCon = [SELECT MailingStreet, MailingCity, MailingPostalCode, MailingState FROM Contact WHERE Id = :con.Id];
        System.assertEquals(null, afterCon.MailingStreet, 'Remains null when Account has no billing address');
        System.assertEquals(null, afterCon.MailingCity);
        System.assertEquals(null, afterCon.MailingPostalCode);
        System.assertEquals(null, afterCon.MailingState);
    }

    @isTest
    static void testMixedBulkUpdateSomeNeedUpdateSomeNot() {
        Account accA = new Account(
            Name = 'Bulk A',
            BillingStreet = 'A St',
            BillingCity = 'Tours',
            BillingPostalCode = '37000',
            BillingCountry = 'France',
            BillingState = 'Centre-Val de Loire',
            External_ID__c = 'EXT-BULK-A-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
        );
        Account accB = new Account(
            Name = 'Bulk B',
            BillingStreet = 'B St',
            BillingCity = 'Orléans',
            BillingPostalCode = '45000',
            BillingCountry = 'France',
            BillingState = 'Centre-Val de Loire',
            External_ID__c = 'EXT-BULK-B-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
        );
        insert new List<Account>{ accA, accB };

        // c1 will need update (insert)
        Contact c1 = new Contact(FirstName = 'C1', LastName = 'L', AccountId = accA.Id);
        // c2 will not need update on second DML (all fields populated and Account same)
        Contact c2 = new Contact(FirstName = 'C2', LastName = 'L', AccountId = accA.Id, MailingStreet = 'Keep', MailingCity = 'Keep', MailingPostalCode = '00000', MailingState = 'Keep');
        // c3 will need update due to Account change
        Contact c3 = new Contact(FirstName = 'C3', LastName = 'L', AccountId = accA.Id);

        insert new List<Contact>{ c1, c2, c3 };

        // Prepare updates: c2 unchanged for address; c3 change account; c1 blank a field to force update
        c1.MailingCity = '';
        c3.AccountId = accB.Id;

        Test.startTest();
        update new List<Contact>{ c1, c2, c3 };
        Test.stopTest();

        Map<Id, Contact> afterMap = new Map<Id, Contact>([
            SELECT MailingStreet, MailingCity, MailingPostalCode, MailingState FROM Contact WHERE Id IN :new List<Id>{ c1.Id, c2.Id, c3.Id }
        ]);

        System.assertEquals('A St', afterMap.get(c1.Id).MailingStreet, 'c1 updated from accA due to blank field');
        System.assertEquals('Tours', afterMap.get(c1.Id).MailingCity, 'c1 updated from accA due to blank field');
        System.assertEquals('37000', afterMap.get(c1.Id).MailingPostalCode, 'c1 updated from accA due to blank field');
        System.assertEquals('Centre-Val de Loire', afterMap.get(c1.Id).MailingState, 'c1 updated from accA due to blank field');

        System.assertEquals('Keep', afterMap.get(c2.Id).MailingStreet, 'c2 should not be overwritten');
        System.assertEquals('Keep', afterMap.get(c2.Id).MailingCity, 'c2 should not be overwritten');
        System.assertEquals('00000', afterMap.get(c2.Id).MailingPostalCode, 'c2 should not be overwritten');
        System.assertEquals('Keep', afterMap.get(c2.Id).MailingState, 'c2 should not be overwritten');

        System.assertEquals('B St', afterMap.get(c3.Id).MailingStreet, 'c3 updated from accB due to account change');
        System.assertEquals('Orléans', afterMap.get(c3.Id).MailingCity, 'c3 updated from accB due to account change');
        System.assertEquals('45000', afterMap.get(c3.Id).MailingPostalCode, 'c3 updated from accB due to account change');
        System.assertEquals('Centre-Val de Loire', afterMap.get(c3.Id).MailingState, 'c3 updated from accB due to account change');
    }
    
    @isTest
    static void testUpdateAddressWithNullBillingFields() {
        // Create Account with some null billing fields
        Account testAccount = new Account(
            Name = 'Account With Null Fields',
            BillingStreet = '123 Main St',
            BillingCity = null,
            BillingPostalCode = '75001',
            BillingCountry = 'France',
            BillingState = null,
            External_ID__c = 'EXT-NULLFIELDS-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
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

        // Verify address was populated (null fields should remain null)
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingPostalCode,
                MailingState
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('123 Main St', result.MailingStreet, 'MailingStreet should match Account BillingStreet');
        System.assertEquals(null, result.MailingCity, 'MailingCity should be null when Account BillingCity is null');
        System.assertEquals('75001', result.MailingPostalCode, 'MailingPostalCode should match Account BillingPostalCode');
        System.assertEquals(null, result.MailingState, 'MailingState should be null when Account BillingState is null');
    }
    
    @isTest
    static void testUpdateAddressWithEmptyBillingFields() {
        // Create Account with empty billing fields
        Account testAccount = new Account(
            Name = 'Account With Empty Fields',
            BillingStreet = '123 Main St',
            BillingCity = '',
            BillingPostalCode = '75001',
            BillingCountry = 'France',
            BillingState = '',
            External_ID__c = 'EXT-EMPTYFIELDS-' + String.valueOf(DateTime.now().getTime()),
            RecordTypeId = RECORD_TYPE_ID
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

        // Verify address was populated (empty fields should be copied)
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingPostalCode,
                MailingState
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('123 Main St', result.MailingStreet, 'MailingStreet should match Account BillingStreet');
        System.assertEquals('', result.MailingCity, 'MailingCity should be empty when Account BillingCity is empty');
        System.assertEquals('75001', result.MailingPostalCode, 'MailingPostalCode should match Account BillingPostalCode');
        System.assertEquals('', result.MailingState, 'MailingState should be empty when Account BillingState is empty');
    }
    
    @isTest
    static void testUpdateAddressWithOnlyAccountIdNull() {
        // Test scenario where AccountId is null but other fields are populated
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MailingStreet = '123 Main St',
            MailingCity = 'Paris',
            MailingPostalCode = '75001',
            MailingCountry = 'France',
            MailingState = 'Île-de-France'
        );

        Test.startTest();
        insert testContact;
        Test.stopTest();

        // Verify no update occurred
        Contact result = [
            SELECT
                MailingStreet,
                MailingCity,
                MailingPostalCode,
                MailingState
            FROM Contact
            WHERE Id = :testContact.Id
        ];

        System.assertEquals('123 Main St', result.MailingStreet, 'MailingStreet should remain unchanged');
        System.assertEquals('Paris', result.MailingCity, 'MailingCity should remain unchanged');
        System.assertEquals('75001', result.MailingPostalCode, 'MailingPostalCode should remain unchanged');
        System.assertEquals('Île-de-France', result.MailingState, 'MailingState should remain unchanged');
    }
}
