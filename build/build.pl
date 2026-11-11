#!/usr/bin/perl
# Builds the profile SVGs into ../assets from the *.src.svg templates and the data below.
# Usage (from this folder): perl build.pl
# Fonts (subset woff2, SIL OFL) are embedded as data URIs because GitHub shows SVGs as images,
# and images cannot load external fonts.
use strict; use warnings; use utf8;
use MIME::Base64 qw(encode_base64);
binmode STDOUT, ':utf8';

my $out = '../assets';
mkdir $out unless -d $out;

my %font = (
  cinzel700 => ['Cinzel', 700], cinzel500 => ['Cinzel', 500],
  jbm400 => ['JetBrains Mono', 400], jbm700 => ['JetBrains Mono', 700],
);
sub fonts {
  my @css;
  for my $k (split /,/, shift) {
    open my $f, '<:raw', "fonts/$k.woff2" or die "font $k: $!";
    local $/; my $b = encode_base64(<$f>, '');
    my ($fam, $w) = @{ $font{$k} };
    push @css, "\@font-face { font-family: \"$fam\"; font-weight: $w; src: url(data:font/woff2;base64,$b) format(\"woff2\"); }";
  }
  join "\n", @css;
}

# deterministic PRNG so rebuilds produce the same picture
my $seed = 1;
sub rnd { $seed = ($seed * 16807) % 2147483647; $seed / 2147483647 }
sub r2 { sprintf '%.1f', shift }

sub embers {
  my ($n, $w, $h, $s) = @_; $seed = $s;
  my @g;
  for (1 .. $n) {
    my $x = r2(rnd() * $w); my $rad = 0.8 + rnd() * 1.8;
    my $dur = r2(7 + rnd() * 9); my $del = r2(rnd() * $dur);
    my $sw = r2(2.5 + rnd() * 3); my $sd = r2(rnd() * 3);
    my $y = $h + 8;
    push @g, sprintf '<g class="r" style="animation-duration:%ss;animation-delay:-%ss"><g class="s" style="animation-duration:%ss;animation-delay:-%ss"><circle cx="%s" cy="%s" r="%s" fill="url(#eg)" opacity=".5"/><circle cx="%s" cy="%s" r="%s" fill="#ffcf96"/></g></g>',
      $dur, $del, $sw, $sd, $x, $y, r2($rad * 4), $x, $y, r2($rad * 0.7);
  }
  join "\n  ", @g;
}

sub links {   # faint static schema-graph in the background
  my ($w, $h, $s) = @_; $seed = $s;
  my @p = map { [rnd() * $w, rnd() * $h] } 1 .. 34;
  my @l;
  for my $i (0 .. $#p) { for my $j ($i + 1 .. $#p) {
    my ($dx, $dy) = ($p[$i][0] - $p[$j][0], $p[$i][1] - $p[$j][1]);
    my $d = sqrt($dx * $dx + $dy * $dy);
    next unless $d < 150;
    push @l, sprintf '<line x1="%s" y1="%s" x2="%s" y2="%s" stroke="#eadcc5" stroke-opacity="%.3f"/>',
      r2($p[$i][0]), r2($p[$i][1]), r2($p[$j][0]), r2($p[$j][1]), 0.10 * (1 - $d / 150);
  } }
  push @l, map { sprintf '<circle cx="%s" cy="%s" r="1.6" fill="#e8833a" opacity=".55"/>', r2($_->[0]), r2($_->[1]) } @p;
  join "\n  ", @l;
}

sub esc { my $s = shift; $s =~ s/&/&amp;/g; $s =~ s/</&lt;/g; $s =~ s/>/&gt;/g; $s }

# ---------------- status sheet data (self-assessed; edit freely) ----------------
my @attrs = (   # name, value (souls-style; the bar is drawn against a soft cap of 60)
  ['Oracle Database',      45],
  ['Backup & Recovery',    40],
  ['Linux & Shell',        40],
  ['Performance Tuning',   40],
  ['Data Guard · RAC · ASM', 38],
  ['OCI',                  26],
  ['MySQL',                20],
  ['PostgreSQL',           15],
);
my @equip = (
  ['Weapon',   'RMAN · Data Pump'],
  ['Shield',   'Data Guard · Broker'],
  ['Armor',    'RAC · ASM · Grid 19c'],
  ['Catalyst', 'AWR · ASH · Statspack'],
  ['Talisman', 'SQL tuning · plans'],
  ['Tools',    'Bash · Linux · oratop'],
  ['Realm',    'OCI · on-premises'],
);
my @rings = (   # name, tier tag; laid out column by column, 4 per column
  ['Oracle DB Administration', 'PRO'],
  ['MySQL 8.0 Database Admin', 'PRO'],
  ['Cloud Database Service',   'PRO'],
  ['Cloud Database Migration', 'PRO'],
  ['Autonomous Database Cloud', 'PRO'],
  ['AI Vector Search',         'PRO'],
  ['Oracle Database SQL',      'ASSOC'],
  ['MySQL Implementation',     'ASSOC'],
  ['OCI Architect',            'ASSOC'],
  ['OCI Foundations',          'ASSOC'],
  ['LPIC-1 · Linux',           'LPI'],
  ['Oracle Specialist badges', '3'],
);

