//
//  Contacts.swift
//  this
//
//  Created by Brian Vallelunga on 12/14/15.
//  Copyright © 2015 Brian Vallelunga. All rights reserved.
//

import UIKit
import MoABContactsManager
import libPhoneNumber_iOS

let phoneUtil = NBPhoneNumberUtil()
let manager = MoABContactsManager.sharedManager()

class Contact: NSObject {
    
    class Phone {
        var label: String! = ""
        var number: String = ""
        var e164: String = ""
        var isValid: Bool = true
        
        init(label: String!, raw: String) {
            self.label = label
            
            do {
                let number = try phoneUtil.parseWithPhoneCarrierRegion(raw)
                
                self.isValid = phoneUtil.isValidNumber(number)
                self.number = try phoneUtil.format(number, numberFormat: .NATIONAL)
                self.e164 = try phoneUtil.format(number, numberFormat: .E164)
            } catch {
                self.isValid = false
            }
        }
    }

    var name: String = ""
    var phone: Phone!
    
    class func getContacts(callback: (contacts: [Contact]) -> Void) {
        var contacts: [Contact] = []
        var phones: [String: Bool] = [:]
        
        manager.sortDescriptors = [NSSortDescriptor(key: "fullName", ascending: true)]
        manager.fieldsMask = .All
        
        manager.contacts { (status, moContacts, error) -> Void in            
            if error == nil && status == .Authorized {
                for moContact in moContacts as! [MoContact] {
                    
                    if let moPhones = moContact.phones as? [[String: String]] {
                        for moPhone in moPhones {
                            let contact = Contact()
                            let phone = Phone(label: moPhone.keys.first, raw: Array(moPhone.values).last!)
                            
                            if let name = moContact.fullName {
                                contact.name = name
                            }
                            
                            contact.phone = phone
                            
                            if !contact.name.isEmpty && phone.isValid && phones[phone.number] == nil {
                                phones[phone.number] = true
                                contacts.append(contact)
                            }
                        }
                    }
                }
                
                callback(contacts: contacts)
            }
        }
    }

}
