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
#ifndef REALM_COLUMN_BASIC_HPP
#define REALM_COLUMN_BASIC_HPP

#include <realm/column.hpp>
#include <realm/column_tpl.hpp>
#include <realm/array_basic.hpp>

namespace realm {

template<class T> struct AggReturnType {
    typedef T sum_type;
};
template<> struct AggReturnType<float> {
    typedef double sum_type;
};

template <>
struct GetLeafType<float, false> {
    using type = BasicArray<float>;
};
template <>
struct GetLeafType<double, false> {
    using type = BasicArray<double>;
};

// FIXME: Remove this - it's unused except in tests.
template <>
struct GetLeafType<int, false> {
    using type = ArrayInteger;
};


/// A basic column (BasicColumn<T>) is a single B+-tree, and the root
/// of the column is the root of the B+-tree. All leaf nodes are
/// single arrays of type BasicArray<T>.
///
/// A basic column can currently only be used for simple unstructured
/// types like float, double.
template<class T>
class BasicColumn : public ColumnBaseSimple, public ColumnTemplate<T> {
public:
    using LeafType = typename GetLeafType<T, false>::type;
    using value_type = T;

    // The FloatColumn and DoubleColumn only exists as class types that support
    // null (there is no separate typed nullable and non-nullable versions).
    // Both have a `bool m_nullable` flag which is set in their constructor
    // according to the m_spec
    static const bool nullable = true;

    BasicColumn(Allocator&, ref_type, bool nullable);

    std::size_t size() const noexcept final;
    bool is_empty() const noexcept { return size() == 0; }

    bool is_nullable() const noexcept override
    {
        return m_nullable;
    }
    bool is_null(size_t index) const noexcept override
    {
        if (!m_nullable)
            return false;

        return null::is_null_float(get(index));
    }

    void set_null(size_t index) override
    {
        REALM_ASSERT(m_nullable);
        if (!m_array->is_inner_bptree_node()) {
            static_cast<BasicArray<T>*>(m_array.get())->set(index, null::get_null_float<T>()); // Throws
            return;
        }
        SetLeafElem set_leaf_elem(m_array->get_alloc(), null::get_null_float<T>());
        m_array->update_bptree_elem(index, set_leaf_elem); // Throws
    }

    struct LeafInfo {
        const BasicArray<T>** out_leaf_ptr;
        BasicArray<T>* in_fallback;
    };

    void get_leaf(std::size_t ndx, std::size_t& ndx_in_leaf,
                          LeafInfo& inout_leaf_info) const noexcept;

    T get(std::size_t ndx) const noexcept;
    StringData get_index_data(std::size_t, StringIndex::StringConversionBuffer& buffer) const noexcept final;
    void add(T value = T());
    void set(std::size_t ndx, T value);
    void insert(std::size_t ndx, T value = T());
    void erase(size_t row_ndx);
    void erase(size_t row_ndx, bool is_last);
    void move_last_over(std::size_t row_ndx);
    void clear();

    std::size_t count(T value) const;

    typedef typename AggReturnType<T>::sum_type SumType;
    SumType sum(std::size_t begin = 0, std::size_t end = npos,
                std::size_t limit = std::size_t(-1), size_t* return_ndx = nullptr) const;

    double average(std::size_t begin = 0, std::size_t end = npos,
                   std::size_t limit = std::size_t(-1), size_t* return_ndx = nullptr) const;

    T maximum(std::size_t begin = 0, std::size_t end = npos,
              std::size_t limit = std::size_t(-1), size_t* return_ndx = nullptr) const;

    T minimum(std::size_t begin = 0, std::size_t end = npos,
              std::size_t limit = std::size_t(-1), size_t* return_ndx = nullptr) const;

    std::size_t find_first(T value, std::size_t begin = 0 , std::size_t end = npos) const;

    void find_all(IntegerColumn& result, T value, std::size_t begin = 0, std::size_t end = npos) const;

    //@{
    /// Find the lower/upper bound for the specified value assuming
    /// that the elements are already sorted in ascending order.
    std::size_t lower_bound(T value) const noexcept;
    std::size_t upper_bound(T value) const noexcept;
    //@{

    /// Compare two columns for equality.
    bool compare(const BasicColumn&) const;

    static ref_type create(Allocator&, std::size_t size = 0);

    // Overrriding method in ColumnBase
    ref_type write(std::size_t, std::size_t, std::size_t,
                   _impl::OutputStream&) const override;

    void insert_rows(size_t, size_t, size_t) override;
    void erase_rows(size_t, size_t, size_t, bool) override;
    void move_last_row_over(size_t, size_t, bool) override;
    void clear(std::size_t, bool) override;
    void refresh_accessor_tree(std::size_t, const Spec&) override;

#ifdef REALM_DEBUG
    void verify() const override;
    void to_dot(std::ostream&, StringData title) const override;
    void do_dump_node_structure(std::ostream&, int) const override;
#endif

protected:
    T get_val(size_t row) const override { return get(row); }

private:
    /// \param row_ndx Must be `realm::npos` if appending.
    void do_insert(std::size_t row_ndx, T value, std::size_t num_rows);

    // Called by Array::bptree_insert().
    static ref_type leaf_insert(MemRef leaf_mem, ArrayParent&, std::size_t ndx_in_parent,
                                Allocator&, std::size_t insert_ndx,
                                Array::TreeInsert<BasicColumn<T>>&);

    class SetLeafElem;
    class EraseLeafElem;
    class CreateHandler;
    class SliceHandler;

    void do_move_last_over(std::size_t row_ndx, std::size_t last_row_ndx);
    void do_clear();

    bool m_nullable;

#ifdef REALM_DEBUG
    static std::size_t verify_leaf(MemRef, Allocator&);
    void leaf_to_dot(MemRef, ArrayParent*, std::size_t ndx_in_parent,
                     std::ostream&) const override;
    static void leaf_dumper(MemRef, Allocator&, std::ostream&, int level);
#endif

    friend class Array;
    friend class ColumnBase;
};

template <class T>
void BasicColumn<T>::get_leaf(std::size_t ndx, std::size_t& ndx_in_leaf,
                                         LeafInfo& leaf) const noexcept
{
    if (!m_array->is_inner_bptree_node()) {
        ndx_in_leaf = ndx;
        *leaf.out_leaf_ptr = static_cast<const BasicArray<T>*>(m_array.get());
        return;
    }
    std::pair<MemRef, std::size_t> p = m_array->get_bptree_leaf(ndx);
    leaf.in_fallback->init_from_mem(p.first);
    *leaf.out_leaf_ptr = leaf.in_fallback;
    ndx_in_leaf = p.second;
}

template <class T>
StringData BasicColumn<T>::get_index_data(std::size_t, StringIndex::StringConversionBuffer&) const noexcept
{
    REALM_ASSERT(false && "Index not supported for floating-point columns yet.");
    REALM_UNREACHABLE();
}


} // namespace realm


// template implementation
#include <realm/column_basic_tpl.hpp>


#endif // REALM_COLUMN_BASIC_HPP
