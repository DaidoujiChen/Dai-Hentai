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
#ifndef REALM_COLUMN_MIXED_HPP
#define REALM_COLUMN_MIXED_HPP

#include <limits>

#include <realm/column.hpp>
#include <realm/column_type.hpp>
#include <realm/column_table.hpp>
#include <realm/column_binary.hpp>
#include <realm/table.hpp>
#include <realm/utilities.hpp>


namespace realm {


// Pre-declarations
class BinaryColumn;


/// A mixed column (MixedColumn) is composed of three subcolumns. The first
/// subcolumn is an integer column (Column) and stores value types. The second
/// one stores values and is a subtable parent column (SubtableColumnBase),
/// which is a subclass of an integer column (Column). The last one is a binary
/// column (BinaryColumn) and stores additional data for values of type string
/// or binary data. The last subcolumn is optional. The root of a mixed column
/// is an array node of type Array that stores the root refs of the subcolumns.
class MixedColumn: public ColumnBaseSimple {
public:
    /// Create a mixed column wrapper and attach it to a preexisting
    /// underlying structure of arrays.
    ///
    /// \param table If this column is used as part of a table you
    /// must pass a pointer to that table. Otherwise you must pass
    /// null
    ///
    /// \param column_ndx If this column is used as part of a table
    /// you must pass the logical index of the column within that
    /// table. Otherwise you should pass zero.
    MixedColumn(Allocator&, ref_type, Table* table, std::size_t column_ndx);

    ~MixedColumn() noexcept override;

    DataType get_type(std::size_t ndx) const noexcept;
    std::size_t size() const noexcept final { return m_types->size(); }
    bool is_empty() const noexcept { return size() == 0; }

    int64_t get_int(std::size_t ndx) const noexcept;
    bool get_bool(std::size_t ndx) const noexcept;
    DateTime get_datetime(std::size_t ndx) const noexcept;
    float get_float(std::size_t ndx) const noexcept;
    double get_double(std::size_t ndx) const noexcept;
    StringData get_string(std::size_t ndx) const noexcept;
    BinaryData get_binary(std::size_t ndx) const noexcept;
    StringData get_index_data(std::size_t ndx, StringIndex::StringConversionBuffer& buffer) const noexcept override;

    /// The returned array ref is zero if the specified row does not
    /// contain a subtable.
    ref_type get_subtable_ref(std::size_t row_ndx) const noexcept;

    /// The returned size is zero if the specified row does not
    /// contain a subtable.
    std::size_t get_subtable_size(std::size_t row_ndx) const noexcept;

    Table* get_subtable_accessor(std::size_t row_ndx) const noexcept override;

    void discard_subtable_accessor(std::size_t row_ndx) noexcept override;

    /// If the value at the specified index is a subtable, return a
    /// pointer to that accessor for that subtable. Otherwise return
    /// null. The accessor will be created if it does not already
    /// exist.
    ///
    /// The returned table pointer must **always** end up being
    /// wrapped in some instantiation of BasicTableRef<>.
    Table* get_subtable_ptr(std::size_t row_ndx);

    const Table* get_subtable_ptr(std::size_t subtable_ndx) const;

    void set_int(std::size_t ndx, int64_t value);
    void set_bool(std::size_t ndx, bool value);
    void set_datetime(std::size_t ndx, DateTime value);
    void set_float(std::size_t ndx, float value);
    void set_double(std::size_t ndx, double value);
    void set_string(std::size_t ndx, StringData value) override;
    void set_binary(std::size_t ndx, BinaryData value);
    void set_subtable(std::size_t ndx, const Table* value);

    void insert_int(std::size_t ndx, int64_t value);
    void insert_bool(std::size_t ndx, bool value);
    void insert_datetime(std::size_t ndx, DateTime value);
    void insert_float(std::size_t ndx, float value);
    void insert_double(std::size_t ndx, double value);
    void insert_string(std::size_t ndx, StringData value);
    void insert_binary(std::size_t ndx, BinaryData value);
    void insert_subtable(std::size_t ndx, const Table* value);

    void erase(std::size_t row_ndx);
    void move_last_over(std::size_t row_ndx);
    void clear();

    /// Compare two mixed columns for equality.
    bool compare_mixed(const MixedColumn&) const;

    void discard_child_accessors() noexcept;

    static ref_type create(Allocator&, std::size_t size = 0);

    static std::size_t get_size_from_ref(ref_type root_ref, Allocator&) noexcept;

    // Overriding method in ColumnBase
    ref_type write(std::size_t, std::size_t, std::size_t,
                   _impl::OutputStream&) const override;

