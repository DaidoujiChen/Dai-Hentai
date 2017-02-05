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
#ifndef REALM_COLUMN_HPP
#define REALM_COLUMN_HPP

#include <stdint.h> // unint8_t etc
#include <cstdlib> // std::size_t
#include <vector>
#include <memory>

#include <realm/array_integer.hpp>
#include <realm/column_type.hpp>
#include <realm/column_fwd.hpp>
#include <realm/spec.hpp>
#include <realm/impl/output_stream.hpp>
#include <realm/query_conditions.hpp>
#include <realm/bptree.hpp>
#include <realm/index_string.hpp>
#include <realm/impl/destroy_guard.hpp>
#include <realm/exceptions.hpp>

namespace realm {


// Pre-definitions
struct CascadeState;
class StringIndex;

template <> struct GetLeafType<int64_t, false> {
    using type = ArrayInteger;
};
template <> struct GetLeafType<int64_t, true> {
    using type = ArrayIntNull;
};

struct ColumnTemplateBase
{
    virtual int compare_values(size_t row1, size_t row2) const = 0;
};

template <class T, class R, Action action, class Condition, class ColType>
R aggregate(const ColType& column, T target, std::size_t start, std::size_t end,
                std::size_t limit, std::size_t* return_ndx);

template <class T> struct ColumnTemplate : public ColumnTemplateBase
{
    // Overridden in column_string.* because == operator of StringData isn't yet locale aware; todo
    virtual int compare_values(size_t row1, size_t row2) const
    {
        // we negate nullability such that the two ternary statements in this method can look identical to reduce
        // risk of bugs
        bool v1 = !is_null(row1);
        bool v2 = !is_null(row2);

        if (!v1 || !v2)
            return v1 == v2 ? 0 : v1 < v2 ? 1 : -1;

        T a = get_val(row1);
        T b = get_val(row2);
        return a == b ? 0 : a < b ? 1 : -1;
    }

    // We cannot use already-existing get() methods because StringEnumColumn and LinkList inherit from
    // Column and overload get() with different return type than int64_t. Todo, find a way to simplify
    virtual T get_val(size_t row) const = 0;
    virtual bool is_null(size_t row) const = 0;
};

/// Base class for all column types.
class ColumnBase {
public:
    /// Get the number of entries in this column. This operation is relatively
    /// slow.
    virtual std::size_t size() const noexcept = 0;

    /// \throw LogicError Thrown if this column is not string valued.
    virtual void set_string(std::size_t row_ndx, StringData value);

    /// Whether or not this column is nullable.
    virtual bool is_nullable() const noexcept;

    /// Whether or not the value at \a row_ndx is NULL. If the column is not
    /// nullable, always returns false.
    virtual bool is_null(std::size_t row_ndx) const noexcept;

    /// Sets the value at \a row_ndx to be NULL.
    /// \throw LogicError Thrown if this column is not nullable.
    virtual void set_null(std::size_t row_ndx);

    //@{

    /// `insert_rows()` inserts the specified number of elements into this column
    /// starting at the specified row index. The new elements will have the
    /// default value for the column type.
    ///
    /// `erase_rows()` removes the specified number of consecutive elements from
    /// this column, starting at the specified row index.
    ///
    /// `move_last_row_over()` removes the element at the specified row index by
    /// moving the element at the last row index over it. This reduces the
    /// number of elements by one.
    ///
    /// \param prior_num_rows The number of elements in this column prior to the
    /// modification.
    ///
    /// \param broken_reciprocal_backlinks If true, link columns must assume
    /// that reciprocal backlinks have already been removed. Non-link columns
    /// should ignore this argument.

    virtual void insert_rows(size_t row_ndx, size_t num_rows_to_insert, size_t prior_num_rows) = 0;
    virtual void erase_rows(size_t row_ndx, size_t num_rows_to_erase, size_t prior_num_rows,
                            bool broken_reciprocal_backlinks) = 0;
    virtual void move_last_row_over(size_t row_ndx, size_t prior_num_rows,
                                    bool broken_reciprocal_backlinks) = 0;

    //@}

    /// Remove all elements from this column.
    ///
    /// \param num_rows The total number of rows in this column.
    ///
    /// \param broken_reciprocal_backlinks If true, link columns must assume
    /// that reciprocal backlinks have already been removed. Non-link columns
    /// should ignore this argument.
    virtual void clear(std::size_t num_rows, bool broken_reciprocal_backlinks) = 0;

    virtual void destroy() noexcept = 0;
    void move_assign(ColumnBase& col) noexcept;

    virtual ~ColumnBase() noexcept {}

    // Getter function for index. For integer index, the caller must supply a buffer that we can store the
    // extracted value in (it may be bitpacked, so we cannot return a pointer in to the Array as we do with
    // String index).
    virtual StringData get_index_data(std::size_t, StringIndex::StringConversionBuffer& buffer) const noexcept = 0;

    // Search index
    virtual bool has_search_index() const noexcept;
    virtual StringIndex* create_search_index();
    virtual void destroy_search_index() noexcept;
    virtual const StringIndex* get_search_index() const noexcept;
    virtual StringIndex* get_search_index() noexcept;
    virtual void set_search_index_ref(ref_type, ArrayParent*, std::size_t ndx_in_parent,
                                      bool allow_duplicate_values);
    virtual void set_search_index_allow_duplicate_values(bool) noexcept;

    virtual Allocator& get_alloc() const noexcept = 0;

    /// Returns the 'ref' of the root array.
    virtual ref_type get_ref() const noexcept = 0;
    virtual MemRef get_mem() const noexcept = 0;

    virtual void replace_root_array(std::unique_ptr<Array> leaf) = 0;
    virtual MemRef clone_deep(Allocator& alloc) const = 0;
    virtual void detach(void) = 0;
    virtual bool is_attached(void) const noexcept = 0;

    static std::size_t get_size_from_type_and_ref(ColumnType, ref_type, Allocator&) noexcept;