sub attrs_svg {
  my @o; my $y = 46;
  for my $a (@attrs) {
    my ($k, $v) = @$a; my $w = sprintf '%.0f', 150 * ($v > 60 ? 1 : $v / 60);
    push @o, sprintf '<text class="k" y="%d">%s</text><text class="n" x="340" y="%d" text-anchor="end">%d</text>', $y, esc($k), $y, $v;
    push @o, sprintf '<rect x="0" y="%d" width="300" height="4" rx="2" fill="#eadcc5" opacity=".08"/><rect class="bar" x="0" y="%d" width="%d" height="4" rx="2" fill="url(#barG)" style="animation-delay:%.2fs"/>',
      $y + 9, $y + 9, $w * 2, 0.15 * @o / 2;
    $y += 44;
  }
  join "\n    ", @o;
}
sub equip_svg {
  my @o; my $y = 46;
  for my $e (@equip) {
    push @o, sprintf '<text class="k" y="%d">%s</text><text class="v" x="300" y="%d" text-anchor="end">%s</text>', $y, esc($e->[0]), $y, esc($e->[1]);
    $y += 50;
  }
  join "\n    ", @o;
}
sub rings_svg {
  my @o; my @cx = (60, 450, 840);
  for my $i (0 .. $#rings) {
    my ($n, $tag) = @{ $rings[$i] };
    my $x = $cx[int($i / 4)]; my $y = 48 + 34 * ($i % 4);
    push @o, sprintf '<use href="#diamond" x="%d" y="%d" opacity=".8"/><text class="v" x="%d" y="%d">%s</text><text class="small" x="%d" y="%d" text-anchor="end">%s</text>',
      $x + 5, $y - 5, $x + 20, $y, esc($n), $x + 300, $y, esc($tag);
  }
  join "\n    ", @o;
}

# ---------------- relic cards ----------------
my @relics = (
  { file => 'relic-install-automation19', repo => 'install-automation19', name => 'Scroll of the Grid Rite', kind => 'Bash · Oracle 19c',
    lore => ['Automates Grid Infrastructure 19c, ASM/AFD', 'and Database 19c installs, primary or', 'standby, ready for Data Guard. A day of', 'manual ritual, reduced to one script.'] },
  { file => 'relic-oratop-monitor', repo => 'oratop-monitor', name => 'Eye of oratop', kind => 'Bash · ★ 3',
    lore => ['Captures Oracle performance metrics', 'with oratop on a schedule, with log', 'retention and compression. For seeing', 'what happened at 3 a.m., long after.'] },
  { file => 'relic-preventiva', repo => 'preventiva', name => 'Preventive Rite', kind => 'Bash · maintenance',
    lore => ['RMAN restore validate, Data Pump dump', 'checks and Statspack/AWR reports,', 'e-mailed on schedule. Wards off what', 'has not broken yet.'] },
);

sub relic_svg {
  my $r = shift;
  my $lore = ''; my $y = 128;
  for my $l (@{ $r->{lore} }) { $lore .= sprintf qq{<text x="28" y="%d" class="mono" font-size="13" fill="#9b8d78">%s</text>\n}, $y, esc($l); $y += 21; }
  return <<"SVG";
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="230" viewBox="0 0 400 230" role="img" aria-label="${\ esc($r->{repo}) }: ${\ esc($r->{name}) }">
<style>
${\ fonts('cinzel700,jbm400') }
.disp { font-family: "Cinzel", "Times New Roman", serif; font-weight: 700; }
.mono { font-family: "JetBrains Mono", Consolas, monospace; }
.gl { animation: gl 4.5s ease-in-out infinite; } \@keyframes gl { 0%,100% { opacity: .4 } 50% { opacity: 1 } }
\@media (prefers-reduced-motion: reduce) { .gl { animation: none; } }
</style>
<defs><radialGradient id="p" cx="85%" cy="0%" r="70%"><stop offset="0" stop-color="#8c3b15" stop-opacity=".35"/><stop offset="1" stop-color="#8c3b15" stop-opacity="0"/></radialGradient></defs>
<rect width="400" height="230" rx="12" fill="#0f0c0a"/>
<rect width="400" height="230" rx="12" fill="url(#p)"/>
<rect x=".5" y=".5" width="399" height="229" rx="12" fill="none" stroke="#eadcc5" stroke-opacity=".16"/>
<path class="gl" d="M372 26l5 5-5 5-5-5z" fill="#e8833a"/>
<text x="28" y="40" class="mono" font-size="12" letter-spacing="2.5" fill="#e8833a">RELIC · ${\ esc($r->{repo}) }</text>
<text x="28" y="76" class="disp" font-size="22" fill="#eadcc5">${\ esc($r->{name}) }</text>
<text x="28" y="100" class="mono" font-size="12.5" fill="#9b8d78" opacity=".85">${\ esc($r->{kind}) }</text>
<rect x="28" y="110" width="344" height="1" fill="#eadcc5" opacity=".1"/>
$lore</svg>
SVG
}

