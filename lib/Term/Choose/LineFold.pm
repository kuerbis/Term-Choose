package Term::Choose::LineFold;

use warnings;
use strict;
use 5.008003;

our $VERSION = '1.601';

use Exporter qw( import );

our @EXPORT_OK = qw( line_fold print_columns cut_to_printwidth );

# *) filtered away with: $s =~ s/\p{Space}/ /; $s =~ s/\p{C}//;
# all chars with width 1 commented out because 1 is default
# where `columns` form Unicode::GCString returns a higher value (width) this higher values is used

# table from https://github.com/unicode-rs/unicode-width/blob/master/src/tables.rs

my $table = [
###[0x00, 0x1f, 0], *)
###[0x7f, 0x9f, 0], *)
#[0xa1, 0xa1, 1],
#[0xa4, 0xa4, 1],
#[0xa7, 0xa8, 1],
#[0xaa, 0xaa, 1],
###[0xad, 0xad, 0], *)
#[0xae, 0xae, 1],
#[0xb0, 0xb4, 1],
#[0xb6, 0xba, 1],
#[0xbc, 0xbf, 1],
#[0xc6, 0xc6, 1],
#[0xd0, 0xd0, 1],
#[0xd7, 0xd8, 1],
#[0xde, 0xe1, 1],
#[0xe6, 0xe6, 1],
#[0xe8, 0xea, 1],
#[0xec, 0xed, 1],
#[0xf0, 0xf0, 1],
#[0xf2, 0xf3, 1],
#[0xf7, 0xfa, 1],
#[0xfc, 0xfc, 1],
#[0xfe, 0xfe, 1],
#[0x101, 0x101, 1],
#[0x111, 0x111, 1],
#[0x113, 0x113, 1],
#[0x11b, 0x11b, 1],
#[0x126, 0x127, 1],
#[0x12b, 0x12b, 1],
#[0x131, 0x133, 1],
#[0x138, 0x138, 1],
#[0x13f, 0x142, 1],
#[0x144, 0x144, 1],
#[0x148, 0x14b, 1],
#[0x14d, 0x14d, 1],
#[0x152, 0x153, 1],
#[0x166, 0x167, 1],
#[0x16b, 0x16b, 1],
#[0x1ce, 0x1ce, 1],
#[0x1d0, 0x1d0, 1],
#[0x1d2, 0x1d2, 1],
#[0x1d4, 0x1d4, 1],
#[0x1d6, 0x1d6, 1],
#[0x1d8, 0x1d8, 1],
#[0x1da, 0x1da, 1],
#[0x1dc, 0x1dc, 1],
#[0x251, 0x251, 1],
#[0x261, 0x261, 1],
#[0x2c4, 0x2c4, 1],
#[0x2c7, 0x2c7, 1],
#[0x2c9, 0x2cb, 1],
#[0x2cd, 0x2cd, 1],
#[0x2d0, 0x2d0, 1],
#[0x2d8, 0x2db, 1],
#[0x2dd, 0x2dd, 1],
#[0x2df, 0x2df, 1],
[0x300, 0x36f, 0],
#[0x391, 0x3a1, 1],
#[0x3a3, 0x3a9, 1],
#[0x3b1, 0x3c1, 1],
#[0x3c3, 0x3c9, 1],
#[0x401, 0x401, 1],
#[0x410, 0x44f, 1],
#[0x451, 0x451, 1],
[0x483, 0x489, 0],
[0x591, 0x5bd, 0],
[0x5bf, 0x5bf, 0],
[0x5c1, 0x5c2, 0],
[0x5c4, 0x5c5, 0],
[0x5c7, 0x5c7, 0],
[0x600, 0x605, 0],
[0x610, 0x61a, 0],
[0x61c, 0x61c, 0],
[0x64b, 0x65f, 0],
[0x670, 0x670, 0],
[0x6d6, 0x6dd, 0],
[0x6df, 0x6e4, 0],
[0x6e7, 0x6e8, 0],
[0x6ea, 0x6ed, 0],
###[0x70f, 0x70f, 0], *)
[0x711, 0x711, 0],
[0x730, 0x74a, 0],
[0x7a6, 0x7b0, 0],
[0x7eb, 0x7f3, 0],
[0x816, 0x819, 0],
[0x81b, 0x823, 0],
[0x825, 0x827, 0],
[0x829, 0x82d, 0],
[0x859, 0x85b, 0],

#################### # Unicode::GCString
# [0x8d4, 0x902, 0], # orig
 #[0x8d4, 0x8e2, 1],
  [0x8e3, 0x902, 0],
####################

[0x93a, 0x93a, 0],
[0x93c, 0x93c, 0],
[0x941, 0x948, 0],
[0x94d, 0x94d, 0],
[0x951, 0x957, 0],
[0x962, 0x963, 0],
[0x981, 0x981, 0],
[0x9bc, 0x9bc, 0],
[0x9c1, 0x9c4, 0],
[0x9cd, 0x9cd, 0],
[0x9e2, 0x9e3, 0],
[0xa01, 0xa02, 0],
[0xa3c, 0xa3c, 0],
[0xa41, 0xa42, 0],
[0xa47, 0xa48, 0],
[0xa4b, 0xa4d, 0],
[0xa51, 0xa51, 0],
[0xa70, 0xa71, 0],
[0xa75, 0xa75, 0],
[0xa81, 0xa82, 0],
[0xabc, 0xabc, 0],
[0xac1, 0xac5, 0],
[0xac7, 0xac8, 0],
[0xacd, 0xacd, 0],
[0xae2, 0xae3, 0],

#################### # Unicode::GCString
# [0xafa, 0xaff, 0], # -> 1
####################

[0xb01, 0xb01, 0],
[0xb3c, 0xb3c, 0],
[0xb3f, 0xb3f, 0],
[0xb41, 0xb44, 0],
[0xb4d, 0xb4d, 0],
[0xb56, 0xb56, 0],
[0xb62, 0xb63, 0],
[0xb82, 0xb82, 0],
[0xbc0, 0xbc0, 0],
[0xbcd, 0xbcd, 0],
[0xc00, 0xc00, 0],
[0xc3e, 0xc40, 0],
[0xc46, 0xc48, 0],
[0xc4a, 0xc4d, 0],
[0xc55, 0xc56, 0],
[0xc62, 0xc63, 0],
[0xc81, 0xc81, 0],
[0xcbc, 0xcbc, 0],
[0xcbf, 0xcbf, 0],
[0xcc6, 0xcc6, 0],
[0xccc, 0xccd, 0],
[0xce2, 0xce3, 0],

#################### # Unicode::GCString
# [0xd00, 0xd01, 0], # orig
 #[0xd00, 0xd00, 1],
  [0xd01, 0xd01, 0],
####################

##################### # Unicode::GCString
 # [0xd3b, 0xd3c, 0], # -> 1
#####################

[0xd41, 0xd44, 0],
[0xd4d, 0xd4d, 0],
[0xd62, 0xd63, 0],
[0xdca, 0xdca, 0],
[0xdd2, 0xdd4, 0],
[0xdd6, 0xdd6, 0],
[0xe31, 0xe31, 0],
[0xe34, 0xe3a, 0],
[0xe47, 0xe4e, 0],
[0xeb1, 0xeb1, 0],
[0xeb4, 0xeb9, 0],
[0xebb, 0xebc, 0],
[0xec8, 0xecd, 0],
[0xf18, 0xf19, 0],
[0xf35, 0xf35, 0],
[0xf37, 0xf37, 0],
[0xf39, 0xf39, 0],
[0xf71, 0xf7e, 0],
[0xf80, 0xf84, 0],
[0xf86, 0xf87, 0],
[0xf8d, 0xf97, 0],
[0xf99, 0xfbc, 0],
[0xfc6, 0xfc6, 0],
[0x102d, 0x1030, 0],
[0x1032, 0x1037, 0],
[0x1039, 0x103a, 0],
[0x103d, 0x103e, 0],
[0x1058, 0x1059, 0],
[0x105e, 0x1060, 0],
[0x1071, 0x1074, 0],
[0x1082, 0x1082, 0],
[0x1085, 0x1086, 0],
[0x108d, 0x108d, 0],
[0x109d, 0x109d, 0],
[0x1100, 0x115f, 2],

###################### # Unicode::GCString
# [0x1160, 0x11ff, 0],
  [0x1160, 0x11ff, 2],
######################

[0x135d, 0x135f, 0],
[0x1712, 0x1714, 0],
[0x1732, 0x1734, 0],
[0x1752, 0x1753, 0],
[0x1772, 0x1773, 0],
[0x17b4, 0x17b5, 0],
[0x17b7, 0x17bd, 0],
[0x17c6, 0x17c6, 0],
[0x17c9, 0x17d3, 0],
[0x17dd, 0x17dd, 0],
[0x180b, 0x180e, 0],

###################### # Unicode::GCString
# [0x1885, 0x1886, 0], # -> 1
######################

[0x18a9, 0x18a9, 0],
[0x1920, 0x1922, 0],
[0x1927, 0x1928, 0],
[0x1932, 0x1932, 0],
[0x1939, 0x193b, 0],
[0x1a17, 0x1a18, 0],
[0x1a1b, 0x1a1b, 0],
[0x1a56, 0x1a56, 0],
[0x1a58, 0x1a5e, 0],
[0x1a60, 0x1a60, 0],
[0x1a62, 0x1a62, 0],
[0x1a65, 0x1a6c, 0],
[0x1a73, 0x1a7c, 0],
[0x1a7f, 0x1a7f, 0],
[0x1ab0, 0x1abe, 0],
[0x1b00, 0x1b03, 0],
[0x1b34, 0x1b34, 0],
[0x1b36, 0x1b3a, 0],
[0x1b3c, 0x1b3c, 0],
[0x1b42, 0x1b42, 0],
[0x1b6b, 0x1b73, 0],
[0x1b80, 0x1b81, 0],
[0x1ba2, 0x1ba5, 0],
[0x1ba8, 0x1ba9, 0],
[0x1bab, 0x1bad, 0],
[0x1be6, 0x1be6, 0],
[0x1be8, 0x1be9, 0],
[0x1bed, 0x1bed, 0],
[0x1bef, 0x1bf1, 0],
[0x1c2c, 0x1c33, 0],
[0x1c36, 0x1c37, 0],
[0x1cd0, 0x1cd2, 0],
[0x1cd4, 0x1ce0, 0],
[0x1ce2, 0x1ce8, 0],
[0x1ced, 0x1ced, 0],
[0x1cf4, 0x1cf4, 0],
[0x1cf8, 0x1cf9, 0],

###################### # Unicode::GCString
# [0x1dc0, 0x1df9, 0], # orig
# [0x1dfb, 0x1dff, 0], # orig
  [0x1dc0, 0x1df5, 0],
 #[0x1df6, 0x1dfb, 1],
  [0x1dfc, 0x1dff, 0],
######################

###[0x200b, 0x200f, 0], *)
#[0x2010, 0x2010, 1],
#[0x2013, 0x2016, 1],
#[0x2018, 0x2019, 1],
#[0x201c, 0x201d, 1],
#[0x2020, 0x2022, 1],
#[0x2024, 0x2027, 1],
###[0x2028, 0x2029, 0], *)
###[0x202a, 0x202e, 0], *)
###[0x206a, 0x206f, 0], *)
#[0x2030, 0x2030, 1],
#[0x2032, 0x2033, 1],
#[0x2035, 0x2035, 1],
#[0x203b, 0x203b, 1],
#[0x203e, 0x203e, 1],
[0x2060, 0x2064, 0],
[0x2066, 0x206f, 0],
#[0x2074, 0x2074, 1],
#[0x207f, 0x207f, 1],
#[0x2081, 0x2084, 1],
#[0x20ac, 0x20ac, 1],
[0x20d0, 0x20f0, 0],
#[0x2103, 0x2103, 1],
#[0x2105, 0x2105, 1],
#[0x2109, 0x2109, 1],
#[0x2113, 0x2113, 1],
#[0x2116, 0x2116, 1],
#[0x2121, 0x2122, 1],
#[0x2126, 0x2126, 1],
#[0x212b, 0x212b, 1],
#[0x2153, 0x2154, 1],
#[0x215b, 0x215e, 1],
#[0x2160, 0x216b, 1],
#[0x2170, 0x2179, 1],
#[0x2189, 0x2189, 1],
#[0x2190, 0x2199, 1],
#[0x21b8, 0x21b9, 1],
#[0x21d2, 0x21d2, 1],
#[0x21d4, 0x21d4, 1],
#[0x21e7, 0x21e7, 1],
#[0x2200, 0x2200, 1],
#[0x2202, 0x2203, 1],
#[0x2207, 0x2208, 1],
#[0x220b, 0x220b, 1],
#[0x220f, 0x220f, 1],
#[0x2211, 0x2211, 1],
#[0x2215, 0x2215, 1],
#[0x221a, 0x221a, 1],
#[0x221d, 0x2220, 1],
#[0x2223, 0x2223, 1],
#[0x2225, 0x2225, 1],
#[0x2227, 0x222c, 1],
#[0x222e, 0x222e, 1],
#[0x2234, 0x2237, 1],
#[0x223c, 0x223d, 1],
#[0x2248, 0x2248, 1],
#[0x224c, 0x224c, 1],
#[0x2252, 0x2252, 1],
#[0x2260, 0x2261, 1],
#[0x2264, 0x2267, 1],
#[0x226a, 0x226b, 1],
#[0x226e, 0x226f, 1],
#[0x2282, 0x2283, 1],
#[0x2286, 0x2287, 1],
#[0x2295, 0x2295, 1],
#[0x2299, 0x2299, 1],
#[0x22a5, 0x22a5, 1],
#[0x22bf, 0x22bf, 1],
#[0x2312, 0x2312, 1],
[0x231a, 0x231b, 2],
[0x2329, 0x232a, 2],
[0x23e9, 0x23ec, 2],
[0x23f0, 0x23f0, 2],
[0x23f3, 0x23f3, 2],
#[0x2460, 0x24e9, 1],
#[0x24eb, 0x254b, 1],
#[0x2550, 0x2573, 1],
#[0x2580, 0x258f, 1],
#[0x2592, 0x2595, 1],
#[0x25a0, 0x25a1, 1],
#[0x25a3, 0x25a9, 1],
#[0x25b2, 0x25b3, 1],
#[0x25b6, 0x25b7, 1],
#[0x25bc, 0x25bd, 1],
#[0x25c0, 0x25c1, 1],
#[0x25c6, 0x25c8, 1],
#[0x25cb, 0x25cb, 1],
#[0x25ce, 0x25d1, 1],
#[0x25e2, 0x25e5, 1],
#[0x25ef, 0x25ef, 1],
[0x25fd, 0x25fe, 2],        # ?
#[0x2605, 0x2606, 1],
#[0x2609, 0x2609, 1],
#[0x260e, 0x260f, 1],
[0x2614, 0x2615, 2],        # ?
#[0x261c, 0x261c, 1],
#[0x261e, 0x261e, 1],
#[0x2640, 0x2640, 1],
#[0x2642, 0x2642, 1],
[0x2648, 0x2653, 2],        # 0x2648 .. 0x2649,  0x0264a .. 0x02653 ?
#[0x2660, 0x2661, 1],
#[0x2663, 0x2665, 1],
#[0x2667, 0x266a, 1],
#[0x266c, 0x266d, 1],
#[0x266f, 0x266f, 1],
[0x267f, 0x267f, 2],
[0x2693, 0x2693, 2],
#[0x269e, 0x269f, 1],
[0x26a1, 0x26a1, 2],
[0x26aa, 0x26ab, 2],
[0x26bd, 0x26be, 2],
#[0x26bf, 0x26bf, 1],
[0x26c4, 0x26c5, 2],
#[0x26c6, 0x26cd, 1],
[0x26ce, 0x26ce, 2],
#[0x26cf, 0x26d3, 1],
[0x26d4, 0x26d4, 2],
#[0x26d5, 0x26e1, 1],
#[0x26e3, 0x26e3, 1],
#[0x26e8, 0x26e9, 1],
[0x26ea, 0x26ea, 2],
#[0x26eb, 0x26f1, 1],
[0x26f2, 0x26f3, 2],
#[0x26f4, 0x26f4, 1],
[0x26f5, 0x26f5, 2],
#[0x26f6, 0x26f9, 1],
[0x26fa, 0x26fa, 2],
#[0x26fb, 0x26fc, 1],
[0x26fd, 0x26fd, 2],
#[0x26fe, 0x26ff, 1],
[0x2705, 0x2705, 2],
[0x270a, 0x270b, 2],
[0x2728, 0x2728, 2],
#[0x273d, 0x273d, 1],
[0x274c, 0x274c, 2],
[0x274e, 0x274e, 2],
[0x2753, 0x2755, 2],
[0x2757, 0x2757, 2],
#[0x2776, 0x277f, 1],
[0x2795, 0x2797, 2],
[0x27b0, 0x27b0, 2],
[0x27bf, 0x27bf, 2],
[0x2b1b, 0x2b1c, 2],
[0x2b50, 0x2b50, 2],
[0x2b55, 0x2b55, 2],
#[0x2b56, 0x2b59, 1],
[0x2cef, 0x2cf1, 0],
[0x2d7f, 0x2d7f, 0],
[0x2de0, 0x2dff, 0],
[0x2e80, 0x2e99, 2],
[0x2e9b, 0x2ef3, 2],
[0x2f00, 0x2fd5, 2],
[0x2ff0, 0x2ffb, 2],
[0x3000, 0x3029, 2],
[0x302a, 0x302d, 0],
[0x302e, 0x303e, 2],
[0x3041, 0x3096, 2],
[0x3099, 0x309a, 0],
[0x309b, 0x30ff, 2],
[0x3105, 0x312e, 2],
[0x3131, 0x318e, 2],
[0x3190, 0x31ba, 2],
[0x31c0, 0x31e3, 2],
[0x31f0, 0x321e, 2],
[0x3220, 0x3247, 2],
#[0x3248, 0x324f, 1],
[0x3250, 0x32fe, 2],
[0x3300, 0x4dbf, 2],
[0x4e00, 0xa48c, 2],
[0xa490, 0xa4c6, 2],
[0xa66f, 0xa672, 0],
[0xa674, 0xa67d, 0],
[0xa69e, 0xa69f, 0],
[0xa6f0, 0xa6f1, 0],
[0xa802, 0xa802, 0],
[0xa806, 0xa806, 0],
[0xa80b, 0xa80b, 0],
[0xa825, 0xa826, 0],

###################### # Unicode::GCString
# [0xa8c4, 0xa8c5, 0], # orig
  [0xa8c4, 0xa8c4, 0],
 #[0xa8c5, 0xa8c5, 1],
######################

[0xa8e0, 0xa8f1, 0],
[0xa926, 0xa92d, 0],
[0xa947, 0xa951, 0],
[0xa960, 0xa97c, 2],
[0xa980, 0xa982, 0],
[0xa9b3, 0xa9b3, 0],
[0xa9b6, 0xa9b9, 0],
[0xa9bc, 0xa9bc, 0],
[0xa9e5, 0xa9e5, 0],
[0xaa29, 0xaa2e, 0],
[0xaa31, 0xaa32, 0],
[0xaa35, 0xaa36, 0],
[0xaa43, 0xaa43, 0],
[0xaa4c, 0xaa4c, 0],
[0xaa7c, 0xaa7c, 0],
[0xaab0, 0xaab0, 0],
[0xaab2, 0xaab4, 0],
[0xaab7, 0xaab8, 0],
[0xaabe, 0xaabf, 0],
[0xaac1, 0xaac1, 0],
[0xaaec, 0xaaed, 0],
[0xaaf6, 0xaaf6, 0],
[0xabe5, 0xabe5, 0],
[0xabe8, 0xabe8, 0],
[0xabed, 0xabed, 0],
[0xac00, 0xd7a3, 2],

####################### # Unicode::GCString
  [0xd7b0, 0x0d7fb, 2], # Hangul Jamo Extended-B
#######################

### [0xd800, 0xdfff, 0], *)    Unicode surrogate

#[0xe000, 0xf8ff, 1], # ###


[0xf900, 0xfaff, 2],
[0xfb1e, 0xfb1e, 0],
[0xfe00, 0xfe0f, 0],
[0xfe10, 0xfe19, 2],
[0xfe20, 0xfe2f, 0],
[0xfe30, 0xfe52, 2],
[0xfe54, 0xfe66, 2],
[0xfe68, 0xfe6b, 2],
### [0xfeff, 0xfeff, 0], *)
[0xff01, 0xff60, 2],
[0xffe0, 0xffe6, 2],
### [0xfff9, 0xfffb, 0], *)
#[0xfffd, 0xfffd, 1],
### [0xfffe, 0xffff, 0], *)
[0x101fd, 0x101fd, 0],
[0x102e0, 0x102e0, 0],
[0x10376, 0x1037a, 0],
[0x10a01, 0x10a03, 0],
[0x10a05, 0x10a06, 0],
[0x10a0c, 0x10a0f, 0],
[0x10a38, 0x10a3a, 0],
[0x10a3f, 0x10a3f, 0],
[0x10ae5, 0x10ae6, 0],
[0x11001, 0x11001, 0],
[0x11038, 0x11046, 0],
[0x1107f, 0x11081, 0],
[0x110b3, 0x110b6, 0],
[0x110b9, 0x110ba, 0],
[0x110bd, 0x110bd, 0],
[0x11100, 0x11102, 0],
[0x11127, 0x1112b, 0],
[0x1112d, 0x11134, 0],
[0x11173, 0x11173, 0],
[0x11180, 0x11181, 0],
[0x111b6, 0x111be, 0],
[0x111ca, 0x111cc, 0],
[0x1122f, 0x11231, 0],
[0x11234, 0x11234, 0],
[0x11236, 0x11237, 0],

######################### # Unicode::GCString
#  [0x1123e, 0x1123e, 0], # -> 1
#########################

[0x112df, 0x112df, 0],
[0x112e3, 0x112ea, 0],
[0x11300, 0x11301, 0],
[0x1133c, 0x1133c, 0],
[0x11340, 0x11340, 0],
[0x11366, 0x1136c, 0],
[0x11370, 0x11374, 0],

######################## # Unicode::GCString
# [0x11438, 0x1143f, 0], # -> 1
# [0x11442, 0x11444, 0], # -> 1
# [0x11446, 0x11446, 0], # -> 1
########################

[0x114b3, 0x114b8, 0],
[0x114ba, 0x114ba, 0],
[0x114bf, 0x114c0, 0],
[0x114c2, 0x114c3, 0],
[0x115b2, 0x115b5, 0],
[0x115bc, 0x115bd, 0],
[0x115bf, 0x115c0, 0],
[0x115dc, 0x115dd, 0],
[0x11633, 0x1163a, 0],
[0x1163d, 0x1163d, 0],
[0x1163f, 0x11640, 0],
[0x116ab, 0x116ab, 0],
[0x116ad, 0x116ad, 0],
[0x116b0, 0x116b5, 0],
[0x116b7, 0x116b7, 0],
[0x1171d, 0x1171f, 0],
[0x11722, 0x11725, 0],
[0x11727, 0x1172b, 0],

######################## # Unicode::GCString
# [0x11a01, 0x11a06, 0], # -> 1
# [0x11a09, 0x11a0a, 0], # -> 1
# [0x11a33, 0x11a38, 0], # -> 1
# [0x11a3b, 0x11a3e, 0], # -> 1
# [0x11a47, 0x11a47, 0], # -> 1
# [0x11a51, 0x11a56, 0], # -> 1
# [0x11a59, 0x11a5b, 0], # -> 1
# [0x11a8a, 0x11a96, 0], # -> 1
# [0x11a98, 0x11a99, 0], # -> 1
# [0x11c30, 0x11c36, 0], # -> 1
# [0x11c38, 0x11c3d, 0], # -> 1
# [0x11c3f, 0x11c3f, 0], # -> 1
# [0x11c92, 0x11ca7, 0], # -> 1
# [0x11caa, 0x11cb0, 0], # -> 1
# [0x11cb2, 0x11cb3, 0], # -> 1
# [0x11cb5, 0x11cb6, 0], # -> 1
# [0x11d31, 0x11d36, 0], # -> 1
# [0x11d3a, 0x11d3a, 0], # -> 1
# [0x11d3c, 0x11d3d, 0], # -> 1
# [0x11d3f, 0x11d45, 0], # -> 1
# [0x11d47, 0x11d47, 0], # -> 1
########################

[0x16af0, 0x16af4, 0],
[0x16b30, 0x16b36, 0],
[0x16f8f, 0x16f92, 0],
[0x16fe0, 0x16fe1, 2],
[0x17000, 0x187ec, 2],
[0x18800, 0x18af2, 2],
[0x1b000, 0x1b11e, 2],
[0x1b170, 0x1b2fb, 2],
[0x1bc9d, 0x1bc9e, 0],
[0x1bca0, 0x1bca3, 0],
[0x1d167, 0x1d169, 0],
[0x1d173, 0x1d182, 0],
[0x1d185, 0x1d18b, 0],
[0x1d1aa, 0x1d1ad, 0],
[0x1d242, 0x1d244, 0],
[0x1da00, 0x1da36, 0],
[0x1da3b, 0x1da6c, 0],
[0x1da75, 0x1da75, 0],
[0x1da84, 0x1da84, 0],
[0x1da9b, 0x1da9f, 0],
[0x1daa1, 0x1daaf, 0],

######################## # Unicode::GCString
# [0x1e000, 0x1e006, 0], # -> 1
# [0x1e008, 0x1e018, 0], # -> 1
# [0x1e01b, 0x1e021, 0], # -> 1
# [0x1e023, 0x1e024, 0], # -> 1
# [0x1e026, 0x1e02a, 0], # -> 1
########################

[0x1e8d0, 0x1e8d6, 0],

######################## # Unicode::GCString
# [0x1e944, 0x1e94a, 0], # -> 1
########################

[0x1f004, 0x1f004, 2],
[0x1f0cf, 0x1f0cf, 2],
#[0x1f100, 0x1f10a, 1],
#[0x1f110, 0x1f12d, 1],
#[0x1f130, 0x1f169, 1],
#[0x1f170, 0x1f18d, 1],
[0x1f18e, 0x1f18e, 2],
#[0x1f18f, 0x1f190, 1],
[0x1f191, 0x1f19a, 2],
#[0x1f19b, 0x1f1ac, 1],
[0x1f200, 0x1f202, 2],
[0x1f210, 0x1f23b, 2],
[0x1f240, 0x1f248, 2],
[0x1f250, 0x1f251, 2],
[0x1f260, 0x1f265, 2],
[0x1f300, 0x1f320, 2],
[0x1f32d, 0x1f335, 2],
[0x1f337, 0x1f37c, 2],
[0x1f37e, 0x1f393, 2],
[0x1f3a0, 0x1f3ca, 2],
[0x1f3cf, 0x1f3d3, 2],
[0x1f3e0, 0x1f3f0, 2],
[0x1f3f4, 0x1f3f4, 2],
[0x1f3f8, 0x1f43e, 2],
[0x1f440, 0x1f440, 2],
[0x1f442, 0x1f4fc, 2],
[0x1f4ff, 0x1f53d, 2],
[0x1f54b, 0x1f54e, 2],
[0x1f550, 0x1f567, 2],
[0x1f57a, 0x1f57a, 2],
[0x1f595, 0x1f596, 2],
[0x1f5a4, 0x1f5a4, 2],
[0x1f5fb, 0x1f64f, 2],
[0x1f680, 0x1f6c5, 2],
[0x1f6cc, 0x1f6cc, 2],
[0x1f6d0, 0x1f6d2, 2],
[0x1f6eb, 0x1f6ec, 2],
[0x1f6f4, 0x1f6f8, 2],
[0x1f910, 0x1f93e, 2],
[0x1f940, 0x1f94c, 2],
[0x1f950, 0x1f96b, 2],
[0x1f980, 0x1f997, 2],
[0x1f9c0, 0x1f9c0, 2],
[0x1f9d0, 0x1f9e6, 2],
[0x20000, 0x2fffd, 2],
[0x30000, 0x3fffd, 2],
[0xe0001, 0xe0001, 0],
[0xe0020, 0xe007f, 0],
[0xe0100, 0xe01ef, 0],
#[0xf0000, 0xffffd, 1],
#[0x100000, 0x10fffd, 1]
];


