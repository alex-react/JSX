#!/usr/bin/env perl
use 5.10.0;
use strict;
use warnings;
use Text::Xslate;
use File::Path qw(mkpath);
use Data::Section::Simple;
use Fatal qw(open close);
use File::Basename qw(dirname);
use Storable qw(lock_retrieve);
use Tie::IxHash;

my $lib = "lib/js/js";
mkpath $lib;

# the order is important!

my $root = dirname(__FILE__);
unlink "$root/.idl2jsx.bin";

my @specs = (
    ['web.jsx' =>
        # DOM spec
        #'http://www.w3.org/TR/DOM-Level-3-Core/idl/dom.idl',
        'http://www.w3.org/TR/dom/',
        'http://www.w3.org/TR/DOM-Level-2-Views/idl/views.idl',
        'http://www.w3.org/TR/DOM-Level-3-Events/',
        "$root/extra/events.idl",

        'http://www.w3.org/TR/XMLHttpRequest/',

        #'http://html5labs.interoperabilitybridges.com/dom4events/', # no correct IDL

        # CSS
        'http://dev.w3.org/csswg/cssom/',
        'http://dev.w3.org/csswg/cssom-view/',
        "$root/extra/chrome.idl",
        "$root/extra/firefox.idl",

        # SVG
        #"http://www.w3.org/TR/2011/REC-SVG11-20110816/svg.idl",

        # HTML5
        #'http://dev.w3.org/html5/spec/single-page.html', # too new
        'http://www.w3.org/TR/html5/single-page.html',
        'http://www.w3.org/TR/FileAPI/',
        "$root/extra/file.idl",

        #"http://www.w3.org/TR/webaudio/", # no correct IDL
        "http://www.w3.org/TR/touch-events/",
        "http://dev.w3.org/html5/websockets/",
        "http://dev.w3.org/geo/api/spec-source-v2.html",
        "http://dev.w3.org/html5/webstorage/",
        'http://www.w3.org/TR/selectors-api/',
        "http://www.w3.org/TR/webmessaging/",
        "http://www.w3.org/TR/workers/",

        # WebRTC has no correct IDL
        #"http://dev.w3.org/2011/webrtc/editor/webrtc.html",
        #"http://dev.w3.org/2011/webrtc/editor/getusermedia.html",

        # by html5.org
        "http://html5.org/specs/dom-parsing.html",

        # graphics
        'https://www.khronos.org/registry/typedarray/specs/latest/typedarray.idl',
        'http://dev.w3.org/html5/2dcontext/',
        'https://www.khronos.org/registry/webgl/specs/latest/webgl.idl',

        # additionals
        "$root/extra/timers.idl",
        "$root/extra/animation-timing.idl",
        "$root/extra/legacy.idl",
    ],
);

my $HEADER = <<'T';
// THIS FILE IS AUTOMATICALLY GENERATED.
T

my $xslate = Text::Xslate->new(
    path  => [ Data::Section::Simple->new->get_data_section() ],
    type => "text",

    function => {
    },
);

foreach my $spec(@specs) {
    my($file, @idls) = @{$spec};
    say "generate $file from ", join ",", @idls;

    my %param = (
        idl => scalar(`idl2jsx/idl2jsx.pl --continuous @idls`),
    );
    if($? != 0) {
        die "Cannot convert @idls to JSX.\n";
    }

    $param{classdef} = lock_retrieve("$root/.idl2jsx.bin");
    $param{html_elements} = [
        map  {
            ($_->{func_name} = $_->{name}) =~ s/^HTML//;
            my $tag_name = lc $_->{func_name};
            $tag_name =~ s/element$//;
            $_->{tag_name} = $tag_name;
            $_; }
        grep { $_->{base} ~~ "HTMLElement"  } values %{ $param{classdef} },
    ];

    my $src = $xslate->render($file, \%param);

    open my($fh), ">", "$lib/$file";
    print $fh $HEADER;
    print $fh $src;
    close $fh;
}

__DATA__
@@ web.jsx
/**

Web Browser Interface

*/
import "js.jsx";

/**

Document Object Model in Web Browsers

*/
final class dom {
	static const window = js.global["window"] as __noconvert__ Window;


	/** alias to <code>dom.window.document.getElementById(id) as HTMLElement</code> */
	static function id(id : string) : HTMLElement {
		return dom.window.document.getElementById(id) as HTMLElement;
	}
	/** alias to <code>dom.window.document.getElementById(id) as HTMLElement</code> */
	static function getElementById(id : string) : HTMLElement {
		return dom.window.document.getElementById(id) as HTMLElement;
	}


	/** alias to <code>dom.window.document.createElement(id) as HTMLElement</code> */
	static function createElement(tag : string) : HTMLElement {
		return dom.window.document.createElement(tag) as __noconvert__ HTMLElement;
	}

}

: $idl

