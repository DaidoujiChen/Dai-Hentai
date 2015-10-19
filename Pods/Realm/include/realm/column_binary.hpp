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
#ifndef REALM_COLUMN_BINARY_HPP
#define REALM_COLUMN_BINARY_HPP

#include <realm/column.hpp>
#include <realm/array_binary.hpp>
#include <realm/array_blobs_big.hpp>

namespace realm {


/// A binary column (BinaryColumn) is a single B+-tree, and the root
/// of the column is the root of the B+-tree. Leaf nodes are either of
/// type ArrayBinary (array of small blobs) or ArrayBigBlobs (array of
/// big blobs).
class BinaryColumn: public ColumnBaseSimple {
public:
    typedef BinaryData value_type;

    BinaryColumn(Allocator&, ref_type, bool nullable = false);

    std::size_t size() const noexcept final;
    bool is_empty() const noexcept { return size() == 0; }
    bool is_nullable() const noexcept override;

    BinaryData get(std::size_t ndx) const noexcept;
    bool is_null(std::size_t ndx) const noexcept override;
    StringData get_index_data(std::size_t, StringIndex::StringConversionBuffer& ) const noexcept final;

    void add(BinaryData value);
    void set(std::size_t ndx, BinaryData value, bool add_zero_term = false);
    void set_null(std::size_t ndx) override;
    void insert(std::size_t ndx, BinaryData value);
    void erase(std::size_t row_ndx);
    void erase(std::size_t row_ndx, bool is_last);
    void move_last_over(std::size_t row_ndx);
    void clear();
    size_t find_first(BinaryData value) const;

    // Requires that the specified entry was inserted as StringData.
    StringData get_string(std::size_t ndx) const noexcept;

    void add_string(StringData value);
    void set_string(std::size_t ndx, StringData value) override;
    void insert_string(std::size_t ndx, StringData value);

    /// Compare two binary columns for equality.
    bool compare_binary(const BinaryColumn&) const;

    static ref_type create(Allocator&, std::size_t size = 0);

    static std::size_t get_size_from_ref(ref_type root_ref, Allocator&) noexcept;

    // Overrriding method in ColumnBase
    ref_type write(std::size_t, std::size_t, std::size_t,
                   _impl::OutputStream&) const override;

    void insert_rows(size_t, size_t, size_t) override;
    void erase_rows(size_t, size_t, size_t, bool) override;
    void move_last_row_over(size_t, size_t, bool) override;
    void clear(std::size_t, bool) override;
    void update_from_parent(std::size_t) noexcept override;
    void refresh_accessor_tree(std::size_t, const Spec&) override;

#ifdef REALM_DEBUG
    void verify() const override;
    void to_dot(std::ostream&, StringData title) const override;
    void do_dump_node_structure(std::ostream&, int) const override;
#endif

private:
    /// \param row_ndx Must be `realm::npos` if appending.
    void do_insert(std::size_t row_ndx, BinaryData value, bool add_zero_term,
                   std::size_t num_rows);

    // Called by Array::bptree_insert().
    static ref_type leaf_insert(MemRef leaf_mem, ArrayParent&, std::size_t ndx_in_parent,
                                Allocator&, std::size_t insert_ndx,
                                Array::TreeInsert<BinaryColumn>& state);

    struct InsertState: Array::TreeInsert<BinaryColumn> {
        bool m_add_zero_term;
    };

    class EraseLeafElem;
    class CreateHandler;
    class SliceHandler;

    void do_move_last_over(std::size_t row_ndx, std::size_t last_row_ndx);
    void do_clear();

    /// Root must be a leaf. Upgrades the root leaf if
    /// necessary. Returns true if, and only if the root is a 'big
    /// blobs' leaf upon return.
    bool upgrade_root_leaf(std::size_t value_size);

    bool m_nullable = false;

#ifdef REALM_DEBUG
    void leaf_to_dot(MemRef, ArrayParent*, std::size_t ndx_in_parent,
                     std::ostream&) const override;
#endif