my $cache = [];


sub char_width {
    # $_[0] == ord $char
    my $min = 0;
    my $mid;
    my $max = $#$table;
    if ($_[0] < $table->[0][0] || $_[0] > $table->[$max][1] ) {
        return 1;
    }
    while ( $max >= $min ) {
        $mid = int( ( $min + $max) / 2 );
        if ( $_[0] > $table->[$mid][1] ) {
            $min = $mid + 1;
        }
        elsif ( $_[0] < $table->[$mid][0] ) {
            $max = $mid - 1;
        }
        else {
            return $table->[$mid][2];
        }
    }
    return 1;
}


sub print_columns {
    # $_[0] == string
    my $width = 0;
    for my $i ( 0 .. ( length( $_[0] ) - 1 ) ) {
        my $c = ord substr $_[0], $i, 1;
        if ( ! defined $cache->[$c] ) {
            $cache->[$c] = char_width( $c )
        }
        $width = $width + $cache->[$c];
    }
    return $width;
}


sub cut_to_printwidth {
    # $_[0] == string
    # $_[1] == available width
    # $_[2] == return the rest (yes/no)
    my $count = 0;
    my $total = 0;
    for my $i ( 0 .. ( length( $_[0] ) - 1 ) ) {
        my $c = ord substr $_[0], $i, 1;
        if ( ! defined $cache->[$c] ) {
            $cache->[$c] = char_width( $c )
        }
        if ( ( $total = $total + $cache->[$c] ) > $_[1] ) {
            if ( ( $total - $cache->[$c] ) < $_[1] ) {
                return substr( $_[0], 0, $count ) . ' ', substr( $_[0], $count ) if $_[2];
                return substr( $_[0], 0, $count ) . ' ';
            }
            return substr( $_[0], 0, $count ), substr( $_[0], $count ) if $_[2];
            return substr( $_[0], 0, $count );

        }
        ++$count;
    }
    return $_[0], '' if $_[2];
    return $_[0];
}