    void insert_rows(size_t, size_t, size_t) override;
    void erase_rows(size_t, size_t, size_t, bool) override;
    void move_last_row_over(size_t, size_t, bool) override;
    void clear(std::size_t, bool) override;
    void update_from_parent(std::size_t) noexcept override;
    void adj_acc_insert_rows(std::size_t, std::size_t) noexcept override;
    void adj_acc_erase_row(std::size_t) noexcept override;
    void adj_acc_move_over(std::size_t, std::size_t) noexcept override;
    void adj_acc_clear_root_table() noexcept override;
    void mark(int) noexcept override;
    void refresh_accessor_tree(std::size_t, const Spec&) override;

#ifdef REALM_DEBUG
    void verify() const override;
    void verify(const Table&, std::size_t) const override;
    void to_dot(std::ostream&, StringData title) const override;
    void do_dump_node_structure(std::ostream&, int) const override;
#endif

private:
    enum MixedColType {
        // NOTE: below numbers must be kept in sync with ColumnType
        // Column types used in Mixed
        mixcol_Int         =  0,
        mixcol_Bool        =  1,
        mixcol_String      =  2,
        //                    3, used for STRING_ENUM in ColumnType
        mixcol_Binary      =  4,
        mixcol_Table       =  5,
        mixcol_Mixed       =  6,
        mixcol_Date        =  7,
        //                    8, used for RESERVED1 in ColumnType
        mixcol_Float       =  9,
        mixcol_Double      = 10, // Positive Double
        mixcol_DoubleNeg   = 11, // Negative Double
        mixcol_IntNeg      = 12  // Negative Integers
    };

    class RefsColumn;

    /// Stores the MixedColType of each value at the given index. For
    /// values that uses all 64 bits, the type also encodes the sign
    /// bit by having distinct types for positive negative values.
    std::unique_ptr<IntegerColumn> m_types;

    /// Stores the data for each entry. For a subtable, the stored
    /// value is the ref of the subtable. For string and binary data,
    /// the stored value is an index within `m_binary_data`. For other
    /// types the stored value is itself. Since we only have 63 bits
    /// available for a non-ref value, the sign of numeric values is
    /// encoded as part of the type in `m_types`.
    std::unique_ptr<RefsColumn> m_data;

    /// For string and binary data types, the bytes are stored here.
    std::unique_ptr<BinaryColumn> m_binary_data;

    void do_erase(size_t row_ndx, size_t num_rows_to_erase, size_t prior_num_rows);
    void do_move_last_over(size_t row_ndx, size_t prior_num_rows);
    void do_clear(std::size_t num_rows);

    void create(Allocator&, ref_type, Table*, std::size_t column_ndx);
    void ensure_binary_data_column();

    MixedColType clear_value(std::size_t ndx, MixedColType new_type); // Returns old type
    void clear_value_and_discard_subtab_acc(std::size_t ndx, MixedColType new_type);

    // Get/set/insert 64-bit values in m_data/m_types
    int64_t get_value(std::size_t ndx) const noexcept;
    void set_value(std::size_t ndx, int64_t value, MixedColType);
    void set_int64(std::size_t ndx, int64_t value, MixedColType pos_type, MixedColType neg_type);

    void insert_value(std::size_t row_ndx, int_fast64_t types_value, int_fast64_t data_value);
    void insert_int(std::size_t ndx, int_fast64_t value, MixedColType type);
    void insert_pos_neg(std::size_t ndx, int_fast64_t value, MixedColType pos_type,
                        MixedColType neg_type);

    void do_discard_child_accessors() noexcept override;

#ifdef REALM_DEBUG
    void do_verify(const Table*, std::size_t col_ndx) const;
    void leaf_to_dot(MemRef, ArrayParent*, std::size_t,
                     std::ostream&) const override {} // Not used
#endif
};

inline StringData MixedColumn::get_index_data(std::size_t, StringIndex::StringConversionBuffer&) const noexcept
{
    REALM_ASSERT(false && "Index not supported for MixedColumn yet.");
    REALM_UNREACHABLE();
}


class MixedColumn::RefsColumn: public SubtableColumnBase {
public:
    RefsColumn(Allocator& alloc, ref_type ref, Table* table, std::size_t column_ndx):
        SubtableColumnBase(alloc, ref, table, column_ndx)
    {
    }

    ~RefsColumn() noexcept override {}

    using SubtableColumnBase::get_subtable_ptr;

    void refresh_accessor_tree(std::size_t, const Spec&) override;

    friend class MixedColumn;
};


} // namespace realm


// Implementation
#include <realm/column_mixed_tpl.hpp>


#endif // REALM_COLUMN_MIXED_HPP
