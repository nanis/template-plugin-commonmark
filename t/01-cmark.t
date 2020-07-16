#!/usr/bin/env perl
use warnings;
use strict;

use Carp qw( croak );
use Test::More;
use Template;

my $tester = sub {
    my ($tmpl, $html, $desc) = @_;
    my $output;

    my $tt = Template->new or croak $Template::ERROR;

    $tt->process(\$tmpl, {}, \$output) or croak $tt->error;

    trim($output, $html);
    is($output, $html, $desc);
};

my @cases = (
[
<<EO_TMPL,
[% USE CommonMark %]
[% FILTER cmark %]
Foo

Bar
[% END %]
EO_TMPL

<<EO_HTML,
<p>Foo</p>
<p>Bar</p>
EO_HTML

'Simple paragraphs',
],

[
<<EO_TMPL,
[% USE CommonMark %]
[% FILTER cmark %]
* Foo
* Bar
[% END %]
EO_TMPL

<<EO_HTML,
<ul>
<li>Foo</li>
<li>Bar</li>
</ul>
EO_HTML

'Bullet list',
],

[
<<'EO_TMPL',
[% USE CommonMark %]
[% FILTER cmark %]
```perl
my $x = $y + $z;
$frobnicator->run( $x );
```
[% END %]
EO_TMPL

<<'EO_HTML',
<pre><code class="language-perl">my $x = $y + $z;
$frobnicator-&gt;run( $x );
</code></pre>
EO_HTML

'Code block',
],

[
<<'EO_TMPL',
[% USE CommonMark %]
[% FILTER cmark %]
Foo

<span>Bar</span>
[% END %]
EO_TMPL

<<EO_HTML,
<p>Foo</p>
<p><!-- raw HTML omitted -->Bar<!-- raw HTML omitted --></p>
EO_HTML

'Safe, no embedded HTML',
],

  [
<<'EO_TMPL',
[% USE CommonMark(unsafe=1) %]
[% FILTER cmark %]
Foo

<span>Bar</span>
[% END %]
EO_TMPL

<<EO_HTML,
<p>Foo</p>
<p><span>Bar</span></p>
EO_HTML

'Embed HTML',
],

);

for my $case ( @cases ) {
    $tester->(@$case);
}

sub trim {
    for ( @_ ) {
        s/\A\s+//;
        s/\s+\z//;
    }
}

done_testing;
