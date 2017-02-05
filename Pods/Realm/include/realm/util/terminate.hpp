/*************************************************************************
 *
 * REALM CONFIDENTIAL
 * __________________
 *
 *  [2011] - [2012] Realm Inc
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
#ifndef REALM_UTIL_TERMINATE_HPP
#define REALM_UTIL_TERMINATE_HPP

#include <cstdlib>
#include <sstream>

#include <realm/util/features.h>
#include <realm/version.hpp>

#define REALM_TERMINATE(msg) realm::util::terminate((msg), __FILE__, __LINE__)

namespace realm {
namespace util {
REALM_NORETURN void terminate_internal(std::stringstream&) noexcept;

REALM_NORETURN void terminate(const char* message, const char* file, long line) noexcept;

template<class T, class... Ts>
REALM_NORETURN void terminate(const char* message, const char* file, long line,
                              T first_info, Ts... other_infos) noexcept
{
    std::stringstream ss;
    using variadics_unpacker = int[];

    static_assert(sizeof...(other_infos) == 1 || sizeof...(other_infos) == 3 || sizeof...(other_infos) == 5,
                  "Called realm::util::terminate() with wrong number of arguments");

    ss << file << ':' << line << ": " REALM_VER_CHUNK " " << message << " [" << first_info;
    (void) variadics_unpacker { 0, (ss << ", " << other_infos, void(), 0)... };
    ss << "]" << '\n';

    terminate_internal(ss);
}

} // namespace util
} // namespace realm

#endif // REALM_UTIL_TERMINATE_HPP