    // These assume that the right column compile-time type has been
    // figured out.
    static std::size_t get_size_from_ref(ref_type root_ref, Allocator&);
    static std::size_t get_size_from_ref(ref_type spec_ref, ref_type columns_ref, Allocator&);

    /// Write a slice of this column to the specified output stream.
    virtual ref_type write(std::size_t slice_offset, std::size_t slice_size,
                           std::size_t table_size, _impl::OutputStream&) const = 0;

    virtual void set_parent(ArrayParent*, std::size_t ndx_in_parent) noexcept = 0;
    virtual std::size_t get_ndx_in_parent() const noexcept = 0;
    virtual void set_ndx_in_parent(std::size_t ndx_in_parent) noexcept = 0;

    /// Called in the context of Group::commit() and
    /// SharedGroup::commit_and_continue_as_read()() to ensure that attached
    /// table and link list accessors stay valid across a commit.
    virtual void update_from_parent(std::size_t old_baseline) noexcept = 0;

    //@{

    /// cascade_break_backlinks_to() is called iteratively for each column by
    /// Table::cascade_break_backlinks_to() with the same arguments as are
    /// passed to Table::cascade_break_backlinks_to(). Link columns must
    /// override it. The same is true for cascade_break_backlinks_to_all_rows(),
    /// except that it is called from
    /// Table::cascade_break_backlinks_to_all_rows(), and that it expects
    /// Table::cascade_break_backlinks_to_all_rows() to pass the number of rows
    /// in the table as \a num_rows.

    virtual void cascade_break_backlinks_to(std::size_t row_ndx, CascadeState&);
    virtual void cascade_break_backlinks_to_all_rows(std::size_t num_rows, CascadeState&);

    //@}

    void discard_child_accessors() noexcept;

    /// For columns that are able to contain subtables, this function returns
    /// the pointer to the subtable accessor at the specified row index if it
    /// exists, otherwise it returns null. For other column types, this function
    /// returns null.
    virtual Table* get_subtable_accessor(std::size_t row_ndx) const noexcept;

    /// Detach and remove the subtable accessor at the specified row if it
    /// exists. For column types that are unable to contain subtable, this
    /// function does nothing.
    virtual void discard_subtable_accessor(std::size_t row_ndx) noexcept;

    virtual void adj_acc_insert_rows(std::size_t row_ndx, std::size_t num_rows) noexcept;
    virtual void adj_acc_erase_row(std::size_t row_ndx) noexcept;
    /// See Table::adj_acc_move_over()
    virtual void adj_acc_move_over(std::size_t from_row_ndx,
                                   std::size_t to_row_ndx) noexcept;
    virtual void adj_acc_clear_root_table() noexcept;

    enum {
        mark_Recursive   = 0x01,
        mark_LinkTargets = 0x02,
        mark_LinkOrigins = 0x04
    };

    virtual void mark(int type) noexcept;

    virtual void bump_link_origin_table_version() noexcept;

    /// Refresh the dirty part of the accessor subtree rooted at this column
    /// accessor.
    ///
    /// The following conditions are necessary and sufficient for the proper
    /// operation of this function:
    ///
    ///  - The parent table accessor (excluding its column accessors) is in a
    ///    valid state (already refreshed).
    ///
    ///  - Every subtable accessor in the subtree is marked dirty if it needs to
    ///    be refreshed, or if it has a descendant accessor that needs to be
    ///    refreshed.
    ///
    ///  - This column accessor, as well as all its descendant accessors, are in
    ///    structural correspondence with the underlying node hierarchy whose
    ///    root ref is stored in the parent (`Table::m_columns`) (see
    ///    AccessorConsistencyLevels).
    ///
    ///  - The 'index in parent' property of the cached root array
    ///    (`root->m_ndx_in_parent`) is valid.
    virtual void refresh_accessor_tree(std::size_t new_col_ndx, const Spec&) = 0;

#ifdef REALM_DEBUG
    // Must be upper case to avoid conflict with macro in Objective-C
    virtual void verify() const = 0;
    virtual void verify(const Table&, std::size_t col_ndx) const;
    virtual void to_dot(std::ostream&, StringData title = StringData()) const = 0;
    void dump_node_structure() const; // To std::cerr (for GDB)
    virtual void do_dump_node_structure(std::ostream&, int level) const = 0;
    void bptree_to_dot(const Array* root, std::ostream& out) const;
#endif

protected:
    using SliceHandler = BpTreeBase::SliceHandler;

    ColumnBase() {}
    ColumnBase(ColumnBase&&) = default;

    // Must not assume more than minimal consistency (see
    // AccessorConsistencyLevels).
    virtual void do_discard_child_accessors() noexcept {}

    //@{
    /// \tparam L Any type with an appropriate `value_type`, %size(),
    /// and %get() members.
    template<class L, class T>
    std::size_t lower_bound(const L& list, T value) const noexcept;
    template<class L, class T>
    std::size_t upper_bound(const L& list, T value) const noexcept;
    //@}

    // Node functions

    class CreateHandler {
    public:
        virtual ref_type create_leaf(std::size_t size) = 0;
        ~CreateHandler() noexcept {}
    };

    static ref_type create(Allocator&, std::size_t size, CreateHandler&);

#ifdef REALM_DEBUG
    class LeafToDot;
    virtual void leaf_to_dot(MemRef, ArrayParent*, std::size_t ndx_in_parent,
                             std::ostream&) const = 0;
#endif

private:
    class WriteSliceHandler;

    static ref_type build(std::size_t* rest_size_ptr, std::size_t fixed_height,
                          Allocator&, CreateHandler&);
};


// FIXME: Temporary class until all column types have been migrated to use BpTree interface
class ColumnBaseSimple : public ColumnBase {
public:
    //@{
    /// Returns the array node at the root of this column, but note
    /// that there is no guarantee that this node is an inner B+-tree
    /// node or a leaf. This is the case for a MixedColumn in
    /// particular.
    Array* get_root_array() noexcept { return m_array.get(); }
    const Array* get_root_array() const noexcept { return m_array.get(); }
    //@}