sub line_fold {
    my ( $string, $avail_width, $init_tab, $subseq_tab ) = @_; #copy
    # return if ! length $string;
    for ( $init_tab, $subseq_tab ) {
        if ( $_ ) {
            s/\s/ /g;
            s/\p{C}//g;
            if ( length > $avail_width / 4 ) {
                $_ = cut_to_printwidth( $_, int( $avail_width / 2 ) );
            }
        }
        else {
            $_ = '';
        }
    }
    $string =~ s/[^\n\P{Space}]/ /g;
    $string =~ s/[^\n\P{C}]//g;
    if ( $string !~ /\n/ && print_columns( $init_tab . $string ) <= $avail_width ) {
        return $init_tab . $string;
    }
    my @paragraph;

    for my $row ( split "\n", $string, -1 ) { # -1 to keep trailing empty fields
        my @lines;
        $row =~ s/\s+\z//;
        my @words = split( /(?<=\S)(?=\s)/, $row );
        my $line = $init_tab;

        for my $i ( 0 .. $#words ) {
            if ( print_columns( $line . $words[$i] ) <= $avail_width ) {
                $line .= $words[$i];
            }
            else {
                my $tmp;
                if ( $i == 0 ) {
                    $tmp = $init_tab . $words[$i];;
                }
                else {
                    push( @lines, $line );
                    $words[$i] =~ s/^\s+//;
                    $tmp = $subseq_tab . $words[$i];
                }
                ( $line, my $remainder ) = cut_to_printwidth( $tmp, $avail_width, 1 );
                while ( length $remainder ) {
                    push( @lines, $line );
                    $tmp = $subseq_tab . $remainder;
                    ( $line, $remainder ) = cut_to_printwidth( $tmp, $avail_width, 1 );
                }
            }
            if ( $i == $#words ) {
                push( @lines, $line );
            }
        }
        push( @paragraph, join( "\n", @lines ) );
    }
    return join( "\n", @paragraph );
}












1;