# ---------------- buttons & footer ----------------
sub button_svg {
  my ($label, $sub, $w) = @_;
  return <<"SVG";
<svg xmlns="http://www.w3.org/2000/svg" width="$w" height="56" viewBox="0 0 $w 56" role="img" aria-label="${\ esc($label) }">
<style>
${\ fonts('cinzel700,jbm400') }
.disp { font-family: "Cinzel", "Times New Roman", serif; font-weight: 700; }
.mono { font-family: "JetBrains Mono", Consolas, monospace; }
</style>
<rect width="$w" height="56" rx="10" fill="#0f0c0a"/>
<rect x=".5" y=".5" width="${\ ($w - 1) }" height="55" rx="10" fill="none" stroke="#e8833a" stroke-opacity=".55"/>
<path d="M22 28l5-5 5 5-5 5z" fill="#e8833a"/>
<text x="44" y="26" class="disp" font-size="15" letter-spacing="1.5" fill="#eadcc5">${\ esc($label) }</text>
<text x="44" y="43" class="mono" font-size="11.5" fill="#9b8d78">${\ esc($sub) }</text>
</svg>
SVG
}

sub footer_svg {
  return <<"SVG";
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="70" viewBox="0 0 1200 70" role="img" aria-label="SQL exit">
<style>
${\ fonts('jbm400') }
.mono { font-family: "JetBrains Mono", Consolas, monospace; font-size: 14px; }
.c { animation: b 1.05s steps(1) infinite; } \@keyframes b { 50% { opacity: 0 } }
\@media (prefers-reduced-motion: reduce) { .c { animation: none; } }
</style>
<rect width="1200" height="70" rx="12" fill="#0c0a09"/>
<rect x=".5" y=".5" width="1199" height="69" rx="12" fill="none" stroke="#eadcc5" stroke-opacity=".12"/>
<text x="28" y="30" class="mono" fill="#9b8d78">SQL&gt; <tspan fill="#e8833a">exit</tspan></text>
<text x="28" y="52" class="mono" fill="#9b8d78">Disconnected from Oracle Database 19c Enterprise Edition. The bonfire stays lit.<tspan class="c" fill="#e8833a"> █</tspan></text>
</svg>
SVG
}

sub write_out { my ($name, $svg) = @_; open my $f, '>:utf8', "$out/$name" or die $!; print $f $svg; close $f; printf "%-36s %6d bytes\n", $name, -s "$out/$name"; }

sub template {
  my $file = shift; open my $f, '<:utf8', $file or die "$file: $!"; local $/; my $s = <$f>;
  $s =~ s/<!--FONTS:([\w,]+)-->/fonts($1)/ge;
  $s =~ s/<!--EMBERS:(\d+),(\d+),(\d+),(\d+)-->/embers($1,$2,$3,$4)/ge;
  $s =~ s/<!--LINKS:(\d+),(\d+),(\d+)-->/links($1,$2,$3)/ge;
  $s =~ s/<!--ATTRS-->/attrs_svg()/e;
  $s =~ s/<!--EQUIP-->/equip_svg()/e;
  $s =~ s/<!--RINGS-->/rings_svg()/e;
  $s;
}

write_out('banner.svg', template('banner.src.svg'));
write_out('status.svg', template('status.src.svg'));
write_out("$_->{file}.svg", relic_svg($_)) for @relics;
write_out('btn-bonfire.svg', button_svg('VISIT THE BONFIRE', 'ptravesso-dba.github.io', 300));
write_out('btn-linkedin.svg', button_svg('LINKEDIN', 'in/pablo-travesso', 220));
write_out('footer.svg', footer_svg());
