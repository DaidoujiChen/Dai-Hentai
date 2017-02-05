/*************************************************************************
 *
 * REALM CONFIDENTIAL
 * __________________
 *
 *  [2011] - [2015] Realm Inc
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Realm Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Realm Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Realm Incorporated.
 *
 **************************************************************************/

#ifndef REALM_UTIL_ENCRYPTION_NOT_SUPPORTED_EXCEPTION_HPP
#define REALM_UTIL_ENCRYPTION_NOT_SUPPORTED_EXCEPTION_HPP

#include <stdexcept>

namespace realm {
namespace util {

struct EncryptionNotSupportedOnThisDevice: std::runtime_error {
    EncryptionNotSupportedOnThisDevice(): std::runtime_error("Encryption is not supported on this device") { }
};

}
}

#endif //REALM_UTIL_ENCRYPTION_NOT_SUPPORTED_EXCEPTION_HPP