    friend class Array;
    friend class ColumnBase;
};




// Implementation

inline StringData BinaryColumn::get_index_data(std::size_t, StringIndex::StringConversionBuffer&) const noexcept
{
    REALM_ASSERT(false && "Index not implemented for BinaryColumn.");
    REALM_UNREACHABLE();
}

inline std::size_t BinaryColumn::size() const  noexcept
{
    if (root_is_leaf()) {
        bool is_big = m_array->get_context_flag();
        if (!is_big) {
            // Small blobs root leaf
            ArrayBinary* leaf = static_cast<ArrayBinary*>(m_array.get());
            return leaf->size();
        }
        // Big blobs root leaf
        ArrayBigBlobs* leaf = static_cast<ArrayBigBlobs*>(m_array.get());
        return leaf->size();
    }
    // Non-leaf root
    return m_array->get_bptree_size();
}

inline bool BinaryColumn::is_nullable() const noexcept
{
    return m_nullable;
}

inline void BinaryColumn::update_from_parent(std::size_t old_baseline) noexcept
{
    if (root_is_leaf()) {
        bool is_big = m_array->get_context_flag();
        if (!is_big) {
            // Small blobs root leaf
            ArrayBinary* leaf = static_cast<ArrayBinary*>(m_array.get());
            leaf->update_from_parent(old_baseline);
            return;
        }
        // Big blobs root leaf
        ArrayBigBlobs* leaf = static_cast<ArrayBigBlobs*>(m_array.get());
        leaf->update_from_parent(old_baseline);
        return;
    }
    // Non-leaf root
    m_array->update_from_parent(old_baseline);
}

inline BinaryData BinaryColumn::get(std::size_t ndx) const noexcept
{
    REALM_ASSERT_DEBUG(ndx < size());
    if (root_is_leaf()) {
        bool is_big = m_array->get_context_flag();
        if (!is_big) {
            // Small blobs root leaf
            ArrayBinary* leaf = static_cast<ArrayBinary*>(m_array.get());
            return leaf->get(ndx);
        }
        // Big blobs root leaf
        ArrayBigBlobs* leaf = static_cast<ArrayBigBlobs*>(m_array.get());
        return leaf->get(ndx);
    }

    // Non-leaf root
    std::pair<MemRef, std::size_t> p = m_array->get_bptree_leaf(ndx);
    const char* leaf_header = p.first.m_addr;
    std::size_t ndx_in_leaf = p.second;
    Allocator& alloc = m_array->get_alloc();
    bool is_big = Array::get_context_flag_from_header(leaf_header);
    if (!is_big) {
        // Small blobs
        return ArrayBinary::get(leaf_header, ndx_in_leaf, alloc);
    }
    // Big blobs
    return ArrayBigBlobs::get(leaf_header, ndx_in_leaf, alloc);
}

inline bool BinaryColumn::is_null(std::size_t ndx) const noexcept
{
    return get(ndx).is_null();
}

inline StringData BinaryColumn::get_string(std::size_t ndx) const noexcept
{
    BinaryData bin = get(ndx);
    REALM_ASSERT_3(0, <, bin.size());
    return StringData(bin.data(), bin.size()-1);
}

inline void BinaryColumn::set_string(std::size_t ndx, StringData value)
{
    if (value.is_null() && !m_nullable)
        throw LogicError(LogicError::column_not_nullable);

    BinaryData bin(value.data(), value.size());
    bool add_zero_term = true;
    set(ndx, bin, add_zero_term);
}

inline void BinaryColumn::add(BinaryData value)
{
    if (value.is_null() && !m_nullable)
        throw LogicError(LogicError::column_not_nullable);

    std::size_t row_ndx = realm::npos;
    bool add_zero_term = false;
    std::size_t num_rows = 1;
    do_insert(row_ndx, value, add_zero_term, num_rows); // Throws
}

inline void BinaryColumn::insert(std::size_t row_ndx, BinaryData value)
{
    if (value.is_null() && !m_nullable)
        throw LogicError(LogicError::column_not_nullable);

    std::size_t size = this->size(); // Slow
    REALM_ASSERT_3(row_ndx, <=, size);
    std::size_t row_ndx_2 = row_ndx == size ? realm::npos : row_ndx;
    bool add_zero_term = false;
    std::size_t num_rows = 1;
    do_insert(row_ndx_2, value, add_zero_term, num_rows); // Throws
}

inline void BinaryColumn::set_null(std::size_t row_ndx)
{
    set(row_ndx, BinaryData{});
}

inline size_t BinaryColumn::find_first(BinaryData value) const
{
    for (size_t t = 0; t < size(); t++)
        if (get(t) == value)
            return t;

    return not_found;
}


inline void BinaryColumn::erase(std::size_t row_ndx)
{
    std::size_t last_row_ndx = size() - 1; // Note that size() is slow
    bool is_last = row_ndx == last_row_ndx;
    erase(row_ndx, is_last); // Throws
}

inline void BinaryColumn::move_last_over(std::size_t row_ndx)
{
    std::size_t last_row_ndx = size() - 1; // Note that size() is slow
    do_move_last_over(row_ndx, last_row_ndx); // Throws
}

inline void BinaryColumn::clear()
{
    do_clear(); // Throws
}

// Implementing pure virtual method of ColumnBase.
inline void BinaryColumn::insert_rows(size_t row_ndx, size_t num_rows_to_insert,
                                      size_t prior_num_rows)
{
    REALM_ASSERT_DEBUG(prior_num_rows == size());
    REALM_ASSERT(row_ndx <= prior_num_rows);

    size_t row_ndx_2 = (row_ndx == prior_num_rows ? realm::npos : row_ndx);
    BinaryData value = m_nullable ? BinaryData() : BinaryData("", 0);
    bool add_zero_term = false;
    do_insert(row_ndx_2, value, add_zero_term, num_rows_to_insert); // Throws
}

// Implementing pure virtual method of ColumnBase.
inline void BinaryColumn::erase_rows(size_t row_ndx, size_t num_rows_to_erase,
                                     size_t prior_num_rows, bool)
{
    REALM_ASSERT_DEBUG(prior_num_rows == size());
    REALM_ASSERT(num_rows_to_erase <= prior_num_rows);
    REALM_ASSERT(row_ndx <= prior_num_rows - num_rows_to_erase);

    bool is_last = (row_ndx + num_rows_to_erase == prior_num_rows);
    for (size_t i = num_rows_to_erase; i > 0; --i) {
        size_t row_ndx_2 = row_ndx + i - 1;
        erase(row_ndx_2, is_last); // Throws
    }
}

// Implementing pure virtual method of ColumnBase.
inline void BinaryColumn::move_last_row_over(size_t row_ndx, size_t prior_num_rows, bool)
{
    REALM_ASSERT_DEBUG(prior_num_rows == size());
    REALM_ASSERT(row_ndx < prior_num_rows);

    size_t last_row_ndx = prior_num_rows - 1;
    do_move_last_over(row_ndx, last_row_ndx); // Throws
}

// Implementing pure virtual method of ColumnBase.
inline void BinaryColumn::clear(std::size_t, bool)
{
    do_clear(); // Throws
}

inline void BinaryColumn::add_string(StringData value)
{
    std::size_t row_ndx = realm::npos;
    BinaryData value_2(value.data(), value.size());
    bool add_zero_term = true;
    std::size_t num_rows = 1;
    do_insert(row_ndx, value_2, add_zero_term, num_rows); // Throws
}

inline void BinaryColumn::insert_string(std::size_t row_ndx, StringData value)
{
    std::size_t size = this->size(); // Slow
    REALM_ASSERT_3(row_ndx, <=, size);
    std::size_t row_ndx_2 = row_ndx == size ? realm::npos : row_ndx;
    BinaryData value_2(value.data(), value.size());
    bool add_zero_term = false;
    std::size_t num_rows = 1;
    do_insert(row_ndx_2, value_2, add_zero_term, num_rows); // Throws
}

inline std::size_t BinaryColumn::get_size_from_ref(ref_type root_ref,
                                                   Allocator& alloc) noexcept
{
    const char* root_header = alloc.translate(root_ref);
    bool root_is_leaf = !Array::get_is_inner_bptree_node_from_header(root_header);
    if (root_is_leaf) {
        bool is_big = Array::get_context_flag_from_header(root_header);
        if (!is_big) {
            // Small blobs leaf
            return ArrayBinary::get_size_from_header(root_header, alloc);
        }
        // Big blobs leaf
        return ArrayBigBlobs::get_size_from_header(root_header);
    }
    return Array::get_bptree_size_from_header(root_header);
}


} // namespace realm

#endif // REALM_COLUMN_BINARY_HPP
