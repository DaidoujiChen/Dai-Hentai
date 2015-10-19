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
#ifndef REALM_COLUMN_FWD_HPP
#define REALM_COLUMN_FWD_HPP

#include <cstdint>

namespace realm {

// Regular classes
class ColumnBase;
class StringColumn;
class StringEnumColumn;
class BinaryColumn;
class SubtableColumn;
class MixedColumn;
class LinkColumn;
class LinkListColumn;

// Templated classes
template <class T, bool Nullable = false> class Column;
template<class T> class BasicColumn;

// Shortcuts, aka typedefs.
using IntegerColumn = Column<std::int64_t, false>;
using IntNullColumn = Column<std::int64_t, true>;
using DoubleColumn = BasicColumn<double>;
using FloatColumn = BasicColumn<float>;

} // namespace realm

#endif // REALM_COLUMN_FWD_HPP
