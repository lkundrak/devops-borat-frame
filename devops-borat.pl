# This is supposed to download tweets from DEVOPS_BORAT twitter
# user and format them into pictures suitable for a picture frame.
# Lubomir Rintel <lubo.rintel@gooddata.com>

# Needs ImageMagick.

use LWP::Simple;
use JSON::XS;

my $json = decode_json (get ('https://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=devops_borat&count=666'));

my $template = `cat template.svg`;

foreach $tweet (@$json) {

	warn $tweet->{id};

	mirror ($tweet->{user}{profile_image_url}, 'profile.jpeg')
		unless -f 'profile.jpeg';

	my $filled = $template;
	$filled =~ s/\@IMG\@/profile.jpeg/gm;
	$filled =~ s/\@USER\@/\@$tweet->{user}{screen_name}/gm;
	$tweet->{created_at} =~ s/ \+\d{4}// or die;
	$filled =~ s/\@TIME\@/$tweet->{created_at}/gm;

	my $line = 1;
	for $line (1..5) {
		$tweet->{text} =~ s/^(.{0,32})( (.*))?$/$3/;
		my ($this, $rest) = ($1, $2);
		$filled =~ s/\@LINE$line\@/$this/gm;
	}

	open (my $im, '|-', 'convert', '-', $tweet->{id}.'.jpeg')
		or die $!;
	print $im $filled;
	close ($im);
};
