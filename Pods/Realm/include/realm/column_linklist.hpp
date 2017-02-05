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
#ifndef REALM_COLUMN_LINKLIST_HPP
#define REALM_COLUMN_LINKLIST_HPP

#include <algorithm>
#include <vector>

#include <realm/column.hpp>
#include <realm/column_linkbase.hpp>
#include <realm/table.hpp>
#include <realm/column_backlink.hpp>
#include <realm/link_view_fwd.hpp>
#include <iostream>

namespace realm {

namespace _impl {
class TransactLogConvenientEncoder;
}


/// A column of link lists (LinkListColumn) is a single B+-tree, and the root of
/// the column is the root of the B+-tree. All leaf nodes are single arrays of
/// type Array with the hasRefs bit set.
///
/// The individual values in the column are either refs to Columns containing the
/// row positions in the target table, or in the case where they are empty, a zero
/// ref.
class LinkListColumn: public LinkColumnBase, public ArrayParent {
public:
    using LinkColumnBase::LinkColumnBase;
    ~LinkListColumn() noexcept override;

    static ref_type create(Allocator&, std::size_t size = 0);

    bool is_nullable() const noexcept final;

    bool has_links(std::size_t row_ndx) const noexcept;
    std::size_t get_link_count(std::size_t row_ndx) const noexcept;

    ConstLinkViewRef get(std::size_t row_ndx) const;
    LinkViewRef get(std::size_t row_ndx);

    bool is_null(std::size_t row_ndx) const noexcept final;
    void set_null(std::size_t row_ndx) final;

    /// Compare two columns for equality.
    bool compare_link_list(const LinkListColumn&) const;

    void to_json_row(std::size_t row_ndx, std::ostream& out) const;

    void insert_rows(size_t, size_t, size_t) override;
    void erase_rows(size_t, size_t, size_t, bool) override;
    void move_last_row_over(size_t, size_t, bool) override;
    void clear(std::size_t, bool) override;
    void cascade_break_backlinks_to(std::size_t, CascadeState&) override;
    void cascade_break_backlinks_to_all_rows(std::size_t, CascadeState&) override;
    void update_from_parent(std::size_t) noexcept override;
    void adj_acc_clear_root_table() noexcept override;
    void adj_acc_insert_rows(size_t, size_t) noexcept override;
    void adj_acc_erase_row(size_t) noexcept override;
    void adj_acc_move_over(size_t, size_t) noexcept override;
    void refresh_accessor_tree(std::size_t, const Spec&) override;

#ifdef REALM_DEBUG
    void verify() const override;
    void verify(const Table&, std::size_t) const override;
#endif

protected:
    void do_discard_child_accessors() noexcept override;

private:
    struct list_entry {
        std::size_t m_row_ndx;
        LinkView* m_list;
    };
    mutable std::vector<list_entry> m_list_accessors;

    LinkView* get_ptr(std::size_t row_ndx) const;

    void do_nullify_link(std::size_t row_ndx, std::size_t old_target_row_ndx) override;
    void do_update_link(std::size_t row_ndx, std::size_t old_target_row_ndx,
                        std::size_t new_target_row_ndx) override;

    void unregister_linkview(const LinkView& view);
    ref_type get_row_ref(std::size_t row_ndx) const noexcept;
    void set_row_ref(std::size_t row_ndx, ref_type new_ref);
    void add_backlink(std::size_t target_row, std::size_t source_row);
    void remove_backlink(std::size_t target_row, std::size_t source_row);

    // ArrayParent overrides
    void update_child_ref(std::size_t child_ndx, ref_type new_ref) override;
    ref_type get_child_ref(std::size_t child_ndx) const noexcept override;

    // These helpers are needed because of the way the B+-tree of links is
    // traversed in cascade_break_backlinks_to() and
    // cascade_break_backlinks_to_all_rows().
    void cascade_break_backlinks_to__leaf(std::size_t row_ndx, const Array& link_list_leaf,
                                          CascadeState&);
    void cascade_break_backlinks_to_all_rows__leaf(const Array& link_list_leaf, CascadeState&);

    void discard_child_accessors() noexcept;

    template<bool fix_ndx_in_parent>
    void adj_insert_rows(size_t row_ndx, size_t num_rows_inserted) noexcept;
    template<bool fix_ndx_in_parent>
    void adj_erase_rows(size_t row_ndx, size_t num_rows_erased) noexcept;
    template<bool fix_ndx_in_parent>
    void adj_move_over(size_t from_row_ndx, size_t to_row_ndx) noexcept;

#ifdef REALM_DEBUG
    std::pair<ref_type, std::size_t> get_to_dot_parent(std::size_t) const override;
#endif

    friend class BacklinkColumn;
    friend class LinkView;
    friend class _impl::TransactLogConvenientEncoder;
};





// Implementation

inline LinkListColumn::~LinkListColumn() noexcept
{
    discard_child_accessors();
}

inline ref_type LinkListColumn::create(Allocator& alloc, std::size_t size)
{
    return IntegerColumn::create(alloc, Array::type_HasRefs, size); // Throws
}

inline bool LinkListColumn::is_nullable() const noexcept
{
    return false;
}

inline bool LinkListColumn::has_links(std::size_t row_ndx) const noexcept
{
    ref_type ref = LinkColumnBase::get_as_ref(row_ndx);
    return (ref != 0);
}

inline std::size_t LinkListColumn::get_link_count(std::size_t row_ndx) const noexcept
{
    ref_type ref = LinkColumnBase::get_as_ref(row_ndx);
    if (ref == 0)
        return 0;
    return ColumnBase::get_size_from_ref(ref, get_alloc());
}

inline ConstLinkViewRef LinkListColumn::get(std::size_t row_ndx) const
{
    LinkView* link_list = get_ptr(row_ndx); // Throws
    return ConstLinkViewRef(link_list);
}

inline LinkViewRef LinkListColumn::get(std::size_t row_ndx)
{
    LinkView* link_list = get_ptr(row_ndx); // Throws
    return LinkViewRef(link_list);
}

inline bool LinkListColumn::is_null(std::size_t) const noexcept
{
    return false;
}

inline void LinkListColumn::set_null(std::size_t)
{
    throw LogicError{LogicError::column_not_nullable};
}

inline void LinkListColumn::do_discard_child_accessors() noexcept
{
    discard_child_accessors();
}

inline void LinkListColumn::unregister_linkview(const LinkView& list)
{
    auto end = m_list_accessors.end();
    for (auto i = m_list_accessors.begin(); i != end; ++i) {
        if (i->m_list == &list) {
            m_list_accessors.erase(i);
            return;
        }
    }
}

inline ref_type LinkListColumn::get_row_ref(std::size_t row_ndx) const noexcept
{
    return LinkColumnBase::get_as_ref(row_ndx);
}

inline void LinkListColumn::set_row_ref(std::size_t row_ndx, ref_type new_ref)
{
    LinkColumnBase::set(row_ndx, new_ref); // Throws
}

inline void LinkListColumn::add_backlink(std::size_t target_row, std::size_t source_row)
{
    m_backlink_column->add_backlink(target_row, source_row); // Throws
}

inline void LinkListColumn::remove_backlink(std::size_t target_row, std::size_t source_row)
{
    m_backlink_column->remove_one_backlink(target_row, source_row); // Throws
}


} //namespace realm

#endif //REALM_COLUMN_LINKLIST_HPP


