package # hide from PAUSE
Term::Choose::LineFold;

use warnings;
use strict;
use 5.008003;

our $VERSION = '1.209_01';

use Exporter qw( import );

our @EXPORT_OK = qw( line_fold print_columns cut_to_printwidth );


use Unicode::GCString;



sub print_columns {
    Unicode::GCString->new( $_[0] )->columns();
}


sub cut_to_printwidth {
    my ( $str, $avail_len, $rest ) = @_;
    my $gc_str = Unicode::GCString->new( $str );
    if ( $gc_str->columns() <= $avail_len ) {
        return $str if ! $rest;
        return $str, '';
    }
    my $left = $gc_str->substr( 0, $avail_len );
    my $left_w = Unicode::GCString->new( $left )->columns(); #
    if ( $left_w == $avail_len ) {
        return $left if ! $rest;
        return $left, $gc_str->substr( $avail_len );
    }
    if ( $avail_len < 2 ) {
        die "Terminal-width less than charakter-width."; # #
    }
    my ( $nr_chars, $adjust );
    if ( $left_w > $avail_len ) {
        $nr_chars = int( $avail_len / 2 );
        $adjust = int( ( $nr_chars + 1 ) / 2 );
        #$nr_chars = int( $avail_len / 4 * 3 );
        #$adjust = int( ( $avail_len + 7 ) / 8 );
    }
    elsif ( $left_w < $avail_len ) {
        $nr_chars = int( $avail_len + ( $gc_str->length() - $avail_len ) / 2 ); #
        $adjust = int( ( $gc_str->length() - $nr_chars ) / 2 );
    }

    while ( 1 ) {
        $left = $gc_str->substr( 0, $nr_chars );
        $left_w = Unicode::GCString->new( $left )->columns(); #
        if ( $left_w + 1 == $avail_len ) {
            my $len_next_char = $gc_str->substr( $nr_chars, 1 )->columns();
            if ( $len_next_char == 1 ) {
                return $gc_str->substr( 0, $nr_chars + 1 ) if ! $rest;
                return $gc_str->substr( 0, $nr_chars + 1 ), $gc_str->substr( $nr_chars + 1 );
            }
            elsif ( $len_next_char == 2 ) {
                return $left . ' ' if ! $rest;
                return $left . ' ' , $gc_str->substr( $nr_chars );
            }
        }
        if ( $left_w > $avail_len ) {
            $nr_chars = int( $nr_chars - $adjust );
        }
        elsif ( $left_w < $avail_len ) { # else
            $nr_chars = int( $nr_chars + $adjust );
        }
        else {
            return $left if ! $rest;
            return $left, $gc_str->substr( $nr_chars );
        }
        $adjust = int( ( $adjust + 1 ) / 2 );
    }
}


sub line_fold {
    my ( $string, $avail_width, $init_tab, $subseq_tab ) = @_;
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

    ROW: for my $row ( split "\n", $string ) {
        my @lines;
        $row =~ s/\s+\z//;
        my @words = split( /(?<=\S)(?=\s)/, $row );
        my $line = $init_tab;

        WORD: for my $i ( 0 .. $#words ) {
            my $tab = $i == 0 ? $init_tab : $subseq_tab;
            my $tab_and_word;
            if ( $i == 0 ) {
                $tab_and_word = $init_tab . $words[$i];
            }
            else {
                ( my $tl_word = $words[$i] ) =~ s/^\s//;
                $tab_and_word = $subseq_tab . $tl_word;
            }

            if ( print_columns( $tab_and_word ) > $avail_width ) {
                if ( $i != 0 ) {
                    push( @lines, $line );
                }
                my ( $tab_and_cut_word, $rest ) = cut_to_printwidth( $tab_and_word, $avail_width, 1 );
                while ( length $rest ) {
                    push( @lines, $tab_and_cut_word );
                    ( $tab_and_cut_word, $rest ) = cut_to_printwidth( $subseq_tab . $rest, $avail_width, 1 );
                }
                if ( $i == $#words ) {
                    push( @lines, $tab_and_cut_word );
                }
                else {
                    $line = $tab_and_cut_word;
                }
            }
            else {
                if ( print_columns( $line . $words[$i] ) <= $avail_width ) {
                    $line .= $words[$i];
                }
                else {
                    push( @lines, $line );
                    ( my $tl_word = $words[$i] ) =~ s/^\s//;
                    $line = $subseq_tab . $tl_word;
                }
                if ( $i == $#words ) {
                    push( @lines, $line );
                }
            }
        }
        push( @paragraph, join( "\n", @lines ) );
    }
    return join( "\n", @paragraph );
}



1;

__END__