    Allocator& get_alloc() const noexcept final { return m_array->get_alloc(); }
    void destroy() noexcept override { if (m_array) m_array->destroy_deep(); }
    ref_type get_ref() const noexcept final { return m_array->get_ref(); }
    MemRef get_mem() const noexcept final { return m_array->get_mem(); }
    void detach() noexcept final { m_array->detach(); }
    bool is_attached() const noexcept final { return m_array->is_attached(); }
    void set_parent(ArrayParent* parent, std::size_t ndx_in_parent) noexcept final { m_array->set_parent(parent, ndx_in_parent); }
    std::size_t get_ndx_in_parent() const noexcept final { return m_array->get_ndx_in_parent(); }
    void set_ndx_in_parent(std::size_t ndx_in_parent) noexcept final { m_array->set_ndx_in_parent(ndx_in_parent); }
    void update_from_parent(std::size_t old_baseline) noexcept override { m_array->update_from_parent(old_baseline); }
    MemRef clone_deep(Allocator& alloc) const override { return m_array->clone_deep(alloc); }
protected:
    ColumnBaseSimple() {}
    ColumnBaseSimple(Array* root) : m_array(root) {}
    std::unique_ptr<Array> m_array;

    void replace_root_array(std::unique_ptr<Array> new_root) final;
    bool root_is_leaf() const noexcept { return !m_array->is_inner_bptree_node(); }

    /// Introduce a new root node which increments the height of the
    /// tree by one.
    void introduce_new_root(ref_type new_sibling_ref, Array::TreeInsertBase& state,
                            bool is_append);

    static ref_type write(const Array* root, std::size_t slice_offset, std::size_t slice_size,
                          std::size_t table_size, SliceHandler&, _impl::OutputStream&);

#if defined(REALM_DEBUG)
    void tree_to_dot(std::ostream&) const;
#endif
};

class ColumnBaseWithIndex : public ColumnBase {
public:
    ~ColumnBaseWithIndex() noexcept override {}
    void set_ndx_in_parent(std::size_t ndx) noexcept override;
    void update_from_parent(std::size_t old_baseline) noexcept override;
    void refresh_accessor_tree(std::size_t, const Spec&) override;
    void move_assign(ColumnBaseWithIndex& col) noexcept;
    void destroy() noexcept override;

    bool has_search_index() const noexcept final { return bool(m_search_index); }
    StringIndex* get_search_index() noexcept final { return m_search_index.get(); }
    const StringIndex* get_search_index() const noexcept final { return m_search_index.get(); }
    void destroy_search_index() noexcept override;
    void set_search_index_ref(ref_type ref, ArrayParent* parent,
            size_t ndx_in_parent, bool allow_duplicate_valaues) final;
    StringIndex* create_search_index() override = 0;
protected:
    ColumnBaseWithIndex() {}
    ColumnBaseWithIndex(ColumnBaseWithIndex&&) = default;
    std::unique_ptr<StringIndex> m_search_index;
};


/// A column (Column) is a single B+-tree, and the root of
/// the column is the root of the B+-tree. All leaf nodes are arrays.
template <class T, bool Nullable>
class Column : public ColumnBaseWithIndex, public ColumnTemplate<T> {
public:
    using value_type = T;
    using LeafInfo = typename BpTree<T, Nullable>::LeafInfo;
    using LeafType = typename BpTree<T, Nullable>::LeafType;
    static const bool nullable = Nullable;

    struct unattached_root_tag {};

    explicit Column() noexcept : m_tree(Allocator::get_default()) {}
    explicit Column(std::unique_ptr<Array> root) noexcept;
    Column(Allocator&, ref_type);
    Column(unattached_root_tag, Allocator&);
    Column(Column<T, Nullable>&&) noexcept = default;
    ~Column() noexcept override;

    void init_from_parent();
    void init_from_ref(Allocator&, ref_type);
    void init_from_mem(Allocator&, MemRef);
    // Accessor concept:
    void destroy() noexcept override;
    Allocator& get_alloc() const noexcept final;
    ref_type get_ref() const noexcept final;
    MemRef get_mem() const noexcept final;
    void set_parent(ArrayParent* parent, std::size_t ndx_in_parent) noexcept override;
    std::size_t get_ndx_in_parent() const noexcept final;
    void set_ndx_in_parent(std::size_t ndx) noexcept final;
    void update_from_parent(std::size_t old_baseline) noexcept override;
    void refresh_accessor_tree(std::size_t, const Spec&) override;
    void detach() noexcept final;
    bool is_attached() const noexcept final;
    MemRef clone_deep(Allocator&) const override;

    void move_assign(Column<T, Nullable>&);

    std::size_t size() const noexcept override;
    bool is_empty() const noexcept { return size() == 0; }
    bool is_nullable() const noexcept override;

    /// Provides access to the leaf that contains the element at the
    /// specified index. Upon return \a ndx_in_leaf will be set to the
    /// corresponding index relative to the beginning of the leaf.
    ///
    /// LeafInfo is a struct defined by the underlying BpTree<T,N>
    /// data structure, that provides a way for the caller to do
    /// leaf caching without instantiating too many objects along
    /// the way.
    ///
    /// This function cannot be used for modifying operations as it
    /// does not ensure the presence of an unbroken chain of parent
    /// accessors. For this reason, the identified leaf should always
    /// be accessed through the returned const-qualified reference,
    /// and never directly through the specfied fallback accessor.
    void get_leaf(std::size_t ndx, std::size_t& ndx_in_leaf,
        LeafInfo& inout_leaf) const noexcept;

    // Getting and setting values
    T get_val(std::size_t ndx) const noexcept final { return get(ndx); }
    T get(std::size_t ndx) const noexcept;
    bool is_null(std::size_t ndx) const noexcept override;
    T back() const noexcept;
    void set(std::size_t, T value);
    void set(std::size_t, null);
    void set_null(std::size_t) override;
    void add(T value = T{});
    void add(null);
    void insert(std::size_t ndx, T value = T{}, std::size_t num_rows = 1);
    void insert(std::size_t ndx, null, std::size_t num_rows = 1);
    void erase(size_t row_ndx);
    void erase(size_t row_ndx, bool is_last);
    void move_last_over(size_t row_ndx, size_t last_row_ndx);
    void clear();

