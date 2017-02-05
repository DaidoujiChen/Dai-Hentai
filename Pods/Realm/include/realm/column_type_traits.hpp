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

#ifndef REALM_COLUMN_TYPE_TRAITS_HPP
#define REALM_COLUMN_TYPE_TRAITS_HPP

#include <realm/column_fwd.hpp>

namespace realm {

template <class T, bool Nullable> struct ColumnTypeTraits;

template <bool Nullable> struct ColumnTypeTraits<int64_t, Nullable> {
    using column_type = Column<int64_t, Nullable>;
    using leaf_type = typename column_type::LeafType;
    using sum_type = int64_t;
    static const DataType id = type_Int;
    static const ColumnType column_id = col_type_Int;
    static const ColumnType real_column_type = col_type_Int;
};

template <bool Nullable> struct ColumnTypeTraits<bool, Nullable> :
    ColumnTypeTraits<int64_t, Nullable>
{
    static const DataType id = type_Bool;
    static const ColumnType column_id = col_type_Bool;
};

template <bool N> struct ColumnTypeTraits<float, N> {
    using column_type = FloatColumn;
    using leaf_type = ArrayFloat;
    using sum_type = double;
    static const DataType id = type_Float;
    static const ColumnType column_id = col_type_Float;
    static const ColumnType real_column_type = col_type_Float;
};

template <bool N> struct ColumnTypeTraits<double, N> {
    using column_type = DoubleColumn;
    using leaf_type = ArrayDouble;
    using sum_type = double;
    static const DataType id = type_Double;
    static const ColumnType column_id = col_type_Double;
    static const ColumnType real_column_type = col_type_Double;
};

template <bool N> struct ColumnTypeTraits<DateTime, N> :
    ColumnTypeTraits<int64_t, N>
{
    static const DataType id = type_DateTime;
    static const ColumnType column_id = col_type_DateTime;
};

template <bool N> struct ColumnTypeTraits<StringData, N> {
    using column_type = StringEnumColumn;
    using leaf_type = StringEnumColumn::LeafType;
    using sum_type = int64_t;
    static const DataType id = type_String;
    static const ColumnType column_id = col_type_String;
    static const ColumnType real_column_type = col_type_String;
};

template <bool N> struct ColumnTypeTraits<BinaryData, N> {
    using column_type = BinaryColumn;
    using leaf_type = ArrayBinary;
    static const DataType id = type_Binary;
    static const ColumnType column_id = col_type_Binary;
    static const ColumnType real_column_type = col_type_Binary;
};

template <DataType, bool Nullable> struct GetColumnType;
template <> struct GetColumnType<type_Int, false> {
    using type = IntegerColumn;
};
template <> struct GetColumnType<type_Int, true> {
    using type = IntNullColumn;
};
template <bool N> struct GetColumnType<type_Float, N> {
    // FIXME: Null definition
    using type = FloatColumn;
};
template <bool N> struct GetColumnType<type_Double, N> {
    // FIXME: Null definition
    using type = DoubleColumn;
};

// Only purpose is to return 'double' if and only if source column (T) is float and you're doing a sum (A)
template<class T, Action A> struct ColumnTypeTraitsSum {
    typedef T sum_type;
};

template<> struct ColumnTypeTraitsSum<float, act_Sum> {
    typedef double sum_type;
};

}

#endif // REALM_COLUMN_TYPE_TRAITS_HPP
