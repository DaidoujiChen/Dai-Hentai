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
#ifndef REALM_UTIL_TYPE_TRAITS_HPP
#define REALM_UTIL_TYPE_TRAITS_HPP

#include <stdint.h>
#include <climits>
#include <cwchar>
#include <limits>
#include <type_traits>

#include <realm/util/features.h>
#include <realm/util/assert.hpp>
#include <realm/util/meta.hpp>
#include <realm/util/type_list.hpp>

namespace realm {
namespace util {

template<class From, class To> struct CopyConst {
private:
    typedef typename std::remove_const<To>::type type_1;
public:
    typedef typename std::conditional<std::is_const<From>::value, const type_1, type_1>::type type;
};


/// Member `type` is the type resulting from integral or
/// floating-point promotion of a value of type `T`.
///
/// \note Enum types are supported only when the compiler supports the
/// C++11 'decltype' feature.
template<class T> struct Promote;


/// Member `type` is the type of the result of a binary arithmetic (or
/// bitwise) operation (+, -, *, /, %, |, &, ^) when applied to
/// operands of type `A` and `B` respectively. The type of the result
/// of a shift operation (<<, >>) can instead be found as the type
/// resulting from integral promotion of the left operand. The type of
/// the result of a unary arithmetic (or bitwise) operation can be
/// found as the type resulting from integral promotion of the
/// operand.
///
/// \note Enum types are supported only when the compiler supports the
/// C++11 'decltype' feature.
template<class A, class B> struct ArithBinOpType;


/// Member `type` is `B` if `B` has more value bits than `A`,
/// otherwise is is `A`.
template<class A, class B> struct ChooseWidestInt;


/// Member `type` is the first of `unsigned char`, `unsigned short`,
/// `unsigned int`, `unsigned long`, and `unsigned long long` that has
/// at least `bits` value bits.
template<int bits> struct LeastUnsigned;


/// Member `type` is `unsigned` if `unsigned` has at least `bits`
/// value bits, otherwise it is the same as
/// `LeastUnsigned<bits>::type`.
template<int bits> struct FastestUnsigned;


// Implementation


#ifdef REALM_HAVE_CXX11_DECLTYPE
template<class T> struct Promote {
    typedef decltype(+T()) type; // FIXME: This is not performing floating-point promotion.
};
#else
template<> struct Promote<bool> {
    typedef int type;
};
template<> struct Promote<char> {
private:
    static const bool cond =
        int(INT_MIN) <= int(CHAR_MIN) && unsigned(CHAR_MAX) <= unsigned(INT_MAX);
public:
    typedef std::conditional<cond, int, unsigned>::type type;
};
template<> struct Promote<signed char> {
    typedef int type;
};
template<> struct Promote<unsigned char> {
private:
    static const bool cond = unsigned(UCHAR_MAX) <= unsigned(INT_MAX);
public:
    typedef std::conditional<cond, int, unsigned>::type type;
};
template<> struct Promote<wchar_t> {
private:
    typedef intmax_t  max_int;
    typedef uintmax_t max_uint;
    static const bool cond_0 =
        (0 <= max_int(WCHAR_MIN)) && (max_uint(WCHAR_MAX) <= max_uint(ULLONG_MAX));
    static const bool cond_1 =
        (max_int(LLONG_MIN) <= max_int(WCHAR_MIN)) && (max_uint(WCHAR_MAX) <= max_uint(LLONG_MAX));
    static const bool cond_2 =
        (0 <= max_int(WCHAR_MIN)) && (max_uint(WCHAR_MAX) <= max_uint(ULONG_MAX));
    static const bool cond_3 =
        (max_int(LONG_MIN) <= max_int(WCHAR_MIN)) && (max_uint(WCHAR_MAX) <= max_uint(LONG_MAX));
    static const bool cond_4 =
        (0 <= max_int(WCHAR_MIN)) && (max_uint(WCHAR_MAX) <= unsigned(UINT_MAX));
    static const bool cond_5 =
        (int(INT_MIN) <= max_int(WCHAR_MIN)) && (max_uint(WCHAR_MAX) <= unsigned(INT_MAX));
    typedef std::conditional<cond_0, unsigned long long, void>::type type_0;
    typedef std::conditional<cond_1, long long,        type_0>::type type_1;
    typedef std::conditional<cond_2, unsigned long,    type_1>::type type_2;
    typedef std::conditional<cond_3, long,             type_2>::type type_3;
    typedef std::conditional<cond_4, unsigned,         type_3>::type type_4;
    typedef std::conditional<cond_5, int,              type_4>::type type_5;
    REALM_STATIC_ASSERT(!(std::is_same<type_5, void>::value), "Failed to promote `wchar_t`");
public:
    typedef type_5 type;
};
template<> struct Promote<short> {
    typedef int type;
};
template<> struct Promote<unsigned short> {
private:
    static const bool cond = unsigned(USHRT_MAX) <= unsigned(INT_MAX);
public:
    typedef std::conditional<cond, int, unsigned>::type type;
};
template<> struct Promote<int> { typedef int type; };
template<> struct Promote<unsigned> { typedef unsigned type; };
template<> struct Promote<long> { typedef long type; };
template<> struct Promote<unsigned long> { typedef unsigned long type; };
template<> struct Promote<long long> { typedef long long type; };
template<> struct Promote<unsigned long long> { typedef unsigned long long type; };
template<> struct Promote<float> { typedef double type; };
template<> struct Promote<double> { typedef double type; };
template<> struct Promote<long double> { typedef long double type; };
#endif // !REALM_HAVE_CXX11_DECLTYPE


#ifdef REALM_HAVE_CXX11_DECLTYPE
template<class A, class B> struct ArithBinOpType {
    typedef decltype(A()+B()) type;
};
#else
template<class A, class B> struct ArithBinOpType {
private:
    typedef typename Promote<A>::type A2;
    typedef typename Promote<B>::type B2;

    typedef unsigned long long ullong;
    typedef typename std::conditional<ullong(UINT_MAX) <= ullong(LONG_MAX), long, unsigned long>::type type_l_u;
    typedef typename std::conditional<EitherTypeIs<unsigned, A2, B2>::value, type_l_u, long>::type type_l;

    typedef typename std::conditional<ullong(UINT_MAX) <= ullong(LLONG_MAX), long long, unsigned long long>::type type_ll_u;
    typedef typename std::conditional<ullong(ULONG_MAX) <= ullong(LLONG_MAX), long long, unsigned long long>::type type_ll_ul;
    typedef typename std::conditional<EitherTypeIs<unsigned, A2, B2>::value, type_ll_u, long long>::type type_ll_1;
    typedef typename std::conditional<EitherTypeIs<unsigned long, A2, B2>::value, type_ll_ul, type_ll_1>::type type_ll;

    typedef typename std::conditional<EitherTypeIs<unsigned, A2, B2>::value, unsigned, int>::type type_1;
    typedef typename std::conditional<EitherTypeIs<long, A2, B2>::value, type_l, type_1>::type type_2;
    typedef typename std::conditional<EitherTypeIs<unsigned long, A2, B2>::value, unsigned long, type_2>::type type_3;
    typedef typename std::conditional<EitherTypeIs<long long, A2, B2>::value, type_ll, type_3>::type type_4;
    typedef typename std::conditional<EitherTypeIs<unsigned long long, A2, B2>::value, unsigned long long, type_4>::type type_5;
    typedef typename std::conditional<EitherTypeIs<float, A, B>::value, float, type_5>::type type_6;
    typedef typename std::conditional<EitherTypeIs<double, A, B>::value, double, type_6>::type type_7;

public:
    typedef typename std::conditional<EitherTypeIs<long double, A, B>::value, long double, type_7>::type type;
};
#endif // !REALM_HAVE_CXX11_DECLTYPE


template<class A, class B> struct ChooseWidestInt {
private:
    typedef std::numeric_limits<A> lim_a;
    typedef std::numeric_limits<B> lim_b;
    REALM_STATIC_ASSERT(lim_a::is_specialized && lim_b::is_specialized,
                          "std::numeric_limits<> must be specialized for both types");
    REALM_STATIC_ASSERT(lim_a::is_integer && lim_b::is_integer,
                          "Both types must be integers");
public:
    typedef typename std::conditional<(lim_a::digits >= lim_b::digits), A, B>::type type;
};


template<int bits> struct LeastUnsigned {
private:
    typedef void                                          types_0;
    typedef TypeAppend<types_0, unsigned char>::type      types_1;
    typedef TypeAppend<types_1, unsigned short>::type     types_2;
    typedef TypeAppend<types_2, unsigned int>::type       types_3;
    typedef TypeAppend<types_3, unsigned long>::type      types_4;
    typedef TypeAppend<types_4, unsigned long long>::type types_5;
    typedef types_5 types;
    // The `dummy<>` template is there to work around a bug in
    // VisualStudio (seen in versions 2010 and 2012). Without the
    // `dummy<>` template, The C++ compiler in Visual Studio would
    // attempt to instantiate `FindType<type, pred>` before the
    // instantiation of `LeastUnsigned<>` which obviously fails
    // because `pred` depends on `bits`.
    template<int> struct dummy {
        template<class T> struct pred {
            static const bool value = std::numeric_limits<T>::digits >= bits;
        };
    };
public:
    typedef typename FindType<types, dummy<bits>::template pred>::type type;
    REALM_STATIC_ASSERT(!(std::is_same<type, void>::value), "No unsigned type is that wide");
};


template<int bits> struct FastestUnsigned {
private:
    typedef typename util::LeastUnsigned<bits>::type least_unsigned;
public:
    typedef typename util::ChooseWidestInt<unsigned, least_unsigned>::type type;
};


} // namespace util
} // namespace realm

#endif // REALM_UTIL_TYPE_TRAITS_HPP
