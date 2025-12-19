public with sharing class ContactTriggerHandler {
    /**
     * Updates Contact mailing address from Account billing address
     * @param newContacts List of new or updated Contacts
     * @param oldContactsMap Map of old Contact values (null for insert)
     */
    public static void updateAddressFromAccount(
        List<Contact> newContacts,
        Map<Id, Contact> oldContactsMap
    ) {
        // Collect Account IDs that need to be queried
        Set<Id> accountIds = new Set<Id>();
        
        // Identify contacts that need address updates
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Contact con : newContacts) {
            // Only process contacts that have an AccountId
            if (con.AccountId != null) {
                // Determine if we should update the contact address
                Boolean shouldUpdate = false;
                
                // For inserts, always update
                if (oldContactsMap == null) {
                    shouldUpdate = true;
                } else {
                    // For updates, check if we should update based on business logic
                    Contact oldContact = oldContactsMap.get(con.Id);
                    if (oldContact != null) {
                        // Update if AccountId has changed OR if any address field is null/empty
                        if (con.AccountId != oldContact.AccountId) {
                            // AccountId changed - always update
                            shouldUpdate = true;
                        } else {
                            // AccountId unchanged - update if any address field is missing
                            if (String.isBlank(con.MailingStreet) ||
                                String.isBlank(con.MailingCity) ||
                                String.isBlank(con.MailingState) ||
                                String.isBlank(con.MailingPostalCode)) {
                                shouldUpdate = true;
                            }
                        }
                    } else {
                        // No old contact found - likely an insert scenario
                        shouldUpdate = true;
                    }
                }
                
                if (shouldUpdate) {
                    accountIds.add(con.AccountId);
                    contactsToUpdate.add(con);
                }
            }
        }

        // Query Account addresses
        if (!accountIds.isEmpty()) {
            Map<Id, Account> accountMap = new Map<Id, Account>(
                [
                    SELECT
                        Id,
                        BillingStreet,
                        BillingCity,
                        BillingState,
                        BillingPostalCode
                    FROM Account
                    WHERE Id IN :accountIds
                ]
            );

            // Update Contact addresses from Account addresses
            for (Contact con : contactsToUpdate) {
                Account acc = accountMap.get(con.AccountId);
                if (acc != null) {
                    // Copy billing address fields from Account to Contact mailing address fields
                    con.MailingStreet = acc.BillingStreet;
                    con.MailingCity = acc.BillingCity;
                    con.MailingState = acc.BillingState;
                    con.MailingPostalCode = acc.BillingPostalCode;
                }
            }
        }
    }
}