    // Index support
    StringData get_index_data(std::size_t ndx, StringIndex::StringConversionBuffer& buffer) const noexcept override;

    // FIXME: Remove these
    uint64_t get_uint(std::size_t ndx) const noexcept;
    ref_type get_as_ref(std::size_t ndx) const noexcept;
    void set_uint(std::size_t ndx, uint64_t value);
    void set_as_ref(std::size_t ndx, ref_type value);

    template <class U>
    void adjust(std::size_t ndx, U diff);
    template <class U>
    void adjust(U diff);
    template <class U>
    void adjust_ge(T limit, U diff);

    std::size_t count(T target) const;

    T sum(std::size_t start = 0, std::size_t end = npos, std::size_t limit = npos,
                std::size_t* return_ndx = nullptr) const;

    T maximum(std::size_t start = 0, std::size_t end = npos, std::size_t limit = npos,
                    std::size_t* return_ndx = nullptr) const;

    T minimum(std::size_t start = 0, std::size_t end = npos, std::size_t limit = npos,
                    std::size_t* return_ndx = nullptr) const;

    double average(std::size_t start = 0, std::size_t end = npos, std::size_t limit = npos,
                    std::size_t* return_ndx = nullptr) const;

    std::size_t find_first(T value, std::size_t begin = 0, std::size_t end = npos) const;
    void find_all(Column<int64_t, false>& out_indices, T value,
                  std::size_t begin = 0, std::size_t end = npos) const;

    void populate_search_index();
    StringIndex* create_search_index() override;

    //@{
    /// Find the lower/upper bound for the specified value assuming
    /// that the elements are already sorted in ascending order
    /// according to ordinary integer comparison.
    // FIXME: Rename
    std::size_t lower_bound_int(T value) const noexcept;
    // FIXME: Rename
    std::size_t upper_bound_int(T value) const noexcept;
    //@}

    std::size_t find_gte(T target, std::size_t start) const;

    // FIXME: Rename
    bool compare_int(const Column<T, Nullable>&) const noexcept;

    static ref_type create(Allocator&, Array::Type leaf_type = Array::type_Normal,
                           std::size_t size = 0, T value = 0);

    // Overriding method in ColumnBase
    ref_type write(std::size_t, std::size_t, std::size_t,
                   _impl::OutputStream&) const override;

    void insert_rows(size_t, size_t, size_t) override;
    void erase_rows(size_t, size_t, size_t, bool) override;
    void move_last_row_over(size_t, size_t, bool) override;
    void clear(std::size_t, bool) override;

    /// \param row_ndx Must be `realm::npos` if appending.
    void insert_without_updating_index(std::size_t row_ndx, T value, std::size_t num_rows);

#ifdef REALM_DEBUG
    void verify() const override;
    using ColumnBase::verify;
    void to_dot(std::ostream&, StringData title) const override;
    void tree_to_dot(std::ostream&) const;
    MemStats stats() const;
    void do_dump_node_structure(std::ostream&, int) const override;
#endif

    //@{
    /// Returns the array node at the root of this column, but note
    /// that there is no guarantee that this node is an inner B+-tree
    /// node or a leaf. This is the case for a MixedColumn in
    /// particular.
    Array* get_root_array() noexcept { return &m_tree.root(); }
    const Array* get_root_array() const noexcept { return &m_tree.root(); }
    //@}

protected:
    bool root_is_leaf() const noexcept { return m_tree.root_is_leaf(); }
    void replace_root_array(std::unique_ptr<Array> leaf) final { m_tree.replace_root(std::move(leaf)); }

    void set_without_updating_index(std::size_t row_ndx, T value);
    void erase_without_updating_index(std::size_t row_ndx, bool is_last);
    void move_last_over_without_updating_index(std::size_t row_ndx, std::size_t last_row_ndx);

    /// If any element points to an array node, this function recursively
    /// destroys that array node. Note that the same is **not** true for
    /// IntegerColumn::do_erase() and IntegerColumn::do_move_last_over().
    ///
    /// FIXME: Be careful, clear_without_updating_index() currently forgets
    /// if the leaf type is Array::type_HasRefs.
    void clear_without_updating_index();

#ifdef REALM_DEBUG
    void leaf_to_dot(MemRef, ArrayParent*, std::size_t ndx_in_parent,
                     std::ostream&) const override;
    static void dump_node_structure(const Array& root, std::ostream&, int level);
#endif

private:
    class EraseLeafElem;
    class CreateHandler;
    class SliceHandler;

    friend class Array;
    friend class ColumnBase;
    friend class StringIndex;

    BpTree<T, Nullable> m_tree;

