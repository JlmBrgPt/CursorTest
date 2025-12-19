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
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact con : newContacts) {
            // Check if AccountId is present and if address needs updating
            if (con.AccountId != null) {
                Boolean shouldUpdate = false;
                
                if (oldContactsMap == null) {
                    // This is an insert - always update
                    shouldUpdate = true;
                } else {
                    // This is an update
                    Contact oldContact = oldContactsMap.get(con.Id);
                    if (oldContact != null) {
                        // Determine if we should update based on the specific business logic:
                        // 1. If AccountId changed - always update
                        // 2. If AccountId unchanged, only update if any address field is empty/null
                        // 3. If all address fields are populated AND AccountId unchanged - don't update
                        
                        if (con.AccountId != oldContact.AccountId) {
                            // AccountId changed - always update
                            shouldUpdate = true;
                        } else {
                            // AccountId unchanged - check address fields
                            // If any address field is null or empty, update
                            if (
                                con.MailingStreet == null || 
                                con.MailingStreet.trim() == '' ||
                                con.MailingCity == null || 
                                con.MailingCity.trim() == '' ||
                                con.MailingState == null || 
                                con.MailingState.trim() == '' ||
                                con.MailingPostalCode == null || 
                                con.MailingPostalCode.trim() == ''
                            ) {
                                shouldUpdate = true;
                            }
                            // If all fields are populated and AccountId unchanged, don't update
                        }
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
                    // Preserve empty strings from Account to Contact (important for test case)
                    con.MailingStreet = acc.BillingStreet;
                    con.MailingCity = acc.BillingCity;
                    con.MailingState = acc.BillingState;
                    con.MailingPostalCode = acc.BillingPostalCode;
                }
            }
        }
    }
}
