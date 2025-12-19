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
                // For insert, always update
                // For update, only update if AccountId changed or address fields are empty
                Boolean shouldUpdate = false;
                if (oldContactsMap == null) {
                    // This is an insert
                    shouldUpdate = true;
                } else {
                    // This is an update
                    Contact oldContact = oldContactsMap.get(con.Id);
                    if (oldContact != null) {
                        if (
                            con.AccountId != oldContact.AccountId ||
                            String.isBlank(con.MailingStreet) ||
                            String.isBlank(con.MailingCity) ||
                            String.isBlank(con.MailingState) ||
                            String.isBlank(con.MailingPostalCode)
                        ) {
                            shouldUpdate = true;
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
                    con.MailingStreet = acc.BillingStreet;
                    con.MailingCity = acc.BillingCity;
                    con.MailingState = acc.BillingState;
                    con.MailingPostalCode = acc.BillingPostalCode;
                }
            }
        }
    }
}