    void do_erase(size_t row_ndx, size_t num_rows_to_erase, bool is_last);
};


// Implementation:

inline bool ColumnBase::has_search_index() const noexcept
{
    return get_search_index() != nullptr;
}

inline StringIndex* ColumnBase::create_search_index()
{
    return nullptr;
}

inline void ColumnBase::destroy_search_index() noexcept
{
}

inline const StringIndex* ColumnBase::get_search_index() const noexcept
{
    return nullptr;
}

inline StringIndex* ColumnBase::get_search_index() noexcept
{
    return nullptr;
}

inline void ColumnBase::set_search_index_ref(ref_type, ArrayParent*, std::size_t, bool)
{
}

inline void ColumnBase::set_search_index_allow_duplicate_values(bool) noexcept
{
}

inline void ColumnBase::discard_child_accessors() noexcept
{
    do_discard_child_accessors();
}

inline Table* ColumnBase::get_subtable_accessor(std::size_t) const noexcept
{
    return 0;
}

inline void ColumnBase::discard_subtable_accessor(std::size_t) noexcept
{
    // Noop
}

inline void ColumnBase::adj_acc_insert_rows(std::size_t, std::size_t) noexcept
{
    // Noop
}

inline void ColumnBase::adj_acc_erase_row(std::size_t) noexcept
{
    // Noop
}

inline void ColumnBase::adj_acc_move_over(std::size_t, std::size_t) noexcept
{
    // Noop
}

inline void ColumnBase::adj_acc_clear_root_table() noexcept
{
    // Noop
}

inline void ColumnBase::mark(int) noexcept
{
    // Noop
}

inline void ColumnBase::bump_link_origin_table_version() noexcept
{
    // Noop
}

template <class T, bool N>
void Column<T, N>::set_without_updating_index(std::size_t ndx, T value)
{
    m_tree.set(ndx, std::move(value));
}

template <class T, bool N>
void Column<T, N>::set(std::size_t ndx, T value)
{
    REALM_ASSERT_DEBUG(ndx < size());
    if (has_search_index()) {
        m_search_index->set(ndx, value);
    }
    set_without_updating_index(ndx, std::move(value));
}

template <class T, bool N>
void Column<T, N>::set_null(std::size_t ndx)
{
    REALM_ASSERT_DEBUG(ndx < size());
    if (!is_nullable()) {
        throw LogicError{LogicError::column_not_nullable};
    }
    if (has_search_index()) {
        m_search_index->set(ndx, null{});
    }
    m_tree.set_null(ndx);
}

template <class T, bool N>
void Column<T, N>::set(std::size_t ndx, null)
{
    set_null(ndx);
}

// When a value of a signed type is converted to an unsigned type, the C++ standard guarantees that negative values
// are converted from the native representation to 2's complement, but the opposite conversion is left as undefined.
// realm::util::from_twos_compl() is used here to perform the correct opposite unsigned-to-signed conversion,
// which reduces to a no-op when 2's complement is the native representation of negative values.
template <class T, bool N>
void Column<T, N>::set_uint(std::size_t ndx, uint64_t value)
{
    set(ndx, util::from_twos_compl<int_fast64_t>(value));
}

template <class T, bool N>
void Column<T, N>::set_as_ref(std::size_t ndx, ref_type ref)
{
    set(ndx, from_ref(ref));
}

template <class T, bool N>
template <class U>
void Column<T, N>::adjust(std::size_t ndx, U diff)
{
    REALM_ASSERT_3(ndx, <, size());
    m_tree.adjust(ndx, diff);
}

template <class T, bool N>
template <class U>
void Column<T, N>::adjust(U diff)
{
    m_tree.adjust(diff);
}

template <class T, bool N>
template <class U>
void Column<T, N>::adjust_ge(T limit, U diff)
{
    m_tree.adjust_ge(limit, diff);
}

template <class T, bool N>
std::size_t Column<T, N>::count(T target) const
{
    if (has_search_index()) {
        return m_search_index->count(target);
    }
    return to_size_t(aggregate<T, T, act_Count, Equal>(*this, target, 0, size(), npos, nullptr));
}

template <class T, bool N>
T Column<T, N>::sum(std::size_t start, std::size_t end, std::size_t limit, std::size_t* return_ndx) const
{
    if (N)
        return aggregate<T, T, act_Sum, NotNull>(*this, 0, start, end, limit, return_ndx);
    else
        return aggregate<T, T, act_Sum, None>(*this, 0, start, end, limit, return_ndx);
}

template <class T, bool N>
double Column<T, N>::average(std::size_t start, std::size_t end, std::size_t limit, std::size_t* return_ndx) const
{
    if (end == size_t(-1))
        end = size();

    auto s = sum(start, end, limit);
    size_t cnt = to_size_t(aggregate<T, int64_t, act_Count, NotNull>(*this, 0, start, end, limit, nullptr));
    if (return_ndx)
        *return_ndx = cnt;
    double avg = double(s) / (cnt == 0 ? 1 : cnt);
    return avg;
}

template <class T, bool N>
T Column<T,N>::minimum(size_t start, size_t end, size_t limit, size_t* return_ndx) const
{
    return aggregate<T, T, act_Min, NotNull>(*this, 0, start, end, limit, return_ndx);
}

template <class T, bool N>
T Column<T,N>::maximum(size_t start, size_t end, size_t limit, size_t* return_ndx) const
{
    return aggregate<T, T, act_Max, NotNull>(*this, 0, start, end, limit, return_ndx);
}

template <class T, bool N>
void Column<T, N>::get_leaf(std::size_t ndx, std::size_t& ndx_in_leaf,
                             typename BpTree<T,N>::LeafInfo& inout_leaf_info) const noexcept
{
    m_tree.get_leaf(ndx, ndx_in_leaf, inout_leaf_info);
}

template <class T, bool N>
StringData Column<T, N>::get_index_data(std::size_t ndx, StringIndex::StringConversionBuffer& buffer) const noexcept
{
    static_assert(sizeof(T) == StringIndex::string_conversion_buffer_size, "not filling buffer");
    if (N && is_null(ndx)) {
        return StringData{nullptr, 0};
    }
    T x = get(ndx);
    *reinterpret_cast<T*>(buffer.data()) = x;
    return StringData(buffer.data(), sizeof(T));
}

template <class T, bool N>
void Column<T,N>::populate_search_index()
{
    REALM_ASSERT(has_search_index());
    // Populate the index
    std::size_t num_rows = size();
    for (std::size_t row_ndx = 0; row_ndx != num_rows; ++row_ndx) {
        bool is_append = true;
        if (N && is_null(row_ndx)) {
            m_search_index->insert(row_ndx, null{}, 1, is_append); // Throws
        }
        else {
            T value = get(row_ndx);
            m_search_index->insert(row_ndx, value, 1, is_append); // Throws
        }
    }
}

template <class T, bool N>
StringIndex* Column<T, N>::create_search_index()
{
    REALM_ASSERT(!has_search_index());
    m_search_index.reset(new StringIndex(this, get_alloc())); // Throws
    populate_search_index();
    return m_search_index.get();
}

template <class T, bool N>
std::size_t Column<T,N>::find_first(T value, std::size_t begin, std::size_t end) const
{
    REALM_ASSERT_3(begin, <=, size());
    REALM_ASSERT(end == npos || (begin <= end && end <= size()));

    if (m_search_index && begin == 0 && end == npos)
        return m_search_index->find_first(value);
    return m_tree.find_first(value, begin, end);
}

template <class T, bool N>
void Column<T,N>::find_all(IntegerColumn& result, T value, size_t begin, size_t end) const
{
    REALM_ASSERT_3(begin, <=, size());
    REALM_ASSERT(end == npos || (begin <= end && end <= size()));

    if (m_search_index && begin == 0 && end == npos)
        return m_search_index->find_all(result, value);
    return m_tree.find_all(result, value, begin, end);
}

inline std::size_t ColumnBase::get_size_from_ref(ref_type root_ref, Allocator& alloc)
{
    const char* root_header = alloc.translate(root_ref);
    bool root_is_leaf = !Array::get_is_inner_bptree_node_from_header(root_header);
    if (root_is_leaf)
        return Array::get_size_from_header(root_header);
    return Array::get_bptree_size_from_header(root_header);
}

template<class L, class T>
std::size_t ColumnBase::lower_bound(const L& list, T value) const noexcept
{
    std::size_t i = 0;
    std::size_t size = list.size();
    while (0 < size) {
        std::size_t half = size / 2;
        std::size_t mid = i + half;
        typename L::value_type probe = list.get(mid);
        if (probe < value) {
            i = mid + 1;
            size -= half + 1;
        }
        else {
            size = half;
        }
    }
    return i;
}

template<class L, class T>
std::size_t ColumnBase::upper_bound(const L& list, T value) const noexcept
{
    size_t i = 0;
    size_t size = list.size();
    while (0 < size) {
        size_t half = size / 2;
        size_t mid = i + half;
        typename L::value_type probe = list.get(mid);
        if (!(value < probe)) {
            i = mid + 1;
            size -= half + 1;
        }
        else {
            size = half;
        }
    }
    return i;
}


inline ref_type ColumnBase::create(Allocator& alloc, std::size_t size, CreateHandler& handler)
{
    std::size_t rest_size = size;
    std::size_t fixed_height = 0; // Not fixed
    return build(&rest_size, fixed_height, alloc, handler);
}

template <class T, bool N>
Column<T,N>::Column(Allocator& alloc, ref_type ref) : m_tree(BpTreeBase::unattached_tag{})
{
    // fixme, must m_search_index be copied here?
    m_tree.init_from_ref(alloc, ref);
}

template <class T, bool N>
Column<T,N>::Column(unattached_root_tag, Allocator& alloc) : m_tree(alloc)
{
}

template <class T, bool N>
Column<T,N>::Column(std::unique_ptr<Array> root) noexcept : m_tree(std::move(root))
{
}

template <class T, bool N>
Column<T,N>::~Column() noexcept
{
}

template <class T, bool N>
void Column<T,N>::init_from_parent()
{
    m_tree.init_from_parent();
}

template <class T, bool N>
void Column<T,N>::init_from_ref(Allocator& alloc, ref_type ref)
{
    m_tree.init_from_ref(alloc, ref);
}

template <class T, bool N>
void Column<T,N>::init_from_mem(Allocator& alloc, MemRef mem)
{
    m_tree.init_from_mem(alloc, mem);
}

template <class T, bool N>
void Column<T,N>::destroy() noexcept
{
    ColumnBaseWithIndex::destroy();
    m_tree.destroy();
}

template <class T, bool N>
void Column<T,N>::move_assign(Column<T,N>& col)
{
    ColumnBaseWithIndex::move_assign(col);
    m_tree = std::move(col.m_tree);
}

template <class T, bool N>
Allocator& Column<T,N>::get_alloc() const noexcept
{
    return m_tree.get_alloc();
}

template <class T, bool N>
void Column<T,N>::set_parent(ArrayParent* parent, std::size_t ndx_in_parent) noexcept
{
    m_tree.set_parent(parent, ndx_in_parent);
}

template <class T, bool N>
std::size_t Column<T,N>::get_ndx_in_parent() const noexcept
{
    return m_tree.get_ndx_in_parent();
}

template <class T, bool N>
void Column<T,N>::set_ndx_in_parent(std::size_t ndx_in_parent) noexcept
{
    ColumnBaseWithIndex::set_ndx_in_parent(ndx_in_parent);
    m_tree.set_ndx_in_parent(ndx_in_parent);
}

template <class T, bool N>
void Column<T,N>::detach() noexcept
{
    m_tree.detach();
}

template <class T, bool N>
bool Column<T,N>::is_attached() const noexcept
{
    return m_tree.is_attached();
}

template <class T, bool N>
ref_type Column<T,N>::get_ref() const noexcept
{
    return get_root_array()->get_ref();
}

template <class T, bool N>
MemRef Column<T,N>::get_mem() const noexcept
{
    return get_root_array()->get_mem();
}

template <class T, bool N>
void Column<T,N>::update_from_parent(std::size_t old_baseline) noexcept
{
    ColumnBaseWithIndex::update_from_parent(old_baseline);
    m_tree.update_from_parent(old_baseline);
}

template <class T, bool N>
MemRef Column<T,N>::clone_deep(Allocator& alloc) const
{
    return m_tree.clone_deep(alloc);
}

template <class T, bool N>
std::size_t Column<T,N>::size() const noexcept
{
    return m_tree.size();
}

template <class T, bool N>
bool Column<T,N>::is_nullable() const noexcept
{
    return N;
}

template <class T, bool N>
T Column<T,N>::get(std::size_t ndx) const noexcept
{
    // TODO: This can be speed optimized by letting .get() do the null check
    if (N)
        if (m_tree.is_null(ndx)) {
            // Float, double and integer columns must return 0 for null entries
            return static_cast<T>(0);
        }
        else {
            return m_tree.get(ndx);
        }
    else {
        return m_tree.get(ndx);
    }
}

template <class T, bool N>
bool Column<T,N>::is_null(std::size_t ndx) const noexcept
{
    if (N)
        return m_tree.is_null(ndx);
    else
        return false;
}

template <class T, bool N>
T Column<T,N>::back() const noexcept
{
    return m_tree.back();
}

template <class T, bool N>
ref_type Column<T,N>::get_as_ref(std::size_t ndx) const noexcept
{
    return to_ref(get(ndx));
}

template <class T, bool N>
uint64_t Column<T,N>::get_uint(std::size_t ndx) const noexcept
{
    static_assert(std::is_convertible<T, uint64_t>::value, "T is not convertible to uint.");
    return static_cast<uint64_t>(get(ndx));
}

template <class T, bool N>
void Column<T,N>::add(T value)
{
    insert(npos, std::move(value));
}

template <class T, bool N>
void Column<T,N>::add(null)
{
    insert(npos, null{});
}

template <class T, bool N>
void Column<T,N>::insert_without_updating_index(std::size_t row_ndx, T value, std::size_t num_rows)
{
    std::size_t size = this->size(); // Slow
    bool is_append = row_ndx == size || row_ndx == npos;
    std::size_t ndx_or_npos_if_append = is_append ? npos : row_ndx;

    m_tree.insert(ndx_or_npos_if_append, std::move(value), num_rows); // Throws
}

template <class T, bool N>
void Column<T,N>::insert(std::size_t row_ndx, T value, std::size_t num_rows)
{
    std::size_t size = this->size(); // Slow
    bool is_append = row_ndx == size || row_ndx == npos;
    std::size_t ndx_or_npos_if_append = is_append ? npos : row_ndx;

    m_tree.insert(ndx_or_npos_if_append, value, num_rows); // Throws

    if (has_search_index()) {
        row_ndx = is_append ? size : row_ndx;
        m_search_index->insert(row_ndx, value, num_rows, is_append); // Throws
    }
}

template <class T, bool N>
void Column<T,N>::insert(std::size_t row_ndx, null, std::size_t num_rows)
{
    std::size_t size = this->size(); // Slow
    bool is_append = row_ndx == size || row_ndx == npos;
    std::size_t ndx_or_npos_if_append = is_append ? npos : row_ndx;

    m_tree.insert(ndx_or_npos_if_append, null{}, num_rows); // Throws

    if (has_search_index()) {
        row_ndx = is_append ? size : row_ndx;
        m_search_index->insert(row_ndx, null{}, num_rows, is_append); // Throws
    }
}

template <class T, bool N>
void Column<T,N>::erase_without_updating_index(std::size_t row_ndx, bool is_last)
{
    m_tree.erase(row_ndx, is_last);
}

template <class T, bool N>
void Column<T,N>::erase(size_t row_ndx)
{
    REALM_ASSERT(size() >= 1);
    size_t last_row_ndx = size() - 1; // Note that size() is slow
    bool is_last = (row_ndx == last_row_ndx);
    erase(row_ndx, is_last); // Throws
}

template <class T, bool N>
void Column<T,N>::erase(size_t row_ndx, bool is_last)
{
    size_t num_rows_to_erase = 1;
    do_erase(row_ndx, num_rows_to_erase, is_last); // Throws
}

template <class T, bool N>
void Column<T, N>::move_last_over_without_updating_index(std::size_t row_ndx, std::size_t last_row_ndx)
{
    m_tree.move_last_over(row_ndx, last_row_ndx);
}

template <class T, bool N>
void Column<T,N>::move_last_over(std::size_t row_ndx, std::size_t last_row_ndx)
{
    REALM_ASSERT_3(row_ndx, <=, last_row_ndx);
    REALM_ASSERT_DEBUG(last_row_ndx + 1 == size());

    if (has_search_index()) {
        // remove the value to be overwritten from index
        bool is_last = true; // This tells StringIndex::erase() to not adjust subsequent indexes
        m_search_index->erase<StringData>(row_ndx, is_last); // Throws

        // update index to point to new location
        if (row_ndx != last_row_ndx) {
            if (is_null(last_row_ndx)) {
                m_search_index->update_ref(null{}, last_row_ndx, row_ndx); // Throws
            }
            else {
                int_fast64_t moved_value = get(last_row_ndx);
                m_search_index->update_ref(moved_value, last_row_ndx, row_ndx); // Throws
            }
        }
    }

    move_last_over_without_updating_index(row_ndx, last_row_ndx);
}

template <class T, bool N>
void Column<T,N>::clear_without_updating_index()
{
    m_tree.clear(); // Throws
}

template <class T, bool N>
void Column<T,N>::clear()
{
    if (has_search_index()) {
        m_search_index->clear();
    }
    clear_without_updating_index();
}

// Implementing pure virtual method of ColumnBase.
template <class T, bool N>
void Column<T,N>::insert_rows(size_t row_ndx, size_t num_rows_to_insert, size_t prior_num_rows)
{
    REALM_ASSERT_DEBUG(prior_num_rows == size());
    REALM_ASSERT(row_ndx <= prior_num_rows);

    size_t row_ndx_2 = (row_ndx == prior_num_rows ? realm::npos : row_ndx);
    T value{};
    insert(row_ndx_2, value, num_rows_to_insert); // Throws

    if (N) {
        // Default value for nullable columns is NULL.
        // FIXME: Make faster with an insert_null method.
        for (size_t i = 0; i < num_rows_to_insert; ++i) {
            set_null(row_ndx + i);
        }
    }
}

// Implementing pure virtual method of ColumnBase.
template <class T, bool N>
void Column<T,N>::erase_rows(size_t row_ndx, size_t num_rows_to_erase, size_t prior_num_rows,
                              bool)
{
    REALM_ASSERT_DEBUG(prior_num_rows == size());
    REALM_ASSERT(num_rows_to_erase <= prior_num_rows);
    REALM_ASSERT(row_ndx <= prior_num_rows - num_rows_to_erase);

    bool is_last = (row_ndx + num_rows_to_erase == prior_num_rows);
    do_erase(row_ndx, num_rows_to_erase, is_last); // Throws
}

// Implementing pure virtual method of ColumnBase.
template <class T, bool N>
void Column<T,N>::move_last_row_over(size_t row_ndx, size_t prior_num_rows, bool)
{
    REALM_ASSERT_DEBUG(prior_num_rows == size());
    REALM_ASSERT(row_ndx < prior_num_rows);

    size_t last_row_ndx = prior_num_rows - 1;
    move_last_over(row_ndx, last_row_ndx); // Throws
}

// Implementing pure virtual method of ColumnBase.
template <class T, bool N>
void Column<T,N>::clear(std::size_t, bool)
{
    clear(); // Throws
}


template <class T, bool N>
std::size_t Column<T,N>::lower_bound_int(T value) const noexcept
{
    static_assert(std::is_same<T, int64_t>::value && !N, "lower_bound_int only works for non-nullable integer columns.");
    if (root_is_leaf()) {
        return get_root_array()->lower_bound_int(value);
    }
    return ColumnBase::lower_bound(*this, value);
}

template <class T, bool N>
std::size_t Column<T,N>::upper_bound_int(T value) const noexcept
{
    static_assert(std::is_same<T, int64_t>::value && !N, "upper_bound_int only works for non-nullable integer columns.");
    if (root_is_leaf()) {
        return get_root_array()->upper_bound_int(value);
    }
    return ColumnBase::upper_bound(*this, value);
}

// For a *sorted* Column, return first element E for which E >= target or return -1 if none
template <class T, bool N>
std::size_t Column<T,N>::find_gte(T target, size_t start) const
{
    // fixme: slow reference implementation. See Array::find_gte for faster version
    size_t ref = 0;
    size_t idx;
    for (idx = start; idx < size(); ++idx) {
        if (get(idx) >= target) {
            ref = idx;
            break;
        }
    }
    if (idx == size())
        ref = not_found;

    return ref;
}


template <class T, bool N>
bool Column<T,N>::compare_int(const Column<T,N>& c) const noexcept
{
    size_t n = size();
    if (c.size() != n)
        return false;
    for (size_t i=0; i<n; ++i) {
        bool left_is_null = is_null(i);
        bool right_is_null = c.is_null(i);
        if (left_is_null != right_is_null) {
            return false;
        }
        if (!left_is_null) {
            if (get(i) != c.get(i))
                return false;
        }
    }
    return true;
}

template <class T, bool N>
class Column<T,N>::CreateHandler: public ColumnBase::CreateHandler {
public:
    CreateHandler(Array::Type leaf_type, T value, Allocator& alloc):
        m_value(value), m_alloc(alloc), m_leaf_type(leaf_type) {}
    ref_type create_leaf(size_t size) override
    {
        MemRef mem = BpTree<T,N>::create_leaf(m_leaf_type, size, m_value, m_alloc); // Throws
        return mem.m_ref;
    }
private:
    const T m_value;
    Allocator& m_alloc;
    Array::Type m_leaf_type;
};

template <class T, bool N>
ref_type Column<T,N>::create(Allocator& alloc, Array::Type leaf_type, size_t size, T value)
{
    CreateHandler handler(leaf_type, std::move(value), alloc);
    return ColumnBase::create(alloc, size, handler);
}

template <class T, bool N>
ref_type Column<T,N>::write(std::size_t slice_offset, std::size_t slice_size,
                       std::size_t table_size, _impl::OutputStream& out) const
{
    return m_tree.write(slice_offset, slice_size, table_size, out);
}

template <class T, bool N>
void Column<T,N>::refresh_accessor_tree(size_t new_col_ndx, const Spec& spec)
{
    m_tree.init_from_parent();
    ColumnBaseWithIndex::refresh_accessor_tree(new_col_ndx, spec);
}

template <class T, bool N>
void Column<T,N>::do_erase(size_t row_ndx, size_t num_rows_to_erase, bool is_last)
{
    if (has_search_index()) {
        for (size_t i = num_rows_to_erase; i > 0; --i) {
            size_t row_ndx_2 = row_ndx + i - 1;
            m_search_index->erase<T>(row_ndx_2, is_last); // Throws
        }
    }
    for (size_t i = num_rows_to_erase; i > 0; --i) {
        size_t row_ndx_2 = row_ndx + i - 1;
        erase_without_updating_index(row_ndx_2, is_last); // Throws
    }
}

#ifdef REALM_DEBUG

template <class T, bool N>
void Column<T,N>::verify() const
{
    m_tree.verify();
}

template <class T, bool N>
void Column<T,N>::to_dot(std::ostream& out, StringData title) const
{
    ref_type ref = get_root_array()->get_ref();
    out << "subgraph cluster_integer_column" << ref << " {" << std::endl;
    out << " label = \"Integer column";
    if (title.size() != 0)
        out << "\\n'" << title << "'";
    out << "\";" << std::endl;
    tree_to_dot(out);
    out << "}" << std::endl;
}

template <class T, bool N>
void Column<T,N>::tree_to_dot(std::ostream& out) const
{
    ColumnBase::bptree_to_dot(get_root_array(), out);
}

template <class T, bool N>
void Column<T,N>::leaf_to_dot(MemRef leaf_mem, ArrayParent* parent, size_t ndx_in_parent,
                         std::ostream& out) const
{
    BpTree<T,N>::leaf_to_dot(leaf_mem, parent, ndx_in_parent, out, get_alloc());
}

template <class T, bool N>
MemStats Column<T,N>::stats() const
{
    MemStats stats;
    get_root_array()->stats(stats);
    return stats;
}


namespace _impl {
    void leaf_dumper(MemRef mem, Allocator& alloc, std::ostream& out, int level);
}

template <class T, bool N>
void Column<T,N>::do_dump_node_structure(std::ostream& out, int level) const
{
    dump_node_structure(*get_root_array(), out, level);
}

template <class T, bool N>
void Column<T,N>::dump_node_structure(const Array& root, std::ostream& out, int level)
{
    root.dump_bptree_structure(out, level, &_impl::leaf_dumper);
}

#endif // REALM_DEBUG


} // namespace realm

#endif // REALM_COLUMN_HPP
