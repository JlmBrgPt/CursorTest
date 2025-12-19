@isTest
public class ContactTriggerHandlerTest {
    
    @isTest
    static void testUpdateAddressFromAccount_Insert() {
        // Create an account with billing address
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'Test City',
            BillingState = 'CA',
            BillingPostalCode = '12345'
        );
        insert testAccount;
        
        // Create a contact without address
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id
        );
        
        // Test the handler with insert scenario (oldContactsMap is null)
        List<Contact> newContacts = new List<Contact>{testContact};
        ContactTriggerHandler.updateAddressFromAccount(newContacts, null);
        
        // Verify the contact address was updated
        Contact updatedContact = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = :testContact.Id];
        Assert.areEqual(testAccount.BillingStreet, updatedContact.MailingStreet, 'MailingStreet should match Account BillingStreet');
        Assert.areEqual(testAccount.BillingCity, updatedContact.MailingCity, 'MailingCity should match Account BillingCity');
        Assert.areEqual(testAccount.BillingState, updatedContact.MailingState, 'MailingState should match Account BillingState');
        Assert.areEqual(testAccount.BillingPostalCode, updatedContact.MailingPostalCode, 'MailingPostalCode should match Account BillingPostalCode');
    }
    
    @isTest
    static void testUpdateAddressFromAccount_UpdateAccountIdChange() {
        // Create an account with billing address
        Account testAccount1 = new Account(
            Name = 'Test Account 1',
            BillingStreet = '123 Main St',
            BillingCity = 'Test City',
            BillingState = 'CA',
            BillingPostalCode = '12345'
        );
        insert testAccount1;
        
        // Create a second account with different billing address
        Account testAccount2 = new Account(
            Name = 'Test Account 2',
            BillingStreet = '456 Oak Ave',
            BillingCity = 'Other City',
            BillingState = 'NY',
            BillingPostalCode = '67890'
        );
        insert testAccount2;
        
        // Create a contact with first account
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount1.Id,
            MailingStreet = 'Old Street',
            MailingCity = 'Old City',
            MailingState = 'OLD',
            MailingPostalCode = 'OLD123'
        );
        insert testContact;
        
        // Update the contact to point to second account
        testContact.AccountId = testAccount2.Id;
        
        // Test the handler with update scenario
        Map<Id, Contact> oldContactsMap = new Map<Id, Contact>{testContact.Id => testContact};
        List<Contact> newContacts = new List<Contact>{testContact};
        ContactTriggerHandler.updateAddressFromAccount(newContacts, oldContactsMap);
        
        // Verify the contact address was updated to second account's address
        Contact updatedContact = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = :testContact.Id];
        Assert.areEqual(testAccount2.BillingStreet, updatedContact.MailingStreet, 'MailingStreet should match Account2 BillingStreet');
        Assert.areEqual(testAccount2.BillingCity, updatedContact.MailingCity, 'MailingCity should match Account2 BillingCity');
        Assert.areEqual(testAccount2.BillingState, updatedContact.MailingState, 'MailingState should match Account2 BillingState');
        Assert.areEqual(testAccount2.BillingPostalCode, updatedContact.MailingPostalCode, 'MailingPostalCode should match Account2 BillingPostalCode');
    }
    
    @isTest
    static void testUpdateAddressFromAccount_UpdateAddressFieldsMissing() {
        // Create an account with billing address
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'Test City',
            BillingState = 'CA',
            BillingPostalCode = '12345'
        );
        insert testAccount;
        
        // Create a contact with partial address
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            MailingCity = 'Test City', // This field is populated
            MailingStreet = null, // This field is missing
            MailingState = 'CA',
            MailingPostalCode = '12345'
        );
        insert testContact;
        
        // Test the handler with update scenario
        Contact oldContact = new Contact(
            Id = testContact.Id,
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            MailingCity = 'Test City',
            MailingStreet = null,
            MailingState = 'CA',
            MailingPostalCode = '12345'
        );
        Map<Id, Contact> oldContactsMap = new Map<Id, Contact>{testContact.Id => oldContact};
        List<Contact> newContacts = new List<Contact>{testContact};
        ContactTriggerHandler.updateAddressFromAccount(newContacts, oldContactsMap);
        
        // Verify the contact address was updated (street should be filled)
        Contact updatedContact = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = :testContact.Id];
        Assert.areEqual(testAccount.BillingStreet, updatedContact.MailingStreet, 'MailingStreet should match Account BillingStreet');
        Assert.areEqual(testAccount.BillingCity, updatedContact.MailingCity, 'MailingCity should match Account BillingCity');
        Assert.areEqual(testAccount.BillingState, updatedContact.MailingState, 'MailingState should match Account BillingState');
        Assert.areEqual(testAccount.BillingPostalCode, updatedContact.MailingPostalCode, 'MailingPostalCode should match Account BillingPostalCode');
    }
    
    @isTest
    static void testUpdateAddressFromAccount_NoUpdateNeeded() {
        // Create an account with billing address
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'Test City',
            BillingState = 'CA',
            BillingPostalCode = '12345'
        );
        insert testAccount;
        
        // Create a contact with complete address
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            MailingStreet = '123 Main St',
            MailingCity = 'Test City',
            MailingState = 'CA',
            MailingPostalCode = '12345'
        );
        insert testContact;
        
        // Test the handler with update scenario (no change needed)
        Contact oldContact = new Contact(
            Id = testContact.Id,
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            MailingStreet = '123 Main St',
            MailingCity = 'Test City',
            MailingState = 'CA',
            MailingPostalCode = '12345'
        );
        Map<Id, Contact> oldContactsMap = new Map<Id, Contact>{testContact.Id => oldContact};
        List<Contact> newContacts = new List<Contact>{testContact};
        ContactTriggerHandler.updateAddressFromAccount(newContacts, oldContactsMap);
        
        // Verify the contact address was NOT updated (should remain the same)
        Contact updatedContact = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = :testContact.Id];
        Assert.areEqual('123 Main St', updatedContact.MailingStreet, 'MailingStreet should remain unchanged');
        Assert.areEqual('Test City', updatedContact.MailingCity, 'MailingCity should remain unchanged');
        Assert.areEqual('CA', updatedContact.MailingState, 'MailingState should remain unchanged');
        Assert.areEqual('12345', updatedContact.MailingPostalCode, 'MailingPostalCode should remain unchanged');
    }
    
    @isTest
    static void testUpdateAddressFromAccount_ContactWithoutAccountId() {
        // Create a contact without an account
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe'
        );
        insert testContact;
        
        // Test the handler
        List<Contact> newContacts = new List<Contact>{testContact};
        ContactTriggerHandler.updateAddressFromAccount(newContacts, null);
        
        // Verify no changes occurred
        Contact updatedContact = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Id = :testContact.Id];
        Assert.isNull(updatedContact.MailingStreet, 'MailingStreet should be null when Contact has no AccountId');
        Assert.isNull(updatedContact.MailingCity, 'MailingCity should be null when Contact has no AccountId');
        Assert.isNull(updatedContact.MailingState, 'MailingState should be null when Contact has no AccountId');
        Assert.isNull(updatedContact.MailingPostalCode, 'MailingPostalCode should be null when Contact has no AccountId');
    }
}
